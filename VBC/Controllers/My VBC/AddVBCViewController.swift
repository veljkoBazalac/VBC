//
//  AddVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit
import Firebase

class AddVBCViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var workActivity: UITextField!
    @IBOutlet weak var productType: UITextField!
    @IBOutlet weak var cityName: UITextField!
    
    let db = Firestore.firestore()
    
    var pickerView = UIPickerView()
    
    
    // Dictionaries for Text Fields
    
    private var workActivities : [WorkActivity] = []
    private var productTypes : [ProductType] = []
    private var cities : [CityName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        configureTextFields()
        
        getWorkActivity()
        getCityName()
        
        
        
//        db.collection("Cards").addDocument(data: ["Name": "Legend KV", "WorkActiviry": "Prodaja", "ProductType": "Garderoba", "City": "Kraljevo"])
        
    }
    
    func configureTextFields() {
        
        workActivity.inputView = pickerView
        workActivity.textAlignment = .center
        workActivity.placeholder = "Select Work Activity"
        
        productType.inputView = pickerView
        productType.textAlignment = .center
        productType.placeholder = "Select Product Type"
        productType.isEnabled = true
        
        cityName.inputView = pickerView
        cityName.textAlignment = .center
        cityName.placeholder = "Select City"
        
        if workActivity.text == "" {
            productType.isEnabled = false
            productType.placeholder = "Please Choose Work Activity First"
        }
        
    }
 
// MARK: - Get Work Activity Funcion
    
    func getWorkActivity() {
        
        db.collection(Constants.Firestore.CollectionName.workActivity).getDocuments { snapshot, error in
            
            if let e = error {
                print("Error getting Work Activity List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                            
                        if let workActivity = data[Constants.Firestore.Key.work] as? String {
                            
                            let work = WorkActivity(work: workActivity)
                            
                            self.workActivities.append(work)
                        }
                    }
                }
            }
        }
    }
    
// MARK: - Get Product Type Funcion
    
    func getProductType() {
        
        productTypes = []
        productType.text = ""
        
        db.collection(Constants.Firestore.CollectionName.workActivity).document(workActivity.text ?? "Select Work Activity").collection(Constants.Firestore.CollectionName.productType).getDocuments { snapshot, error in
            
            if let e = error {
                print("Error getting Work Activity List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                        
                        print(data)
                            
                        if let productType = data[Constants.Firestore.Key.type] as? String {
                            
                            let type = ProductType(type: productType)
                            
                            self.productTypes.append(type)
                        }
                    }
                }
            }
        }
    }
    
// MARK: - Get City Name Funcion
    
    func getCityName() {
        
        db.collection(Constants.Firestore.CollectionName.cityName).getDocuments { snapshot, error in
            
            if let e = error {
                print("Error getting City Names List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                            
                        if let cityName = data[Constants.Firestore.Key.name] as? String {
                            
                            let city = CityName(name: cityName)
                            
                            self.cities.append(city)
                            
                        }
                    }
                }
            }
        }
    }

// MARK: - Add Logo Image Pressed
    
    @IBAction func addLogoTapped(_ sender: UITapGestureRecognizer) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
        
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
    }
    
}

// MARK: - UIPickerController for Image Add

extension AddVBCViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let logoImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = logoImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIPickerView for City

extension AddVBCViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if workActivity.isEditing {
            return workActivities.count
        }
        
        else if productType.isEditing {
            return productTypes.count
        }
        
        else if cityName.isEditing {
            return cities.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        if workActivity.isEditing {
            return workActivities[row].work
        }
        
        else if productType.isEditing {
            return productTypes[row].type
        }
        
        else if cityName.isEditing {
            return cities[row].name
        } else {
            
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if workActivity.isEditing {
            workActivity.text = workActivities[row].work
            configureTextFields()
            getProductType()
        }
        
        else if productType.isEditing {
            productType.text = productTypes[row].type
        }
        
        else if cityName.isEditing {
            cityName.text = cities[row].name
        } else {
            print("Error selecting Row!")
        }
    }
}
