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
    
    // Base string for searching buildings
    let baseSearchString = "http://campus-map.stanford.edu/bldg_xml.cfm"
  
    let searchManager:AFHTTPRequestOperationManager
    let searchRequestSerializer:AFHTTPRequestSerializer
    let searchResponseSerializer:AFHTTPResponseSerializer
    
    // Base string for searching specific building information
    let baseReportString = "http://campus-map.stanford.edu/report-cm.cfm"
    
    let reportManager:AFHTTPRequestOperationManager
    let reportRequestSerializer:AFHTTPRequestSerializer
    let reportResponseSerializer:AFHTTPResponseSerializer
    
    let userAgentString = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
   
    override init() {
        
        // Search
        searchRequestSerializer = AFHTTPRequestSerializer()
        searchRequestSerializer.setValue("User-Agent", forHTTPHeaderField: userAgentString)
        
        searchResponseSerializer = AFHTTPResponseSerializer()
        searchResponseSerializer.acceptableContentTypes = Set(["text/xml"])
        
        var searchURL:NSURL = NSURL(string: baseSearchString)!
        searchManager = AFHTTPRequestOperationManager(baseURL: searchURL)
        
        searchManager.requestSerializer = searchRequestSerializer
        searchManager.responseSerializer = searchResponseSerializer
        
        // Reports
        reportRequestSerializer = AFHTTPRequestSerializer()
        reportRequestSerializer.setValue("User-Agent", forHTTPHeaderField: userAgentString)
        
        reportResponseSerializer = AFHTTPResponseSerializer()
        reportResponseSerializer.acceptableContentTypes = Set(["text/html"])
        
        var reportURL:NSURL = NSURL(string: baseReportString)!
        reportManager = AFHTTPRequestOperationManager(baseURL: reportURL)
        
        reportManager.requestSerializer = reportRequestSerializer
        reportManager.responseSerializer = reportResponseSerializer
        
        super.init()
    }
    
    // Current API only supports exact search with a single term
    func searchBuildingsWithCompletion(searchTerm: String, completion: (buildings:[Building]?, error: NSError?) -> Void) {
        
        var params = NSMutableDictionary()
        params.setValue(searchTerm, forKey: "srch")
        
        searchManager.GET("",
            parameters: params,
            success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                
                var buildings:[Building] = []
                var data: NSData? = responseObject as? NSData
                
                // This inner wrapping is to deal with wrapping issues with the API
                if (data != nil) {
                    // This extra unwrapping was necessary to hit unusual breaking cases
                    var parserOptional: XMLParser? = XMLParser(data: data)
                    if let parser:XMLParser = parserOptional {
                        
                        if parser.rootElement.numberOfChildElements > 0 {
                            for element: XMLParser.XMLElement in parser.rootElement {
                                var building: Building = Building(element: element)
                                
                                buildings.append(building)
                                //building.print()

                            }
                        }
                    }
                }
                completion(buildings: buildings, error: nil)
            },
            
            failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                
                println("Error: "+error.localizedDescription)
                
                completion(buildings: nil, error: error)
        })
        
    }
    
    func getBuildingReportWithCompletion(buildingId: String, completion: (imageString:String?, error:NSError) -> Void) {
        var params = NSMutableDictionary()
        params.setValue(buildingId, forKey: "id")
        
        // Call the Stanford Campus Map API
        reportManager.GET("",
            parameters: params,
            success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                
                var data: NSData? = responseObject as? NSData
                if (data != nil) {
                    // NEED TO PARSE HTML FOR THE PICTURE HERE
                    // http://campus-map.stanford.edu/js/stan_cm_js.cfm
                    // view-source:http://campus-map.stanford.edu/report-cm.cfm?id=02-640
                    // http://campus-map.stanford.edu/bldg_xml.cfm?srch=cow
                    // http://campus-map.stanford.edu/report-cm.cfm?id=02-640
                    
                }
            },
            
            failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                
                println("Error: "+error.localizedDescription)
                
                completion(imageString: nil, error: error)
        })
 
    }
    
    // This makes recursive calls to the API until we get all results, then it will deduplicate them
    func searchBuildingsWithCompletionRecurse(searchTerms: [String], buildings: [Building], completion: (buildings:[Building]?, error: NSError?) -> Void) {
        
        // Base case: deduplicate and call completion
        if searchTerms.count == 0 {
            
            // Deduplication
            
            var deduplicated:[Building] = Array(Set(buildings))
            
            completion(buildings: deduplicated, error: nil)
            
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
            reportManager.GET("",
                parameters: params,
                success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                    
                    var newBuildings:[Building] = NSArray(array: buildings) as! [Building]
                    var data: NSData? = responseObject as? NSData
                    if (data != nil) {
                        var parser: XMLParser = XMLParser(data: data)!
                        if parser.rootElement.numberOfChildElements > 0 {
                            for element: XMLParser.XMLElement in parser.rootElement {
                                var building: Building = Building(element: element)
                                
                                newBuildings.append(building)
                                //building.print()
                                
                            }
                        }
                    }
                    self.searchBuildingsWithCompletionRecurse(updatedSearchTerms, buildings: newBuildings, completion: completion)
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
            searchBuildingsWithCompletionRecurse(terms, buildings: buildings, completion: completion)
        }
    }
    
}