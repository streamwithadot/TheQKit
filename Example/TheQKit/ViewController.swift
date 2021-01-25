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
    @IBOutlet weak var tableView: UITableView!
    
    
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
                                        useThemeAsBackground: true,
                                        useWebPlayer: false)
            
            TheQKit.showCardsController(fromViewController: connectContainerViewController,
                                        gameOptions: options)
        }
    }
    
    func logout() {
        TheQKit.LogoutQUser()
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchAndLaunchGame(test:Bool,useWebPlayer:Bool,alwaysUseHLS:Bool){
        if(test){
            TheQKit.CheckForTestGames { (isActive, gamesArray) in
                //isActive : Bool
                //gamesArray : [TQKGame] ... active and non active games
                if(isActive){
                    print("active game exist")
                    let options = TQKGameOptions(useWebPlayer: useWebPlayer, alwaysUseHLS: alwaysUseHLS)
                    TheQKit.LaunchGame(theGame: gamesArray!.first!, gameOptions: options) { (success) in
                        //launched
                    }
                }else{
                    print("no active games")
                }
            }
        }else{
            TheQKit.CheckForGames { (isActive, gamesArray) in
                //isActive : Bool
                //gamesArray : [TQKGame] ... active and non active games
                if(isActive){
                    print("active game exist")
                    let options = TQKGameOptions(useWebPlayer: useWebPlayer, alwaysUseHLS: alwaysUseHLS)
                    TheQKit.LaunchGame(theGame: gamesArray!.first!, gameOptions: options) { (success) in
                        //launched
                    }
                }else{
                    print("no active games")
                }
            }
        }
    }

    
    @IBAction func joinGame(_ sender: Any) {
        let options = TQKGameOptions(isEliminationDisabled: true)
        TheQKit.LaunchActiveGame(gameOptions: options) {_ in
            
        }
    }
    
    func cashOut() {
        TheQKit.CashOut()
    }
    
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                self.logout()
            }else{
                self.cashOut()
            }
        }else if(indexPath.section == 1) {
            if(indexPath.row == 0){
                self.searchAndLaunchGame(test: false, useWebPlayer: false, alwaysUseHLS: false)
            }else{
                self.searchAndLaunchGame(test: false, useWebPlayer: true, alwaysUseHLS: true)
            }
        }else {
            if(indexPath.row == 0){
                self.searchAndLaunchGame(test: true, useWebPlayer: false, alwaysUseHLS: false)
            }else{
                self.searchAndLaunchGame(test: true, useWebPlayer: true, alwaysUseHLS: true)
            }
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else{
            return 2
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "defaultCell")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LoginCell
        
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                cell.textLabel?.text = "Logout"
            }else{
                cell.textLabel?.text = "Cashout"
            }
        }else if(indexPath.section == 1) {
            if(indexPath.row == 0){
                cell.textLabel?.text = "Native / LLHLS"
            }else{
                cell.textLabel?.text = "Web / HLS"
            }
        }else {
            if(indexPath.row == 0){
                cell.textLabel?.text = "Native / LLHLS"
            }else{
                cell.textLabel?.text = "Web / HLS"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "TheQKit"
        }else if(section == 1){
            return "Normal Games"
        }else{
            return "Test Games"
        }
    }
}
