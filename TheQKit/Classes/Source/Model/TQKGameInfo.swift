//
//  GameInfo.swift
//  theq
//
//  Created by Jonathan Spohn on 5/15/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
import ObjectMapper

public struct TQKSchedule : Mappable {
    public var arrOfGames : [TQKGames]?
    
    public init?(map: Map) {
        
    }
    
    public init () {
        arrOfGames = []
    }
    
    mutating public func mapping(map: Map) {
        
    }
}

public struct TQKGames : Mappable {
    public var actualDate: Date?
    public var dateString: String?
    public var games : [TQKGame]?
        
    public init?(map: Map) {
        
    }
    
    public init(){
        
    }
    
    public init (actualDate : Date, dateString : String, games : [TQKGame]) {
        self.actualDate = actualDate
        self.dateString = dateString
        self.games = games
        
    }
    
    mutating public func mapping(map: Map) {
        games <- map["games"]
    }
}

enum TQKGameType : String {
    case TRIVIA
    case POPULAR
}


public struct TQKGame : Mappable {
    
    /*
         {
         "reward" : 500,
         "id" : "21197da9-bece-4f86-86d4-dd08aa5e0cbc",
         "locked" : false,
         "active" : false,
         "scheduled" : 1526430600000,
         "streamUrl" : "SCHEDULED"
         }
     */
    public var reward : Int = 0
    public var id : String?
    public var locked : Bool = false
    public var active : Bool = false
    public var scheduled : Double = 0
    public var streamUrl : String?
    public var host : String?
    public var sseHost : String?
    public var title : String = "\(TQKConstants.appName) Game Title"
    public var dateString : String?
    public var theme : TQKTheme = TQKTheme()
    public var lastQuestionHeartEligible : Int?
    public var heartsEnabled : Bool = false
    public var customRewardText : String?
    public var eligible : Bool = true
    public var notEligibleMessage : String?
    public var subscriberOnly : Bool = false
    public var gameType : String = "TRIVIA"
    public var adCode : String?
    public var testMode : Bool = false
    public var videoDisabled : Bool = false
    public var backgroundImageUrl : String?
    
    public init?(map: Map) {
        
    }
    
    public init () {
        
    }
    
    mutating public func mapping(map: Map) {
        reward <- map["reward"]
        id <- map["id"]
        active <- map["active"]
        scheduled <- map["scheduled"]
        streamUrl <- map["streamUrl"]
        host <- map["host"]
        sseHost <- map["sseHost"]
        theme <- map["theme"]
        lastQuestionHeartEligible <- map["lastQuestionHeartEligible"]
        heartsEnabled <- map["heartsEnabled"]
        customRewardText <- map["customRewardText"]
        eligible <- map["eligible"]
        notEligibleMessage <- map["notEligibleMessage"]
        subscriberOnly <- map["subscriberOnly"]
        gameType <- map["gameType"]
        adCode <- map["adCode"]
        testMode <- map["testMode"]
        videoDisabled <- map["videoDisabled"]
        backgroundImageUrl <- map["backgroundImageUrl"]
        
        //TEST CODE
//        adCode = Constants.AD_SECOND_CODE
    }
    
}

public struct TQKTheme : Mappable {
    
    public var altTextColorCode : String = "#FFFFFF"
    public var id : String = "28b2a929-4324-47bc-af20-fe96c1e50160"
    public var textColorCode : String = "#FFFFFF"
    public var displayName : String = ""
    public var backgroundImageUrl : String = ""
    public var networkBadgeUrl : String?
    public var defaultColorCode : String = TQKConstants.GEN_COLOR_CODE
    public var scheduleBackgroundImageUrl : String?
    
    public init?(map: Map) {
        
    }
    
    public init () {
        
    }
    
    public mutating func mapping(map: Map) {
        altTextColorCode <- map["altTextColorCode"]
        id <- map["id"]
        textColorCode <- map["textColorCode"]
        displayName <- map["displayName"]
        backgroundImageUrl <- map["backgroundImageUrl"]
        networkBadgeUrl <- map["networkBadgeUrl"]
        defaultColorCode <- map["defaultColorCode"]
        scheduleBackgroundImageUrl <- map["scheduleBackgroundImageUrl"]
    }
}


