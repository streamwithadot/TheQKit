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
    
    var currentScore: NSNumber?
    var currentQuestionNum : Int = 0
    var totalQuestionNum : Int = 0
    var mostRecentQuestionNUm : Int = 0
    
    var gameStats : TQKGameStats?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var statsTableView: UITableView!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statsTableView.delegate = self
        statsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitButton(_ sender: Any) {
        statsDelegate.leaderBoardGoDown()
    }
    
    func refreshStats(){
        
        let username = TheQKit.getUser()!.username!
       //Update userscore first
        if(currentScore != nil){
            self.scoreLabel.text = String(format: NSLocalizedString("Your Score: %@ Points", comment: ""), "\(currentScore!)")
        }else{
            self.scoreLabel.text = String(format: NSLocalizedString("Your Score: 0 Points", comment: ""))
        }
        
        
        if(totalQuestionNum != 0){
            self.currentQuestionLabel.text = String(format: NSLocalizedString("Question %@ / %@", comment: ""), "\(currentQuestionNum)","\(totalQuestionNum)")
        }else{
            self.currentQuestionLabel.text = String(format: NSLocalizedString("Question %@", comment: ""), "\(currentQuestionNum)")
        }
        
        
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
                            self.gameStats = TQKGameStats(JSON: json.dictionaryObject!)
                            if (self.gameStats != nil && self.gameStats!.leaderBoardList != nil){
                                for i in 0 ..< self.gameStats!.leaderBoardList!.count {
                                    if (i - 1 >= 0) {
                                        if let item = self.gameStats?.leaderBoardList![i], let item2 = self.gameStats?.leaderBoardList![i - 1]{
                                            if(item.score == item2.score){
                                                self.gameStats!.leaderBoardList![i].rank = item2.rank
                                            }else{
                                                self.gameStats!.leaderBoardList![i].rank = item2.rank + 1
                                            }
                                        }else{
                                            self.gameStats!.leaderBoardList![i].rank = i
                                        }
                                    }else{
                                        self.gameStats!.leaderBoardList![i].rank = i
                                    }
                                }
                            }
                            
                            self.statsTableView.reloadData()

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

extension GameStatsViewController : UITableViewDelegate {
    
}

extension GameStatsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let gs = self.gameStats {
            if(gs.leaderBoardList != nil){
                if(gs.leaderBoardList!.isEmpty){
                    return 1
                }else{
                    return gs.leaderBoardList!.count
                }
            }else{
                return 1
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let gs = self.gameStats {
            if(gs.leaderBoardList!.isEmpty){
                let cell = UITableViewCell.init()
                cell.textLabel?.text = "No Questions Asked Yet"
                cell.textLabel?.textAlignment = .center
                return cell
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameStatCell", for: indexPath) as! GameStatCell
        
        if let item = gameStats?.leaderBoardList![indexPath.row] {
            
            cell.rankLabel.text = "  \(item.rank + 1)  "
            cell.usernameLabel.text = "\(item.username ?? "")"
            cell.scoreLabel.text = "  \(item.score ?? 0)  "
        }
        
        return cell
    }
    
    
}



class GameStatCell : UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        rankLabel.layer.cornerRadius = 10
        rankLabel.clipsToBounds = true
            
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.clipsToBounds = true

    }
}
