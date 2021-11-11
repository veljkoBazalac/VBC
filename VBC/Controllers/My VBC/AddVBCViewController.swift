//
//  AddVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit

class AddVBCViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var workActivity: UITextField!
    @IBOutlet weak var productType: UITextField!
    @IBOutlet weak var cityName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    // Add Logo Image Pressed
    @IBAction func addLogoTapped(_ sender: UITapGestureRecognizer) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
    }
    
}

extension AddVBCViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let logoImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = logoImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
