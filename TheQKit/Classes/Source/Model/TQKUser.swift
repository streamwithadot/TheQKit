//
//  User.swift
//  theq
//
//  Created by Will Jamieson on 11/2/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

public struct TQKUser: Mappable{
    
    public var balance: Double = 0
    public var id: String?
    public var email: String?
    public var username: String?
    public var admin: Bool = false
    public var profilePicUrl : String?
    public var heartPieceCount : Int = 0
    public var referralCode : String?
    public var activeSubscription : Bool = false
    public var withdrawalRequested : Bool = false
    public var tester : Bool = false
    
    public init?(map: Map) {
        
    }
    
    public init () {
        
    }
    
    public init(balance : Double, id : String, email : String, username : String, admin : Bool, profilePicUrl : String, heartPieceCount : Int, referralCode : String, activeSubscription: Bool, withdrawalRequested:Bool, tester:Bool) {
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
        self.tester = tester
    }
    
    public init?(dictionary : [String:Any]) {
        self.init(balance: dictionary["balance"] as? Double ?? 0,
                  id: String(describing: dictionary["id"]!),
                  email: String(describing: dictionary["email"]!),
                  username: String(describing: dictionary["username"]!),
                  admin: dictionary["admin"] as? Bool ?? false,
                  profilePicUrl: String(describing: dictionary["profilePicUrl"]!),
                  heartPieceCount: dictionary["heartPieceCount"] as? Int ?? 0,
                  referralCode: dictionary["referralCode"] as? String ?? String(describing: dictionary["username"]!),
                  activeSubscription: dictionary["activeSubscription"] as? Bool ?? false,
                  withdrawalRequested: dictionary["withdrawalRequested"] as? Bool ?? false,
                  tester: dictionary["tester"] as? Bool ?? false)
    }
    
    mutating public func mapping(map: Map) {
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
        tester <- map["tester"]
    }
    
    public var propertyListRepresentation : [String:Any] {
        return ["balance" : balance , "id" : id!, "email" : email ?? "", "username" : username!, "admin" : admin, "profilePicUrl" : profilePicUrl ?? "", "heartPieceCount" : heartPieceCount , "referralCode" : referralCode ?? username!, "activeSubscription":activeSubscription, "withdrawalRequested":withdrawalRequested, "tester":tester]
    }
}
