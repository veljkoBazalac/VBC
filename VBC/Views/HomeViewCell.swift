//
//  HomeViewCell.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit

class HomeViewCell: UITableViewCell {

    // Image Label
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Numbers Label
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var followNumber: UILabel!
    
    // Text Label
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
