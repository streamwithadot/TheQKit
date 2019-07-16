//
//  ViewController.swift
//  TheQKit
//
//  Created by Spohn on 01/22/2019.
//  Copyright (c) 2019 Spohn. All rights reserved.
//

import UIKit
import TheQKit
import MBProgressHUD
import Firebase

class ViewController: UIViewController {
    
    
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "cardTest" {
            let connectContainerViewController = segue.destination as UIViewController
            //            containerViewController = connectContainerViewController
            TheQKit.showCardsController(fromViewController: connectContainerViewController)
        }
    }
    
    
    @IBAction func AKLogin(_ sender: Any) {
        //TODO replace ID and Token
        TheQKit.LoginQUserWithAK(accountID: "<Insert ID>",
                                 tokenString: "<Insert Token String>") { (success) in
            if(success){
                //user logged in
                print("Logged in")
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "Success"
                hud.hide(animated: true, afterDelay: 2.0)
            }else{
                //user not logged in
                print("Not logged in")
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "Failure"
                hud.hide(animated: true, afterDelay: 2.0)
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        TheQKit.LogoutQUser()
    }
    
    @IBAction func checkForGame(_ sender: Any) {
        TheQKit.CheckForGames { (isActive, gamesArray) in
            //isActive : Bool
            //gamesArray : [TQKGame] ... active and non active games
            if(isActive){
                print("active game exist")
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "Active Games Found"
                hud.hide(animated: true, afterDelay: 2.0)
            }else{
                print("no active games")
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "No Active Games"
                hud.hide(animated: true, afterDelay: 2.0)
            }
        }
    }
    
    @IBAction func joinGame(_ sender: Any) {
        TheQKit.LaunchActiveGame()
    }
    
    @IBAction func cashOut(_ sender: Any) {
        TheQKit.CashOut()
    }
    
    @IBAction func testFunc(_ sender: Any) {
    
        //TODO - replace email and password
        Auth.auth().signIn(withEmail: "<Insert Email>", password: "<Insert Password>") { [weak self] user, error in

            let user = user?.user
            let isAnonymous = user!.isAnonymous  // true
            let uid = user!.uid

            user!.getIDTokenResult(completion: { (result, error) in
                let token = result?.token
                print(token)
                
                TheQKit.LoginQUserWithFirebase(userId: uid,
                                         tokenString: token!) { (success) in
                                            if(success){
                                                //user logged in
                                                print("Logged in")
                                                let hud = MBProgressHUD.showAdded(to: self!.view, animated: true)
                                                hud.label.text = "Success"
                                                hud.hide(animated: true, afterDelay: 2.0)
                                            }else{
                                                //user not logged in
                                                print("Not logged in")
                                                let hud = MBProgressHUD.showAdded(to: self!.view, animated: true)
                                                hud.label.text = "Failure"
                                                hud.hide(animated: true, afterDelay: 2.0)
                                            }
                }
                
                
            })
        }
    }
}

