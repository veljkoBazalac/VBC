//
//  ChangeEmailVC.swift
//  VBC
//
//  Created by VELJKO on 7.3.22..
//

import UIKit
import Lottie


class ChangeEmailOrPasswordVC: UIViewController, UITextFieldDelegate {
    
    let stackViewForAnimation : UIStackView = { () -> UIStackView in
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let stackView1 : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 30
        stack.frame.size.height = 300
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    let newEmailOrPassLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "New Email Address"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let newEmailOrPassTF : UITextField = { () -> UITextField in
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 15)
        field.borderStyle = UITextField.BorderStyle.roundedRect
        field.autocorrectionType = UITextAutocorrectionType.no
        field.keyboardType = UIKeyboardType.default
        field.returnKeyType = UIReturnKeyType.done
        field.clearButtonMode = UITextField.ViewMode.whileEditing
        field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        field.placeholder = "Enter New Email Address..."
        field.textAlignment = .center
        field.clearsOnBeginEditing = false
        field.autocapitalizationType = .none
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        
        return field
    }()
    
    let stackView2 : UIStackView = { () -> UIStackView in
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 30
        stack.frame.size.height = 300
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    let repeatEmailOrPassLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Repeat Email Address"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let repeatEmailOrPassTF : UITextField = { () -> UITextField in
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 15)
        field.borderStyle = UITextField.BorderStyle.roundedRect
        field.autocorrectionType = UITextAutocorrectionType.no
        field.keyboardType = UIKeyboardType.default
        field.returnKeyType = UIReturnKeyType.done
        field.clearButtonMode = UITextField.ViewMode.whileEditing
        field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        field.placeholder = "Repeat New Email Address..."
        field.textAlignment = .center
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        
        return field
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
    var changeEmail : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEmailOrPassTF.delegate = self
        repeatEmailOrPassTF.delegate = self
        
        view.addSubview(stackViewForAnimation)
        view.addSubview(finishButton)
        view.addSubview(stackView1)
        stackView1.addArrangedSubview(newEmailOrPassLabel)
        stackView1.addArrangedSubview(newEmailOrPassTF)
        view.addSubview(stackView2)
        stackView2.addArrangedSubview(repeatEmailOrPassLabel)
        stackView2.addArrangedSubview(repeatEmailOrPassTF)
        
        setStackViewForAnimation()
        setStackView1()
        setStackView2()
        setFinishButton()
        
        if changeEmail == false {
            newEmailOrPassLabel.text = "New Password"
            newEmailOrPassTF.isSecureTextEntry = true
            repeatEmailOrPassLabel.text = "Repeat New Password"
            repeatEmailOrPassTF.isSecureTextEntry = true
            setSecureTextButton1()
            setSecureTextButton2()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setAnimation()
    }
    
    // MARK: - Hide Text in New Password Text Field
    
    @objc func hideNewPassword(sender: AnyObject) {
        newEmailOrPassTF.isSecureTextEntry.toggle()
        
        if newEmailOrPassTF.isSecureTextEntry == false {
            secureTextButton1.setImage(UIImage(named: "ClosedEye"), for: .normal)
        } else {
            secureTextButton1.setImage(UIImage(named: "OpenEye"), for: .normal)
        }
    }
    
    // MARK: - Hide Text in Repeat Password TextField
    
    @objc func hideRepeatPassword(sender: AnyObject) {
        repeatEmailOrPassTF.isSecureTextEntry.toggle()
        
        if repeatEmailOrPassTF.isSecureTextEntry == false {
            secureTextButton2.setImage(UIImage(named: "ClosedEye"), for: .normal)
        } else {
            secureTextButton2.setImage(UIImage(named: "OpenEye"), for: .normal)
        }
    }
    
    // MARK: - Finish Button Pressed
    
    @objc func finishButtonPressed() {
        
        if newEmailOrPassTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true || repeatEmailOrPassTF.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true  {
            if changeEmail == true {
                popUpWithOk(newTitle: "Email text fields EMPTY", newMessage: "Please Enter your Email Address.")
            } else {
                popUpWithOk(newTitle: "Password text fields EMPTY", newMessage: "Please Enter your Password.")
            }
        } else if newEmailOrPassTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) != repeatEmailOrPassTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if changeEmail == true {
                popUpWithOk(newTitle: "Email does NOT match", newMessage: "Please Enter same Email Address.")
            } else {
                popUpWithOk(newTitle: "Password does NOT match", newMessage: "Please Enter same Password.")
            }
        } else if newEmailOrPassTF.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 6 && changeEmail == false {
            popUpWithOk(newTitle: "Short Password", newMessage: "Your Password must be at least 6 characters long.")
        } else {
            performSegue(withIdentifier: Constants.Segue.confirmSegue, sender: self)
        }
    }
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.confirmSegue {
            
            let destinationVC = segue.destination as! ConfirmChangesVC
            
            destinationVC.emailChanged = changeEmail
            if changeEmail == true {
                destinationVC.emailForChange = newEmailOrPassTF.text!
            } else {
                destinationVC.passwordForChange = newEmailOrPassTF.text!
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

extension ChangeEmailOrPasswordVC {
    
    func setAnimation() {
        
        if changeEmail == true {
            animationView = AnimationView(name: "email")
        } else {
            animationView = AnimationView(name: "password")
        }
        
        animationView?.contentMode = .scaleAspectFit
        animationView?.center = self.view.center
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        stackViewForAnimation.addArrangedSubview(animationView!)
        animationView?.play()
        animationView?.loopMode = .loop
        animationView?.animationSpeed = 0.5

    }
    
    func setStackViewForAnimation() {
        
        stackViewForAnimation.translatesAutoresizingMaskIntoConstraints = false
        stackViewForAnimation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stackViewForAnimation.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackViewForAnimation.heightAnchor.constraint(equalTo: stackViewForAnimation.widthAnchor).isActive = true
        stackViewForAnimation.bottomAnchor.constraint(equalTo: stackView1.topAnchor, constant: -50).isActive = true
    }
    
    func setSecureTextButton1() {
        
        secureTextButton1.setImage(UIImage(named: "OpenEye"), for: .normal)
        secureTextButton1.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        secureTextButton1.imageView?.contentMode = .scaleAspectFit
        secureTextButton1.addTarget(self, action: #selector(self.hideNewPassword(sender:)), for: .touchUpInside)
        
        let padding : CGFloat = 6
        
        let rightView = UIView(frame: CGRect(
            x: 0, y: 0,
            width: secureTextButton1.frame.width + padding,
            height: secureTextButton1.frame.height))
        rightView.addSubview(secureTextButton1)
        
        self.newEmailOrPassTF.rightViewMode = .always
        self.newEmailOrPassTF.rightView = rightView
    }
    
    func setSecureTextButton2() {
        
        secureTextButton2.setImage(UIImage(named: "OpenEye"), for: .normal)
        secureTextButton2.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        secureTextButton2.imageView?.contentMode = .scaleAspectFit
        secureTextButton2.addTarget(self, action: #selector(self.hideRepeatPassword(sender:)), for: .touchUpInside)
        
        let padding : CGFloat = 6
        
        let rightView = UIView(frame: CGRect(
            x: 0, y: 0,
            width: secureTextButton2.frame.width + padding,
            height: secureTextButton2.frame.height))
        rightView.addSubview(secureTextButton2)
        
        self.repeatEmailOrPassTF.rightViewMode = .always
        self.repeatEmailOrPassTF.rightView = rightView
    }
    
    func setFinishButton() {
        
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
    }
    
    func setStackView1() {
        
        stackView1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300).isActive = true
        stackView1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        newEmailOrPassLabel.leftAnchor.constraint(equalTo: stackView1.leftAnchor).isActive = true
        newEmailOrPassLabel.rightAnchor.constraint(equalTo: stackView1.rightAnchor).isActive = true
        newEmailOrPassLabel.topAnchor.constraint(equalTo: stackView1.topAnchor).isActive = true
        
        newEmailOrPassTF.centerXAnchor.constraint(equalTo: stackView1.centerXAnchor).isActive = true
        newEmailOrPassTF.leftAnchor.constraint(equalTo: stackView1.leftAnchor, constant: 50).isActive = true
        newEmailOrPassTF.rightAnchor.constraint(equalTo: stackView1.rightAnchor, constant: -50).isActive = true
        newEmailOrPassTF.bottomAnchor.constraint(equalTo: stackView1.bottomAnchor).isActive = true
    }
    
    func setStackView2() {
        
        stackView2.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 30).isActive = true
        stackView2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView2.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        repeatEmailOrPassLabel.leftAnchor.constraint(equalTo: stackView2.leftAnchor).isActive = true
        repeatEmailOrPassLabel.rightAnchor.constraint(equalTo: stackView2.rightAnchor).isActive = true
        repeatEmailOrPassLabel.topAnchor.constraint(equalTo: stackView2.topAnchor).isActive = true
        
        repeatEmailOrPassTF.centerXAnchor.constraint(equalTo: stackView2.centerXAnchor).isActive = true
        repeatEmailOrPassTF.leftAnchor.constraint(equalTo: stackView2.leftAnchor, constant: 50).isActive = true
        repeatEmailOrPassTF.rightAnchor.constraint(equalTo: stackView2.rightAnchor, constant: -50).isActive = true
        repeatEmailOrPassTF.bottomAnchor.constraint(equalTo: stackView2.bottomAnchor).isActive = true
    }
}

