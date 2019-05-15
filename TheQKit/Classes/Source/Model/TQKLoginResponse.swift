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


struct TQKLoginResponse: Mappable{
    
    var user: TQKUser?
    var oauth: TQKOAuth?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        user 	<- map["user"]
        oauth <- map["oauth"]
      
    }
}
