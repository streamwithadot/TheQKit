//
//  TheQManager.swift
//  TheQKit
//
//  Created by Jonathan Spohn on 2/7/19.
//

import UIKit
import Alamofire
import SwiftyJSON
import Mixpanel

class TheQManager {
    
    var profanityFlag : Bool = true
    var canRecordScreen : Bool = false
    var mixpanelInstance : MixpanelInstance?
    static let sharedInstance = TheQManager()
    private var apiToken : String?
    private var loggedInUser : TQKUser? {
        get {
            if UserDefaults.standard.object(forKey: "myUser") != nil {
                let myUser = TQKUser(dictionary: UserDefaults.standard.object(forKey: "myUser") as! [String : Any])!
                return myUser
            }else{
                return nil
            }
        }
    }
    
    init() {
        apiToken = ""
    }
    
    func disableProfanityFilter(){
        self.profanityFlag = false
    }
    
    func enableScreenRecording(){
        self.canRecordScreen = true
    }
    
    func getUser() -> TQKUser? {
        return TheQManager.sharedInstance.loggedInUser
    }
    
    func getPartnerCode() -> String? {
        
        if TheQManager.sharedInstance.apiToken != nil && !(TheQManager.sharedInstance.apiToken!.isEmpty){
            return TheQManager.sharedInstance.apiToken
        }else{
            return nil
        }
    }
    
//    func initialize() {
//        TheQManager.sharedInstance.apiToken = ""
//        mixpanelInstance =  Mixpanel.initialize(token: TQKConstants.MIXPANEL_TOKEN)
//    }
//
//    func initialize(token apiToken: String) {
//        TheQManager.sharedInstance.apiToken = apiToken
//        mixpanelInstance =  Mixpanel.initialize(token: TQKConstants.MIXPANEL_TOKEN)
//    }
    
    func initialize(baseURL:String, locale:String, moneySymbol:String, appName:String,token apiToken: String? = nil, mixpanelToken : String? = nil) {
        TheQManager.sharedInstance.apiToken = apiToken ?? ""
        UserDefaults.standard.set(baseURL, forKey: "TQK_BASE_URL")
        UserDefaults.standard.set(locale, forKey: "TQK_LOCALE")
        UserDefaults.standard.set(moneySymbol, forKey: "TQK_MONEY_SYMBOL")
        UserDefaults.standard.set(appName, forKey: "TQK_APP_NAME")
        UserDefaults.standard.synchronize()
        
        if(mixpanelToken != nil){
            mixpanelInstance =  Mixpanel.initialize(token: mixpanelToken!)
        }
        
        if(TheQManager.sharedInstance.loggedInUser != nil){
            //Refresh user object if needed
            let lastUserUpdate = UserDefaults.standard.object(forKey: "lastUserUpdate")
            if(lastUserUpdate == nil){
                updateUserObject()
            }else{
                let interval = Date().timeIntervalSince(lastUserUpdate as! Date)
                let minutes = (Int(interval) / 60) % 60
                if(minutes >= 5){
                    updateUserObject()
                }
            }
        }
    }
    
    
    // MARK: functions
    
    func updateUserObject(){
        
        if(TheQManager.sharedInstance.getUser() == nil){
            return
        }
        
        print("testing this")
        let userUrl = TQKConstants.baseUrl + "users/" + (TheQManager.sharedInstance.loggedInUser?.id)!
        if UserDefaults.standard.object(forKey: "myTokens") != nil{
            let myTokens =  TQKOAuth(dictionary: UserDefaults.standard.object(forKey: "myTokens") as! [String : Any])!
            let finalBearerToken:String = "Bearer " + (myTokens.accessToken)!
            
            let headers = [
                "Authorization": finalBearerToken,
                "Accept": "application/json",
            ]
            
            Alamofire.request(userUrl, parameters: nil, headers: headers).responseJSON { response in
                response.result.ifFailure {
                    //check for 401
                    if(response.response?.statusCode == 401){
                        TheQManager.sharedInstance.refreshToken(completionHandler: { (success) in
                            if(!success){
                                TheQManager.sharedInstance.LogoutQUser()
                            }
                        })
                    }
                }
                
                
                response.result.ifSuccess {
                    if let json = response.result.value as? [String: Any] {
                        
                        if ( !(json["success"] as! Bool) ) {
                            if ( json["errorCode"] != nil ){
                                let errorCode = json["errorCode"] as! String
                                if( errorCode == "USER_BANNED"){
                                    //Let app know this user is banned
                                    NotificationCenter.default.post(name: .userBanned, object: nil)
                                }
                            }
                            
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                if(utf8Text == "Token validation error."){
                                    TheQManager.sharedInstance.refreshToken(completionHandler: { (success) in
                                        if(!success){
                                            TheQManager.sharedInstance.LogoutQUser()
                                        }
                                    })
                                }
                            }
                            
                        }else{
                            do{
                                let json = try JSON(data: response.data!)
                                var user = TQKUser(JSON: json["user"].dictionaryObject!)
                                if let tester = json["tester"].bool {
                                    user?.tester = tester
                                }
                                UserDefaults.standard.set(user?.propertyListRepresentation, forKey: "myUser")
                                UserDefaults.standard.set(Date(), forKey: "lastUserUpdate")
                                UserDefaults.standard.synchronize()
                            }catch{
                                print(error)
                            }
                        }
                    }
                }
                
            }
        }
        

    }
    
    @discardableResult
    func updateUser(email: String? = nil, phoneNumber: String? = nil) -> Bool{
        if(TheQManager.sharedInstance.loggedInUser == nil){
            return false
        }
        
        if(email != nil && !self.isValidEmail(testStr: email!)){
            return false
        }
        
        
        let key = "token"
        let preferences = UserDefaults.standard
        let bearerToken = preferences.string(forKey: key)
        let finalBearerToken:String = "Bearer " + (bearerToken as! String)
        
        var parameters: Parameters = [:]
        
        if(email != nil){
            parameters.updateValue(email, forKey: "email")
        }
        if(phoneNumber != nil){
            parameters.updateValue(phoneNumber , forKey: "phoneNumber")
        }
        
        let headers: HTTPHeaders = [
            "Authorization": finalBearerToken,
            "Accept": "application/json"
        ]
        
        let updateURL:String = TQKConstants.baseUrl + "users/" + (TheQManager.sharedInstance.loggedInUser?.id)!
        
        Alamofire.request(updateURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
            { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                response.result.ifFailure {
                    print("USER UPDATED: FAILURE")
                }
                
                response.result.ifSuccess {
                    print("USER UPDATED: SUCCESS")
                }
        }
        
        return true
    }
    
    @discardableResult
    func LoginQUserWithFB(UserID: String, TokenString: String) -> Bool {
        AuthenticationService.sharedInstance.FacebookLogin(UserID: UserID, TokenString: TokenString, apiToken: TheQManager.sharedInstance.apiToken!)
        return true
    }
    
    func LoginQUserWithAK(accountID: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void) {
        AuthenticationService.sharedInstance.AccountKitLogin(userID: accountID, tokenString: tokenString, username: username, apiToken: TheQManager.sharedInstance.apiToken!, completionHandler: completionHandler)
    }
    
    func LoginQUserWithFirebase(userId: String, tokenString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void) {
        AuthenticationService.sharedInstance.FirebaseLogin(userID: userId, tokenString: tokenString, username: username, apiToken: TheQManager.sharedInstance.apiToken!, completionHandler: completionHandler)
    }
    
    func LoginQUserWithApple(userID: String, identityString: String, username: String? = nil, completionHandler: @escaping (_ success : Bool) -> Void) {
        AuthenticationService.sharedInstance.AppleLogin(userID: userID, identityString: identityString, username: username, apiToken: TheQManager.sharedInstance.apiToken!, completionHandler: completionHandler)
    }
    
    func refreshToken(completionHandler: @escaping (_ success : Bool) -> Void){
        AuthenticationService.sharedInstance.refreshTokens(apiToken: TheQManager.sharedInstance.apiToken, completionHandler: completionHandler)
    }
    
    func LogoutQUser() {
        AuthenticationService.sharedInstance.commonLogout()
    }
    
    func CheckForGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) -> Void {
        
        var params : Parameters
        if(TheQManager.sharedInstance.getUser() == nil){
              params  = [
                           "includeSubscriberOnly":false,
                           "gameTypes":"TRIVIA,POPULAR"
                       ]
        }else{
             params = [
                "includeSubscriberOnly":false,
                "gameTypes":"TRIVIA,POPULAR",
                "userId":(TheQManager.sharedInstance.loggedInUser?.id)!,
                "uid":(TheQManager.sharedInstance.loggedInUser?.id)!
            ]
        }
        
        let gameHeaders : HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        var url:String = TQKConstants.baseUrl + "games"
        
        if(!apiToken!.isEmpty){
            url = url + "?partnerCode=\(apiToken!)"
        }
        
        Alamofire.request(url, parameters: params, headers: gameHeaders).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                //TODO - maybe add in a failure card here
                completionHandler(false,nil)
            }
            response.result.ifSuccess {
                
                if var json = response.result.value as? [String: Any] {
                    
                    if ( !(json["success"] as! Bool) ) {
                        
                        //                        return false
                        completionHandler(false,nil)
                        
                    }else{
                        
                        do {6
                            let json = try JSON(data: response.data!)
                            print("JSON: \(json)") // serialized json response
                            let games = TQKGames(JSON: json.dictionaryObject!)
                            if (json["games"][0]["active"] == true) {
                                completionHandler(true,games?.games)
                            }else{
                                completionHandler(false,games?.games)
                            }
                        }catch{
                            print(error)
                            completionHandler(false,nil)
                        }
                        
                    }
                }
            }
        }        
    }
    
    func CheckForTestGames(completionHandler: @escaping (_ active: Bool, _ games: [TQKGame]?) -> Void) -> Void {
        
        let key = "token"
        let preferences = UserDefaults.standard
        let bearerToken = preferences.string(forKey: key)
        var finalBearerToken:String = "Bearer " + (bearerToken as! String)
       
        let gameHeaders: HTTPHeaders = [
            "Authorization": finalBearerToken,
            "Accept": "application/json"
        ]
        
        let params : Parameters = [
            "includeSubscriberOnly":false,
            "gameTypes":"TRIVIA,POPULAR",
            "userId":(TheQManager.sharedInstance.loggedInUser?.id)!,
            "uid":(TheQManager.sharedInstance.loggedInUser?.id)!
        ]
        
        var url:String = TQKConstants.baseUrl + "test-games"
        
        if(!apiToken!.isEmpty){
            url = url + "?partnerCode=\(apiToken!)"
        }
        
        Alamofire.request(url, parameters: params, headers: gameHeaders).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                //TODO - maybe add in a failure card here
                completionHandler(false,nil)
            }
            response.result.ifSuccess {
                
                if var json = response.result.value as? [String: Any] {
                    
                    if ( !(json["success"] as! Bool) ) {
                        
//                        let json = try JSON(data: response.data!)
                        print("JSON: \(json)") // serialized json response
                        //                        return false
                        completionHandler(false,nil)
                        
                    }else{
                        
                        do {
                            let json = try JSON(data: response.data!)
                            print("JSON: \(json)") // serialized json response
                            let games = TQKGames(JSON: json.dictionaryObject!)
                            if (json["games"][0]["active"] == true) {
                                completionHandler(true,games?.games)
                            }else{
                                completionHandler(false,games?.games)
                            }
                        }catch{
                            print(error)
                            completionHandler(false,nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    func LaunchGame(theGame : TQKGame,
                    colorCode : String?,
                    useLongTimer : Bool? = false,
                    logoOverride: UIImage?,
                    playerBackgroundColor: UIColor? = nil,
                    useThemeAsBackground: Bool? = false,
                    completed: @escaping (_ success : Bool) -> Void ) {
        
        if(theGame.active == false){
            print("TheQKit ERROR: GAME IS NOT ACTIVE - CAN NOT LAUNCH GAME")
            return
        }
        
        if(TheQManager.sharedInstance.getUser() == nil){
            print("TheQKit ERROR: NO USER LOGGED IN - CAN NOT LAUNCH GAME")
            return
        }else{
            //check to make sure the host/sseHost exist
            if(theGame.host == nil || theGame.sseHost == nil){
                //Do not launch, though logged in when trying to join the game, they were not logged in when getting a list of games and do not have the required parameters
                if(theGame.testMode){
                    //refresh test game
                    self.CheckForTestGames { (sucess, games) in
                        if let game = games?.first(where: {$0.id == theGame.id}) {
                            TheQManager.sharedInstance.LaunchGame(theGame: game, colorCode: colorCode, useLongTimer: useLongTimer, logoOverride: logoOverride,completed: completed)
                        }else{
                            print("TheQKit ERROR: GAME DOES NOT CONTAIN HOST URL")
                        }
                    }
                }else{
                    //refresh normal
                    self.CheckForGames { (success, games) in
                        if let game = games?.first(where: {$0.id == theGame.id}) {
                            TheQManager.sharedInstance.LaunchGame(theGame: game, colorCode: colorCode, useLongTimer: useLongTimer, logoOverride: logoOverride,completed: completed)
                        }else{
                            print("TheQKit ERROR: GAME DOES NOT CONTAIN HOST URL")
                        }
                    }
                }
                return
            }
        }
        
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let storyboard = UIStoryboard(name: TQKConstants.STORYBOARD_STRING, bundle: bundle)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "gameViewController") as! GameViewController
        vc.myGameId = theGame.id
        vc.host = theGame.host
        vc.sseHost = theGame.sseHost
        vc.rtmpUrl = theGame.streamUrl
        vc.reward = "\(theGame.reward)"
        vc.lastQuestionHeartEligible = theGame.lastQuestionHeartEligible!
        vc.heartsEnabled = theGame.heartsEnabled
        vc.useLongTimer = useLongTimer!
        vc.theGame = theGame
        vc.completed = completed
        vc.playerBackgroundColor = playerBackgroundColor
        vc.useThemeAsBackground = useThemeAsBackground!
        
        if(logoOverride != nil){
            vc.logo = logoOverride
        }
        
        if(colorCode != nil){
            vc.colorOverride = colorCode
        }
        
        if let topController = UIApplication.topViewController() {
            DispatchQueue.main.async(execute: {
//                vc.modalPresentationStyle = .fullScreen
                if(topController.navigationController != nil){
                    topController.navigationController?.pushViewController(vc, animated: true)
                    topController.navigationController?.navigationBar.isHidden = true
                }else{
                    topController.present(vc, animated: true) {

                    }
                }
            })
        }
    }
    
    
    func LaunchActiveGame(colorCode : String?,
                          logoOverride: UIImage?,
                          playerBackgroundColor: UIColor? = nil,
                          useThemeAsBackground: Bool? = false,
                          completed: @escaping (_ success : Bool) -> Void ) {
        if(TheQManager.sharedInstance.loggedInUser != nil){
            
            let gameHeaders : HTTPHeaders = [
                "Accept": "application/json"
            ]
            let params : Parameters = [
                "userId":(loggedInUser!.id)!,
                "uid":(loggedInUser!.id)!,
                "includeSubscriberOnly":false,
                "gameTypes":"TRIVIA,POPULAR"
            ]
            
            var url:String = TQKConstants.baseUrl + "games"
            
            if(!apiToken!.isEmpty){
                url = url + "?partnerCode=\(apiToken!)"
            }
            
            Alamofire.request(url, parameters: params, headers: gameHeaders).responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                response.result.ifFailure {
                    //TODO - maybe add in a failure card here
                }
                response.result.ifSuccess {
                    
                    if var json = response.result.value as? [String: Any] {
                        
                        if ( !(json["success"] as! Bool) ) {
                            
                            //no
                            
                        }else{
                            
                            do{
                                let json = try JSON(data: response.data!)
                                
                                if (json["games"][0]["active"] == true) {
                                    if let game = TQKGame(JSON: json["games"][0].dictionaryObject!) {
                                        self.LaunchGame(theGame: game,
                                                        colorCode: colorCode,
                                                        logoOverride: logoOverride,
                                                        playerBackgroundColor: playerBackgroundColor,
                                                        useThemeAsBackground: useThemeAsBackground,
                                                        completed: completed)
                                    }
                                }
                            }catch{
                                print(error)
                            }
                        }
                    }
                }
            }
        }else{
            //Login is needed
        }
    }
    
    @discardableResult
    func CashOutNoUI(email:String) -> Bool {
        
        if(TheQManager.sharedInstance.loggedInUser == nil){
            return false
        }
        
        let balance = TheQManager.sharedInstance.loggedInUser?.balance
        
        if(balance! <= 0.0 ){
            return false
        }
        
        if(!self.isValidEmail(testStr: email)){
            return false
        }
        
        let finalUrl:String = TQKConstants.baseUrl + "users/\(TheQManager.sharedInstance.loggedInUser!.id!)/withdrawal-request"
        
        let key = "token"
        let preferences = UserDefaults.standard
        let bearerToken = preferences.string(forKey: key)
        var finalBearerToken:String = "Bearer " + (bearerToken as! String)
        let userId:String = (preferences.string(forKey: "userId")!)
        let parameters: Parameters = ["email": email,
                                      "userId":userId,
                                      "uid":userId]
        
        let headers: HTTPHeaders = [
            "Authorization": finalBearerToken,
            "Accept": "application/json"
        ]
        
        let updateURL:String = TQKConstants.baseUrl + "users/" + (TheQManager.sharedInstance.loggedInUser?.id)!
        
        Alamofire.request(updateURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
            { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if var json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
                
                response.result.ifFailure {
                    let alert = UIAlertController(title: "Error", message: "An error has occured; please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                        //add an action if needed
                    }))
                
                    if let topController = UIApplication.topViewController() {
                        topController.present(alert, animated: true) {}
                    }
                }
                
                response.result.ifSuccess {
                    Alamofire.request(finalUrl, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON
                        { response in
                            print("Request: \(String(describing: response.request))")   // original url request
                            print("Response: \(String(describing: response.response))") // http url response
                            print("Result: \(response.result)")                         // response serialization result
                            
                            response.result.ifFailure {
                                let alert = UIAlertController(title: "Error", message: "An error has occured; please try again later", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                                    //add an action if needed
                                }))
                            
                                if let topController = UIApplication.topViewController() {
                                    topController.present(alert, animated: true) {}
                                }
                            }
                            
                            response.result.ifSuccess {
                                if let json = response.result.value as? [String: Any] {
                                    print("JSON: \(json)") // serialized json response
                                    if ( !(json["success"] as! Bool) ) {
                                        if (String(describing: json["errorCode"]!) == "INSUFFICIENT_FUNDS") {
                                            self.showInsufficientFundsPopUp()
                                        }
                                    }else{
                                        //TODO: maybe a good spot to make sure the user can get notifications
                                        self.showPopUp()
                                        
                                        let props = ["Amount":TheQManager.sharedInstance.loggedInUser?.balance] as! Properties
                                        TheQManager.sharedInstance.mixpanelInstance?.track(event: "Cashout Requested", properties: props)
                                        
                                    }
                                }
                            }
                    }
                }
        }
        
        return true
    }
    
    
    @discardableResult
    func CashOut() -> Bool {
        
        if(TheQManager.sharedInstance.loggedInUser == nil){
            return false
        }
        
        let alert = UIAlertController(title: "Cash Out", message: "You currently have $\(TheQManager.sharedInstance.loggedInUser?.balance ?? 0). Enter your PayPal email to request to cash out.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Request", style: .default, handler: { (alertAction) in
            let email = alert.textFields![0].text
            print(email)
            
            let balance = TheQManager.sharedInstance.loggedInUser?.balance
            
            if(balance! <= 0.0 ){
                self.showInsufficientFundsPopUp()
                return
            }
            
            if(!self.isValidEmail(testStr: email!)){
                
                let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                    //add an action if needed
                }))
            
                if let topController = UIApplication.topViewController() {
                    topController.present(alert, animated: true) {}
                }
                
                return
            }
            
            let finalUrl:String = TQKConstants.baseUrl + "users/\(TheQManager.sharedInstance.loggedInUser!.id!)/withdrawal-request"
            var code:String = ""
            print(finalUrl + "finalUrl")
            
            let key = "token"
            let preferences = UserDefaults.standard
            let bearerToken = preferences.string(forKey: key)
            var finalBearerToken:String = "Bearer " + (bearerToken as! String)
            let userId:String = (preferences.string(forKey: "userId")!)
            let parameters: Parameters = ["email": email,
                                          "userId":userId,
                                          "uid":userId]
            
            let headers: HTTPHeaders = [
                "Authorization": finalBearerToken,
                "Accept": "application/json"
            ]
            
            let updateURL:String = TQKConstants.baseUrl + "users/" + (TheQManager.sharedInstance.loggedInUser?.id)!
            print(updateURL + "  is the updateURL")
            
            Alamofire.request(updateURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
                { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                    
                    if var json = response.result.value as? [String: Any] {
                        print("JSON: \(json)") // serialized json response
                    }
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)") // original server data as UTF8 string
                    }
                    
                    response.result.ifFailure {
                        let alert = UIAlertController(title: "Error", message: "An error has occured; please try again later", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                            //add an action if needed
                        }))
                    
                        if let topController = UIApplication.topViewController() {
                            topController.present(alert, animated: true) {}
                        }
                    }
                    
                    response.result.ifSuccess {
                        Alamofire.request(finalUrl, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON
                            { response in
                                print("Request: \(String(describing: response.request))")   // original url request
                                print("Response: \(String(describing: response.response))") // http url response
                                print("Result: \(response.result)")                         // response serialization result
                                
                                response.result.ifFailure {
                                    let alert = UIAlertController(title: "Error", message: "An error has occured; please try again later", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                                        //add an action if needed
                                    }))
                                
                                    if let topController = UIApplication.topViewController() {
                                        topController.present(alert, animated: true) {}
                                    }
                                }
                                
                                response.result.ifSuccess {
                                    if let json = response.result.value as? [String: Any] {
                                        print("JSON: \(json)") // serialized json response
                                        if ( !(json["success"] as! Bool) ) {
                                            if (String(describing: json["errorCode"]!) == "INSUFFICIENT_FUNDS") {
                                                self.showInsufficientFundsPopUp()
                                            }
                                        }else{
                                            //TODO: maybe a good spot to make sure the user can get notifications
                                            self.showPopUp()
                                            
                                            let props = ["Amount":TheQManager.sharedInstance.loggedInUser?.balance] as! Properties
                                            TheQManager.sharedInstance.mixpanelInstance?.track(event: "Cashout Requested", properties: props)
                                            
                                        }
                                    }
                                }
                        }
                    }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "email"
            textField.isSecureTextEntry = false // for password input
        })
        
        UIApplication.topViewController()!.present(alert, animated: true) {
            
        }
        
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func showInsufficientFundsPopUp(){
        print("showing dialog")
        // Prepare the popup assets
        var title = "Insufficient Funds"
        let message = "You must have at least $25 in your account to cashout"
       
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { (alertAction) in
            //add an action if needed
        }))
    
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true) {}
        }
    }
    
    func showPopUp() {
        let alert = UIAlertController(title: "Congratulations!", message: "We payout on a monthly basis.  You will be notified once your prize payout has been processed via PayPal.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
            //add an action if needed
        }))
    
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true) {}
        }
    }
    
    func playTest() {
        //        let urls = ["https://streamvideo.akamaized.net/5a353e10-f2c5-4c63-a7c0-3d6bb0a2df22.mp4"]
        //
        //        let options = IJKFFOptions.byDefault()
        //        let url = URL(string: urls[0])
        //
        //        let player = IJKFFMoviePlayerController(contentURL: url!, with: options)
        //
        //
        //        let window = UIApplication.shared.keyWindow
        //        let topView = window?.rootViewController?.view
        //
        //        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        player?.view.frame = topView!.bounds
        //        player?.scalingMode = .aspectFit
        //        player?.shouldAutoplay = true
        //
        //        topView!.autoresizesSubviews = true
        //        topView!.addSubview((player?.view)!)
        //
        //        player?.prepareToPlay()
        //        player?.play()
        
        //TEST - FullScreen Questions

                if let path = TheQKit.bundle.path(forResource: "testQuestion", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                        let jsonObj = try JSON(data: data)
                        print("jsonData:\(jsonObj)")
        
                        let qu = TQKQuestion(JSON: jsonObj.dictionaryObject!)

                        let sb = UIStoryboard(name: "Games", bundle: TheQKit.bundle)

                        let testVC = sb.instantiateViewController(withIdentifier: "FullScreenTriviaViewController") as? FullScreenTriviaViewController
                        let vc = UIApplication.topViewController()
                        testVC?.view.frame = CGRect(x:0, y:0, width: vc!.view.frame.width, height: vc!.view.frame.height)
                        testVC?.view.alpha = 1.0
                        //        testVC?.leaderboardDelegate = self.leaderboardDelegate
                        //        testVC?.gameDelegate = self
                        testVC?.question = qu
                        testVC?.type = .Question

                        vc!.addChild(testVC!)
                        vc!.view.addSubview(testVC!.view)
                        testVC!.didMove(toParent: vc!)
                    } catch let error {
                        print("parse error: \(error.localizedDescription)")
                    }
                } else {
                    print("Invalid filename/path.")
                }
        //TEST - SS Questions

//                if let path = TheQKit.bundle.path(forResource: "testQuestion", ofType: "json") {
//                    do {
//                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
//                        let jsonObj = try JSON(data: data)
//                        print("jsonData:\(jsonObj)")
//
//                        let qu = TQKQuestion(JSON: jsonObj.dictionaryObject!)
//
//                        let sb = UIStoryboard(name: "Games", bundle: TheQKit.bundle)
//
//                        let testVC = sb.instantiateViewController(withIdentifier: "SSQuestionViewController") as? SSQuestionViewController
//                        let vc = UIApplication.topViewController()
//                        testVC?.view.frame = CGRect(x:0, y:0, width: vc!.view.frame.width, height: vc!.view.frame.height)
//                        testVC?.view.alpha = 1.0
//                        //        testVC?.leaderboardDelegate = self.leaderboardDelegate
//                        //        testVC?.gameDelegate = self
//                        testVC?.question = qu
//
//                        vc!.addChild(testVC!)
//                        vc!.view.addSubview(testVC!.view)
//                        testVC!.didMove(toParent: vc!)
//                    } catch let error {
//                        print("parse error: \(error.localizedDescription)")
//                    }
//                } else {
//                    print("Invalid filename/path.")
//                }
        
        
    }
    
    
}
