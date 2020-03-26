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
    
    @IBAction func logout(_ sender: Any) {
        TheQKit.LogoutQUser()
        self.navigationController?.popViewController(animated: true)
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
                let x = UIImage(named: "test")
                TheQKit.LaunchGame(theGame: gamesArray!.first!, colorCode: nil, logoOverride: x) { (success) in
                    //launched
                }
            }else{
                print("no active games")
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "No Active Games"
                hud.hide(animated: true, afterDelay: 2.0)
            }
        }
    }
    
    @IBAction func joinGame(_ sender: Any) {
        let x = UIImage(named: "test")
        
        
        TheQKit.LaunchActiveGame(logoOverride: x) {_ in
            
        }
    }
    
    @IBAction func cashOut(_ sender: Any) {
        TheQKit.CashOut()
    }
    
}

