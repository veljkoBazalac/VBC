//
//  PAdd1VC.swift
//  VBC
//
//  Created by VELJKO on 25.12.21..
//

import UIKit
import Firebase
import FirebaseStorage

class PAdd1VC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var personalName: UITextField!
    @IBOutlet weak var selectSector: UITextField!
    @IBOutlet weak var productType: UITextField!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    
    var pickerView = UIPickerView()
    var sectorRow : Int = 0
    
    // Sector List Dictionary
    private var sectors : [Sectors] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        configureTextFields()
        
        getSectorsList()
    }

// MARK: - Validate Text Fields Function
    
    func validateFields() -> String? {

        if personalName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 30 {
            return "Personal Name can have Max 30 letters."
        }
        else if personalName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            return "Personal Name must have Min 3 letters."
        }
        else if sectorRow == 0 {
            return "Please Select Sector."
        }
        else if productType.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 30 {
            return "Product Type can have Max 30 letters."
        }
        else if productType.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            return "Product Type must have Min 3 letters."
        }
        return nil
    }

// MARK: - Next Button Pressed
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        
        let error = validateFields()
        
        if error != nil {
            // If fields are not correct, show error.
            popUpWithOk(newTitle: "Basic Personal Info missing", newMessage: "\(error!)")
        } else {
            performSegue(withIdentifier: Constants.Segue.pAdd2, sender: self)
        }
    }
    
// MARK: - Prepare for Segue
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == Constants.Segue.pAdd2 {
                
                let destinationVC = segue.destination as! PAdd2VC

                    destinationVC.sectorNumber = sectorRow
                    destinationVC.logoImage = imageView.image
                    destinationVC.newPersonalName = personalName.text
                    destinationVC.newSector = selectSector.text
                    destinationVC.newProductType = productType.text
               
            }
        }
    
// MARK: - Configure Text Fields Function
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
    
// MARK: - Pop Up With Ok
    
    func popUpWithOk(newTitle: String, newMessage: String) {
        // Pop Up with OK button
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPickerController for Image Add

extension PAdd1VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension PAdd1VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
