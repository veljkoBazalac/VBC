//
//  ContactListCell.swift
//  VBC
//
//  Created by VELJKO on 16.2.22..
//

import UIKit

protocol DeleteCellDelegate: AnyObject {
    func deleteButtonPressed(with title: String, row: Int)
}

class ContactListCell: UITableViewCell {

    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    private var rowTitle: String = ""
    private var rowNumber: Int = 0
    
    weak var delegate: DeleteCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: String, row: Int) {
        self.rowTitle = title
        self.rowNumber = row
        contactLabel.text = title
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(with: rowTitle, row: rowNumber)
    }
}
