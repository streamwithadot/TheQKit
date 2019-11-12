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

class LoginViewController: UIViewController {

    var authUI : FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authUI = FUIAuth.defaultAuthUI()
        authUI!.delegate = self
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


// MARK: - FireBase UI
extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        if let user = authDataResult?.user {
            
            user.getIDTokenResult(completion: { (result, error) in
                let token = result?.token
                let userId:String = user.uid
                
                TheQKit.LoginQUserWithFirebase(userId: userId, tokenString: token!, username: "FirebaseTester") { (success) in
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
