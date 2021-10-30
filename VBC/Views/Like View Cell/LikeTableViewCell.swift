//
//  LikeTableViewCell.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit

class LikeTableViewCell: UITableViewCell {

    // Like and Dislike
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var dislikeImage: UIImageView!
    
    // Name and Comment
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
