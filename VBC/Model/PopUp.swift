//
//  PopUp.swift
//  VBC
//
//  Created by VELJKO on 3.4.22..
//

import UIKit


class PopUp: UIView {
    
    // MARK: - Var and Let
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let blurEffectView = UIVisualEffectView()
    var popUpView = UIView()
    
    // PopUp Spiner
    let spinner = UIActivityIndicatorView()
    let pleaseWaitLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Please Wait..."
        label.textColor = UIColor(named: "Reverse Background Color")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
    
        return label
    }()
    
    // MARK: - Functions
    
    // Pop Up with Ok Button
    func popUpWithOk(newTitle: String, newMessage: String, vc: UIViewController) {
        
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionOK)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // Pop Up that dismiss after numberOfSeconds
    func quickPopUp(newTitle: String, newMessage: String, vc: UIViewController, numberOfSeconds: Double) {
        let alert = UIAlertController(title: newTitle,
                                      message: newMessage,
                                      preferredStyle: .alert)
        
        vc.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + numberOfSeconds) {
                vc.dismiss(animated: true, completion: nil)
            }
    }
    
    // Pop Up with Blur and Spinner
    func spinnerWithBlur(backgroundView: UIView) {
        
        blurEffectView.effect = blurEffect
        blurEffectView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        blurEffectView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor).isActive = true
        blurEffectView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(blurEffectView)
        
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        popUpView.topAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.topAnchor).isActive = true
        popUpView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        popUpView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        popUpView.layer.cornerRadius = backgroundView.bounds.height / 50

        popUpView.addSubview(spinner)
        popUpView.addSubview(pleaseWaitLabel)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 10).isActive = true
        pleaseWaitLabel.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
        pleaseWaitLabel.leftAnchor.constraint(equalTo: popUpView.leftAnchor).isActive = true
        pleaseWaitLabel.rightAnchor.constraint(equalTo: popUpView.rightAnchor).isActive = true
        pleaseWaitLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
        
        animateIn(forView: blurEffectView, backgroundView: backgroundView)
        animateIn(forView: popUpView, backgroundView: backgroundView)
        
        spinner.startAnimating()
    }

    // Animate In PopUp View
    func animateIn(forView: UIView, backgroundView: UIView) {
        forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        forView.alpha = 0
        forView.center = backgroundView.center
        
        UIView.animate(withDuration: 0.3, animations: {
            forView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            forView.alpha = 1
        })
    }
    
    // Animate Out PopUp View
    func animateOut(forView: UIView) {
        UIView.animate(withDuration: 0.3) {
            forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            forView.alpha = 0
        } completion: { _ in
            forView.removeFromSuperview()
        }
    }
    
    
}
