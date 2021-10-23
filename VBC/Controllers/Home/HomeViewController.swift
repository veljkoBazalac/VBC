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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func languageButtonPressed(_ sender: UIButton) {
     
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        
    }
    
}
//
//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
//
//}

