//
//  OAuth.swift
//  theq
//
//  Created by Will Jamieson on 11/2/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

public struct TQKOAuth: Mappable{
    
    public var accessToken: String?
    public var expiration: Double?
    public var refreshToken: String?
    public var tokenType: String?
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        accessToken <- map["accessToken"]
        expiration 	<- map["expiration"]
        refreshToken <- map["refreshToken"]
        tokenType <- map ["tokenType"]
    }
    
    public init(accessToken : String, expiration : Double, refreshToken : String, tokenType : String) {
        self.accessToken = accessToken
        self.expiration = expiration
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        
    }
    
    public init?(dictionary : [String:Any]) {
        self.init(accessToken: String(describing: dictionary["accessToken"]!),
                  expiration: dictionary["expiration"] as! Double,
                  refreshToken: String(describing: dictionary["refreshToken"]!),
                  tokenType: String(describing: dictionary["tokenType"]!))
    }
    
    public var propertyListRepresentation : [String:Any] {
        return ["accessToken" : accessToken, "expiration" : expiration!, "refreshToken" : refreshToken!, "tokenType" : tokenType!]
    }
    
}
