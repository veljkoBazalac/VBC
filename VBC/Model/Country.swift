//
//  Country.swift
//  VBC
//
//  Created by VELJKO on 15.11.21..
//

import Foundation

struct Country {
    
    var name : String = ""
    
    func getCountryCode(country: String) -> String {
        
        
        switch country {
        case "Serbia":
            return "381"
        case "Afghanistan":
            return "93"
        case "Albania":
            return "355"
        case "Algeria":
            return "213"
        case "American Samoa":
            return "1-684"
        case "Andorra":
            return "376"
        case "Angola":
            return "244"
        case "Anguilla":
            return "1-264"
        case "Antarctica":
            return "672"
        case "Antigua and Barbuda":
            return "1-268"
        case "Argentina":
            return "54"
        case "Armenia":
            return "374"
        case "Aruba":
            return "297"
        case "Australia":
            return "61"
        case "Austria":
            return "43"
        case "Azerbaijan":
            return "994"
        default:
            return "Error"
        }

    }
    
}
