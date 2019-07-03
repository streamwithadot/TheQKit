//
//  TheQKit.swift
//  TheQKit
//
//  Created by Jonathan Spohn on 1/17/19.
//  Copyright © 2019 Stream Live. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Mixpanel

public class TheQKit {
    
    init() {}
    
    
    public static var bundle:Bundle {
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q"){
        TheQManager.sharedInstance.initialize(baseURL:baseURL, locale: locale!, moneySymbol: moneySymbol!, appName: appName!)
    }
    
    public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q", token : String){
        TheQManager.sharedInstance.initialize(baseURL:baseURL, locale: locale!, moneySymbol: moneySymbol!, appName: appName!, token: token)
    }
    
    public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q", token : String, mixpanelToken : String){
        TheQManager.sharedInstance.initialize(baseURL:baseURL, locale: locale!, moneySymbol: moneySymbol!, appName: appName!, token: token, mixpanelToken: mixpanelToken)
    }
    
    public class func LoginQUserWithAK(accountID: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
        TheQManager.sharedInstance.LoginQUserWithAK(accountID: accountID, tokenString: tokenString, username: username, completionHandler: completionHandler)
    }
    
    public class func LoginQUserWithFirebase(userId: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
            TheQManager.sharedInstance.LoginQUserWithFirebase(userId: userId, tokenString: tokenString, username: username, completionHandler: completionHandler)
    }
    
    public class func LoginQUserWithTwilio(userId: String, tokenString: String, userName: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
//        TheQManager.sharedInstance.LoginQUserWithFirebase(userId: userId, tokenString: tokenString, completionHandler: completionHandler)
    }
    
    public class func LogoutQUser() {
        TheQManager.sharedInstance.LogoutQUser()
    }
    
    public class func CheckForGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) {
        return TheQManager.sharedInstance.CheckForGames(completionHandler: completionHandler)
    }
    
    public class func LaunchGame(theGame : TQKGame, colorCode : String? = nil ,useLongTimer : Bool? = false){
        TheQManager.sharedInstance.LaunchGame(theGame: theGame, colorCode: colorCode, useLongTimer: useLongTimer)
    }
    
    public class func LaunchActiveGame() {
        TheQManager.sharedInstance.LaunchActiveGame(colorCode: nil)
    }
    
    @discardableResult
    public class func CashOut() -> Bool {
        return TheQManager.sharedInstance.CashOut()
    }
    
    public class func testVideo(){
       TheQManager.sharedInstance.playTest()
    }
    
    public class func CheckForTestGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) {
        return TheQManager.sharedInstance.CheckForTestGames(completionHandler: completionHandler)
    }
    
    public class func getUser() -> TQKUser? {
        return TheQManager.sharedInstance.getUser()
    }
    
    public class func refreshTokens(completionHandler: @escaping (_ success : Bool) -> Void) {
        TheQManager.sharedInstance.refreshToken(completionHandler: completionHandler)
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension Notification.Name {
    static let showGameSubs = Notification.Name("TQK_SHOW_INGAME_SUBS")
    static let removeGameSubs = Notification.Name("TQK_REMOVE_INGAME_SUBS")
    static let choiceSelected = Notification.Name("TQK_GAME_CHOICE_SELECTED")
    static let errorSubmittingAnswer = Notification.Name("TQK_GAME_ERROR_SUB_ANSWER")
    static let screenRecordingDetected = Notification.Name("TQK_GAME_SCREEN_RECORDING")
    static let airplayDetected = Notification.Name("TQK_GAME_AIRPLAY")
    static let correctAnswerSubmitted = Notification.Name("TQK_GAME_CORRECT_ANS_SUB")
    static let incorrectAnswerSubmitted = Notification.Name("TQK_GAME_WRONG_ANS_SUB")
    static let enteredGame = Notification.Name("TQK_ENTERED_GAME")
    static let gameWon = Notification.Name("TQK_GAME_WON")
    static let userBanned = Notification.Name("TQK_USER_BANNED")
    static let showEliminatedAd = Notification.Name("TQK_SHOW_ELIMINATED_AD")
    static let showEndgameAd = Notification.Name("TQK_SHOW_ENDGAME_AD")
    
    static let playQuestionAudio = Notification.Name("TQK_PLAY_QUESTION_AUDIO")
    static let stopQuestionAudio = Notification.Name("TQK_STOP_QUESTION_AUDIO")

}

