//
//  FacebookAuth.swift
//  theq
//
//  Created by Will Jamieson on 10/26/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation


public struct TQKFacebookAuth {
    public var id: String
    public var accessToken: String
    
    public var dictionaryRepresentation: [String: Any] {
        return
             [ "facebook": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }

    public init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
    }
}

public struct TQKAccountKitAuth {
    public var id: String
    public var accessToken: String
    
    public var dictionaryRepresentation: [String: Any] {
        return
            [ "accountKit": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    public init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
    }
    
}

public struct TQKFirebaseAuth {
    public var id: String
    public var accessToken: String
    
    public var dictionaryRepresentation: [String: Any] {
        return
            [ "firebase": [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    public init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
    }
    
}

public struct TQKCommonAuth {

    public var id: String
    public var accessToken: String
    public var provider: String
    
    public var dictionaryRepresentation: [String: Any] {
        return
            [ provider: [
                "id": id,
                "accessToken": accessToken
                ]
        ]
    }
    
    public init(id: String, accessToken: String, provider: String) {
        self.id = id
        self.accessToken = accessToken
        self.provider = provider
    }
    
}
