//
//  Question.swift
//  theq
//
//  Created by Will Jamieson on 10/25/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

public enum TQKQuestionType : String {
    case TRIVIA = "TRIVIA"
    case POPULAR = "POPULAR"
    case TEXT_SURVEY = "TEXT_SURVEY"
    case CHOICE_SURVEY = "CHOICE_SURVEY"
}

struct TQKResetMsg: Mappable{
    
    var heartEligible : Bool = false
    var active : Bool = false
    var canRedeemHeart : Bool = false

    init?(map: Map) {
        
    }
        
    mutating func mapping(map: Map) {
        heartEligible <- map["heartEligible"]
        active <- map["id"]
        canRedeemHeart <- map["canRedeemHeart"]
    }
    
}

struct TQKQuestion: Mappable{
    
//    var gameId: String?
    var questionId: String?
    var question: String?
    var secondsToRespond: Int?
    var choices: [TQKChoice]?
    var number: Int = 0
    var total: Int = 0
    var id : String?
    var categoryId : String = "GEN"
    var wasMarkedIneligibleForTracking : Bool = false
    var questionType : TQKQuestionType = .TRIVIA
    var canRedeemHeart : Bool = false
    var pointValue : NSNumber?

    var isMultipleChoice : Bool = false
    var isFreeformText : Bool = false
    
    var pointOverride : Bool = false
    
    init?(map: Map) {
        
    }
        
    mutating func mapping(map: Map) {
//        gameId     <- map["gameId"]
        questionId <- map["questionId"]
        id <- map["id"]
        question <- map["question"]
        choices <- map ["choices"]
        secondsToRespond <- map ["secondsToRespond"]
        number <- map ["number"]
        total <- map ["total"]
        categoryId <- map ["categoryId"]
        questionType <- map["questionType"]
        canRedeemHeart <- map["canRedeemHeart"]
        pointValue <- map["pointValue"]
        
        isMultipleChoice = (questionType == TQKQuestionType.TRIVIA || questionType == TQKQuestionType.CHOICE_SURVEY)
        isFreeformText = (questionType == TQKQuestionType.POPULAR || questionType == TQKQuestionType.TEXT_SURVEY)
        
        if let _ = choices?.first(where: {$0.pointValue != nil}) {
            pointOverride = true
        }
    }
    
}

struct TQKGameStatus: Mappable{
    var id: Double?
    var active: Bool?
    var question: TQKQuestion?
    var heartEligible : Bool = false
    var score : NSNumber?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        id     <- map["id"]
        active <- map["active"]
        question <- map ["question"]
        heartEligible <- map["heartEligible"]
        score <- map["score"]
    }
}
