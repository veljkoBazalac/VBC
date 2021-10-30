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
        
        static let homeToCard = "HomeToCardSegue"
        static let cardToLike = "CardToLike"
        static let cardToContact = "CardToContactSegue"
        static let cardToAbout = "CardToAboutSegue"
        
    }
    
    struct Cell {
        
        static let homeCell = "homeCell"
        static let likeCell = "likeCell"
        
    }
    
    struct Nib {
        
        static let homeViewCell = "HomeViewCell"
        static let likeViewCell = "LikeTableViewCell"
        
    }
}
