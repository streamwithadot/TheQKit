//
//  AuthData.swift
//  theq
//
//  Created by Will Jamieson on 10/26/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation

public struct TQKAuthData {
    public init(facebook: TQKFacebookAuth) {
        self.facebook = facebook
    }
    
    public var facebook: TQKFacebookAuth
}
