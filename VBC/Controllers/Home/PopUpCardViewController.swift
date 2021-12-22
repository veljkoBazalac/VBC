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
    
    var callPressed : Bool = false
    var emailPressed : Bool = false
    var websitePressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print(callPressed,emailPressed,websitePressed)
        
        print(phoneNumbersList, emailAddressList, websiteList)
        
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if callPressed == true {
        return phoneNumbersList.count
        } else if emailPressed == true {
            return emailAddressList.count
        } else {
            return websiteList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        if callPressed == true {
            cell.cellTextLabel.text = "\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"
        } else if emailPressed == true {
        cell.cellTextLabel.text = emailAddressList[indexPath.row]
        } else {
        cell.cellTextLabel.text = websiteList[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if callPressed == true {
            if let phoneNumber = URL(string:"tel://\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"), UIApplication.shared.canOpenURL(phoneNumber) {
                        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
                    }
        } else if emailPressed == true {
            if let email = URL(string:"mailto://\(emailAddressList[indexPath.row])"), UIApplication.shared.canOpenURL(email) {
                        UIApplication.shared.open(email, options: [:], completionHandler: nil)
                    }
        } else {
            //Open Safari and Go to Website.
            guard let url = URL(string: "https://\(websiteList[indexPath.row])") else { return }
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        
        }
        
    }
    
    
    


}
