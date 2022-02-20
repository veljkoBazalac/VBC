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
    @IBOutlet weak var personalName: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var selectSector: UITextField!
    @IBOutlet weak var productType: UITextField!

    @IBOutlet weak var nameStack: UIStackView!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    
    var pickerView = UIPickerView()
    var sectorRow : Int = 0
    var companyCard : Bool = true
    
    // Sector List Dictionary
    private var sectors : [Sectors] = []
    
    var editCard : Bool = false
    var editCardID : String = ""
    var editUserID : String = ""
    var editSinglePlace : Bool = true
    var editCardCountry : String = ""
    var NavBarTitle1 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectSector.inputView = pickerView
        
        getSectorsList()
        
        if companyCard == true {
            nameStack.isHidden = true
        }
        
        if editCard == false {
            productType.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.title = NavBarTitle1
            selectSector.isEnabled = false
            getCardForEdit()
        }
        
    }
    
    
// MARK: - Pop Up With Ok
    
    func popUpWithOk(newTitle: String, newMessage: String) {
        
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }

    
// MARK: - Check if Fields are correct
    
    func validateFields() -> String? {
        
        if personalName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 30 && companyCard == false {
            return "Personal Name can have Max 30 letters."
        }
        else if personalName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3  && companyCard == false {
            return "Personal Name must have Min 3 letters."
        }
        else if companyName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 30 {
            return "Company Name can have Max 30 letters."
        }
        else if companyName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            return "Company Name must have Min 3 letters."
        }
        else if sectorRow == 0 && selectSector.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
            self.popUpWithOk(newTitle: "Basic Company Info missing", newMessage: "\(error!)")
        } else {
            
            if editCard == false {
                performSegue(withIdentifier: Constants.Segue.addNew2, sender: self)
            } else {
                
                // Upload Edit Data to Database
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(editUserID)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(editCardID)
                    .setData([Constants.Firestore.Key.personalName: personalName.text!,
                              Constants.Firestore.Key.companyName: companyName.text!,
                              Constants.Firestore.Key.type: productType.text!], merge: true) { error in
                        
                        if let e = error {
                            self.popUpWithOk(newTitle: "Error Saving New Data", newMessage: "Error Uploading Edit data to Database. \(e)")
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                
            }
        }
    }

// MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.addNew2 {
            
            let destinationVC = segue.destination as! CAdd2ViewController
            
            destinationVC.sectorNumber2 = sectorRow
            destinationVC.logoImage2 = imageView.image
            destinationVC.companyName2 = companyName.text!
            destinationVC.sector2 = selectSector.text!
            destinationVC.productType2 = productType.text!
            destinationVC.companyCard2 = companyCard
            
            if companyCard == false {
                destinationVC.personalName2 = personalName.text!
            }
        }
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
    
    
// MARK: - Get Card for Edit
    
    func getCardForEdit() {
        
        // Getting Card from Firebase Database
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(editUserID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(editCardID)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error Getting Company Card for Edit. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        // Get Basic Info data
                        //TODO: ZAVRSI ZA SLIKU DA MOZE DA SE MENJA
                        if let companyName = data![Constants.Firestore.Key.companyName] as? String {
                            if let sector = data![Constants.Firestore.Key.sector] as? String {
                                if let productType = data![Constants.Firestore.Key.type] as? String {
                                    
                                    self.companyName.text = companyName
                                    self.selectSector.text = sector
                                    self.productType.text = productType
                                    
                                    if self.companyCard == false {
                                        if let personalName = data![Constants.Firestore.Key.personalName] as? String {
                                            
                                            self.personalName.text = personalName
                                        }
                                    }
                                }
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
    
} //



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
            productType.isEnabled = true
        }
         else {
            print("Error selecting Row!")
        }
    }
}
