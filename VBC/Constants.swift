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
        static let cAddLocationList = "AddNewLocationList"
        static let cAdd3 = "CompanyAddVBC3"
        static let cAddFinish = "CompanyAddVBCFinish"
            // Personal Add VBC
        static let pAdd1 = "PersonalAddVBC1"
        static let pAdd2 = "PersonalAddVBC2"
        
        
    }
    
    struct Cell {
        static let homeCell = "homeCell"
        static let addLocListCell = "addLocListCell"
    
    }
    
    struct Nib {
        static let homeViewCell = "HomeViewCell"
        static let addLocList = "AddLocListTableViewCell"
    }
    
    struct Firestore {
        
        struct CollectionName {
            
            static let VBC = "VBC"
            static let companyCards = "Company Cards"
            static let personalCards = "Personal Cards"
            static let sectors = "Sectors"
            static let countries = "Country"
            static let productType = "ProductType"
            static let multiplePlaces = "Multiple Places"
            static let singlePlace = "Single Place"
            static let cardID = "Card ID"
            static let locations = "Locations"
            static let basicInfo = "Basic Info"
            
             
            
        }
        
        struct Key {
            
            static let Name = "Name"
            static let name = "name"
            static let sector = "Sector"
            static let type = "ProductType"
            static let country = "Country"
            static let cardID = "CardID"
            
            static let city = "City"
            static let street = "Street"
            static let gMaps = "gMaps Link"
            
        }
        
        struct Storage {
            
            static let companyLogo = "Company Logo Folder"
        }
        
    }
}
