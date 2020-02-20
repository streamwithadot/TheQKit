//
//  LoginViewController.swift
//  TheQKit_Example
//
//  Created by Jonathan Spohn on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import TheQKit
import FirebaseUI
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {

    var authUI : FUIAuth?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authUI = FUIAuth.defaultAuthUI()
        authUI!.delegate = self
        
        if(TheQKit.getUser() != nil){
            self.performSegue(withIdentifier: "Onward!", sender: self)
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
           GIDSignIn.sharedInstance()?.presentingViewController = self
           GIDSignIn.sharedInstance().delegate = self
           GIDSignIn.sharedInstance().signIn()
       }
    
    @IBAction func loginPressed(_ sender: Any) {
                
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!)
        ]
        
        self.authUI!.providers = providers

        let phoneProvider = FUIAuth.defaultAuthUI()!.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
    }

}

// MARK: - TableViewDelegate
extension LoginViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                self.loginPressed(self)
            }else{
                self.googleLogin(self)
            }
        }else{
            //apple
             if #available(iOS 13.0, *) {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                    
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
    //            authorizationController.presentationContextProvider = self as! ASAuthorizationControllerPresentationContextProviding
                authorizationController.performRequests()
            }
        }
    }
    
}

extension LoginViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else{
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LoginCell
        
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                cell.loginLabel.text = "Phone #"
            }else{
                cell.loginLabel.text = "Google Account"
            }
        }else{
            cell.loginLabel.text = "Sign in with Apple"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Firebase Logins"
        }else{
            return "Apple"
        }
    }
        
}

// MARK: Google Sign In
extension LoginViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      if let _ = error {
        return
      }

      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let _ = error {
                return
            }
            // User is signed in
            let user = authResult?.user
            let uid = user!.uid

            user!.getIDTokenResult(completion: { (result, error) in
                let token = result?.token
                print(token)
                
                TheQKit.LoginQUserWithFirebase(userId: uid, tokenString: token!, username: "FBGoogTester") { (success) in
                    if(success){
                        self.performSegue(withIdentifier: "Onward!", sender: self)
                    }else{
                        print("Something went wrong")
                    }
                }
            })
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

// MARK: Apple Sign In

@available(iOS 13.0, *)
extension LoginViewController : ASAuthorizationControllerDelegate {
 
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
                      
            if let token = appleIDCredential.identityToken?.base64EncodedString() {
                
                TheQKit.LoginQUserWithApple(userID: userIdentifier, identityString: token) { (success) in
                    if(success){
                        self.performSegue(withIdentifier: "Onward!", sender: self)
                    }
                }
            }
        }
    }
}

// MARK: - FireBase UI
extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        if let user = authDataResult?.user {
            
            user.getIDTokenResult(completion: { (result, error) in
                let token = result?.token
                let userId:String = user.uid
                
                TheQKit.LoginQUserWithFirebase(userId: userId, tokenString: token!) { (success) in
                    if(success){
                        self.performSegue(withIdentifier: "Onward!", sender: self)
                    }else{
                        print("Something went wrong")
                    }
                }
            })
        }
    }
}


// MARK: LoginCell
class LoginCell : UITableViewCell {
    
    @IBOutlet weak var loginLabel: UILabel!
    
    
}

