//
//  AddLocListTableViewCell.swift
//  VBC
//
//  Created by VELJKO on 15.11.21..
//

import UIKit

protocol AddListCellDelegate: AnyObject {
    func deleteButtonPressed(with title: String)
}

class AddLocListTableViewCell: UITableViewCell {

    weak var delegate: AddListCellDelegate?
    private var rowTitle: String = ""
    var documentName: String = ""
    
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String) {
        self.rowTitle = title
        cellTextLabel.text = title
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(with: rowTitle)
    }
    
}
