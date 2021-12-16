//
//  PopUpCardViewController.swift
//  VBC
//
//  Created by VELJKO on 16.12.21..
//

import UIKit

class PopUpCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var popUpTitle : String?
    var phoneNumbersList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumbersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        cell.cellTextLabel.text = phoneNumbersList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let phoneNumber = URL(string:"tel://\(phoneNumbersList[indexPath.row])"), UIApplication.shared.canOpenURL(phoneNumber) {
                    UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
                }
    }
    
    
    


}
