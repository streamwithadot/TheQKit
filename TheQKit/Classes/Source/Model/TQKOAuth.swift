//
//  OAuth.swift
//  theq
//
//  Created by Will Jamieson on 11/2/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

struct TQKOAuth: Mappable{
    
    var accessToken: String?
    var expiration: Double?
    var refreshToken: String?
    var tokenType: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        accessToken <- map["accessToken"]
        expiration 	<- map["expiration"]
        refreshToken <- map["refreshToken"]
        tokenType <- map ["tokenType"]
    }
    
    init(accessToken : String, expiration : Double, refreshToken : String, tokenType : String) {
        self.accessToken = accessToken
        self.expiration = expiration
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        
    }
    
    init?(dictionary : [String:Any]) {
        self.init(accessToken: String(describing: dictionary["accessToken"]!),
                  expiration: dictionary["expiration"] as! Double,
                  refreshToken: String(describing: dictionary["refreshToken"]!),
                  tokenType: String(describing: dictionary["tokenType"]!))
    }
    
    var propertyListRepresentation : [String:Any] {
        return ["accessToken" : accessToken, "expiration" : expiration!, "refreshToken" : refreshToken!, "tokenType" : tokenType!]
    }
    
}
