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

class AddLocListTableViewCell: UITableViewCell {

    weak var delegate: DeleteCellDelegate?
    private var rowTitle: String = ""
    private var rowNumber: Int = 0
    var documentName: String = ""
    
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String, row: Int) {
        self.rowTitle = title
        self.rowNumber = row
        cellTextLabel.text = title
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(with: rowTitle, row: rowNumber)
    }
    
}
