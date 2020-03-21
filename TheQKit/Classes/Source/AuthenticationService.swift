//
//  UserManager.swift
//  TheQKit
//
//  Created by Jonathan Spohn on 1/17/19.
//  Copyright © 2019 Stream Live. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AuthenticationService {
    
    static let sharedInstance = AuthenticationService()
    init() {}
    
    var loginResponse: TQKLoginResponse!
    
    func FacebookLogin(UserID: String, TokenString: String, apiToken: String) {
        
        let fbAuth = TQKFacebookAuth(id: UserID, accessToken: TokenString)
        let params: Parameters = fbAuth.dictionaryRepresentation
        var finalUrl:String = TQKConstants.baseUrl + "oauth/token"
        if(!apiToken.isEmpty){
            finalUrl = finalUrl + "?partnerCode=\(apiToken)"
        }
        
//        self.commonLogin(finalUrl: finalUrl, params: params)
    }
    
    func AccountKitLogin(userID: String, tokenString: String, username: String? = nil, apiToken: String, completionHandler: @escaping (_ success : Bool) -> Void) {
        
        
        let commonAuth = TQKCommonAuth(id: userID, accessToken: tokenString, provider: "accountKit")
        let params : Parameters = commonAuth.dictionaryRepresentation
        
        var finalUrl:String = TQKConstants.baseUrl + "oauth/token"
        if(!apiToken.isEmpty){
            finalUrl = finalUrl + "?partnerCode=\(apiToken)"
        }
        
        var code:String = ""
        Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                self.showLoginError()
                completionHandler(false)
            }
            
            response.result.ifSuccess {
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    do{
                        let json1 = try JSON(data: response.data!)
                        code = json1["errorCode"].stringValue
                        
                        self.loginResponse =  TQKLoginResponse(JSON: json)
                        if (self.loginResponse.user != nil) {
                            self.setupUserInfo()
                            completionHandler(true)
                        }else{
                            print("the user login code is" + code)
                            if (code == "CLIENT_ERROR" || code == "AUTHORIZATION_ERROR") {
                                self.showLoginError()
                                completionHandler(false)
                            }else if (code == "NO_SUCH_USER"){
                                if(username != nil){
                                    self.createAccountWithUsername(id: userID, accessToken: tokenString, apiToken: apiToken, provider: "accountKit", username: username!, completionHandler: completionHandler)
                                }else{
                                    self.createAccountWithUI(id: userID, accessToken: tokenString, apiToken: apiToken, provider: "accountKit", completionHandler: completionHandler)
                                }
                            }else if( code == "USER_BANNED"){
                                //Show a banned thing here
//                                self.showBannedMessage()
                                NotificationCenter.default.post(name: .userBanned, object: nil)
                                completionHandler(false)
                            } else {
                                self.showLoginError()
                                completionHandler(false)
                            }
                        }
                    }catch{
                        print(error)
                        completionHandler(false)
                    }
                }
            }
        }
        
    }
    
    func AppleLogin(userID: String, identityString: String, username: String? = nil, apiToken: String, completionHandler: @escaping (_ success : Bool) -> Void) {
        let commonAuth = TQKCommonAuth(id: userID, accessToken: identityString, provider: "apple")
        let params: Parameters = commonAuth.dictionaryRepresentation
       
        var finalUrl:String = TQKConstants.baseUrl + "oauth/token"
        if(!apiToken.isEmpty){
            finalUrl = finalUrl + "?partnerCode=\(apiToken)"
        }

        var code:String = ""
       
       Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON
       { response in
           print("Request: \(String(describing: response.request))")   // original url request
           print("Response: \(String(describing: response.response))") // http url response
           print("Result: \(response.result)")                         // response serialization result

           response.result.ifFailure {
               self.showLoginError()
               completionHandler(false)
           }
           
           response.result.ifSuccess {
               if let json = response.result.value as? [String: Any] {
                   print("JSON: \(json)") // serialized json response
                   do{
                       let json1 = try JSON(data: response.data!)
                       code = json1["errorCode"].stringValue
                       
                       self.loginResponse =  TQKLoginResponse(JSON: json)
                       if (self.loginResponse.user != nil) {
                           self.setupUserInfo()
                           completionHandler(true)
                       }else{
                           print("the user login code is" + code)
                           if (code == "CLIENT_ERROR" || code == "AUTHORIZATION_ERROR") {
                               self.showLoginError()
                               completionHandler(false)
                           }else if (code == "NO_SUCH_USER"){
                               if(username != nil){
                                   self.createAccountWithUsername(id: userID, accessToken: identityString, apiToken: apiToken, provider: "apple", username: username!, completionHandler: completionHandler)
                               }else{
                                   self.createAccountWithUI(id: userID, accessToken: identityString, apiToken: apiToken, provider: "apple", completionHandler: completionHandler)
                               }
                           }else if( code == "USER_BANNED"){
                               //Show a banned thing here
    //                                self.showBannedMessage()
                               NotificationCenter.default.post(name: .userBanned, object: nil)
                               completionHandler(false)
                           } else {
                               self.showLoginError()
                               completionHandler(false)
                           }
                       }
                   }catch{
                       print(error)
                       completionHandler(false)
                   }
               }
           }
       }
    }
    
    func FirebaseLogin(userID: String, tokenString: String, username: String? = nil, apiToken: String, completionHandler: @escaping (_ success : Bool) -> Void) {
        
        let akAuth = TQKFirebaseAuth(id: userID, accessToken: tokenString)
        let params: Parameters = akAuth.dictionaryRepresentation
        var finalUrl:String = TQKConstants.baseUrl + "oauth/token"
        if(!apiToken.isEmpty){
            finalUrl = finalUrl + "?partnerCode=\(apiToken)"
        }
        
        var code:String = ""
        Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                self.showLoginError()
                completionHandler(false)
            }
            
            response.result.ifSuccess {
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    do{
                        let json1 = try JSON(data: response.data!)
                        code = json1["errorCode"].stringValue
                        
                        self.loginResponse =  TQKLoginResponse(JSON: json)
                        if (self.loginResponse.user != nil) {
                            self.setupUserInfo()
                            completionHandler(true)
                        }else{
                            print("the user login code is" + code)
                            if (code == "CLIENT_ERROR" || code == "AUTHORIZATION_ERROR") {
                                self.showLoginError()
                                completionHandler(false)
                            }else if (code == "NO_SUCH_USER"){
                                print("This is a new user bring to username screen")
                                if(username != nil){
                                    self.createAccountWithUsername(id: userID, accessToken: tokenString, apiToken: apiToken, provider: "firebase", username: username!, completionHandler: completionHandler)
                                }else{
                                    self.createAccountWithUI(id: userID, accessToken: tokenString, apiToken: apiToken, provider: "firebase", completionHandler: completionHandler)
                                }
                            }else if( code == "USER_BANNED"){
                                //Show a banned thing here
//                                self.showBannedMessage()
                                NotificationCenter.default.post(name: .userBanned, object: nil)
                                completionHandler(false)
                            } else {
                                self.showLoginError()
                                completionHandler(false)
                            }
                        }
                    }catch{
                        completionHandler(false)
                    }
                }
            }
        }
        
    }
    
    func createAccountWithUsername(id:String, accessToken:String, apiToken: String, provider:String, username:String, completionHandler: @escaping (_ success : Bool) -> Void) {
    
        var params: Parameters
        let commonAuth = TQKCommonAuth(id: id, accessToken: accessToken, provider: provider)
        let newUser = TQKCommonPlayer(username: username,
                                        email: "",
                                        commonAuth: commonAuth,
                                        optInBool: false,
                                        apnToken: UserDefaults.standard.string(forKey: "apnToken") ?? "",
                                        firebaseToken: UserDefaults.standard.string(forKey: "firebaseToken") ?? "",
                                        deviceId: UIDevice.current.identifierForVendor!.uuidString,
                                        type: "IOS", autoHandleUsernameCollision: true)
        params = newUser.dictionaryRepresentation
        
        print(params)
        
        let finalUrl:String = TQKConstants.baseUrl + "users?partnerCode=\(apiToken)"
        print("the url to create user " + finalUrl)
        
        
        Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                completionHandler(false)
            }
            
            if let json = response.result.value as? [String: Any] {
                
                if ( !(json["success"] as! Bool) ) {
                    completionHandler(false)
                }else{
                    
                    print("JSON: \(json)") // serialized json response
                    
                    //                    var requesRes: String = String(describing: response.response)
                    
                    self.loginResponse =  TQKLoginResponse(JSON: json)
                    
                    
                    //saves tokens to device
                    let preferences = UserDefaults.standard
                    
                    let key = "token"
                    let token:String = (self.loginResponse.oauth?.accessToken)!
                    
                    preferences.set(token, forKey: key)
                    //
                    let refreshKey = "refreshToken"
                    let refreshToken:String = (self.loginResponse.oauth?.refreshToken)!
                    preferences.set(refreshToken, forKey: refreshKey)
                    let userId: String = (self.loginResponse.user?.id)!
                    preferences.set(userId, forKey: "userId")
                    
                    preferences.set(self.loginResponse.user?.propertyListRepresentation, forKey: "myUser")
                    preferences.set(self.loginResponse.oauth?.propertyListRepresentation, forKey: "myTokens")
                    
                    //  Save to disk
                    let didSave = preferences.synchronize()
                    
                    if !didSave {
                        //  Couldn't save (I've never seen this happen in real world testing)
                    }
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)") // original server data as UTF8 string
                    }
                    
                    completionHandler(true)
                }
            }
        }
    }
    
    func createAccountWithUI(id:String, accessToken:String, apiToken: String, provider:String, completionHandler: @escaping (_ success : Bool) -> Void) {
        
        let alert = UIAlertController(title: "Enter Username", message: "Please choose a username", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (alertAction) in
            let username = alert.textFields![0].text
            print(username)
            self.createAccountWithUsername(id: id, accessToken: accessToken, apiToken: apiToken, provider: provider, username: username!, completionHandler: completionHandler)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alertAction) in
            completionHandler(false)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "username"
            textField.isSecureTextEntry = false // for password input
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIApplication.topViewController()!.present(alert, animated: true) {}
        }
        
    }
    
    
//    func updateUser(success: @escaping (_ success : Bool) -> Void, failure: @escaping (_ success : Bool) -> Void){
//
//        if(TheQManager.sharedInstance.getUser() == nil){
//            return
//        }
////
//        let user = TheQManager.sharedInstance.getUser()
//
//        let key = "token"
//        let preferences = UserDefaults.standard
//        let bearerToken = preferences.string(forKey: key)
//        let finalBearerToken:String = "Bearer " + (bearerToken!)
//
//        var userUrl = TQKConstants.baseUrl + "users/" + (user?.id)!
//
//        let apiToken = TheQManager.sharedInstance.getPartnerCode()
//        if(apiToken != nil && !apiToken!.isEmpty){
//            userUrl = userUrl + "?partnerCode=\(apiToken!)"
//        }
//
//        let headers = [
//            "Authorization": finalBearerToken,
//            "Accept": "application/json",
//        ]
////
//        Alamofire.request(userUrl, parameters: nil, headers: headers).responseJSON { response in
//
//            //go on
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
//
//            response.result.ifFailure {
//                //check for 401 and log out if so
//                if(response.response?.statusCode == 401){
////                        self.commonLogout()
//                }
//
//                failure(false)
//            }
//
//
//            response.result.ifSuccess {
//                if let json = response.result.value as? [String: Any] {
//
//                    if ( !(json["success"] as! Bool) ) {
//                        if ( json["errorCode"] != nil ){
//                            let errorCode = json["errorCode"] as! String
//                            if( errorCode == "USER_BANNED"){
//                                //Go to banned screen
//                                NotificationCenter.default.post(name: .userBanned, object: nil)
//                            }
//                        }
//
//                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                            print("Data: \(utf8Text)") // original server data as UTF8 string
//                            print("yoooo")
//                            if(utf8Text == "Token validation error."){
//                                failure(false)
//                            }
//                        }
//
//                        failure(false)
//
//                    }else{
//                        do{
//                            let json = try JSON(data: response.data!)
//                            let user = TQKUser(JSON: json["user"].dictionaryObject!)
//
//                            UserDefaults.standard.set(user?.propertyListRepresentation, forKey: "myUser")
//                            UserDefaults.standard.set(Date(), forKey: "lastUserUpdate")
//                            UserDefaults.standard.synchronize()
//                            success(true)
//                        }catch{
//                            failure(false)
//                        }
//                    }
//                }
//            }
//        }
//
//    }
    
    func refreshTokens(apiToken: String?,completionHandler: @escaping (_ success : Bool) -> Void){
        var finalUrl:String = TQKConstants.baseUrl + "oauth/token"
        
        if(apiToken != nil && !apiToken!.isEmpty){
            finalUrl = finalUrl + "?partnerCode=\(apiToken!)"
        }
        
        let myTokens =  TQKOAuth(dictionary: UserDefaults.standard.object(forKey: "myTokens") as! [String : Any])!
        let finalBearerToken:String = "Bearer " + myTokens.accessToken!
        let headers = [
            "Authorization": finalBearerToken,
            "Accept": "application/json",
            "grant_type": "refresh_token",
            "refresh_token": myTokens.refreshToken!
        ]
//        let params : Parameters = ["refresh_token":myTokens.refreshToken!]
        
        Alamofire.request(finalUrl, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                completionHandler(false)
            }
            
            response.result.ifSuccess {
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    do{
                        let json1 = try JSON(data: response.data!)
                        
                        self.loginResponse =  TQKLoginResponse(JSON: json)
                        
                        if (self.loginResponse.user != nil) {
                            self.setupUserTokensOnly()
                            completionHandler(true)
                        }

                    }catch{
                        print(error)
                        completionHandler(false)
                    }
                }
                completionHandler(false)
            }
        }
    }
    
    
    
//    func commonLogin(finalUrl: String, params : Parameters){
//        var code:String = ""
//        Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
//            response.result.ifFailure {
//                self.showLoginError()
//            }
//
//            response.result.ifSuccess {
//                if let json = response.result.value as? [String: Any] {
//                    print("JSON: \(json)") // serialized json response
//
//                    let json1 = JSON(data: response.data!)
//                    code = json1["errorCode"].stringValue
//
//                    self.loginResponse =  LoginResponse(JSON: json)
//                    if (self.loginResponse.user != nil) {
//                        self.setupUserInfo()
//                    }else{
//                        print("the user login code is" + code)
//                        if (code == "CLIENT_ERROR" || code == "AUTHORIZATION_ERROR") {
//                            self.showLoginError()
//                        }else if (code == "NO_SUCH_USER"){
//                            // handle error
//                            print("This is a new user bring to username screen")
//
//                            //                            if let resultController = self.storyboard!.instantiateViewController(withIdentifier: "selectName") as? SelectNameVC {
//                            //                                resultController.loginWithAK = true
//                            //                                //                                self.present(resultController, animated: true, completion: nil)
//                            //                                self.navigationController?.pushViewController(resultController, animated: true)
//                            //
//                            //                            }
//
////                            let sb = UIStoryboard(name: "Onboarding", bundle: TheQKit.bundle)
////                            let vc = sb.instantiateViewController(withIdentifier: "SelectNameVC") as? SelectNameVC
////                            vc?.id = params.values.object
//
//                        }
//                            //                        else if( code == "USER_BANNED"){
//                            //                            //Go to banned screen
//                            //                            print("banned")
//                            //                            if let resultController = self.storyboard!.instantiateViewController(withIdentifier: "BannedViewController") as? BannedViewController {
//                            //                                //                                self.present(resultController, animated: true, completion: nil)
//                            //                                self.navigationController?.pushViewController(resultController, animated: true)
//                            //                            }
//                            //                        }
//                        else {
//                            self.showLoginError()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func showLoginError() {
        let alert = UIAlertController(title: "Error", message: "Sorry an error has occured. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
            //add an action if needed
        }))
        
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true) {}
        }
    }
    
    func showBannedMessage() {
        let alert = UIAlertController(title: "Banned", message: "You have been banned.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
            //add an action if needed
        }))
    
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true) {}
        }
    }
    
    
    fileprivate func setupUserInfo(){
        //saves tokens to device
        let preferences = UserDefaults.standard
        
        let key = "token"
        let token:String = (self.loginResponse.oauth?.accessToken)!
        
        preferences.set(token, forKey: key)
        //
        let refreshKey = "refreshToken"
        let refreshToken:String = (self.loginResponse.oauth?.refreshToken)!
        preferences.set(refreshToken, forKey: refreshKey)
        let userId: String = (self.loginResponse.user?.id)!
        preferences.set(userId, forKey: "userId")
        
        let isAdmin: Bool = (self.loginResponse.user?.admin)!
        preferences.set(isAdmin, forKey: "isAdmin")
        
        preferences.set(self.loginResponse.user?.propertyListRepresentation, forKey: "myUser")
        preferences.set(self.loginResponse.oauth?.propertyListRepresentation, forKey: "myTokens")
        
        preferences.synchronize()
    }
    
    fileprivate func setupUserTokensOnly(){
        //saves tokens to device
        let preferences = UserDefaults.standard
        let key = "token"
        let token:String = (self.loginResponse.oauth?.accessToken)!
        preferences.set(token, forKey: key)
        let refreshKey = "refreshToken"
        let refreshToken:String = (self.loginResponse.oauth?.refreshToken)!
        preferences.set(refreshToken, forKey: refreshKey)
        preferences.set(self.loginResponse.oauth?.propertyListRepresentation, forKey: "myTokens")
        
        preferences.synchronize()
    }
    
    func commonLogout(){
        //nil preferences on device
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: "token")
        preferences.removeObject(forKey: "refreshToken")
        preferences.removeObject(forKey: "userId")
        
        preferences.removeObject(forKey: "myUser")
        preferences.removeObject(forKey: "myTokens")
        
        preferences.removeObject(forKey: "lastUserUpdate")
        preferences.removeObject(forKey: "lastUserScoreCheck")
        preferences.removeObject(forKey: "userScores")
        preferences.removeObject(forKey: "lastScheduleUpdate")
        
        preferences.removeObject(forKey: "lastUserActivityCheck")
        preferences.removeObject(forKey: "storedActivityFeed")
        
        preferences.removeObject(forKey: "isAdmin")
        
        let prefDict = preferences.dictionaryRepresentation()
        for obj in prefDict {
            if (obj.key.contains("joined") || obj.key.contains("eliminated")) {
                preferences.removeObject(forKey: obj.key)
            }
        }
        
        preferences.synchronize()
        
        NotificationCenter.default.post(name: .userLogout, object: nil)
    }


}
