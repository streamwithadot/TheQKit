//
//  GameStatsViewController.swift
//  TheQKit
//
//  Created by Jonathan Spohn on 3/13/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class GameStatsViewController: UIViewController {

    
    var gameId : String! = ""
    var statsDelegate : StatsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitButton(_ sender: Any) {
        statsDelegate.leaderBoardGoDown()
    }
    
    func refreshStats(){
       let key = "token"
       let preferences = UserDefaults.standard
       let bearerToken = preferences.string(forKey: key)
       var finalBearerToken:String = "Bearer " + (bearerToken as! String)
      
       let gameHeaders: HTTPHeaders = [
           "Authorization": finalBearerToken,
           "Accept": "application/json"
       ]
       
       let params : Parameters = [
           "userId":(TheQKit.getUser()!.id)!,
           "uid":(TheQKit.getUser()!.id)!
       ]
       
       var url:String = TQKConstants.baseUrl + "games/\(gameId!)/view/leaderboard"
        
        if let partnerCode = TheQKit.getPartnerCode() {
           if(!partnerCode.isEmpty){
                url = url + "?partnerCode=\(partnerCode)"
           }
        }
       
       Alamofire.request(url, parameters: nil, headers: gameHeaders).responseJSON { response in
           print("Request: \(String(describing: response.request))")   // original url request
           print("Response: \(String(describing: response.response))") // http url response
           print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                print("failure")
            }
            
            response.result.ifSuccess {
                if let json = response.result.value as? [String: Any] {
                    
                    if ( !(json["success"] as! Bool) ) {
                        //api failure
                    }else{
                        
                        do{
                            let json = try JSON(data: response.data!)
                            print("JSON: \(json)") // serialized json response
                            
//                            self.leaderboard = Leaderboard(JSON: json.dictionaryObject!)
                            
                            
                        }catch{
                            print(error)
                        }
                    }

                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
