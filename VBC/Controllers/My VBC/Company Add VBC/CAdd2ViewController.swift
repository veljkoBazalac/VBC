//
//  CAdd2ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class CAdd2ViewController: UIViewController {

    // Image and Text Stack Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySector: UILabel!
    @IBOutlet weak var companyProductType: UILabel!
    
    // Text Fields Outlets
    @IBOutlet weak var countrySelect: UITextField!
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var streetName: UITextField!
    @IBOutlet weak var googleMapsLink: UITextField!
    
    // Segment Outlet
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var sectorNumber : Int?
    var logoImage : UIImage?
    var newCompanyName : String?
    var newSector : String?
    var newProductType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = logoImage
        companyName.text = newCompanyName
        companySector.text = newSector
        companyProductType.text = newProductType

        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: Constants.Segue.cAdd3, sender: self)
    }
    
    
    

}
