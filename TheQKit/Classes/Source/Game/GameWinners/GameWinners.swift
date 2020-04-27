//
//  GameWinners.swift
//  theq
//
//  Created by Jonathan Spohn on 2/13/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
import ObjectMapper

struct GameWinners : Mappable {
    
    var id : Double = 0
    var gameId : String = ""
    var winnerCount : Int = 0
    var winners : [GameWinner]?
    var won : Bool = false
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        gameId <- map["gameId"]
        winnerCount <- map["winnerCount"]
        winners <- map["winners"]
        won <- map["won"]
    }
}


struct GameWinner : Mappable {

    var user : String = ""
    var pic : String = ""
    
    init?(map: Map) {
        
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        user <- map["user"]
        pic <- map["pic"]
    }

}
