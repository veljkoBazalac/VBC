//
//  HomeViewCell.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class DefaultCell: UITableViewCell {

    // Image Label
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Text Label
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var companyOrPersonalIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
