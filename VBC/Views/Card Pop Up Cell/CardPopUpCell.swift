//
//  CardPopUpCell.swift
//  VBC
//
//  Created by VELJKO on 22.12.21..
//

import UIKit

class CardPopUpCell: UITableViewCell {

    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        
        UIPasteboard.general.string = cellTextLabel.text
        copyButton.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
        copyButton.tintColor = UIColor.systemGreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
            self.copyButton.tintColor = UIColor(named: "Color Blue")
        }
    }
}
