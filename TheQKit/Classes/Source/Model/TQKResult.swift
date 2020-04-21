//
//  Result.swift
//  theq
//
//  Created by Will Jamieson on 10/30/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 QuestionResult %@ {
 "results" : [
 {
 "questionId" : "b7f9d8c2-0475-11e9-8219-bbe3756a9bf8",
 "correct" : true,
 "response" : "wooh",
 "responses" : 1,
 "userResponseRatio" : 100
 }
 ],
 "questionType" : "POPULAR",
 "canRedeemHeart" : false,
 "gameId" : "2350881e-928d-411e-9290-5328b2c283ce",
 "questionId" : "b7f9d8c2-0475-11e9-8219-bbe3756a9bf8",
 "correctResponse" : "wooh",
 "active" : false,
 "selection" : "wooh",
 "id" : 1545324393496
 }
 */

struct TQKResult: Mappable{
    
    var questionId: String?
    var active: Bool?
    var id: String?
    var answerId: String?
    var question: String?
    var choices: [TQKChoice]?
    var selection: String!
    var categoryId : String?
    var canRedeemHeart : Bool = false
    var canUseSubscription : Bool = false
    var results : [TQKPopularAnswers]?
    var questionType : TQKQuestionType = .TRIVIA
    var correctResponse : String?
    var pointValue : NSNumber?
    var score : NSNumber?
    
    var isMultipleChoice : Bool = false
    var isFreeformText : Bool = false
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        active <- map["active"]
        questionId 	<- map["questionId"]
        question <- map["question"]
        choices <- map ["choices"]
        id <- map ["id"]
        answerId <- map ["answerId"]
        selection <- map["selection"]
        categoryId <- map["categoryId"]
        canRedeemHeart <- map["canRedeemHeart"]
        canUseSubscription <- map["canUseSubscription"]
        results <- map["results"]
        questionType <- map["questionType"]
        correctResponse <- map["correctResponse"]
        pointValue <- map["pointValue"]
        score <- map["score"]
        
        isMultipleChoice = (questionType == TQKQuestionType.TRIVIA || questionType == TQKQuestionType.CHOICE_SURVEY)
        isFreeformText = (questionType == TQKQuestionType.POPULAR || questionType == TQKQuestionType.TEXT_SURVEY)
    }
    
}

struct TQKChoice: Mappable{
    
    var id: String?
    var choice: String?
    var questionId: String?
    var correct: Bool?
    var responses: Int?
    var pointValue : NSNumber?
    
    init?(map: Map) {
        
    }
    
    
    mutating func mapping(map: Map) {
        id     <- map["id"]
        questionId     <- map["questionId"]
        choice <- map["choice"]
        correct <- map["correct"]
        responses <- map["responses"]
        pointValue <- map["pointValue"]
    }
}

/*
 PopularAnswerResult(
 questionId: UUID,
 answer: String,
 correct: Boolean,
 responses: Int,
 percentage: Double)      // Percentage of population that selected answer

 
 case class ResponseResult(
 questionId: UUID,
 response: String,
 correct: Boolean,
 responses: Int,
 userResponseRatio: Double,  // Percentage of population that selected answer
 // Choice Specific Fields
 id: Option[UUID],
 choice: Option[String])
 
 */

struct TQKPopularAnswers: Mappable{
    
    var id: String?
    var questionId: String?
    var response: String?
    var correct: Bool = false
    var userResponseRatio: Double?
    var responses: Int?
    
    
    init?(map: Map) {
        
    }
    
    
    mutating func mapping(map: Map) {
        id     <- map["id"]
        questionId     <- map["questionId"]
        response <- map["response"]
        correct <- map["correct"]
        userResponseRatio <- map["userResponseRatio"]
        responses <- map["responses"]
        
    }
}
