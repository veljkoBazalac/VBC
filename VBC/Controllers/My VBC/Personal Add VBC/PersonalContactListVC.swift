//
//  PersonalContactListVC.swift
//  VBC
//
//  Created by VELJKO on 1.1.22..
//

import UIKit

protocol PhoneNumberListDelegate: AnyObject {
    func newPhoneNumberList(list: [PhoneNumber])
    func deletedPhoneNumber(atRow: Int)
}

class PersonalContactListVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var phoneNumbers : [PhoneNumber] = []
    
    weak var delegate : PhoneNumberListDelegate?
    // Card ID
    var cardID : String = ""
    // Pop Up Title
    var popUpTitle : String?
    
    // Var that show which Button is pressed on previous View Controller
    var phoneListPressed : Bool = false
    var emailListPressed : Bool = false
    var websiteListPressed : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.newPhoneNumberList(list: phoneNumbers)
    }
    
}

// MARK: - Delete Table View Cell

extension PersonalContactListVC: DeleteCellDelegate {
        
        func deleteButtonPressed(with title: String, row: Int) {
            
            // Pop Up with Yes and No
            let alert = UIAlertController(title: "Delete?", message: "Are you sure that you want to delete? Data will be lost forever.", preferredStyle: .alert)
            let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
                
                phoneNumbers.remove(at: row)
                tableView.reloadData()
                delegate?.deletedPhoneNumber(atRow: row)
            }
            
            alert.addAction(actionDELETE)
            alert.addAction(actionBACK)
            
            self.present(alert, animated: true, completion: nil)
        }
}

extension PersonalContactListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        phoneNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        cell.configure(with: "\(phoneNumbers[indexPath.row].code) \(phoneNumbers[indexPath.row].number)", row: indexPath.row)
        
        cell.delegate = self
        return cell
    }
    
}
