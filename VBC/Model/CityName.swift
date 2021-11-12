//
//  CityName.swift
//  VBC
//
//  Created by VELJKO on 11.11.21..
//

import Foundation

struct CityName {
    
    var name : String = ""
    
    func getCityLetters(city: String) -> String {
        
        switch city {
        case "Ada":
            return "SA"
        case "Aleksandrovac":
            return "AC"
        case "Aleksinac":
            return "AL"
        case "Alibunar":
            return "PA"
        case "Apatin":
            return "SO"
        case "Arandjelovac":
            return "AR"
        case "Arilje":
            return "UE"
        default:
            return "ERROR"
        }
        
        
    }
    
}
