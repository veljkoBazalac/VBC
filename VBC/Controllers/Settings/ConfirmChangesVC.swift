//
//  ConfirmChangesVC.swift
//  VBC
//
//  Created by VELJKO on 9.3.22..
//

import UIKit
import Lottie
import Firebase

class ConfirmChangesVC: UIViewController, UITextFieldDelegate {
    
    let stackView1 : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 30
        stack.frame.size.height = 300
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    let currentPasswordLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Current Password"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let currentPasswordTF : UITextField = { () -> UITextField in
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 15)
        field.borderStyle = UITextField.BorderStyle.roundedRect
        field.autocorrectionType = UITextAutocorrectionType.no
        field.keyboardType = UIKeyboardType.default
        field.returnKeyType = UIReturnKeyType.done
        field.clearButtonMode = UITextField.ViewMode.whileEditing
        field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        field.placeholder = "Enter Your Password..."
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.clearsOnBeginEditing = false
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        
        return field
    }()
    
    let stackViewForAnimation : UIStackView = { () -> UIStackView in
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var finishButton : UIButton = { () -> UIButton in
        
        let button = UIButton()
        button.setTitle("Finish", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.frame.size.width = 100
        button.frame.size.height = 30
        button.addTarget(self, action: #selector(finishButtonPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var animationView : AnimationView?
    let secureTextButton1 = UIButton()
    let secureTextButton2 = UIButton()
    
    // Firebase Auth Current User
    let userID = Auth.auth().currentUser?.uid
    let user = Auth.auth().currentUser
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()

    var emailChanged : Bool = true
    var emailForChange : String = ""
    var passwordForChange : String = ""
    var deleteAccount : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPasswordTF.delegate = self
        currentPasswordTF.isSecureTextEntry = true
        
        view.addSubview(stackViewForAnimation)
        view.addSubview(stackView1)
        stackView1.addArrangedSubview(currentPasswordLabel)
        stackView1.addArrangedSubview(currentPasswordTF)
        view.addSubview(finishButton)
        
        setStackViewForAnimation()
        setStackView()
        setSecureTextButton()
        setFinishButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setAnimation()
    }
    
    // MARK: - Finish Button Pressed
    
    @objc func finishButtonPressed() {
        
        if currentPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            if emailChanged == true {
                popUpWithOk(newTitle: "EMPTY Password", newMessage: "Please Enter your password to confirm Email Address change.")
            } else {
                popUpWithOk(newTitle: "EMPTY Password", newMessage: "Please Enter your OLD password to confirm Password change.")
            }
        } else if currentPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && emailChanged == false && deleteAccount == false {
            // Change Password
            changePassword()
        } else if currentPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && emailChanged == true && deleteAccount == false {
            // Change Email Address
            changeEmailAddress()
        } else if currentPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && deleteAccount == true {
            // Delete Account
            accountDelete()
        }
    }
    
    // MARK: - Change Password Function
    
    func changePassword() {
        
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: currentPasswordTF.text!)
        
        user?.reauthenticate(with: credential , completion: { AuthResult, error in
            if error != nil {
                self.popUpWithOk(newTitle: "Wrong Password", newMessage: "Please Enter your password.")
            } else {
                
                self.user?.updatePassword(to: self.passwordForChange.trimmingCharacters(in: .whitespacesAndNewlines), completion: { error in
                    if let e = error {
                        self.popUpWithOk(newTitle: "Error Adding New Password", newMessage: "\(e)")
                    } else {
                        // Password Successfully Updated
                        self.animationView?.play(completion: { _ in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                })
            }
        })
    }
    
    // MARK: - Change Email Address Function
    
    func changeEmailAddress() {
        
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: currentPasswordTF.text!)
        
        user?.reauthenticate(with: credential , completion: { AuthResult, error in
            if error != nil {
                self.popUpWithOk(newTitle: "Wrong Password", newMessage: "Please Enter your password.")
            } else {
                
                self.user?.sendEmailVerification(beforeUpdatingEmail: self.emailForChange.trimmingCharacters(in: .whitespacesAndNewlines), completion: { (error) in
                    
                    if error != nil {
                        // Error sending Email verification
                        self.popUpWithOk(newTitle: "Verification Error", newMessage: "Sending Email verification error. Check your internet connection and try again.")
                    } else {
                        
                        // Email Verification Sent
                        self.animationView?.play(completion: { _ in
                            self.performSegue(withIdentifier: Constants.Segue.emailVerifySegue, sender: self)
                        })
                        
                    }
                })
            }
        })
    }
    
    // MARK: - Delete Account Function
    
    func accountDelete() {
        
        if user != nil {
            
            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: currentPasswordTF.text!)
            
            user?.reauthenticate(with: credential , completion: { AuthResult, error in
                if error != nil {
                    self.popUpWithOk(newTitle: "Wrong Password", newMessage: "Please Enter your password.")
                } else {
                    
                    self.user?.delete(completion: { err in
                        if err != nil {
                            self.popUpWithOk(newTitle: "Error Deleting Account", newMessage: "Please try again.")
                        } else {
                            // Deleted User from Auth.. Now Delete All user Data..
                            self.deleteAccountData()
                        }
                    })
                    
                }
            })
        }
    }
   
    // MARK: - Delete Account Data Function
    
    func deleteAccountData() {
     
        if user != nil {
         
            self.db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(self.userID!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .getDocuments { snapshot, err in
              
                    if err != nil {
                        print("Error Getting Users Documents.")
                    } else {
                        
                        if let snapshotDocuments = snapshot?.documents {
                   
                            for documents in snapshotDocuments {
                          
                                let data = documents.data()
                                
                                if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                 
                                    // Delete Card Locations
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(cardID)
                                        .collection(Constants.Firestore.CollectionName.locations)
                                        .getDocuments { snapshot, error in
                                            
                                            if let e = error {
                                                print("Error Getting Locations for Delete. \(e)")
                                            } else {
                                                
                                                if let snapshotDocuments = snapshot?.documents {
                                                    
                                                    for documents in snapshotDocuments {
                                                        
                                                        let data = documents.data()
                                                        
                                                        if let cityName = data[Constants.Firestore.Key.city] as? String {
                                                            if let streetName = data[Constants.Firestore.Key.street] as? String {
                                                             
                                                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                    .document(Constants.Firestore.CollectionName.data)
                                                                    .collection(Constants.Firestore.CollectionName.users)
                                                                    .document(self.userID!)
                                                                    .collection(Constants.Firestore.CollectionName.cardID)
                                                                    .document(cardID)
                                                                    .collection(Constants.Firestore.CollectionName.locations)
                                                                    .document("\(cityName) - \(streetName)")
                                                                    .delete { error in
                                                                        
                                                                        if let e = error {
                                                                            print("Error Deleting Location. \(e)")
                                                                        } else {
                                                                            
                                                                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                                .document(Constants.Firestore.CollectionName.data)
                                                                                .collection(Constants.Firestore.CollectionName.users)
                                                                                .document(self.userID!)
                                                                                .collection(Constants.Firestore.CollectionName.cardID)
                                                                                .document(cardID)
                                                                                .collection(Constants.Firestore.CollectionName.locations)
                                                                                .document("\(cityName) - \(streetName)")
                                                                                .collection(Constants.Firestore.CollectionName.social)
                                                                                .getDocuments { snapshot, error in
                                                                                    
                                                                                    if let e = error {
                                                                                        print("Error Deleting Social Media. \(e)")
                                                                                    } else {
                                                                                        
                                                                                        if let snapshotDocuments = snapshot?.documents {
                                                                                            
                                                                                            for documents in snapshotDocuments {
                                                                                                
                                                                                                let data = documents.data()
                                                                                                
                                                                                                if let socialName = data[Constants.Firestore.Key.name] as? String {
                                                                                                    
                                                                                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                                                        .document(Constants.Firestore.CollectionName.data)
                                                                                                        .collection(Constants.Firestore.CollectionName.users)
                                                                                                        .document(self.userID!)
                                                                                                        .collection(Constants.Firestore.CollectionName.cardID)
                                                                                                        .document(cardID)
                                                                                                        .collection(Constants.Firestore.CollectionName.locations)
                                                                                                        .document("\(cityName) - \(streetName)")
                                                                                                        .collection(Constants.Firestore.CollectionName.social)
                                                                                                        .document(socialName)
                                                                                                        .delete()
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                        }
                                                                    }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    
                                    // Delete SavedForUsers
                                    self.db
                                        .collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(cardID)
                                        .collection(Constants.Firestore.CollectionName.savedForUsers)
                                        .getDocuments { snapshot, error in
                                            
                                            if let e = error {
                                                print("Error Deleting Saved For User. \(e)")
                                            } else {
                                                
                                                if let snapshotDocuments = snapshot?.documents {
                                                    
                                                    for documents in snapshotDocuments {
                                                        
                                                        let data = documents.data()
                                                        
                                                        if let saverUserID = data[Constants.Firestore.Key.userID] as? String {
                                                            if let saverCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                            
                                                            self.db
                                                                .collection(Constants.Firestore.CollectionName.VBC)
                                                                .document(Constants.Firestore.CollectionName.data)
                                                                .collection(Constants.Firestore.CollectionName.users)
                                                                .document(saverUserID)
                                                                .collection(Constants.Firestore.CollectionName.savedVBC)
                                                                .document(saverCardID)
                                                                .delete() { err in
                                                                    if let e = err {
                                                                        print("Error Deleting Card from Saver Profile. \(e)")
                                                                    }
                                                                }
                                                            
                                                            
                                                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                .document(Constants.Firestore.CollectionName.data)
                                                                .collection(Constants.Firestore.CollectionName.users)
                                                                .document(self.userID!)
                                                                .collection(Constants.Firestore.CollectionName.cardID)
                                                                .document(cardID)
                                                                .collection(Constants.Firestore.CollectionName.savedForUsers)
                                                                .document(saverUserID)
                                                                .delete() { err in
                                                                    if let e = err {
                                                                        print("Error Deleting Saver ID from SavedForUsers. \(e)")
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    
                                    // Delete About Collection
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(cardID)
                                        .collection(Constants.Firestore.CollectionName.aboutSection)
                                        .document(Constants.Firestore.CollectionName.about)
                                        .delete() { err in
                                            
                                            if err != nil {
                                                print("Error Deleting About Subcollection.")
                                            }
                                        }
                                    
                                    // Delete Saved VBC Collection
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID!)
                                        .collection(Constants.Firestore.CollectionName.savedVBC)
                                        .getDocuments { snapshot, err in
                                            
                                            if err != nil {
                                                print("Error Saved VBC.")
                                            } else {
                                                
                                                if let snapshotDocuments = snapshot?.documents {
                                                    
                                                    for documents in snapshotDocuments {
                                                        
                                                        let data = documents.data()
                                                        
                                                        if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                            
                                                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                .document(Constants.Firestore.CollectionName.data)
                                                                .collection(Constants.Firestore.CollectionName.users)
                                                                .document(self.userID!)
                                                                .collection(Constants.Firestore.CollectionName.savedVBC)
                                                                .document(cardID)
                                                                .delete { err in
                                                                    if err != nil {
                                                                        print("Error Deleting Saved VBC.")
                                                                    }
                                                                }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    
                                    
                                    // Delete Card Document and Image from Storage
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(cardID)
                                        .delete { error in
                                            if let e = error {
                                                print("Error Deleting VBC. \(e)")
                                            } else {
                                                
                                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                    .document(Constants.Firestore.CollectionName.data)
                                                    .collection(Constants.Firestore.CollectionName.users)
                                                    .document(self.userID!)
                                                    .delete() { err in
                                                        if let e = err {
                                                            print("Error Deleting user from Users Subcollection. \(e)")
                                                        }
                                                    }
                                                
                                                self.storage
                                                    .child(Constants.Firestore.Storage.logoImage)
                                                    .child(self.userID!)
                                                    .child("Img.\(cardID)")
                                                    .delete() { err in
                                                        if let e = err {
                                                            print("Error Deleting Images from Storage. \(e)")
                                                        }
                                                    }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
        }
        // Password Successfully Updated
        self.animationView?.play(completion: { _ in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.welcomeVC)
            self.view.window!.rootViewController = initialViewController
        })
    }
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.emailVerifySegue {
            
            let destinationVC = segue.destination as! UpdatedEmailVerifyVC
            
            destinationVC.emailForChange = emailForChange
            destinationVC.confirmedPassword = currentPasswordTF.text!
        }
    }
    
    // MARK: - Change TextField Eye Image
    
    @objc func hideOldPassword(sender: AnyObject) {
        currentPasswordTF.isSecureTextEntry.toggle()
        
        if currentPasswordTF.isSecureTextEntry == false {
            secureTextButton1.setImage(UIImage(named: "ClosedEye"), for: .normal)
        } else {
            secureTextButton1.setImage(UIImage(named: "OpenEye"), for: .normal)
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
    
} //

// MARK: - UI Settings

extension ConfirmChangesVC {
    
    func setStackView() {
        
        stackView1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 450).isActive = true
        stackView1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        currentPasswordLabel.leftAnchor.constraint(equalTo: stackView1.leftAnchor).isActive = true
        currentPasswordLabel.rightAnchor.constraint(equalTo: stackView1.rightAnchor).isActive = true
        currentPasswordLabel.topAnchor.constraint(equalTo: stackView1.topAnchor).isActive = true
        
        currentPasswordTF.centerXAnchor.constraint(equalTo: stackView1.centerXAnchor).isActive = true
        currentPasswordTF.leftAnchor.constraint(equalTo: stackView1.leftAnchor, constant: 50).isActive = true
        currentPasswordTF.rightAnchor.constraint(equalTo: stackView1.rightAnchor, constant: -50).isActive = true
        currentPasswordTF.bottomAnchor.constraint(equalTo: stackView1.bottomAnchor).isActive = true
    }
    
    func setAnimation() {
        
        animationView = AnimationView(name: "password2")
    
        animationView?.contentMode = .scaleAspectFit
        animationView?.center = self.view.center
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        stackViewForAnimation.addArrangedSubview(animationView!)
        animationView?.loopMode = .playOnce
        animationView?.animationSpeed = 1
    }
    
    func setStackViewForAnimation() {
        
        stackViewForAnimation.translatesAutoresizingMaskIntoConstraints = false
        stackViewForAnimation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stackViewForAnimation.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackViewForAnimation.heightAnchor.constraint(equalTo: stackViewForAnimation.widthAnchor).isActive = true
        stackViewForAnimation.bottomAnchor.constraint(equalTo: stackView1.topAnchor, constant: -50).isActive = true
    }
    
    func setSecureTextButton() {
        
        secureTextButton1.setImage(UIImage(named: "OpenEye"), for: .normal)
        secureTextButton1.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        secureTextButton1.imageView?.contentMode = .scaleAspectFit
        secureTextButton1.addTarget(self, action: #selector(self.hideOldPassword(sender:)), for: .touchUpInside)
        
        let padding : CGFloat = 6
        
        let rightView = UIView(frame: CGRect(
            x: 0, y: 0,
            width: secureTextButton1.frame.width + padding,
            height: secureTextButton1.frame.height))
        rightView.addSubview(secureTextButton1)
        
        self.currentPasswordTF.rightViewMode = .always
        self.currentPasswordTF.rightView = rightView
    }
    
    func setFinishButton() {
        
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
    }
    
    
}
