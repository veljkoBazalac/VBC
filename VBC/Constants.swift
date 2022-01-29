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
        static let editComCard = "editCompanyCardSegue"
        static let editPersCard = "editPersonalCardSegue"
        
        // My Cards
        static let viewCard = "ViewCardSegue"
        static let cardToPopUp = "CardToPopUp"
        static let addVBC = "addVBCSegue"
        
            // Company Add VBC
        static let cAdd1 = "CompanyAddVBC1"
        static let cAdd2 = "CompanyAddVBC2"
        static let cAddLocationList = "AddNewLocationList"
        static let cAdd3 = "CompanyAddVBC3"
        static let cPhoneListSegue = "CPhoneListSegue"
        static let cEmailListSegue = "CEmailListSegue"
        static let cWebsiteListSegue = "CWebsiteListSegue"
        static let cAddFinish = "CompanyAddVBCFinish"
            // Personal Add VBC
        static let pAdd1 = "PersonalAddVBC1"
        static let pAdd2 = "PersonalAddVBC2"
        static let pPhoneListSegue = "PPhoneListSegue"
        static let pAdd3 = "PersonalAddVBC3"
        static let pSocialList = "pSocialListSegue"
        static let pEmailList = "pEmailListSegue"
        static let pWebList = "pWebsiteListSegue"
        static let pAddFinish = "PersonalAddVBCFinish"
        
        
        // Saved Cards
        static let savedToCard = "SavedToCardSegue"
    }
    
    struct Cell {
        static let homeCell = "homeCell"
        static let addLocListCell = "addLocListCell"
        static let popUpCell = "CardPopUpCell"
    
    }
    
    struct Nib {
        static let homeViewCell = "HomeViewCell"
        static let addLocList = "AddLocListTableViewCell"
        static let popUpCell = "CardPopUpCell"
    }
    
    struct Firestore {
        
        struct CollectionName {
            
            static let VBC = "VBC"
            static let data = "Data"
            static let sectors = "Sectors"
            static let countries = "Country"
            static let cardID = "Card ID"
            static let locations = "Locations"
            static let social = "Social Media"
            static let users = "Users"
            static let savedVBC = "Saved VBC"
        
        }
        
        struct Key {
            
            // Key for Basic Info
            static let Name = "Name"
            static let name = "name"
            static let sector = "Sector"
            static let type = "ProductType"
            static let country = "Country"
            static let cardID = "CardID"
            static let singlePlace = "Single Place"
            static let companyCard = "Company Card"
            static let userID = "User ID"
            
            // Key for Contact Info
            static let phone1 = "Phone 1"
            static let phone2 = "Phone 2"
            static let phone3 = "Phone 3"
            static let phone1code = "Phone1Code"
            static let phone2code = "Phone2Code"
            static let phone3code = "Phone3Code"
            static let email1 = "Email 1"
            static let email2 = "Email 2"
            static let web1 = "Website 1"
            static let web2 = "Website 2"
            static let social1 = "Social Network 1"
            static let social2 = "Social Network 2"
            static let social3 = "Social Network 3"
            static let social4 = "Social Network 4"
            static let social5 = "Social Network 5"
            
            // Key for Location Info
            static let city = "City"
            static let street = "Street"
            static let gMaps = "gMaps Link"
            
            // Key for Social Network
            static let link = "link"
            static let socialAdded = "Social Media Added"
        }
        
        struct Storage {
            
            static let companyLogo = "Company Logo Folder"
            static let personalImage = "Personal Image Folder"
        }
        
    }
}
