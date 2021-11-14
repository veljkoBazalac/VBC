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
        static let cardToAbout = "CardToAboutSegue"
        
        // Cards
        static let viewCard = "ViewCardSegue"
        static let addVBC = "addVBCSegue"
    
            // Company Add VBC
        static let cAdd1 = "CompanyAddVBC1"
        static let cAdd2 = "CompanyAddVBC2"
        static let cAdd3 = "CompanyAddVBC3"
        static let cAddFinish = "CompanyAddVBCFinish"
            // Personal Add VBC
        static let pAdd1 = "PersonalAddVBC1"
        static let pAdd2 = "PersonalAddVBC2"
        
        
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
    
    struct Firestore {
        
        struct CollectionName {
            
            static let cards = "Cards"
            static let sectors = "Sectors"
            static let productType = "ProductType"
             
            
        }
        
        struct Key {

            static let type = "type"
            static let name = "name"
        }
        
    }
}
