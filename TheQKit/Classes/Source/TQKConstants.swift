//
//  Constants.swift
//  theq
//
//  Created by Will Jamieson on 10/30/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation


struct TQKConstants {
    
    static var RUNNING_JOIN_GAME_COUNT = "TQK_RUNNING_JOIN_GAME_COUNT"
    
    static var STORYBOARD_STRING : String {
        get{
            return "Games"
        }
    }
    
    static var GAMES_STORYBOARD_STRING : String {
        get{
            return "Games"
        }
    }
    
    static var LOCALE : String {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: "TQK_LOCALE") ?? ""
        }
//        get {
//            return "en_US"
//        }
    }
    
    static var MONEY_SYMBOL : String {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: "TQK_MONEY_SYMBOL") ?? ""
        }
    }
    
    static var GEN_COLOR_CODE : String {
        get {
            return "#E63462"
        }
    }

    static var baseUrl:String {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: "TQK_BASE_URL") ?? ""
        }
    }
    
    
    static var appName : String {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: "TQK_APP_NAME") ?? ""
        }
    }
    
}
