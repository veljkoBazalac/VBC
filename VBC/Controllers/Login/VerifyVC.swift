//
//  VerifyViewController.swift
//  VBC
//
//  Created by VELJKO on 28.10.21..
//

import UIKit
import Firebase
import Lottie

class VerifyVC: UIViewController {
    
    private let animationStackView : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let text1 : UITextView = { () -> UITextView in
       let text = UITextView()
        text.text = "E-mail verification has been sent. \n Please verify your E-mail address."
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
        text.text = "Did NOT recevied an E-mail? \n Check your Spam or Send Again."
        text.font = UIFont.systemFont(ofSize: 16)
        text.textAlignment = .center
        text.backgroundColor = .clear
        text.isEditable = false
        text.isScrollEnabled = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        return text
    }()
    
    private let buttonsStackView : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 30
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var sendAgainButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Send Again", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderColor = CGColor(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendAgainButtonPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var continueButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(continueButtonPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
       return button
    }()
    
    let user = Auth.auth().currentUser
    var animationView : AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationStackView)
        view.addSubview(text1)
        view.addSubview(text2)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(sendAgainButton)
        buttonsStackView.addArrangedSubview(continueButton)
        
        setAnimationStackView()
        setTextStackView()
        setButtonsStackView()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Send Email Verification Function
    func sendVerificationMail() {
        
        if user != nil && user!.isEmailVerified == false {
            user?.sendEmailVerification(completion: { (error) in
                if error != nil {
                    // Error sending Email verification
                    PopUp().quickPopUp(newTitle: "Verification failed",
                                       newMessage: "Email verification error. Check your internet connection and try again.",
                                       vc: self,
                                       numberOfSeconds: 2)
                    print(error)
                } else {
                    // Email verification sent again
                    PopUp().quickPopUp(newTitle: "Email Verification Sent",
                                       newMessage: "",
                                       vc: self,
                                       numberOfSeconds: 1.5)
                }
            })
        }
    }
    
    // MARK: - Send Again Button Pressed
    @objc func sendAgainButtonPressed(_ sender: UIButton) {
        sendVerificationMail()
    }
    
    // MARK: - Continue Button Pressed
    @objc func continueButtonPressed(_ sender: UIButton) {
        
        user?.reload(completion: { error in
            
            if self.user?.isEmailVerified == false {
                // Error sending Email verification
                PopUp().popUpWithOk(newTitle: "Email is NOT verified.",
                                    newMessage: "Check your Email and then try again.",
                                    vc: self)
            }
            else {
                self.performSegue(withIdentifier: Constants.Segue.verifyToHome, sender: self)
            }
        })
    }
}

// MARK: - UI Settings

extension VerifyVC {

    func setAnimationStackView() {
    
        animationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        animationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationStackView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        animationStackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        animationView = AnimationView(name: "verifySend")
    
        animationView?.contentMode = .scaleAspectFit
        animationView?.center = self.view.center
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationStackView.addArrangedSubview(animationView!)
        animationView?.play()
        animationView?.loopMode = .playOnce
        animationView?.animationSpeed = 0.8
    }
    
    func setTextStackView() {

        text1.topAnchor.constraint(equalTo: animationStackView.bottomAnchor, constant: 100).isActive = true
        text1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        text1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        text2.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20).isActive = true
        text2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        text2.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }
    
    func setButtonsStackView() {

        buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -20).isActive = true
        buttonsStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                               constant: 50).isActive = true
        buttonsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                constant: -50).isActive = true
    }
    
}
