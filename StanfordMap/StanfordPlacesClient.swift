//
//  StanfordPlacesClient.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import Foundation
import AFNetworking
import CheatyXML

class StanfordPlacesClient: NSObject {
    
    let baseString = "http://campus-map.stanford.edu/bldg_xml.cfm"
    
    let userAgentString = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
   
    let manager:AFHTTPRequestOperationManager
    let requestSerializer:AFHTTPRequestSerializer
    let responseSerializer:AFHTTPResponseSerializer
    
    override init() {
        
        requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue("User-Agent", forHTTPHeaderField: userAgentString)
        
        responseSerializer = AFHTTPResponseSerializer()
        responseSerializer.acceptableContentTypes = Set(["text/xml"])
        
        var url:NSURL = NSURL(string: baseString)!
        manager = AFHTTPRequestOperationManager(baseURL: url)
        
        manager.requestSerializer = requestSerializer
        manager.responseSerializer = responseSerializer
        
        
        super.init()
    }
    
    // Current API only supports exact search with a single term
    func searchBuildingsWithCompletion(searchTerm: String, completion: (buildings:[Building]?, error: NSError?) -> Void) {
        
        var params = NSMutableDictionary()
        params.setValue(searchTerm, forKey: "srch")
        
        manager.GET("",
            parameters: params,
            success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                
                var data: NSData = responseObject as! NSData
                var parser: XMLParser = XMLParser(data: data)!
                
                var buildings:[Building] = []
                
                if parser.rootElement.numberOfChildElements > 0 {
                    for element: XMLParser.XMLElement in parser.rootElement {
                        var building: Building = Building(element: element)
                        
                        buildings.append(building)
                        //building.print()

                    }
                }
                completion(buildings: buildings, error: nil)
            },
            
            failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                
                println("Error: "+error.localizedDescription)
                
                completion(buildings: nil, error: error)
        })
        
    }
    
    // This makes recursive calls to the API until we get all results, then it will deduplicate them
    func searchBuildingsWithCompletionRecurse(searchTerms: [String], buildings: [Building], completion: (buildings:[Building]?, error: NSError?) -> Void) {
        
        // Base case: deduplicate and call completion
        if searchTerms.count == 0 {
            
            // Deduplication
            
            var deduplicated: NSMutableArray = NSMutableArray(array: buildings)
            
            // Go from the back to the front to be safe
            for var index = deduplicated.count - 1; index >= 0; --index {
                for var prevIndex = 0; prevIndex < index; ++prevIndex {
                    if deduplicated[prevIndex].name == deduplicated[index].name {
                        deduplicated.removeObjectAtIndex(index)
                        continue
                    }
                }
            }
            
            // Call the final completion block
            var newBuildingsArray: [Building] = deduplicated.copy() as! [Building]
            completion(buildings: newBuildingsArray, error: nil)
            
        // We still ahve multiple search terms
        } else {
        
            // Get the last search term and set it for parameters
            var params = NSMutableDictionary()
            params.setValue(searchTerms[searchTerms.count - 1], forKey: "srch")
            
            // Remove the last search term
            var newSearchTerms:NSMutableArray = NSMutableArray(array: searchTerms)
            newSearchTerms.removeLastObject()
            var updatedSearchTerms:[String] = newSearchTerms.copy() as! [String]
        
            // Call the Stanford Campus Map API
            manager.GET("",
                parameters: params,
                success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                    
                    var data: NSData = responseObject as! NSData
                    var parser: XMLParser = XMLParser(data: data)!
                    
                    var newBuildings:[Building] = NSArray(array: buildings) as! [Building]
                    
                    if parser.rootElement.numberOfChildElements > 0 {
                        for element: XMLParser.XMLElement in parser.rootElement {
                            var building: Building = Building(element: element)
                            
                            newBuildings.append(building)
                            //building.print()
                            
                        }
                    }
                    completion(buildings: buildings, error: nil)
                },
                
                failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                    
                    println("Error: "+error.localizedDescription)
                    
                    completion(buildings: nil, error: error)
            })
        }
    }
    
    // This allows for somewhat more "fuzzy" search by splitting up search terms
    func searchBuildingsFuzzyWithCompletion(searchTerm: String, completion: (buildings:[Building]?, error: NSError?) -> Void) {
        
        var terms:[String] = split(searchTerm) {$0 == " "}
        if terms.count <= 1 {
            searchBuildingsWithCompletion(searchTerm, completion: completion)
        } else {
            var buildings: [Building] = []
            
        }
        
        var params = NSMutableDictionary()
        params.setValue(searchTerm, forKey: "srch")
        
        manager.GET("",
            parameters: params,
            success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                
                var data: NSData = responseObject as! NSData
                var parser: XMLParser = XMLParser(data: data)!
                
                var buildings:[Building] = []
                
                if parser.rootElement.numberOfChildElements > 0 {
                    for element: XMLParser.XMLElement in parser.rootElement {
                        var building: Building = Building(element: element)
                        
                        buildings.append(building)
                        //building.print()
                        
                    }
                }
                completion(buildings: buildings, error: nil)
            },
            
            failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                
                println("Error: "+error.localizedDescription)
                
                completion(buildings: nil, error: error)
        })

        
        
    }
    
}