//
//  ViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
    }
    
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func languageButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
              try Auth.auth().signOut()
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  self.navigationController?.popToRootViewController(animated: true)
              }
          } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
          }
    }
    
    
}

// MARK: - TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        cell.nameLabel.text = "Metalac AD"
        cell.sectorLabel.text = "Bela Tehnika"
        cell.productTypeLabel.text = "Bojleri"
        cell.countryLabel.text = "Gornji Milanovac"
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.homeToCard, sender: self)
        
    }

}

