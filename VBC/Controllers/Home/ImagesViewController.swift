//
//  ImagesViewController.swift
//  VBC
//
//  Created by VELJKO on 31.10.21..
//

import UIKit

class ImagesViewController: UIViewController {

    // Collection View Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource : [String] = ["test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9", "test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9"]
    
    // Company Name Outlet
    @IBOutlet weak var nameLabel: UILabel!
    
    // Pop Up Outlets
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var popUpImageView: UIImageView!
    @IBOutlet weak var productInfo: UITextView!
    
    // Blur View and PopUp View Outlets
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = "Metalac AD"
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: Constants.Nib.imageViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.imageCell)
        
        
        
        imageSize()
        popUp()
        
        }
    
    func imageSize() {
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }

    func popUp() {
        // Sets Fullscreen Blur 
        blurView.bounds = self.view.bounds
        
        // PopUp View - Width = 90% of the screen width - Height = 70% of screen height
        popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.7)
        
        // PopUp View Rounded Corners
        popUpView.layer.cornerRadius = popUpView.frame.size.height / 40
    }
    
    // Animate desired view
    
    // Animate In
    func animateIn(desiredView: UIView) {
        
        let backgroundView = self.view!
        
        // Adding desiredView to be member of ImageViewController
        backgroundView.addSubview(desiredView)
        
        
        // Sets the view Scaling to be 120%
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        // Animation
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
        })
    }
    
    // Animate Out
    func animateOut(desiredView: UIView) {
        // Animation
        UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
            
            desiredView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            desiredView.alpha = 0
            
        }, completion: { _ in
            desiredView.removeFromSuperview()
        })
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        animateOut(desiredView: popUpView)
        animateOut(desiredView: blurView)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// Collection View Extension

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        productName.text = "Bojler 40L"
        popUpImageView.image = UIImage(named: dataSource[indexPath.row])
        
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
            animateIn(desiredView: blurView)
            animateIn(desiredView: popUpView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.imageCell, for: indexPath) as! ImageCollectionViewCell
        
        let selectedImage = UIImage(named: dataSource[indexPath.row])!
    
        cell.configure(with: selectedImage)
        cell.layer.cornerRadius = cell.frame.size.height / 10
    
        return cell
    }
    
    
}
