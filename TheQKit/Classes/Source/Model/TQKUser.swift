//
//  User.swift
//  theq
//
//  Created by Will Jamieson on 11/2/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

struct TQKUser: Mappable{
    
    var balance: Double = 0
    var id: String?
    var email: String?
    var username: String?
    var admin: Bool = false
    var profilePicUrl : String?
    var heartPieceCount : Int = 0
    var referralCode : String?
    var activeSubscription : Bool = false
    var withdrawalRequested : Bool = false
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    init(balance : Double, id : String, email : String, username : String, admin : Bool, profilePicUrl : String, heartPieceCount : Int, referralCode : String, activeSubscription: Bool, withdrawalRequested:Bool) {
        self.balance = balance
        self.id = id
        self.email = email
        self.username = username
        self.admin = admin
        self.profilePicUrl = profilePicUrl
        self.heartPieceCount =  heartPieceCount
        self.referralCode = referralCode
        self.activeSubscription = activeSubscription
        self.withdrawalRequested = withdrawalRequested
    }
    
    init?(dictionary : [String:Any]) {
        self.init(balance: dictionary["balance"] as? Double ?? 0,
                  id: String(describing: dictionary["id"]!),
                  email: String(describing: dictionary["email"]!),
                  username: String(describing: dictionary["username"]!),
                  admin: dictionary["admin"] as? Bool ?? false,
                  profilePicUrl: String(describing: dictionary["profilePicUrl"]!),
                  heartPieceCount: dictionary["heartPieceCount"] as? Int ?? 0,
                  referralCode: dictionary["referralCode"] as? String ?? String(describing: dictionary["username"]!),
                  activeSubscription: dictionary["activeSubscription"] as? Bool ?? false,
                  withdrawalRequested: dictionary["withdrawalRequested"] as? Bool ?? false)
    }
    
    mutating func mapping(map: Map) {
        id 	<- map["id"]
        balance <- map["balance"]
        email <- map["email"]
        username <- map["username"]
        admin <- map["admin"]
        profilePicUrl <- map["profilePicUrl"]
        heartPieceCount <- map["heartPieceCount"]
        referralCode <- map["referralCode"]
        activeSubscription <- map["activeSubscription"]
        withdrawalRequested <- map["withdrawalRequested"]
    }
    
    var propertyListRepresentation : [String:Any] {
        return ["balance" : balance ?? 0, "id" : id!, "email" : email ?? "", "username" : username!, "admin" : admin, "profilePicUrl" : profilePicUrl ?? "", "heartPieceCount" : heartPieceCount ?? 0, "referralCode" : referralCode ?? username!, "activeSubscription":activeSubscription, "withdrawalRequested":withdrawalRequested]
    }
}
