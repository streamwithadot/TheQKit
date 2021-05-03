# TheQKit

[![Version](https://img.shields.io/cocoapods/v/TheQKit.svg?style=flat)](https://cocoapods.org/pods/TheQKit)
[![Platform](https://img.shields.io/cocoapods/p/TheQKit.svg?style=flat)](https://cocoapods.org/pods/TheQKit)

# What's New? 1.2.6

1.2.6 adds a "Full Web Experience" route, that allows new game features to be included without updating the SDK.
    - a 'partnerName' parameter added to the initilization that is defined in the partner admin console.
    - a 'fullWebExp' parameter in TQKGameOptions to launch the game in that mode when set to 'true'
    - a 'firebaseToken' parameter in TQKGameOptions that is required to use the new "Full Web Experience" mode. This is the authentication token that Firebase Authentication will provide.
    
These three parameters added to the initlization or game options will allow a web player using the user assocatiated with the Firebase Token for existing users, or a new user created automatically.
    

1.2.5 adds an optional param to the TQKGameOptions, alwaysUseHLS, when set to true will override the default behavior of using the LLHS whenever possible.

# Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Login / Authentication and Setup instructions

1) Always change the bundle identifier to one that is accosiated with your developer account.

2) To use the Example app either Firebase or AccountKit (with "Sign in with Apple" coming soon) will need to be utilized and setup on the app and that login flow implemented. Once a user has been authenticated through these services can you pass the relative information to the SDK to create a user on The Q platform. 

    2a) For Firebase this includes adding the GoogleServices.plist file and any info.plist modifications

# Installation 

TheQKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TheQKit'
```
or if adding from a local source

```ruby
pod 'TheQKit', :path => '<path to directory with the .podspec>'
```

# Getting Started

## Initialize

Import TheQKit into AppDelegate.swift, and initialize TheQKit within `application:didFinishLaunchingWithOptions:` using the token provided by our support team

The `THEQKIT_TOKEN` allows for only this tenants games to be visable by TheQKit and is required.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    TheQKit.initialize(baseUrl: "<Provided Base Url>", webPlayerUrl: "<Provided Web Player Url>",token: "<Provided Account Token>")
    
    //Optional - Disable the built in profanity filter on freeform user answers
    //TheQKit.disableProfanityFilter()
    
    //Optional - Allow users to screen record during games
    //TheQKit.enableScreenRecording()
}
```
Full list of paramters when initilizing, and defaults provided
```swift
/// - Parameters:
///     - baseURL: *Required* base URL to partners domain 
///     - locale: *Optional* language / region 
///     - moneySymbol: *Optional* meant to always match the one the locale would use
///     - appName: *Optional* name of the app to be shown to users 
///     - webPlayerURL: *Optional* url for alternative / optional webplayer (provided by Stream Live, Inc.) 
///     - token: *Required* partner key (provided by Stream Live, Inc.) 
public class func initialize(baseURL:String, locale:String? = "en_US", moneySymbol:String? = "$", appName:String? = "The Q", webPlayerURL:String? = nil, token : String){..}
```

## User Authentication

Integration with Account Kit must be done app side, after verification with those providers, pass along the token string, and account ID to login existing user  / enter user creation flow

Sign in with Apple
```swift
if let token = appleIDCredential.identityToken?.base64EncodedString() {
    let userIdentifier = appleIDCredential.user
    
    TheQKit.LoginQUserWithApple(userID: userIdentifier, identityString: token) { (success) in
        //success : Bool ... if user successfully is logged in, if no user exist will be false and account creation flow launches
    }
}
```

Account Kit: *DEPRECATED: with AccountKit shuting down, this method will go away, though avaliable for existing users or apps that are not setup for firebase phone #*
```swift
let token = AKFAccountKit(responseType: .accessToken).currentAccessToken
let accountID:String = token!.accountID
let tokenString:String = token!.tokenString

TheQKit.LoginQUserWithAK(accountID: accountID, tokenString: tokenString) { (success) in
    //success : Bool ... if user successfully is logged in, if no user exist will be false and account creation flow launches
}
```

Firebase: has a few different ways to accomplish the same thing, all ultimately end up with a user ID and token that get passed on to the TheQKit
```swift
extension YourVC: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {

        if let user = authDataResult?.user {
            user.getIDTokenResult(completion: { (result, error) in
                let token = result?.token
                let userId:String = user.uid

                TheQKit.LoginQUserWithFirebase(userId: userId, tokenString: token) { (success) in
                    //success : Bool ... if user successfully is logged in, if no user exist will be false and account creation flow launches
                }
            })
        }
    }
}
```

Additionally you can skip the username selection and provide one the user may already have associated with your app. If already taken a number will incrementally be added

```swift    
TheQKit.LoginQUserWithApple(userID: userIdentifier, identityString: token, username : "username") { (success) in
     //success : Bool ... if user successfully is logged in, no account creation flow
}

*DEPRECATED*
TheQKit.LoginQUserWithAK(accountID: "accountID", tokenString: "tokenString", username : "username") { (success) in
    //success : Bool ... if user successfully is logged in, no account creation flow
}

TheQKit.LoginQUserWithFirebase(userId: "uid", tokenString: "tokenString", username : "username") { (success) in
    //success : Bool ... if user successfully is logged in, if no user exist will be false and account creation flow launches
}
```

Logout and clear stored user

```swift
TheQKit.LogoutQUser()
```

# Launching / Playing Games
New with Version 1.1.4, an optional gameOptions parameter when launching a game allows configuration of various UI elements 
```swift
///     - logoOverride: *Optional* the logo in the upper right of the game, will override the default or the network badge from a game theme if avaliable
///     - colorCode: *Optional* override the color theme of the game - supercedes useThemeColors
///     - playerBackgroundColor: *Optinal* sets the backgroundcolor of the player, default to clear
///     - useThemeAsBackground: *Optional* tells the player to use the theme image as a background. Note: leave playerBackgroundColor as clear to see this
///     - useThemeColors: *Optional* Overrides the text color and background overloay of questions / results with default color code, text color code from the theme object configured from the admin portal
///     - correctBackgroundColor: *Optional* overrides the default color of the correct screen
///     - incorrectBackgroundColor: *Optional* overrides the default color of the incorrect screen
///     - questionBackgroundAlpha: *Optional* allows the opacity of the question/incorrect/correct screens to be changes. (0.0 .. 1.0)
///     - isEliminationDisabled: *Optional* Users will never know if they are eliminated or not, simulates a non-elimination game mode
///     - useWebPlayer: *Optional* toggles from using the native AVPlayer to using an embedded webplayer via WebKit. MUST HAVE "webPlayerURL" DEFINED IN TheQKit.initialize(...) IN THE APP DELEGATE TO WORK
///     - alwaysUseHLS: *Optional* forces the player to use the HLS url even if the LLHLS url is present - default behavior uses LLHLS if present.

let options = TQKGameOptions(logoOverride: <#T##UIImage?#>,
                            colorCode: <#T##String?#>,
                            playerBackgroundColor: <#T##UIColor?#>,
                            useThemeAsBackground: <#T##Bool?#>,
                            useThemeColors: <#T##Bool?#>,
                            correctBackgroundColor: <#T##UIColor?#>,
                            incorrectBackgroundColor: <#T##UIColor?#>,
                            questionBackgroundAlpha: <#T##CGFloat?#>,
                            isEliminationDisabled: <#T##Bool?#>,
                            useWebPlayer: <#T##Bool?#>,
                            alwaysUseHLS: <#T##Bool?#>)

```

## Play Games - With UI
A schedule controller that will display game "cards" can be populated into any container view. These cards can be clicked on when the game is active and a logged in user exist.
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "name_of_your_seque" {
        let connectContainerViewController = segue.destination as UIViewController
        TheQKit.showCardsController(fromViewController: connectContainerViewController, gameOptions: options)
    }
}
```

## Play Games - No UI
To play a game with The Q Kit, after initilizing you will have to check and launch games with. 
```swift
TheQKit.CheckForGames { (isActive, gamesArray) in
    //isActive : Bool ... are any games returned currently active
    //gamesArray : [TQKGame]? ... active and non active games
}
TheQKit.LaunchGame(theGame : TQKGame, gameOptions: options) //Checks if specified game is active and launches it
TheQKit.LaunchActiveGame(gameOptions: options)            //checks for an active game and launches it if avaliable
```

## Update Username / email / phone
Update username
```swift
TheQKit.updateUsername(username: " ") { (success, errorMsg) in
     //success : Bool ... if user record is updates succesfully
     //errorMsg : error msg if one
}
```
Update the user with either email, phone #, or both.
```swift
TheQKit.updateUser(email:"<Optional Email>", phoneNumber:"<Optional Phone#>") { (success, errorMsg) in
     //success : Bool ... if user record is updates succesfully
     //errorMsg : error msg if one
}
```

## Customize Color Theme
Games have a default color theme, if you wish to over ride that, pass in the colorCode as a hex string to the launch functions
```swift
TheQKit.LaunchGame(theGame : TQKGame, colorCode : "#E63462") 
TheQKit.LaunchActiveGame(colorCode : "#E63462")         
```

## Get $ 

Users who win money, can request to cashout. To begin this request call the method below. A dialogue asking for the paypal email will show, then success/failure will show after the request

```swift
TheQKit.CashOutWithUI()
```

Or pass an email to this method to bypass the default dialogue

```swift
TheQKit.CashOutNoUI(email: String)
```

## Leaderboards

```swift
//This function retrieves scores for each category for the signed in user
TheQKit.getCurrentUserScores { (success, scores) in
    //success
    //scores: user scores object
}

//This function retrieves the current leaderboard, seperated into season info and category/scores
TheQKit.getCurrentLeaderboard { (success, lb) in
    //success
    //lb: leaderboard object containing season and category info
}

//Combination function that will return either
TheQKit.getCurrentLeaderboardAndUserScores { (success, lb, scores) in
    //success
    //lb: leaderboard object containing season and category info
    //scores: user scores object
}
```

## Observable Keys 

Events that happen during the game; add an observer to add custom event tracking. Add the extension in for easy use or use the string literal. Each event return a [String:Any] dictionry of metadata relevant to the event


```swift 
NotificationCenter.default.addObserver(self, selector: #selector(errorSubmittingAnswer), name: .errorSubmittingAnswer, object: nil)

extension Notification.Name {
    static let choiceSelected = Notification.Name("TQK_GAME_CHOICE_SELECTED")
    static let errorSubmittingAnswer = Notification.Name("TQK_GAME_ERROR_SUB_ANSWER")
    static let screenRecordingDetected = Notification.Name("TQK_GAME_SCREEN_RECORDING")
    static let airplayDetected = Notification.Name("TQK_GAME_AIRPLAY")
    static let correctAnswerSubmitted = Notification.Name("TQK_GAME_CORRECT_ANS_SUB")
    static let incorrectAnswerSubmitted = Notification.Name("TQK_GAME_WRONG_ANS_SUB")
    static let enteredGame = Notification.Name("TQK_ENTERED_GAME")
    static let gameWon = Notification.Name("TQK_GAME_WON")
}
```

## Author

Spohn, spohn@stre.am and the lovely people at Stream Live, Inc.

## License

Copyright (c) 2020 Stream Live, Inc.
