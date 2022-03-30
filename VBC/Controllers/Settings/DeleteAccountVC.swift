//
//  DeleteAccountVC.swift
//  VBC
//
//  Created by VELJKO on 27.3.22..
//

import UIKit
import Firebase
import Lottie

class DeleteAccountVC: UIViewController {

    private let animationStackView : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let text1 : UITextView = { () -> UITextView in
       let text = UITextView()
        text.text = "Are you sure that you want to delete account?"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.textAlignment = .center
        text.backgroundColor = .clear
        text.isEditable = false
        text.isScrollEnabled = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        return text
    }()
    
    private let text2 : UITextView = { () -> UITextView in
       let text = UITextView()
        text.text = "If you delete your account \n all your cards and data will be lost."
        text.font = UIFont.systemFont(ofSize: 16)
        text.textAlignment = .center
        text.backgroundColor = .clear
        text.isEditable = false
        text.isScrollEnabled = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        return text
    }()
    
    private lazy var deleteButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Delete Account", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(deleteAccountPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
       return button
    }()
    
    let user = Auth.auth().currentUser
    var animationView : AnimationView?
    var deleteAccount : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationStackView)
        view.addSubview(text1)
        view.addSubview(text2)
        view.addSubview(deleteButton)
        
        setAnimationStackView()
        setTextView()
        setDeleteButton()
    }
    
    @objc func deleteAccountPressed() {
        performSegue(withIdentifier: Constants.Segue.confirmDeleteSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.confirmDeleteSegue {
            
            let destinationVC = segue.destination as! ConfirmChangesVC
            destinationVC.deleteAccount = deleteAccount
        }
    }


}

// MARK: - UI Settings

extension DeleteAccountVC {

    func setAnimationStackView() {
    
        animationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        animationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationStackView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        animationStackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        animationView = AnimationView(name: "warning")
    
        animationView?.contentMode = .scaleAspectFit
        animationView?.center = self.view.center
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationStackView.addArrangedSubview(animationView!)
        animationView?.play()
        animationView?.loopMode = .loop
        animationView?.animationSpeed = 0.6
    }
    
    func setTextView() {

        text1.topAnchor.constraint(equalTo: animationStackView.bottomAnchor, constant: 100).isActive = true
        text1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        text1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        text2.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20).isActive = true
        text2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        text2.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }
    
    func setDeleteButton() {

        deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        deleteButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
}
