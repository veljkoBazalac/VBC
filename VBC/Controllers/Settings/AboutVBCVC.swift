//
//  AboutVBCVC.swift
//  VBC
//
//  Created by VELJKO on 1.4.22..
//

import UIKit
import MessageUI
import Firebase

class AboutVBCVC: UIViewController, MFMailComposeViewControllerDelegate {

    private let imageView : UIImageView = { () -> UIImageView in
       let imageView = UIImageView()
        imageView.image = UIImage(named: "LogoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let text1 : UITextView = { () -> UITextView in
        let text = UITextView()
        text.text = "About VBC"
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
        text.text = "VBC - Virtual Business Card is application created by Solomon Software.\nVBC is created with idea to help connections between Companies and Business People more easily. Our app allow users to connect with others in just few steps. \n\nCreating Virtual Business Card is very simple and it can be created for both Single Place or Multiple Places, based on Company's or Person's locations.\n \nIf you have any questions, be free to Contact Us."
        text.font = UIFont.systemFont(ofSize: 16)
        text.textAlignment = .left
        text.backgroundColor = .clear
        text.isEditable = false
        text.isScrollEnabled = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        return text
    }()
    
    let user = Auth.auth().currentUser
    
    private lazy var contactButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Contact Us", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(contactUsPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        view.addSubview(text1)
        view.addSubview(text2)
        view.addSubview(contactButton)
        
        setTextView()
        setImageView()
        setContactButton()
    }
    
    @objc func contactUsPressed() {
        EmailComposer().showEmailComposer(recipient: "solosoft.serbia@gmail.com",
                                          subject: "VBC - \(self.user?.email ?? "Your Email here...")",
                                          body: "Dear VBC Team,\n\n",
                                          delegate: self,
                                          vc: self)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let e = error {
            print("Error Finish with. \(e)")
            return
        }
        
        controller.dismiss(animated: true)
        
    }
    
}

extension AboutVBCVC {
    
    func setImageView() {
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 80).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -80).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    func setTextView() {
        
        text1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40).isActive = true
        text1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        text1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        text2.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20).isActive = true
        text2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        text2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
    }
    
    func setContactButton() {
        contactButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        contactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contactButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        contactButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
}
