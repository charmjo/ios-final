//
//  HistoryCell.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-05.
//

import UIKit

//protocol HistoryCellDelegate {
//    func performSegueFromCell(_ identifier:String, _ destination:String);
//}

class HistoryCell: UITableViewCell {
    //MARK: - outlets and delegates
//    var delegate : HistoryCellDelegate!

    
    @IBOutlet weak var fromOutlet: UILabel!
    @IBOutlet weak var cityNameOutlet: UILabel!
    @IBOutlet weak var interactionBtnOutlet: UIButton!
    
    
    // MARK: - Weather View
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weaterDateValue: UILabel!
    @IBOutlet weak var weaTimeLabel: UILabel!
    @IBOutlet weak var weaTimeValue: UILabel!
    
    @IBOutlet weak var weaTemp: UILabel!
    @IBOutlet weak var weaHumidLabel: UILabel!
    @IBOutlet weak var weaHumidVal: UILabel!
    @IBOutlet weak var weaWindLabel: UILabel!
    @IBOutlet weak var weaWindVal: UILabel!
    
    // MARK: - News View
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsAuthor: UILabel!
    @IBOutlet weak var newsDesc: UITextView!
    @IBOutlet weak var newsSource: UILabel!
    
    
    // MARK: - Directions View
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var dirStartVal: UILabel!
    @IBOutlet weak var dirEndVal: UILabel!
    @IBOutlet weak var dirMethodOfTravel: UILabel!
    
    @IBOutlet weak var dirTotalDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
