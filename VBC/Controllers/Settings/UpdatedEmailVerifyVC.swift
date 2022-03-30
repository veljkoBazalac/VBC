//
//  UpdatedEmailVerifyVC.swift
//  VBC
//
//  Created by VELJKO on 24.3.22..
//

import UIKit
import Firebase
import Lottie

class UpdatedEmailVerifyVC: UIViewController {
    
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
    
    private lazy var cancelButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Cancel Changes", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
       return button
    }()
    
    let user = Auth.auth().currentUser
    var animationView : AnimationView?
    var emailForChange : String = ""
    var confirmedPassword : String = ""
    var verificationTimer : Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdatedEmailVerifyVC.checkEmailVerification) , userInfo: nil, repeats: true)
        
        view.addSubview(animationStackView)
        view.addSubview(text1)
        view.addSubview(text2)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(sendAgainButton)
        buttonsStackView.addArrangedSubview(cancelButton)
        
        setAnimationStackView()
        setTextStackView()
        setButtonsStackView()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Check Email Verification
    @objc func checkEmailVerification() {
        
        if user != nil {
            
            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: self.emailForChange,
                                                                          password: self.confirmedPassword)
            
            self.user?.reauthenticate(with: credential , completion: { AuthResult, error in
                if error == nil {
                    
                    self.user?.reload(completion: { error in
                       
                        if error == nil {
                            
                            if self.user!.isEmailVerified {
                                
                                // Successfully Reauthenticate
                                DispatchQueue.main.async {
                                    self.verificationTimer.invalidate()
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                            else {
                                
                                // Error sending Email verification
                                let alert = UIAlertController(title: "Email is NOT verified.", message: "Check your Email and then try again.", preferredStyle: .alert)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.dismiss(animated: true, completion: nil)
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        } else {
                            self.popUpWithOk(newTitle: "Error Reloading", newMessage: "Please check your Internet Connection and try again.")
                        }
                    })
                }
            })
        }
    }
  
    // MARK: - Send Again Button Pressed
    
    @objc func sendAgainButtonPressed(sender: UIButton) {
        
        if user != nil {
            
            user?.sendEmailVerification(beforeUpdatingEmail: self.emailForChange.trimmingCharacters(in: .whitespacesAndNewlines), completion: { (error) in
                
                if error != nil {
                    // Error sending Email verification
                    let alert = UIAlertController(title: "Verification failed", message: "Email verification error. Check your internet connection and try again.", preferredStyle: .alert)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                } else {
                    
                    // Email Verification Sent
                    let alert = UIAlertController(title: "Email Verification has been sent", message: "Please check your Email address.", preferredStyle: .alert)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    // MARK: - Continue Button Pressed
    
    @objc func cancelButtonPressed() {
        if user != nil {
            DispatchQueue.main.async {
                self.verificationTimer.invalidate()
                self.navigationController?.popToRootViewController(animated: true)
            }
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

extension UpdatedEmailVerifyVC {

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
