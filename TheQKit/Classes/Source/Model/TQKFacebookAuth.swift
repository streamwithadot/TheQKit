//
//  FacebookAuth.swift
//  theq
//
//  Created by Will Jamieson on 10/26/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation


struct TQKFacebookAuth {
    var id: String
    var accessToken: String
    
    var dictionaryRepresentation: [String: Any] {
        return
             [ "facebook": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }

    
}

struct TQKAccountKitAuth {
    var id: String
    var accessToken: String
    
    var dictionaryRepresentation: [String: Any] {
        return
            [ "accountKit": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    
}

struct TQKFirebaseAuth {
    var id: String
    var accessToken: String
    
    var dictionaryRepresentation: [String: Any] {
        return
            [ "firebase": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    
}

struct TQKCommonAuth {
    var id: String
    var accessToken: String
    var provider: String
    
    var dictionaryRepresentation: [String: Any] {
        return
            [ provider: [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    
}
