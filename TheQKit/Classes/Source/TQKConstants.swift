//
//  Constants.swift
//  theq
//
//  Created by Will Jamieson on 10/30/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation


enum TQKConstants {
    
    //true for dev. false for prod.
    static var DEV_MODE : Bool {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.bool(forKey: "DEV_MODE") //DEVELOPER NOTE: CHANGE THIS TO RETURN TRUE TO HARDCODE DEV MODE
        }
    }
    
    //set to true to show to hardcode the rtmp url to the "dan brand" one
    static var DAN_BRAND_MODE : Bool {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.bool(forKey: "DAN_BRAND_MODE")
        }
    }
    
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
            return "en_US"
        }
    }
    
    static var MONEY_SYMBOL : String {
        get {
            return "$"
        }
    }
    
    static var GEN_COLOR_CODE : String {
        get {
            return "#E63462"
        }
    }

    
    static var EVENT_FEED_URL : String {
        get {
            return DEV_MODE ? "https://feed-servers-dev.theq.live/v2/" : "https://feed.theq.live/v2/"
        }
    }
    
    static var baseUrl:String {
        get { //https://api-dev.us.theq.live/v2/games
            return DEV_MODE ? "https://api-dev.us.theq.live/v2/" : "https://api.us.theq.live/v2/"
        }
    }
    
    
    static var appName : String = "The Q"
    
}
