//
//  LoginResponse.swift
//  theq
//
//  Created by Will Jamieson on 11/2/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

//class LoginResponseWrapper : NSObject {
//
//    var loginResponse : LoginResponse
//
//    init(loginResponse : LoginResponse){
//        self.loginResponse = loginResponse
//    }
//    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(loginResponse, forKey: "loginResponse")
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        loginResponse = aDecoder.decodeObject(forKey: "loginResponse") as! LoginResponse
//    }
//
//    var propertyListRepresentation : [String:Any] {
//        return ["balance" : balance ?? "0", "id" : id, "email" : email ?? "", "username" : username, "admin" : admin, "token" : token]
//    }
//
//}


public struct TQKLoginResponse: Mappable{
    
    public var user: TQKUser?
    public var oauth: TQKOAuth?
    public var tester: Bool = false
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        user 	<- map["user"]
        oauth <- map["oauth"]
        tester <- map["tester"]
        
        user?.tester = tester
    }
}
