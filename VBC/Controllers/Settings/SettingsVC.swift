//
//  SettingsVC.swift
//  VBC
//
//  Created by VELJKO on 7.3.22..
//

import UIKit
import Firebase
import MessageUI

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

struct Section {
    let title: String
    let options:[SettingsOption]
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let emailLabel : UILabel = { () -> UILabel in
        // Current Auth User ID
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var logOutButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.addTarget(self, action: #selector(logOutPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let tableView : UITableView = { () -> UITableView in
        let table = UITableView()
        table.backgroundColor = UIColor.systemRed
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SettingsCell.self, forCellReuseIdentifier: Constants.Cell.settingsCell)
        return table
    }()
    
    let user = Auth.auth().currentUser
    
    var models = [Section]()
    
    var changeEmailPressed : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        title = "Settings"
        view.addSubview(tableView)
        view.addSubview(emailLabel)
        view.addSubview(logOutButton)
        tableView.delegate = self
        tableView.dataSource = self
        
        setEmailLabel()
        setLogOutButton()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailLabel.text = user?.email
    }
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.emailPasswordSegue {
            
            let destinationVC = segue.destination as! ChangeEmailOrPasswordVC
            destinationVC.changeEmail = changeEmailPressed
        }
    }

    // MARK: - Log Out Button Pressed
    
    @objc func logOutPressed() {
        
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.welcomeVC)
            self.view.window!.rootViewController = initialViewController
        } catch {
            PopUp().popUpWithOk(newTitle: "Log Out Error",
                                newMessage: "Please check your internet connection and try again.",
                                vc: self)
        }
    }
    
    // MARK: - Configure Table View Sections and Cells
    func configure() {
        
        // Section 1
        models.append(Section(title: "Account", options: [
            SettingsOption(title: "Change Email Address", icon: UIImage(named: "Serbia"), iconBackgroundColor: .systemPink) {
                self.changeEmailPressed = true
                self.performSegue(withIdentifier: Constants.Segue.emailPasswordSegue, sender: self)
            },
            
            SettingsOption(title: "Change Password", icon: UIImage(named: "Austria"), iconBackgroundColor: .systemGreen) {
                self.changeEmailPressed = false
                self.performSegue(withIdentifier: Constants.Segue.emailPasswordSegue, sender: self)
            },
            
            SettingsOption(title: "Delete Account", icon: UIImage(named: "LogoImage"), iconBackgroundColor: .systemGreen) {
                self.performSegue(withIdentifier: Constants.Segue.deleteAccountSegue, sender: self)
            }
            
            
        ]))
        
        // Section 2
        models.append(Section(title: "Application", options: [
            
            SettingsOption(title: "Contact Us", icon: UIImage(named: "Austria"), iconBackgroundColor: .systemGreen) {
                EmailComposer().showEmailComposer(recipient: "solosoft.serbia@gmail.com",
                                                  subject: "VBC - \(self.user?.email ?? "Your Email here...")",
                                                  body: "Dear VBC Team,\n\n",
                                                  delegate: self,
                                                  vc: self)
            },
            
            SettingsOption(title: "About VBC", icon: UIImage(named: "Austria"), iconBackgroundColor: .systemGreen) {
                self.performSegue(withIdentifier: Constants.Segue.aboutVBCSegue, sender: self)
            }
        ]))
    }
    
} //

// MARK: - Contact US open Mail

extension SettingsVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let e = error {
            print("Error Finish with. \(e)")
            return
        }
        
        switch result {
        case .sent:
            PopUp().quickPopUp(newTitle: "Email Sent",
                               newMessage: "We will respond as quickly as possible.",
                               vc: controller,
                               numberOfSeconds: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                controller.dismiss(animated: true)
            }
        case .failed:
            PopUp().quickPopUp(newTitle: "Email Failed",
                               newMessage: "Please check your connection and try again.",
                               vc: controller,
                               numberOfSeconds: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                controller.dismiss(animated: true)
            }
        case .cancelled:
            PopUp().quickPopUp(newTitle: "Email Cancelled",
                               newMessage: "Be free to Contact Us if you have some questions.",
                               vc: controller,
                               numberOfSeconds: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                controller.dismiss(animated: true)
            }
        case .saved :
            PopUp().quickPopUp(newTitle: "Email Saved",
                               newMessage: "Your Email is saved in Drafts.",
                               vc: controller,
                               numberOfSeconds: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                controller.dismiss(animated: true)
            }
        default:
            PopUp().quickPopUp(newTitle: "Error",
                               newMessage: "Oops, Please try again...",
                               vc: controller,
                               numberOfSeconds: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                controller.dismiss(animated: true)
            }
        }
    }

}

// MARK: - Table View Methods

extension SettingsVC {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath) as! SettingsCell
        
        cell.backgroundColor = UIColor.clear
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    
}

// MARK: - UI Settings

extension SettingsVC {
    
    private func setEmailLabel() {
        
        emailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        emailLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
    }
    
    private func setLogOutButton() {
        
        logOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30).isActive = true
        logOutButton.centerXAnchor.constraint(equalTo: emailLabel.centerXAnchor).isActive = true
    }
    
    private func setTableView() {
        
        tableView.backgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.red
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        tableView.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: 40).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
    }
    
}
