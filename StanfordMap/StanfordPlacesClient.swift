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
    
    func searchWithCompletion(searchTerm: String, completion: ()) {
        
        var params = NSMutableDictionary()
        params.setValue(searchTerm, forKey: "srch")
        
        manager.GET("",
            parameters: params,
            success:{(operation: AFHTTPRequestOperation!, responseObject: AnyObject!)in
                
                var data: NSData = responseObject as! NSData
                var parser: XMLParser = XMLParser(data: data)!
                
                for element in parser.rootElement {
                    println("Element: \(element.tagName)")
                }
                
                //print("XML response: \(data)")
                
                //println("\(responseObject)")
            },
            
            failure:{(operation: AFHTTPRequestOperation!, error: NSError!)in
                
                println("Error: "+error.localizedDescription)
        })

    }
    
}