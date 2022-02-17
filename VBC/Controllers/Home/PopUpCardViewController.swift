//
//  PopUpCardViewController.swift
//  VBC
//
//  Created by VELJKO on 16.12.21..
//

import UIKit
import SafariServices

class PopUpCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var popUpTitle : String?
    var phoneNumbersList : [PhoneNumber] = []
    var emailAddressList : [String] = []
    var websiteList : [String] = []
    var socialMediaList : [SocialMedia] = []
    
    var callPressed : Bool = false
    var emailPressed : Bool = false
    var websitePressed : Bool = false
    var socialPressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.popUpCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.popUpCell)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    // MARK: - Pop Up With Ok
    
    func popUpWithOk(newTitle: String, newMessage: String) {
        // Pop Up with OK button
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if callPressed == true {
        return phoneNumbersList.count
        } else if emailPressed == true {
            return emailAddressList.count
        } else if websitePressed == true {
            return websiteList.count
        } else {
            return socialMediaList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.popUpCell, for: indexPath) as! CardPopUpCell
        
        if callPressed == true {
            cell.cellTextLabel.text = "\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"
        } else if emailPressed == true {
            cell.cellTextLabel.text = emailAddressList[indexPath.row]
        } else if websitePressed == true {
            cell.cellTextLabel.text = websiteList[indexPath.row]
        } else {
            cell.cellTextLabel.text = socialMediaList[indexPath.row].name
            cell.copyButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if callPressed == true {
            if let phoneNumber = URL(string:"tel://\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"), UIApplication.shared.canOpenURL(phoneNumber) {
                        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
                    }
        } else if emailPressed == true {
            if let email = URL(string:"mailto:\(emailAddressList[indexPath.row])"), UIApplication.shared.canOpenURL(email) {
                        UIApplication.shared.open(email, options: [:], completionHandler: nil)
                    }
        } else if websitePressed == true {
            //Open Safari and Go to Website.
            guard let url = URL(string: "https://\(websiteList[indexPath.row])") else { return }
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        
        } else {
            
            let link = socialMediaList[indexPath.row].link.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if socialMediaList[indexPath.row].name == "Instagram" {
                
                    let appInsta = URL(string: "instagram://user?username=\(link)")!
                guard let webInsta = URL(string: "https://www.instagram.com/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "Instagram Link does NOT work or that user does NOT exist.")
                    return
                }

                    if UIApplication.shared.canOpenURL(appInsta) {
                            UIApplication.shared.open(appInsta, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.open(webInsta, options: [:], completionHandler: nil)
                    }
                
            } else if socialMediaList[indexPath.row].name == "TikTok" {
                
                guard let tikTok = URL(string: "https://www.tiktok.com/@\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "TikTok Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(tikTok) {
                    UIApplication.shared.open(tikTok, options: [:], completionHandler: nil)
                } else {
                    print("TikTok not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "Viber" {
                
                guard let viber = URL(string: "viber://contact?number=\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "Viber Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(viber) {
                    UIApplication.shared.open(viber, options: [:], completionHandler: nil)
                } else {
                    print("Viber not working")
                }
                
            } else if socialMediaList[indexPath.row].name == "WhatsApp" {
                
                guard let wa = URL(string: "whatsapp://send?phone=\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "WhatsApp Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(wa) {
                    UIApplication.shared.open(wa, options: [:], completionHandler: nil)
                } else {
                    print("WhatsApp not working")
                }
                
            } else if socialMediaList[indexPath.row].name == "Facebook" {
                
                let appFb = URL(string: "fb://profile/\(link)")!
                guard let webFb = URL(string: "https://www.facebook.com/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "Facebook Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(appFb) {
                    UIApplication.shared.open(appFb, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(webFb, options: [:], completionHandler: nil)
                }
                
            } else if socialMediaList[indexPath.row].name == "Twitter" {
                
                let appTwt = URL(string: "twitter://user?screen_name=\(link)")!
                let webTwt = URL(string: "https://twitter.com/\(link)")!
                
                if UIApplication.shared.canOpenURL(appTwt) {
                    UIApplication.shared.open(appTwt, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(webTwt, options: [:], completionHandler: nil)
                }
                
            } else if socialMediaList[indexPath.row].name == "LinkedIn" {
                
                guard let li = URL(string: "https://www.linkedin.com/in/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "LinkedIn Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(li) {
                    UIApplication.shared.open(li, options: [:], completionHandler: nil)
                } else {
                    popUpWithOk(newTitle: "Can NOT open Link", newMessage: "LinkedIn Link does NOT work or that user does NOT exist.")
                }
            } else if socialMediaList[indexPath.row].name == "Pinterest" {
                
                guard let pint = URL(string: "https://www.pinterest.com/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "Pinterest Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(pint) {
                    UIApplication.shared.open(pint, options: [:], completionHandler: nil)
                } else {
                    print("Pinterest not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "GitHub" {
                
                guard let gh = URL(string: "https://www.github.com/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "GitHub Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(gh) {
                    UIApplication.shared.open(gh, options: [:], completionHandler: nil)
                } else {
                    print("GitHub not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "YouTube" {
                
                guard let yt = URL(string: "https://www.youtube.com/channel/\(link)") else {
                    popUpWithOk(newTitle: "Link does NOT work", newMessage: "YouTube Link does NOT work or that user does NOT exist.")
                    return
                }
                
                if UIApplication.shared.canOpenURL(yt) {
                    UIApplication.shared.open(yt, options: [:], completionHandler: nil)
                } else {
                    print("YouTube not installed")
                }
                
            }
            
            
        }
    }
}
