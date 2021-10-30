//
//  AboutViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit

class AboutViewController: UIViewController {

    // Text Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    // About Us Outlet
    @IBOutlet weak var aboutUsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = "Metalac AD"
        workLabel.text = "Bela Tehnika"
        workTwoLabel.text = "Bojleri"
        cityLabel.text = "Gornji Milanovac"
        
        
    }
    


}
