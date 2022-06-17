//
//  SettingsCell.swift
//  VBC
//
//  Created by VELJKO on 7.3.22..
//

import UIKit

class SettingsCell: UITableViewCell {
    
    private let iconContainer: UIView = { () -> UIView in
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = { () -> UIImageView in
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = { () -> UILabel in
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor(named: "Reverse Background Color")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 15
        iconContainer.frame = CGRect(x: 15, y: 8, width: size, height: size)
        
        let imageSize: CGFloat = size / 1.5
        iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)
        
        label.frame = CGRect(x: 25 + iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width - 20 - iconContainer.frame.size.width - 10,
                             height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    public func configure(with model: SettingsOption) {
        contentView.backgroundColor = UIColor.clear
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
    }
    
    
    
}
