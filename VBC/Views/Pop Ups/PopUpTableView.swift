//
//  PopUpTableView1.swift
//  VBC
//
//  Created by VELJKO on 9.5.22..
//

import UIKit
import MessageUI
import SafariServices

class PopUpTableView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    // MARK: - Var and Let
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let blurEffectView = UIVisualEffectView()
    var popUpView = UIView()
    
    // Pop Up with TableView and Ok Button
    var popUpTableView : UITableView = { () -> UITableView in
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.separatorColor = UIColor(named: "Color Dark Blue")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset.left = 15
        tableView.separatorInset.right = 15
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        
        return tableView
    }()
    // Pop Up Title
    var popUpTitle : UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(named: "Color DO")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    // Pop Up Back Button
    lazy var backButton : UIButton = { () -> UIButton in
        let button = UIButton()
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor(named: "Background Color"), for: .normal)
        button.backgroundColor = UIColor(named: "Color DO")
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: -  Pop Up With TableView and Ok Button
    func popUpWithTableView(vc: UIViewController, rows: Int, type: String, nibName: String, cellIdentifier: String) {
        
        popUpTableView.delegate = vc as? UITableViewDelegate
        popUpTableView.dataSource = vc as? UITableViewDataSource
        popUpTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        addSubview(blurEffectView)
        addSubview(popUpView)
        popUpView.addSubview(popUpTitle)
        popUpView.addSubview(popUpTableView)
        popUpView.addSubview(backButton)
        
        switch type {
        case "Phone":
            if rows == 1 {
                popUpTitle.text = "Phone Number"
            } else {
                popUpTitle.text = "Phone Numbers"
            }
        case "Email":
            if rows == 1 {
                popUpTitle.text = "Email Address"
            } else {
                popUpTitle.text = "Email Addresses"
            }
        case "Website":
            if rows == 1 {
                popUpTitle.text = "Website Link"
            } else {
                popUpTitle.text = "Website Link"
            }
        case "Social":
            popUpTitle.text = "Social Media"
        case "Location":
            if rows == 1 {
                popUpTitle.text = "Location"
            } else {
                popUpTitle.text = "Locations"
            }
        default:
            popUpTitle.text = "Error"
        }
        
        switch rows {
        case 1:
            popUpView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        case 2:
            popUpView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        case 3:
            popUpView.heightAnchor.constraint(equalToConstant: 270).isActive = true
        case 4:
            popUpView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        case 5:
            popUpView.heightAnchor.constraint(equalToConstant: 370).isActive = true
        case 5...:
            popUpView.heightAnchor.constraint(equalToConstant: 420).isActive = true
            popUpTableView.isScrollEnabled = true
        default:
            popUpView.heightAnchor.constraint(equalToConstant: 420).isActive = true
        }
        
        blurEffectView.effect = blurEffect
        blurEffectView.bounds = self.bounds
        blurEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurEffectView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        popUpView.backgroundColor = UIColor(named: "Background Color")
        popUpView.layer.cornerRadius = self.bounds.height / 50
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        popUpView.widthAnchor.constraint(equalToConstant: self.bounds.width * 0.7).isActive = true
        
        popUpTitle.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 10).isActive = true
        popUpTitle.leftAnchor.constraint(equalTo: popUpView.leftAnchor).isActive = true
        popUpTitle.rightAnchor.constraint(equalTo: popUpView.rightAnchor).isActive = true
        popUpTitle.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true

        popUpTableView.topAnchor.constraint(equalTo: popUpTitle.bottomAnchor, constant: 20).isActive = true
        popUpTableView.leftAnchor.constraint(equalTo: popUpView.leftAnchor).isActive = true
        popUpTableView.rightAnchor.constraint(equalTo: popUpView.rightAnchor).isActive = true

        backButton.topAnchor.constraint(equalTo: popUpTableView.bottomAnchor, constant: 20).isActive = true
        backButton.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor, constant: -15).isActive = true
        backButton.centerXAnchor.constraint(equalTo: popUpTableView.centerXAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    
        animateIn(forView: popUpView)
    }
    
    func rowDeleted(numberOfRows: Int) {
        DispatchQueue.main.async {
            self.popUpTableView.reloadData()
            
            switch numberOfRows {
            case 1:
                self.popUpView.heightAnchor.constraint(equalToConstant: 170).isActive = true
            case 2:
                self.popUpView.heightAnchor.constraint(equalToConstant: 220).isActive = true
            case 3:
                self.popUpView.heightAnchor.constraint(equalToConstant: 270).isActive = true
            case 4:
                self.popUpView.heightAnchor.constraint(equalToConstant: 320).isActive = true
            case 5:
                self.popUpView.heightAnchor.constraint(equalToConstant: 370).isActive = true
            case 5...:
                self.popUpView.heightAnchor.constraint(equalToConstant: 420).isActive = true
                self.popUpTableView.isScrollEnabled = true
            default:
                self.popUpView.heightAnchor.constraint(equalToConstant: 370).isActive = true
            }
            
        }
    }
    
    // Animate In PopUp View
    func animateIn(forView: UIView) {
        forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        forView.alpha = 0
        forView.center = self.center
        
        UIView.animate(withDuration: 0.3, animations: {
            forView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            forView.alpha = 1
        })
    }
    
    // Animate Out PopUp View
    func animateOut(forView: UIView, mainView: UIView) {
        UIView.animate(withDuration: 0.3) {
            forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            forView.alpha = 0
        } completion: { _ in
            mainView.removeFromSuperview()
        }
    }

}
