//
//  Player.swift
//  theq
//
//  Created by Will Jamieson on 10/26/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

struct TQKPlayer {
    var username: String
    var email: String
    var authData: TQKAuthData
    var optInBool : Bool = false
    var apnToken : String!
    var firebaseToken : String!
    var deviceId : String!
    var type : String!
    
    var dictionaryRepresentation: [String: Any] {

        return
            ["username" : username,
             "autoHandleUsernameCollision": true,
             "contactEmail" : email,
             "marketingOptIn" : optInBool,
             "authData" : [
                "facebook": [
                    "id": authData.facebook.id,
                    "accessToken": authData.facebook.accessToken
                ]
                ]
        ]

    }
}

struct TQKAKPlayer {
    var username: String
    var email: String
    var accountKit: TQKAccountKitAuth
    var optInBool : Bool = false
    var apnToken : String!
    var firebaseToken : String!
    var deviceId : String!
    var type : String!

    var dictionaryRepresentationAK: [String: Any] {

        return
            ["username" : username,
             "autoHandleUsernameCollision": true,
             "contactEmail" : email,
             "marketingOptIn" : optInBool,
             "authData" : [
                "accountKit": [
                    "id": accountKit.id,
                    "accessToken": accountKit.accessToken
                ]
                ]
        ]

    }
}

struct TQKFirebasePlayer {
    var username: String
    var email: String
    var firebaseAuth: TQKFirebaseAuth
    var optInBool : Bool = false
    var apnToken : String!
    var firebaseToken : String!
    var deviceId : String!
    var type : String!
    
    var dictionaryRepresentationFirebase: [String: Any] {
        
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

struct TQKCommonPlayer {
    var username: String
    var email: String
    var commonAuth: TQKCommonAuth
    var optInBool : Bool = false
    var apnToken : String!
    var firebaseToken : String!
    var deviceId : String!
    var type : String!
    
    var dictionaryRepresentationFirebase: [String: Any] {
        
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
