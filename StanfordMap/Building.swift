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
    
    init(element: XMLParser.XMLElement) {
        self.name = element["name"].string
        self.buildingId = element["bldg_id"].string
        self.street = element["street"].string
        self.latitude = element["latitude"].string
        self.longitude = element["longitude"].string
    }
    
    func print() {
        println("Building: \(name)")
        println("name: \(name)")
        println("street: \(street)")
        println("latitude: \(latitude)")
        println("longitude: \(longitude)")
    }
}
