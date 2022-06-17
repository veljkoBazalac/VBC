//
//  AddLocListTableViewCell.swift
//  VBC
//
//  Created by VELJKO on 15.11.21..
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var mapIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(city: String, street: String, gMap: String, aMap: String) {
        cellTextLabel.text = "\(city) - \(street)"
        
        if gMap == "" && aMap == "" {
            mapIcon.isHidden = true
        } else if gMap != "" && aMap == "" {
            mapIcon.image = UIImage(named: "Google Maps")
        } else if gMap == "" && aMap != "" {
            mapIcon.image = UIImage(named: "Apple Maps")
        } else if gMap != "" && aMap != "" {
            mapIcon.image = UIImage(named: "GAmaps")
        }
    }
    
}
