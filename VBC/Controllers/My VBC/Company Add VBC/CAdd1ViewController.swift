//
//  AddVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit
import Firebase
import FirebaseStorage

class CAdd1ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var selectSector: UITextField!
    @IBOutlet weak var productType: UITextField!

    // Firebase Firestore Database
    let db = Firestore.firestore()
    
    var pickerView = UIPickerView()
    var sectorRow : Int = 0
    
    // Dictionaries for Text Fields
    private var sectors : [Sectors] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        configureTextFields()
        
        getSectorsList()
        
    }
    
    func validateFields() -> String? {
        
//        if companyName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || selectSector.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || productType.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            return "Please fill all the fields."
//        }
        if companyName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 20 {
            return "Company Name can have Max 20 letters."
        }
        else if companyName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 {
            return "Company Name must have Min 4 letters."
        }
        else if sectorRow == 0 {
            return "Please Select Sector."
        }
        else if productType.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 30 {
            return "Product Type can have Max 30 letters."
        }
        else if productType.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 {
            return "Product Type must have Min 4 letters."
        }
        else if imageView.image == UIImage(named: "Add_Logo") {
            return "Please Add Your Logo"
        }
        
        return nil
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        //imageView.image != nil && companyName.text != nil && selectSector.text != nil && productType.text != nil
        
        let error = validateFields()
        
        if error != nil {
            // If fields are not correct, show error.
            print(error!)
        } else {
            
            performSegue(withIdentifier: Constants.Segue.cAdd2, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.cAdd2 {
            
            let destinationVC = segue.destination as! CAdd2ViewController
            
                destinationVC.sectorNumber = sectorRow
                destinationVC.logoImage = imageView.image
                destinationVC.newCompanyName = companyName.text
                destinationVC.newSector = selectSector.text
                destinationVC.newProductType = productType.text
           
        }
    }

    func configureTextFields() {
        selectSector.inputView = pickerView
        productType.isEnabled = false
        
    }
 
// MARK: - Get Sectors List Function
    
    func getSectorsList() {
        
        db.collection(Constants.Firestore.CollectionName.sectors).getDocuments { snapshot, error in
            
            if let e = error {
                print("Error getting Sectors List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                            
                        if let sectorsData = data[Constants.Firestore.Key.name] as? String {
                            
                            let sector  = Sectors(name: sectorsData)
                            
                            self.sectors.append(sector)
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
    
// MARK: - Upload Data to Firestore
    

        
//        guard let image = imageView.image else {return}
//
//        guard let imageData = image.pngData() else {return}
//
//        storage.putData(imageData, metadata: nil) { metadata, error in
//
//            if error != nil {
//                print("Failed to Upload image.")
//            }

   // let storage = Storage.storage().reference()
        
        //db.collection(Constants.Firestore.CollectionName.cards).document(cardID).setData(["Name": companyName.text, "Sector": selectSector.text, "ProductType": productType.text, "CardID": cardID])
    
    //        db.collection("Cards").addDocument(data: ["Name": "Legend KV", "WorkActiviry": "Prodaja", "ProductType": "Garderoba", "City": "Kraljevo"])
    
}

// MARK: - UIPickerController for Image Add

extension CAdd1ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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


// MARK: - UIPickerView for Sectors

extension CAdd1ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if selectSector.isEditing {
            return sectors.count
        }
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        if selectSector.isEditing {
            return sectors[row].name
        }
         else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectSector.isEditing {
            selectSector.text = sectors[row].name
            sectorRow = row + 1
            configureTextFields()
            productType.isEnabled = true
        }
         else {
            print("Error selecting Row!")
        }
    }
}
