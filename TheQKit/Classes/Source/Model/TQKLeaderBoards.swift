//
//  TQKLeaderboards.swift
//  theq
//
//  Created by Jonathan Spohn on 2/12/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

//Top level struct holding all leaderboard related data
public struct TQKLeaderboard : Mappable {
    var season : TQKSeason?
    var categories : [TQKCategory]? 
    
    public init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating public func mapping(map: Map) {
        season <- map["season"]
        categories <- map["categories"]
    }
}


/*
 Season(
 id: String,
 name: String,
 startDate: Long, // timestamp
 endDate: Long,   // timestamp
 active: Boolean) */
struct TQKSeason : Mappable {
    var id : String = ""
    var name : String = ""
    var startDate : Double?
    var endDate : Double?
    var active : Bool?
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        active <- map["active"]
    }
}

/*
 Category(
 id: String,
 name: String,
 code: String,
 description: String,
 active: Boolean,
 iconImageUrl: String,
 backgroundImageUrl: String,
 backgroundVideoUrl: String,
 colorCode: String,
 leaderboard: Option[Seq[LeaderboardEntry]]) */
struct TQKCategory : Mappable {
    var id : String = ""
    var name : String = ""
    var code : String = ""
    var description : String = ""
    var active : Bool = false
    var iconImageUrl : String = ""
    var backgroundImageUrl : String = ""
    var backgroundVideoUrl : String = ""
    var colorCode : String = TQKConstants.GEN_COLOR_CODE
    var leaderboard : [TQKLeaderboardEntry]? {
        didSet{
            if(!(leaderboard?.isEmpty)!){
                highest = leaderboard![0].score
                var count = 0
                for le in leaderboard! {
                    if(le.score == highest){
                        count = count + 1
                    }
                }
                split = Double(reward / count)
            }
        }
    }
    var reward : Int = 0
    var split : Double = 0
    var highest : Int = 0
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        code <- map["code"]
        description <- map["description"]
        active <- map["active"]
        iconImageUrl <- map["iconImageUrl"]
        backgroundImageUrl <- map["backgroundImageUrl"]
        backgroundVideoUrl <- map["backgroundVideoUrl"]
        colorCode <- map["colorCode"]
        reward <- map["reward"]
        leaderboard <- map["leaderboard"]
    }
}

/*
 LeaderboardEntry(
 userId: String,
 username: String,
 profilePicUrl: Option[String],
 score: Int)
 */
struct TQKLeaderboardEntry : Mappable {
    var userId : String = ""
    var username : String = ""
    var profilePicUrl : String = ""
    var score : Int = 0
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        username <- map["username"]
        profilePicUrl <- map["profilePicUrl"]
        score <- map["score"]
    }
}

/*
===== UN-CACHED ENDPOINTS =====
    
GET /v1/category/scores
Response:
{
    scores: {
        <categoryId1>: Int,
        <categoryId2>: Int,
        ...
        <categoryIdN>: Int
    }
} */
public struct TQKScores : Mappable {
    var scores : [TQKScore]?
    
    public init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    init(scores : [TQKScore]) {
        self.scores = scores
    }
    
    mutating public func mapping(map: Map) {
        scores <- map["scores"]
    }
    
    var propertyListRepresentation : String {
        let paramsJSON = JSON(scores!)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
        return paramsString
    }
}

/*
GET /v1/category/:id/scores
Response:
{
    score: Int
} */
struct TQKScore : Mappable {
    var score : Int = 0
    var categoryId : String = ""
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    init(score : Int, categoryId : String) {
        self.score = score
        self.categoryId = categoryId
    }
    
    mutating func mapping(map: Map) {
        score <- map["score"]
        categoryId <- map["categoryId"]
    }
    
    var propertyListRepresentation : [String:Any] {
        return ["score" : score, "categoryId" : categoryId]
    }
}


