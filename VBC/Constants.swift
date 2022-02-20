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
        static let homeToSearch = "HomeToSearchSegue"
        static let searchToCard = "SearchToCardSegue"
        static let cardToAbout = "CardToAboutSegue"
        static let editStep1 = "EditStep1"
        static let editStep2 = "EditStep2"
        static let editStep3 = "EditStep3"
        
        // My Cards
        static let viewCard = "ViewCardSegue"
        static let cardToPopUp = "CardToPopUp"
        static let addVBC = "addVBCSegue"
        
            // Company Add VBC
        static let addNew1 = "AddNewVBC1"
        static let addNew2 = "AddNewVBC2"
        static let newLocationsList = "AddNewLocationList"
        static let addNew3 = "AddNewVBC3"
        static let phoneListSegue = "PhoneListSegue"
        static let emailListSegue = "EmailListSegue"
        static let websiteListSegue = "WebsiteListSegue"
        static let addFinish = "AddVBCFinish"
            // Personal Add VBC
        static let pAdd1 = "PersonalAddVBC1"
        static let pAdd2 = "PersonalAddVBC2"
        static let pPhoneListSegue = "PPhoneListSegue"
        static let pAdd3 = "PersonalAddVBC3"
        static let pSocialList = "SocialListSegue"
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
        static let contactListCell = "ContactListCell"
    
    }
    
    struct Nib {
        static let homeViewCell = "HomeViewCell"
        static let addLocList = "AddLocListTableViewCell"
        static let popUpCell = "CardPopUpCell"
        static let contactListCell = "ContactListCell"
    }
    
    struct NotificationKey {
        static let cardRemoved = "solosoft.VBC.cardRemoved"
        
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
            static let aboutSection = "About Section"
            static let about = "About"
            static let searchBy = "SearchBy"
            static let savedForUsers = "Saved For Users"
        
        }
        
        struct Key {
            
            // Key for Basic Info
            static let personalName = "Personal Name"
            static let companyName = "Company Name"
            static let name = "name"
            static let sector = "Sector"
            static let type = "ProductType"
            static let country = "Country"
            static let cardID = "CardID"
            static let singlePlace = "Single Place"
            static let companyCard = "Company Card"
            static let userID = "User ID"
            static let cardSaved = "Card Saved"
            
            // Key for Contact Info
            
              // Phone Number
            static let phone1 = "Phone 1"
            static let phone2 = "Phone 2"
            static let phone3 = "Phone 3"
            static let phone1code = "Phone1Code"
            static let phone2code = "Phone2Code"
            static let phone3code = "Phone3Code"
            static let phone1Exist = "Phone1Exist"
            static let phone2Exist = "Phone2Exist"
            static let phone3Exist = "Phone3Exist"
            
              // Email Address
            static let email1 = "Email 1"
            static let email2 = "Email 2"
            static let email1Exist = "Email1Exist"
            static let email2Exist = "Email2Exist"
            
              // Website Link
            static let web1 = "Website 1"
            static let web2 = "Website 2"
            static let web1Exist = "Web1Exist"
            static let web2Exist = "Web2Exist"
            
              // Social Media
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
            
            // Key for About Info
            static let about = "About"
            
            // Key for Search By
            static let parameter = "parameter"
        }
        
        struct Storage {
            
            static let companyLogo = "Company Logo Folder"
            static let personalImage = "Personal Image Folder"
        }
        
    }
}
