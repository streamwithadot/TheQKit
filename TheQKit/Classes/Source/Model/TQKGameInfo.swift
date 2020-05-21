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

public enum TQKGameType : String {
    case TRIVIA = "TRIVIA"
    case POPULAR = "POPULAR"
}

public enum TQKWinCondition : String {
    case POINTS = "POINTS"
    case ELIMINATION = "ELIMINATION"
}

/// Optional object to configure in game UI
///
/// - Parameters:
///     - logoOverride: *Optional* Image to override the default logo (found in upper right)
///     - colorCode: *Optional* override the color theme of the game
///     - useLongTimer: *Optional* temporary workaround to use a 15 second countdown timer
///     - logoOverride: *Optional* the logo in the upper right of the game, will override the default or the network badge from a game theme if avaliable
///     - playerBackgroundColor: *Optinal* sets the backgroundcolor of the player, default to clear
///     - useThemeAsBackground: *Optional* tells the player to use the theme image as a background. Note: leave playerBackgroundColor as clear to see this
///     - isEliminationDisabled: *Optional* Users will never know if they are eliminated or not, simulates a non-elimination game mode
public struct TQKGameOptions {
   
    var logoOverride: UIImage? = nil
    var colorCode : String? = nil
    var useLongTimer : Bool = false
    var playerBackgroundColor : UIColor? = UIColor.clear
    var useThemeAsBackground : Bool = false
    var useThemeColors : Bool = false
    var correctBackgroundColor : UIColor = UIColor.init(red: 50, green: 194, blue: 116, alpha: 0.8)
    var incorrectBackgroundColor : UIColor = UIColor.init(red: 230, green: 52, blue: 98, alpha: 0.8)
    var questionBackgroundAlpha : CGFloat = 0.8
    var isEliminationDisabled : Bool = false
    
    public init(logoOverride : UIImage? = nil,
                colorCode: String? = nil,
                useLongTimer: Bool? = false,
                playerBackgroundColor: UIColor? = UIColor.clear,
                useThemeAsBackground: Bool? = false,
                useThemeColors: Bool? = false,
                correctBackgroundColor: UIColor? = UIColor.init(red: 50, green: 194, blue: 116, alpha: 0.8),
                incorrectBackgroundColor: UIColor? = UIColor.init(red: 230, green: 52, blue: 98, alpha: 0.8),
                questionBackgroundAlpha: CGFloat? = 0.8,
                isEliminationDisabled: Bool? = false) {
        
               self.logoOverride = logoOverride
               self.colorCode = colorCode
               self.useLongTimer = useLongTimer!
               self.playerBackgroundColor = playerBackgroundColor!
               self.useThemeAsBackground = useThemeAsBackground!
               self.useThemeColors = useThemeColors!
               self.correctBackgroundColor = correctBackgroundColor!
               self.incorrectBackgroundColor = incorrectBackgroundColor!
               self.questionBackgroundAlpha = questionBackgroundAlpha!
               self.isEliminationDisabled = isEliminationDisabled!
           }
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
    public var winCondition : TQKWinCondition = .ELIMINATION
    public var hlsUrl : String?
    
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
        winCondition <- map["winCondition"]
        hlsUrl <- map["hlsUrl"]
        
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




struct TQKGameStats : Mappable {
    
    var leaderBoardList : [TQKGameStatItem]?
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        leaderBoardList <- map["leaderboard"]
    }
}


struct TQKGameStatItem : Mappable {

    var score : NSNumber?
    var username : String?
    var profilePicUrl : String?
    var id : String?
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        score <- map["score"]
        username <- map["username"]
        profilePicUrl <- map["profilePicUrl"]
        id <- map["id"]
    }

}


