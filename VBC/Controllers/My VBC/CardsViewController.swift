//
//  myVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit

class CardsViewController: UIViewController {


    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: Constants.Segue.addVBC, sender: self)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        
    }
    
}

extension CardsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        cell.nameLabel.text = "Legend Kraljevo"
        cell.workLabel.text = "Prodaja"
        cell.workTwoLabel.text = "Odeca"
        cell.cityLabel.text = "Kraljevo"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.viewCard, sender: self)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
////        if segue.identifier == Constants.Segue.viewCard {
////            let destinationVC = segue.destination as! CardViewController
////
////            if let indexPath = tableView.indexPathForSelectedRow {
////
////                destinationVC.nameLabel.text = "Legend Kraljevo"
////                destinationVC.workLabel.text = "Prodaja"
////                destinationVC.workTwoLabel.text = "Garderoba"
////                destinationVC.cityLabel.text = "Kraljevo"
////
////            }
////
////        }
//
//    }
    
    
}
