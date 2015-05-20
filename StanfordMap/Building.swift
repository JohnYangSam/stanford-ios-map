//
//  Building.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import Foundation
import CheatyXML

class Building: NSObject {
    var name: String?
    var buildingId: String?
    var street: String?
    var latitude: String?
    var longitude: String?
    var location: CLLocationCoordinate2D?
    
    init(element: XMLParser.XMLElement) {
        self.name = element["name"].string
        self.buildingId = element["bldg_id"].string
        self.street = element["street"].string
        self.latitude = element["latitude"].string
        self.longitude = element["longitude"].string
        
        self.location = CLLocationCoordinate2DMake(CLLocationDegrees(latitude!.doubleValue), CLLocationDegrees(longitude!.doubleValue))
    }
    
    func print() {
        println("Building: \(name)")
        println("name: \(name)")
        println("street: \(street)")
        println("latitude: \(latitude)")
        println("longitude: \(longitude)")
    }
}

//from: http://stackoverflow.com/questions/26198612/string-to-double-in-xcode-6s-swift
extension String {
    var doubleValue: Double {
        if let number = NSNumberFormatter().numberFromString(self) {
            return number.doubleValue
        }
        return 0
    }
}