//
//  Map.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

import UIKit
import MapKit
import CoreLocation

// TODO: Integrate this.

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - DirectionsModelToStore
    struct DirectionsModelStore: Codable {
        let sourceLat: Double
        let sourceLong: Double
        let destLat: Double
        let destLong: Double
        let methodOfTravel: String
        let totalDistance: Double
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!;
    let locManager = CLLocationManager ();
    
    // MARK: -  globals
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var dest : String?;
    var fromScreen : String?;
    var destText : String?;
    var delta : Double = 0.5;
    var sourceLocation : CLLocation?;
    var destinationLoc : CLLocation?;
    var globalDest : String?;
    var transpoType : String = "Auto";
    

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
    }
    

    // MARK: - Route buttons
    // TODO: Write how to alternate between car, bike and walk
    @IBAction func setToCarRoute(_ sender: Any) {
        transpoType = "Auto";
        remapRoute();
    }
    // TODO: Apple Documentation only has three routes: transit, car, and waling. There is no route for bikes.
    // https://developer.apple.com/documentation/mapkit/mkdirectionstransporttype/1451972-any
    @IBAction func setToBikeRoute(_ sender: Any) {
        // why I am putting this instead of auto because mostly bikes can go on routes where pedestrians can. sidewalks are also besides roads and bikelanes. In my experience when it comes to canadian highways, I haven't seen a bicycle there.
        transpoType = "Bike";
        remapRoute();
        
    }
    @IBAction func setToWalkRoute(_ sender: Any) {
        transpoType = "Walking";
        remapRoute();
    }
    
    @IBAction func tempGetDirections(_ sender: Any) {
        showAlert()
    }

    // TODO: refine this slider some more.
    // MARK: Region slider
    @IBAction func setRegionValue(_ sender: UISlider) {
        delta = Double(sender.value);
        let coordinate = CLLocationCoordinate2D(latitude: sourceLocation!.coordinate.latitude, longitude: sourceLocation!.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        // greater accuracy, will eat more battery power
        // v means value, that makes sense
        locManager.requestWhenInUseAuthorization();
        
        // default route is auto
        mapView.delegate = self;
        if dest != nil {
            convertAddress(dest!);
            locManager.startUpdatingLocation();
            destText = dest;
        }
        
    }
    
   // TODO: Make this passable. Will need to ask help from this on how to make this alert customizable
    // will open an aler function
    func showAlert () {
        let alert = UIAlertController(title: "Where would you like to go?", message: "Please enter your destination", preferredStyle: .alert);
        
        alert.addTextField { field in
            field.placeholder = "Waterloo";
            field.returnKeyType = .continue;
        }
        
        alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { _ in
            guard let field = alert.textFields, field.count == 1 else {
                return;
            }
            
            let txtLocField = field[0]
            guard let textLoc = txtLocField.text, !textLoc.isEmpty else {
                return;
            }
            
            if (self.sourceLocation != nil) {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.removeOverlays(self.mapView.overlays)
                self.render(self.sourceLocation!)
            }
            
            // should the route buttons be clicked, it source screen will still be home as we're basing where the data was inputted.
            self.fromScreen = "map";
            self.destText = textLoc
            self.locManager.startUpdatingLocation();
            self.convertAddress(textLoc)
            
            
        }))
                        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.startUpdatingLocation();
            sourceLocation = location;
            render (location)
        }
    }
    
    func mapView (_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeline = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        // TODO: change this for biking
        switch transpoType {
        case "Auto":
            routeline.strokeColor = .systemBlue;
        case "Walking":
            routeline.strokeColor = .green;
        case "Bike":
            routeline.strokeColor = .purple;
        default:
            routeline.strokeColor = .systemBlue;
        }
        return routeline
    }
    
    func render (_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
                                        
        pin.coordinate = coordinate
        pin.title = "You are here"
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    func convertAddress (_ textLoc: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textLoc) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                print ("no location found")
                return
            }
            
            // decided to make this global due to route changing everytime the three buttons are clicked. This is null on initial state but is easier to check as a global.
            self.destinationLoc = location;
            self.mapThis(destinationLoc: location)
        }
    }
    
    func remapRoute () {
        mapView.removeOverlays(mapView.overlays)
        
        guard destinationLoc != nil else {
            return;
        }
        mapThis(destinationLoc: destinationLoc!);
    }
    
    func mapThis (destinationLoc : CLLocation) {
        
        // a. setting the table
        // get source coordinate
        let sourceCoordinate = (locManager.location?.coordinate)!
        let desitiationCor = destinationLoc.coordinate;
        
        // get the placemarks source and dest
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: desitiationCor)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        // send destination request. depends on a variety of parameters like traffic, mode of transpo and all
        let destinationRequest = MKDirections.Request()
        
        // start and end
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
    
        // how travel, can add a toggle or a value
        destinationRequest.requestsAlternateRoutes = true
        
        // decided to make this global due to route changing everytime the three buttons are clicked.
        destinationRequest.transportType = getModeOfTravel()

        // one route = false multi = true -> this will generate multi routes
        // b. submit request to calculate directions
            let directions = MKDirections(request: destinationRequest)
        directions.calculate {
            (response, error) in
            // guard to get atleast one response back
            guard let response = response else {
                if let error = error {
                    print ("something went wrong")
                }
                return
            }
            
            // output to the submit request is an array of routes.
            let route = response.routes[0]
            
            print("This is the route \(route)")
            
            let details = DirectionsModelStore(
                sourceLat: sourceCoordinate.latitude
                ,sourceLong: sourceCoordinate.longitude
                ,destLat: desitiationCor.latitude
                ,destLong: desitiationCor.longitude
                ,methodOfTravel: self.transpoType
                ,totalDistance: route.distance
            )
            
            if (!self.saveToHistoryList(self.destText!,self.fromScreen!,"directions", data: details)) {
                print ("Saving to db failed");
            }
            
            // in this case only the first route is fetched
            
            // add ze overlay to route
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            // setting the endpoint pin
            let pin = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: desitiationCor.latitude, longitude: desitiationCor.longitude)
            
            pin.coordinate = coordinate
            
            // decided to make this global because of the segues and route changes.
            pin.title = self.destText
            self.mapView.addAnnotation(pin)
        }
    }
    
    // MARK: - CoreData Functions
    func saveToHistoryList (_ textLoc:String,_ source:String, _ interactionType:String,data: DirectionsModelStore) -> Bool {
        let historyEntry = HistoryList(context: self.content)
        historyEntry.dateEntered = Date()
        historyEntry.destination = textLoc
        historyEntry.sourceModule = source
        historyEntry.interactionType = interactionType
        
        convertToJSON(data) { result in
            switch result {
            case let .success(toStore):
                historyEntry.data = toStore;
            default:
                return;
            }

        }
     
        do {
            try content.save();
        } catch {
            return false;
        }
        return true;
  
    }
    
    func convertToJSON (_ data: DirectionsModelStore,completion: @escaping(Result<String, Error>) ->Void) {
        do {
            let jsonData = try JSONEncoder().encode(data);
            let toStore = String(data: jsonData, encoding: String.Encoding.utf8);

            completion(.success(toStore!));
         } catch {
             completion(.failure(error));
         }
    }
    
    func getModeOfTravel () -> MKDirectionsTransportType {
        switch transpoType {
        case "Auto":
            return .automobile;
        case "Walking":
            return .walking;
        case "Bike":
            return .walking
        default:
            return .automobile;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
