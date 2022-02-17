//
//  AddLocListTableViewCell.swift
//  VBC
//
//  Created by VELJKO on 15.11.21..
//

import UIKit

protocol DeleteCellDelegate: AnyObject {
    func deleteButtonPressed(with title: String, row: Int)
}

protocol EditCellDelegate: AnyObject {
    func editButtonPressed(city: String, street: String, map: String)
}

class AddLocListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mapIcon: UIImageView!
    
    weak var delegate: DeleteCellDelegate?
    weak var delegate2: EditCellDelegate?
    private var rowTitle: String = ""
    private var rowNumber: Int = 0
    private var cityName: String = ""
    private var streetName: String = ""
    private var gMapsLink: String = ""
    var documentName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(city: String, street: String, map: String, row: Int) {
        self.rowTitle = "\(city) - \(street)"
        self.rowNumber = row
        self.cityName = city
        self.streetName = street
        self.gMapsLink = map
        cellTextLabel.text = "\(city) - \(street)"
        
        if map == "" {
            mapIcon.isHidden = true
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate2?.editButtonPressed(city: cityName, street: streetName, map: gMapsLink)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(with: rowTitle, row: rowNumber)
    }
    
}
