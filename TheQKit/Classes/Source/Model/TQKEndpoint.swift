//
//  Endpoint.swift
//  theq
//
//  Created by Will Jamieson on 10/25/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation

enum TQKEndpoint {
    case GetUserInfo(userId: String)
    case UpdateUserInfo(userId: String)
    case CreateUser(username: String, email: String)
    
}
