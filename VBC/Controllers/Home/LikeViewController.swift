//
//  LikeViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase

class LikeViewController: UIViewController {

    //Table View Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // Text and Image Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    // Like and Follow Numbers Outlets
    @IBOutlet weak var followNumber: UILabel!
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var dislikeNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.likeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.likeCell)
        
        
    }
    


}


extension LikeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.likeCell, for: indexPath) as! LikeTableViewCell
        
        cell.nameLabel.text = "Pero"
        cell.dislikeImage.alpha = 0
        cell.commentTextView.text = "Ovo je jedna sjajna firma! Svaka cast na profesionalnosti! 5+"
        
        
        return cell
    }
    
    
    
}
