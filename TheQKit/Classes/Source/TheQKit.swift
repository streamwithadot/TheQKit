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
import Mixpanel

/// TheQKit public functions
public class TheQKit {
    
    init() {}
    
    /// Easy reference to the class's bundle
    public static var bundle:Bundle {
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    /// Overriden initializer
    ///
    /// - Parameters:
    ///     - baseURL: base URL to partners domain
    ///     - locale: language / region
    ///     - moneySymbol: meant to always match the one the locale would use
    ///     - appName: name of the app to be shown to users
    public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q"){
        TheQManager.sharedInstance.initialize(baseURL:baseURL, locale: locale!, moneySymbol: moneySymbol!, appName: appName!)
    }
    
    /// Overriden initializer with token
    ///
    /// - Parameters:
    ///     - baseURL: base URL to partners domain
    ///     - locale: language / region
    ///     - moneySymbol: meant to always match the one the locale would use
    ///     - appName: name of the app to be shown to users
    ///     - token: partner key (provided by Stream Live, Inc.)
    public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q", token : String){
        TheQManager.sharedInstance.initialize(baseURL:baseURL, locale: locale!, moneySymbol: moneySymbol!, appName: appName!, token: token)
    }
    
    /// Disable the built in profanity filter on user submissions
    public class func disableProfanityFilter(){
        TheQManager.sharedInstance.disableProfanityFilter()
    }
    
    /// Disable the built in screen recording prevention
    public class func enableScreenRecording(){
        TheQManager.sharedInstance.enableScreenRecording()
    }
    
    /// Getter for profanity filter override flag
    ///
    /// - Returns: A bool representing the profanity override flag
    public class func profanityFilter() -> Bool{
        return TheQManager.sharedInstance.profanityFlag
    }
        
    /// Getter for profanity filter override flag
    ///
    /// - Returns: A bool representing if screen recording is enabled
    public class func canRecordScreen() -> Bool{
        return TheQManager.sharedInstance.canRecordScreen
    }
    
    /// Logs a user in using AccountKit, setting a user object into NSUserDefaults
    ///
    /// - Parameters:
    ///     - accountID: AccountKit provided ID
    ///     - tokenString: AccountKit provided Token String
    ///     - username: *Optional* provide the username to be used
    ///     - completionHandler: callback with success/failure bool
    ///
    /// - Returns: A bool representing success / failure inside the completion handler
    public class func LoginQUserWithAK(accountID: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
        TheQManager.sharedInstance.LoginQUserWithAK(accountID: accountID, tokenString: tokenString, username: username, completionHandler: completionHandler)
    }
    
    /// Logs a user in Firebase, setting a user object into NSUserDefaults
    ///
    /// - Parameters:
    ///     - userId: Firebase provided ID
    ///     - tokenString: Firebase provided Token String
    ///     - username: *Optional* provide the username to be used
    ///     - completionHandler: callback with success/failure bool
    ///
    /// - Returns: A bool representing success / failure inside the completion handler
    public class func LoginQUserWithFirebase(userId: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
            TheQManager.sharedInstance.LoginQUserWithFirebase(userId: userId, tokenString: tokenString, username: username, completionHandler: completionHandler)
    }
    
    /// Logs a user in using Sign in with Apple, setting a user object into NSUserDefaults
    ///
    /// - Parameters:
    ///     - userID: userID from apple
    ///     - identityString: base64EncodedString  of identityToken
    ///     - username: *Optional* provide the username to be used
    ///     - completionHandler: callback with success/failure bool
    ///
    /// - Returns: A bool representing success / failure inside the completion handler
    public class func LoginQUserWithApple(userID: String, identityString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
        TheQManager.sharedInstance.LoginQUserWithApple(userID: userID, identityString: identityString, username: username, completionHandler: completionHandler)
    }
    
    /// Logs a user in OneAccount, setting a user object into NSUserDefaults
    ///
    /// - Parameters:
    ///     - tokenString: OneAccount provided Token String / Access Token
    ///     - username: *Optional* provide the username to be used
    ///     - completionHandler: callback with success/failure bool
    ///
    /// - Returns: A bool representing success / failure inside the completion handler
    public class func LoginQUserWithOneAccount(tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void ) {
            TheQManager.sharedInstance.LoginQUserWithOneAccount(tokenString: tokenString, username: username, completionHandler: completionHandler)
    }
  
    /// Logout a logged in user - clears SDK specifics in NSUserDefaults
    public class func LogoutQUser() {
        TheQManager.sharedInstance.LogoutQUser()
    }
    
    /// Checks for scheduled games, returning a flag if any of them are currently active
    ///
    /// - Parameters:
    ///     - completionHandler: callback with active game flag and array of scheduled games
    ///
    /// - Returns: callback with active game flag and array of scheduled games
    public class func CheckForGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) {
        return TheQManager.sharedInstance.CheckForGames(completionHandler: completionHandler)
    }
    
    /// Launches a specified game
    ///
    /// - Parameters:
    ///     - theGame: TQKGame object
    ///     - colorCode: *Optional* override the color theme of the game
    ///     - useLongTimer: *Optional* temporary workaround to use a 15 second countdown timer
    ///     - logoOverride: *Optional* the logo in the upper right of the game, will override the default or the network badge from a game theme if avaliable
    ///     - playerBackgroundColor: *Optinal* sets the backgroundcolor of the player, default to clear
    ///     - useThemeAsBackground: *Optional* tells the player to use the theme image as a background. Note: leave playerBackgroundColor as clear to see this
    ///     - isEliminationDisabled: *Optional* Users will never know if they are eliminated or not, simulates a non-elimination game mode
    public class func LaunchGame(theGame : TQKGame,
                                 colorCode : String? = nil ,
                                 useLongTimer : Bool? = false,
                                 logoOverride: UIImage? = nil,
                                 playerBackgroundColor: UIColor? = nil,
                                 useThemeAsBackground: Bool? = false,
                                 isEliminationDisabled: Bool? = false,
                                 completed: @escaping (_ success : Bool) -> Void ){
        TheQManager.sharedInstance.LaunchGame(theGame: theGame,
                                              colorCode: colorCode,
                                              useLongTimer: useLongTimer,
                                              logoOverride: logoOverride,
                                              playerBackgroundColor: playerBackgroundColor,
                                              useThemeAsBackground: useThemeAsBackground,
                                              isEliminationDisabled: isEliminationDisabled,
                                              completed: completed)
    }
    
    /// Launches the most recent active game
    ///
    /// - Parameters:
    ///     - logoOverride: *Optional* the logo in the upper right of the game, will override the default or the network badge from a game theme if avaliable
    ///     - playerBackgroundColor: *Optinal* sets the backgroundcolor of the player, default to clear
    ///     - useThemeAsBackground: *Optional* tells the player to use the theme image as a background. Note: leave playerBackgroundColor as clear to see this
    ///     - isEliminationDisabled: *Optional* Users will never know if they are eliminated or not, simulates a non-elimination game mode
    public class func LaunchActiveGame(logoOverride: UIImage? = nil,
                                       playerBackgroundColor: UIColor? = nil,
                                       useThemeAsBackground: Bool? = false,
                                       isEliminationDisabled: Bool? = false,
                                       completed: @escaping (_ success : Bool) -> Void) {
        TheQManager.sharedInstance.LaunchActiveGame(colorCode: nil,
                                                    logoOverride: logoOverride,
                                                    playerBackgroundColor: playerBackgroundColor,
                                                    useThemeAsBackground: useThemeAsBackground,
                                                    isEliminationDisabled: isEliminationDisabled,
                                                    completed: completed)
    }
    
    /// Prompts the user for an email and performs a cash out request
    ///
    /// - Returns: bool for success/failer
    @discardableResult
    public class func CashOut() -> Bool {
        return TheQManager.sharedInstance.CashOut()
    }
    
    /// Uses the specified email and performs a cash out request
    ///
    /// - Parameters:
    ///     - email: email
    /// - Returns: bool for success/failer
    @discardableResult
    public class func CashOutNoUI(email:String) -> Bool {
        return TheQManager.sharedInstance.CashOutNoUI(email: email)
    }
    
    /// Populates a given container view with the cards schedule controller, allowing a UI for up to 10 scheduled games
    ///
    /// - Parameters:
    ///     - viewController: container view where the cards controller will populate
    ///     - logoOverride: *Optional* the logo in the upper right of the game, will override the default or the network badge from a game theme if avaliable
    ///     - playerBackgroundColor: *Optinal* sets the backgroundcolor of the player, default to clear
    ///     - useThemeAsBackground: *Optional* tells the player to use the theme image as a background. Note: leave playerBackgroundColor as clear to see this
    ///     - isEliminationDisabled: *Optional* Users will never know if they are eliminated or not, simulates a non-elimination game mode
    public class func showCardsController(fromViewController viewController : UIViewController,
                                          logoOverride: UIImage? = nil,
                                          playerBackgroundColor: UIColor? = nil,
                                          useThemeAsBackground: Bool? = false,
                                          isEliminationDisabled: Bool? = false){
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let storyboard = UIStoryboard(name: "TQKStoryboard", bundle: bundle)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "TQKCardsViewController") as! TQKCardsViewController
        
        vc.view.bounds = CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height)
        
        if(logoOverride != nil){
            vc.logoOverride = logoOverride
        }
        
        vc.playerBackgroundColor = playerBackgroundColor
        vc.useThemeAsBackground = useThemeAsBackground!
        vc.isEliminationDisabled = isEliminationDisabled!
        viewController.addChild(vc)
        viewController.view.addSubview(vc.view)
        vc.didMove(toParent: viewController)
    }
    
    /// Checks for scheduled test games, returning a flag if any of them are currently active
    ///
    /// - Parameters:
    ///     - completionHandler: callback with active game flag and array of scheduled test games
    ///
    /// - Returns: callback with active game flag and array of scheduled test games
    public class func CheckForTestGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) {
        return TheQManager.sharedInstance.CheckForTestGames(completionHandler: completionHandler)
    }
    
    /// Returns the current logged in user, or nil
    ///
    /// - Returns: TQKUser object, nil if not logged in
    public class func getUser() -> TQKUser? {
        return TheQManager.sharedInstance.getUser()
    }
    
    /// Returns the partnerCode, or nil
    ///
    /// - Returns: partnerCode, nil if not set
    public class func getPartnerCode() -> String? {
        return TheQManager.sharedInstance.getPartnerCode()
    }
    
    /// Manually refreshes tokens
    public class func refreshTokens(completionHandler: @escaping (_ success : Bool) -> Void) {
        TheQManager.sharedInstance.refreshToken(completionHandler: completionHandler)
    }
    
    /// Manually refresh the user object (this cannot occur more than once every 5 minutes to prevent spamming)
    public class func refreshUserObject() {
        TheQManager.sharedInstance.updateUserObject()
    }
    
    /// Update username
    /// - Parameters:
    ///     - username: *Optional*
    public class func updateUsername(username:String, completionHandler: @escaping (_ success: Bool, _ errorrMsg: String) -> Void){
        TheQManager.sharedInstance.updateUsername(username: username, completionHandler: completionHandler)
    }
    
    /// Update certain values of the user
    /// - Parameters:
    ///     - email: *Optional*
    ///     - phoneNumber: *Optional*
    ///     - username: *Optional*
    public class func updateUser(email: String? = nil, phoneNumber: String? = nil, completionHandler: @escaping (_ success: Bool, _ errorrMsg: String) -> Void){
        TheQManager.sharedInstance.updateUser(email: email, phoneNumber: phoneNumber, completionHandler: completionHandler)
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
    static let userLogout = Notification.Name("TQK_USER_LOGOUT")
    
    static let playQuestionAudio = Notification.Name("TQK_PLAY_QUESTION_AUDIO")
    static let stopQuestionAudio = Notification.Name("TQK_STOP_QUESTION_AUDIO")
    static let sharedToSnapchat = Notification.Name("TQK_SNAPCHAT_SHARE")
    
    static let gameEndedAndEliminated = Notification.Name("TQK_GAME_END_ELIMINATED")

}

