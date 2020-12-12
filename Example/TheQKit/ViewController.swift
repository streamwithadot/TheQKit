//
//  ViewController.swift
//  TheQKit
//
//  Created by Spohn on 01/22/2019.
//  Copyright (c) 2019 Spohn. All rights reserved.
//

import UIKit
import TheQKit
//import MBProgressHUD
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
            
            let options = TQKGameOptions(logoOverride: UIImage(named: "test"),
                                        playerBackgroundColor: UIColor.clear,
                                        useThemeAsBackground: true)
            
            TheQKit.showCardsController(fromViewController: connectContainerViewController,
                                        gameOptions: options)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        TheQKit.LogoutQUser()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkForGame(_ sender: Any) {
     
        //Swap to CheckForTestGames for games tagged as test only
        TheQKit.CheckForGames { (isActive, gamesArray) in
            //isActive : Bool
            //gamesArray : [TQKGame] ... active and non active games
            if(isActive){
                print("active game exist")
                let options = TQKGameOptions()
                TheQKit.LaunchGame(theGame: gamesArray!.first!, gameOptions: options) { (success) in
                    //launched
                }
            }else{
                print("no active games")
            }
        }
    }
    @IBAction func TestGamesPressed(_ sender: Any) {
        //Swap to CheckForTestGames for games tagged as test only
        TheQKit.CheckForTestGames { (isActive, gamesArray) in
            //isActive : Bool
            //gamesArray : [TQKGame] ... active and non active games
            if(isActive){
                print("active game exist")
                let options = TQKGameOptions()
                TheQKit.LaunchGame(theGame: gamesArray!.first!, gameOptions: options) { (success) in
                    //launched
                }
            }else{
                print("no active games")
            }
        }
    }
    
    @IBAction func joinGame(_ sender: Any) {
        let options = TQKGameOptions(isEliminationDisabled: true)
        TheQKit.LaunchActiveGame(gameOptions: options) {_ in
            
        }
    }
    
    @IBAction func cashOut(_ sender: Any) {
        TheQKit.CashOut()
    }
    
}

