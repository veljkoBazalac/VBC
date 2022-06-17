//
//  AddVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit
import Firebase
import FirebaseStorage

class AddStep1VC: UIViewController {
    // Basic Info Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var personalName: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var selectSector: UITextField!
    @IBOutlet weak var productType: UITextField!
    // Personal Name Stack Outlet
    @IBOutlet weak var personalNameStack: UIStackView!
    // Remove Image Outlet
    @IBOutlet weak var removeImageButton: UIButton!
    // -------------------- //
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    // PopUp with Spinner
    private var popUpSpinner : PopUpSpinner!
    // PickerView for Sector
    private var pickerView = UIPickerView()
    // Number of Sector Row
    private var sectorRow : Int = 0
    // Company or Personal Card
    var companyCard : Bool = true
    // Sector List Dictionary
    private var sectors : [Sectors] = []
    // Edit Card
    var editCard : Bool = false
    var editCardID : String = ""
    var editUserID : String = ""
    var editImage : UIImage?
    var NavBarTitle1 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Placeholders for Textfields
        setPlaceholders()
        // PickerView Delegate for Select Sector
        pickerView.delegate = self
        pickerView.dataSource = self
        selectSector.inputView = pickerView
        getSectorsList()
        
        // Hide PersonalName Stack if it's Company Card.
        if companyCard == true {
            personalNameStack.isHidden = true
        }
        
        if editCard == false {
            // User Create New Card.
            productType.isEnabled = false
            removeImageButton.isHidden = true
        } else {
            // User Edit Card.
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.hidesBackButton = true
            navigationItem.title = NavBarTitle1
            selectSector.isEnabled = false
            
            // Check for LogoImage.
            if editImage == UIImage(named: "LogoImage") {
                // User does NOT have Image.
                DispatchQueue.main.async {
                    self.imageView.image = nil
                    self.removeImageButton.isHidden = true
                }
            } else {
                // User DOES have Image.
                DispatchQueue.main.async {
                    self.imageView.image = self.editImage
                    self.removeImageButton.isHidden = false
                }
            }
            // Get Card Data for Edit from Firestore.
            getCardForEdit()
        }
    }
    
    // MARK: - Set Placeholders for Textfields
    private func setPlaceholders() {
        
        personalName.attributedPlaceholder = NSAttributedString(
            string: "Enter Your Name...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        companyName.attributedPlaceholder = NSAttributedString(
            string: "Enter Company Name...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        selectSector.attributedPlaceholder = NSAttributedString(
            string: "Select Sector",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        productType.attributedPlaceholder = NSAttributedString(
            string: "Select Sector first...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    // MARK: - Upload Company Logo Image
    func uploadImage() {
        
        startSpinner()
        
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 0.5) else {
            PopUp().popUpWithOk(newTitle: "Error!",
                                newMessage: "Something went wrong. Please Check your Internet connection and try again.",
                                vc: self)
            return
        }
        
        let imageName = "Img.\(editCardID)"
        let imageReference = storage
            .child(Constants.Firestore.Storage.logoImage)
            .child(self.user!)
            .child(imageName)
    
        let uploadTask = imageReference.putData(data, metadata: nil) { mData, error in
            if let e = error {
                PopUp().popUpWithOk(newTitle: "Error!",
                                    newMessage: "Error Uploading Image data to Storage. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                    vc: self)
                return
            }
            
                imageReference.downloadURL { url, error in
                    if let e = error {
                        PopUp().popUpWithOk(newTitle: "Error!",
                                            newMessage: "Error Downloading URL. \(e.localizedDescription)",
                                            vc: self)
                    } else {
                    
                    guard let url = url else {
                        PopUp().popUpWithOk(newTitle: "Error!",
                                            newMessage: "Something went wrong. Please Check your Internet connection and try again.",
                                            vc: self)
                        return
                    }
                        
                        let urlString = url.absoluteString

                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.editCardID)
                        .setData(["\(Constants.Firestore.Storage.imageURL)" : "\(urlString)"], merge: true) { error in

                            if let error = error {
                                PopUp().popUpWithOk(newTitle: "Error!",
                                                    newMessage: "Error Uploading Image URL to Firestore. Please Check your Internet connection and try again. \(error.localizedDescription)",
                                                    vc: self)
                                return
                            }
                        }
                    }
                }
        }
        
        uploadTask.observe(.success) { snapshot in
            self.stopSpinner()
            
            if self.popUpSpinner.spinner.isAnimating == false {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
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
            PopUp().popUpWithOk(newTitle: "Basic Company Info missing",
                                newMessage: "\(error!)",
                                vc: self)
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
                            PopUp().popUpWithOk(newTitle: "Error Saving New Data",
                                                newMessage: "Error Uploading Edit data to Database. \(e)",
                                                vc: self)
                        } else {
                            if self.imageView.image != nil {
                                self.uploadImage()
                            } else {
                                
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.editCardID)
                                .setData(["Card Edited" : false], merge: true)
                                
                                self.storage
                                    .child(Constants.Firestore.Storage.logoImage)
                                    .child(self.editUserID)
                                    .child("Img.\(self.editCardID)")
                                    .delete()
                                
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.editCardID)
                                .setData([Constants.Firestore.Key.imageURL : "",
                                          "Card Edited" : true], merge: true)
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.addNew2 {
            
            let destinationVC = segue.destination as! AddStep2VC
            
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

    // MARK: - Remove Logo Image Pressed
    @IBAction func removeImagePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.imageView.image = nil
            self.removeImageButton.isHidden = true
        }
    }
    
    // MARK: - Add Logo Image Pressed
    @IBAction func addImagePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            
            self.present(vc, animated: true)
        }
    }
    
} //

// MARK: - UIPickerController for Image Add
extension AddStep1VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let logoImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = logoImage
            removeImageButton.isHidden = false
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIPickerView for Sectors
extension AddStep1VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

// MARK: - PopUp with Spinner
extension AddStep1VC {
    
    func startSpinner() {
        self.popUpSpinner = PopUpSpinner(frame: self.view.frame)
        self.popUpSpinner.spinnerWithBlur()
        self.view.addSubview(self.popUpSpinner)
    }
    
    func stopSpinner() {
        self.popUpSpinner.animateOut(forView: popUpSpinner.popUpView, mainView: popUpSpinner)
    }
}
