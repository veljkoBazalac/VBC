//
//  Constants.swift
//  VBC
//
//  Created by VELJKO on 26.10.21..
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let homeVC = "HomeVC"
    }
    
    struct Segue {
        // Login
        static let regToVerify = "regToVerifySegue"
        static let loginSegue = "loginSegue"
        static let loginToVerify = "logToVerifySegue"
        static let verifyToHome = "verifyToHomeSegue"
        
        //Tab Bar
        
        // Home
        static let homeToCard = "HomeToCardSegue"
        static let cardToLike = "CardToLike"
        static let cardToContact = "CardToContactSegue"
        static let cardToAbout = "CardToAboutSegue"
        static let cardToImages = "CardToImages"
        static let imageDetail = "ImageDetailSegue"
        
        // My VBC
        static let addVBC = "addVBCSegue"
        static let viewCard = "ViewCardSegue"
        
        
    }
    
    struct Cell {
        
        static let homeCell = "homeCell"
        static let likeCell = "likeCell"
        static let imageCell = "ImageCollectionCell"
      
        
    }
    
    struct Nib {
        
        static let homeViewCell = "HomeViewCell"
        static let likeViewCell = "LikeTableViewCell"
        static let imageViewCell = "ImageCollectionViewCell"
     
        
    }
}
