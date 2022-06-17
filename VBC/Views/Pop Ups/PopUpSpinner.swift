//
//  PopUp Spinner.swift
//  VBC
//
//  Created by VELJKO on 16.5.22..
//

import UIKit

class PopUpSpinner: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }

    var popUpView = UIView()
    
    // PopUp Spiner
    let spinner = UIActivityIndicatorView()
    let pleaseWaitLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Please Wait..."
        label.textColor = UIColor(named: "Background Color")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
    
        return label
    }()
    
    // Pop Up with Blur and Spinner
    func spinnerWithBlur() {
        
        addSubview(popUpView)
        popUpView.addSubview(spinner)
        popUpView.addSubview(pleaseWaitLabel)
        
        popUpView.backgroundColor = UIColor(named: "Color DO")
        popUpView.layer.cornerRadius = self.bounds.height / 30
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        popUpView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        popUpView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        popUpView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        spinner.color = UIColor(named: "Background Color")
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 5).isActive = true
        pleaseWaitLabel.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
        pleaseWaitLabel.leftAnchor.constraint(equalTo: popUpView.leftAnchor).isActive = true
        pleaseWaitLabel.rightAnchor.constraint(equalTo: popUpView.rightAnchor).isActive = true
        pleaseWaitLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 5).isActive = true
        
        animateIn(forView: popUpView)
        
        spinner.startAnimating()
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
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            forView.alpha = 0
        } completion: { _ in
            mainView.removeFromSuperview()
        }
    }

    
}
