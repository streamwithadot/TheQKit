//
//  Player.swift
//  theq
//
//  Created by Will Jamieson on 10/26/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper
import AdSupport


public struct TQKPlayer {
    
    public init(username: String, email: String, authData: TQKFacebookAuth,optInBool:Bool, apnToken: String?, firebaseToken: String?, deviceId: String?, type: String?) {
        self.username = username
        self.email = email
        self.authData = authData
        self.apnToken = apnToken
        self.firebaseToken = firebaseToken
        self.deviceId = deviceId
        self.type = type
        self.optInBool = optInBool
    }
    
    
    public var username: String
    public var email: String
    public var authData: TQKFacebookAuth
    public var optInBool : Bool = false
    public var apnToken : String!
    public var firebaseToken : String!
    public var deviceId : String!
    public var type : String!
    
    public var dictionaryRepresentation: [String: Any] {

    let idfa = ASIdentifierManager.shared().advertisingIdentifier
        
        return
            ["username" : username,
             "device" :  ["id":deviceId!,
                          "type":type!,
                          "token":apnToken!,
                          "firebaseRegistrationToken":firebaseToken!,
                          "idfa": idfa.uuidString,
                          "idfv": deviceId!
                ],
             "authData" : [
                "facebook": [
                    "id": authData.id,
                    "accessToken": authData.accessToken
                ]
                ]
        ]

    }
}

public class TQKAKPlayer {
    
    public init(username: String, email: String, accountKit: TQKAccountKitAuth,optInBool:Bool,apnToken: String?, firebaseToken: String?, deviceId: String?, type: String?) {
        self.username = username
        self.email = email
        self.accountKit = accountKit
        self.apnToken = apnToken
        self.firebaseToken = firebaseToken
        self.deviceId = deviceId
        self.type = type
        self.optInBool = optInBool
    }
    
    public var username: String
    public var email: String
    public var accountKit: TQKAccountKitAuth
    public var optInBool : Bool = false
    public var apnToken : String!
    public var firebaseToken : String!
    public var deviceId : String!
    public var type : String!

    public var dictionaryRepresentationAK: [String: Any] {

    let idfa = ASIdentifierManager.shared().advertisingIdentifier
        
        return
            ["username" : username,
             "device" :  ["id":deviceId!,
                          "type":type!,
                          "token":apnToken!,
                          "firebaseRegistrationToken":firebaseToken!,
                          "idfa":idfa.uuidString,
                          "idfv": deviceId!
                ],
             "authData" : [
                "accountKit": [
                    "id": accountKit.id,
                    "accessToken": accountKit.accessToken
                ]
                ]
        ]

    }
}

public struct TQKFirebasePlayer {
    public var username: String
    public var email: String
    public var firebaseAuth: TQKFirebaseAuth
    public var optInBool : Bool = false
    public var apnToken : String!
    public var firebaseToken : String!
    public var deviceId : String!
    public var type : String!
    
    public var dictionaryRepresentationFirebase: [String: Any] {
        
        return
            ["username" : username,
             "autoHandleUsernameCollision": true,
             "authData" : [
                "firebase": [
                    "id": firebaseAuth.id,
                    "accessToken": firebaseAuth.accessToken
                ]
                ]
        ]
        
    }
}

public struct TQKCommonPlayer {
    public var username: String
    public var email: String
    public var commonAuth: TQKCommonAuth
    public var optInBool : Bool = false
    public var apnToken : String!
    public var firebaseToken : String!
    public var deviceId : String!
    public var type : String!
    
    public var dictionaryRepresentationFirebase: [String: Any] {
        
        return
            ["username" : username,
             "autoHandleUsernameCollision": true,
             "authData" : [
                commonAuth.provider: [
                    "id": commonAuth.id,
                    "accessToken": commonAuth.accessToken
                ]
            ]
        ]
        
    }
}
