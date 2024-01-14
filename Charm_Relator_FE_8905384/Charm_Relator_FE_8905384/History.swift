//
//  History.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

import UIKit
import Foundation
import CoreLocation

class History: UITableViewController {
    
    
    
    @IBOutlet var histListTable: UITableView!
    // TODO: Have these buttons link to another segue
    // TODO: save the interaction to historylist
    // TODO: retrieve list from historyList
    
    // MARK: - model for weather
    struct WeatherModelStore: Codable {
        let temp:Double
        let humidity:Int
        let windSpeed:Double
        let dt:Int
        let timezone:Int
    }
    
    // MARK: - Struct for news Articles
    struct Article: Codable {
        let source: Source
        let author: String?
        let title, description: String
        let url: String
        let urlToImage: String?
        let publishedAt: Date
        let content: String
    }

    struct Source: Codable {
        let id: String?
        let name: String
    }
    
    // MARK: - DirectionsModelToStore
    struct DirectionsModelStore: Codable {
        let sourceLat: Double
        let sourceLong: Double
        let destLat: Double
        let destLong: Double
        let methodOfTravel: String
        let totalDistance: Double
    }
    
    // MARK: -  globals
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var historyList : [HistoryList]?;
    var fromScreen : String?; 
    
    // MARK: - Enums
    enum CoreDataError: Error {
        case insertError;
        case fetchError;
        case deleteError;
    }
    
    enum JsonError: Error {
        case decodeError;
    }
    
//    enum SourceModules {
//        case main;
//        case history;
//        case news;
//        case weather;
//        case directions;
//    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //
        histListTable.delegate = self;
        histListTable.dataSource = self;
        
        fetchHistoryList() { result in
            switch (result) {
            case .success(true):
                DispatchQueue.main.async {
                    self.histListTable.reloadData();
                };
            default:
                // TODO: put error alert here
                return;
            } // end of switch
        }
        
        
        // I do not know why the tableView register causes the error.
       // tableView.register(HistoryCell.self, forCellReuseIdentifier: "historyCell")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.historyList?.count ?? 0;
    }
    
    
 
    
    // MARK: - CoreData Functions
    func fetchHistoryList (completion: @escaping(Result<Bool,Error>)->Void) {
        do {
            self.historyList = try content.fetch(HistoryList.fetchRequest());
            completion(.success(true));
        } catch {
            completion(.failure(CoreDataError.fetchError));
        }
    }
    
    func saveToHistoryList (_ textLoc:String,_ source:String, _ interactionType:String) -> Bool {
        let historyEntry = HistoryList(context: self.content)
        historyEntry.dateEntered = Date()
        historyEntry.destination = textLoc
        historyEntry.sourceModule = source
        historyEntry.interactionType = interactionType
        
        do {
            try content.save();
        } catch {
            return false;
        }
        return true;
  
    }
    
    // MARK: - tableView functionalities
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = histListTable.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        

        // Configure the cell...
        let cellItem = self.historyList![indexPath.row];
        
        cell.interactionBtnOutlet.setTitle(cellItem.interactionType?.capitalized ?? "title", for: .normal)
        cell.cityNameOutlet.text = cellItem.destination;
        cell.fromOutlet.text = "From: \(cellItem.sourceModule!.capitalized)";
        
        let decoder = JSONDecoder()
        
        // MARK: weather cell config
        if cellItem.interactionType == "weather" {
            // MARK: process weatherCell
            // TODO: configure weather view from here
            
            // hide other views here.
            cell.newsView.isHidden = true;
            cell.directionsView.isHidden = true;
            cell.weatherView.isHidden = false;
            do {
                let decodedWeaData = try decoder.decode(WeatherModelStore.self, from: cellItem.data!.data(using: .utf8)!)
                let formattedWindSpeed = formatDouble(number: decodedWeaData.windSpeed, floatPlaces: 2);
                let formattedTemp = formatDouble(number: decodedWeaData.temp, floatPlaces: 1);
                
                let dateSearched = Date(timeIntervalSince1970: TimeInterval(decodedWeaData.dt))
                
                let formattedDate = formatSourceDate(dateSearched, formatString: "yyyy-MMMM-dd");
                let formattedTime = formatSourceDate(dateSearched, formatString: "hh:mm:ss a");
                
                cell.weaWindVal.text = "\(formattedWindSpeed) km/hr";
                cell.weaHumidVal.text = "\(decodedWeaData.humidity)%";
                cell.weaTemp.text = "\(formattedWindSpeed)°";
                cell.weaterDateValue.text = formattedDate;
                cell.weaTimeValue.text = formattedTime;
                
            } catch {
                
            }
         // MARK: news cell config
        } else if cellItem.interactionType == "news" {
            // MARK: process weatherCell
            // TODO: configure weather view from here
            // hide other views here.
            cell.weatherView.isHidden = true;
            cell.directionsView.isHidden = true;
            cell.newsView.isHidden = false;
            do {
                let decodedNewsData = try decoder.decode(Article.self, from: cellItem.data!.data(using: .utf8)!)
                cell.newsTitle.text = decodedNewsData.title;
                cell.newsDesc.text = decodedNewsData.description;
                cell.newsSource.text = decodedNewsData.source.name;
                cell.newsAuthor.text = decodedNewsData.author ?? "No Author";
                
            } catch {
                
            }
            
        // MARK: direction cell config
        } else if cellItem.interactionType == "directions" {
            // hide other views here.
            cell.weatherView.isHidden = true;
            cell.newsView.isHidden = true;
            cell.directionsView.isHidden = false;
            do {
                let decodedDirData = try decoder.decode(DirectionsModelStore.self, from: cellItem.data!.data(using: .utf8)!)
                
                // format to 2 decimal places for display
                let formattedSourceLat = formatDouble(number: decodedDirData.sourceLat, floatPlaces: 2);
                let formattedSourceLong = formatDouble(number: decodedDirData.sourceLong, floatPlaces: 2);
                let formattedDestLat = formatDouble(number: decodedDirData.destLat, floatPlaces: 2);
                let formattedDestLong = formatDouble(number: decodedDirData.destLong, floatPlaces: 2);
                let formattedDistance = formatDouble(number: (decodedDirData.totalDistance / 1000 ), floatPlaces: 3)
                
                // displaying to cell
                cell.dirStartVal.text = "lat: \(formattedSourceLat)°   long: \(formattedSourceLong)°";
                cell.dirEndVal.text = "lat: \(formattedDestLat)°   long: \(formattedDestLong)°";
                cell.dirMethodOfTravel.text = decodedDirData.methodOfTravel;
                cell.dirTotalDistance.text = "\(formattedDistance) km"
                
            } catch {
                
            }
        }

        return cell
    }
    
    // MARK: - Delete cell history item
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let itemToRemove = self.historyList![indexPath.row];
            self.content.delete(itemToRemove);
            
            do {
                try self.content.save();
            } catch {
                print("error saving data");
            }
            
            self.historyList?.remove(at: indexPath.row)
            histListTable.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // this will return a SINGLE CLLocation object.
    // MARK: Geocode and Reverse Geocoding
    func convertAddress (_ textLoc: String, completion: @escaping(_ location: CLLocation?,_ error: Error?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textLoc) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                completion(nil, error)
                return
            }
            
            completion(location, nil)
            // TODO: I did escape but I'm not sure if this is the best... I do not know closures nor
        }
        
    }

    // thank you to my dear friend for introducing me to escaping closures. I'm still a noob at this...
    // https://stackoverflow.com/questions/46869394/reverse-geocoding-in-swift-4
    func convertCoordinate(_ latitude: Double,_ longitude: Double, completion: @escaping (Result<CLPlacemark,Error>) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(.failure(error!))
                return
            }
            
            if let placem = placemark.first {
                completion(.success(placem))
            }
            completion(.failure(error!))
        }
    }
    
    // MARK: - helper functions
    func calcKmph (_ rawSpeed: Double) -> Double {
        let kmConv : Double = 1 / 1000;
        let hrConv : Double = 3600;
        
        let mToKm = rawSpeed * kmConv;
        let secToHr = mToKm * hrConv;
        let kmph = secToHr;
        
        return kmph;
    }
    
    func formatDouble (number: Double, floatPlaces places: Int) -> String {
        let formatString = String (format: "%%.%df", places);
        let truncatedString = String (format: formatString, number);
        
        return truncatedString;
    }
    
    // https://stackoverflow.com/questions/35700281/how-do-i-convert-a-date-time-string-into-a-different-date-string
    func formatSourceDate (_ dateToBeFormatted: Date, formatString: String) ->String {
        // 1) Create a DateFormatter() object.
        let format = DateFormatter();
         
        // 2) Set the current timezone to .current
        format.timeZone = .current;
         
        // 3) Set the format of the altered date.
        format.dateFormat = formatString;
         
        // 4) Set the current date, altered by timezone.
        let formattedString = format.string(from: dateToBeFormatted);
        
        return formattedString;
    }
    
    // MARK: - tableviewTemplates

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
