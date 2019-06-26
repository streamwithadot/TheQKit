//
//  GameWinnersViewController.swift
//  theq
//
//  Created by Jonathan Spohn on 2/19/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
import Kingfisher

class GameWinnersViewController: UIViewController {

    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var gameWinnerTableView: UITableView!
    var reward : String?
    var gameWinners : GameWinners!
//    {
//        didSet {
//            self.gameWinnerTableView.reloadData()
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 2
//        closeButton.clipsToBounds = true
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 0.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameWinnerTableView.delegate = self
        gameWinnerTableView.dataSource = self
        // Do any additional setup after loading the view.
        
//        let blurEffect = UIBlurEffect(style: .regular)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        gameWinnerTableView.backgroundView = blurEffectView
        gameWinnerTableView.backgroundColor =  UIColor.clear

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeWinnersScreen(_ sender: Any) {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}

extension GameWinnersViewController : UITableViewDelegate {
    
}

extension GameWinnersViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0){
            return 200
        }else{
            return 65
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(gameWinners == nil){
            return 0
        }
        
        if(section == 0){
            return 1
        }else{
            return (gameWinners.winners?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "WinnerStatsTableViewCell", for: indexPath) as! WinnerStatsTableViewCell
            
            if(gameWinners.winnerCount < 1){
                cell.winnerCountLabel.text = String(format: NSLocalizedString(" %@ Winners! ", comment: ""), "\(gameWinners.winnerCount)")
            }else if(gameWinners.winnerCount == 1){
                cell.winnerCountLabel.text = String(format: NSLocalizedString(" %@ Winner! ", comment: ""), "\(gameWinners.winnerCount)")
            }else{
                cell.winnerCountLabel.text = String(format: NSLocalizedString(" %@ Winners! ", comment: ""), "\(gameWinners.winnerCount)")
            }
            
            let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
            formatter.locale = Locale(identifier: TQKConstants.LOCALE) // Here indian locale with english language is used
            formatter.numberStyle = .currency               // Change to `.currency` if needed
            
            let asd = formatter.string(from: NSNumber(value: Int(reward!)!)) // "10,00,000"
            
            
            cell.prizeAmountLabel.text = "\(asd!) Prize"
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WinnerTableViewCell", for: indexPath) as! WinnerTableViewCell
            
            cell.winnerImageView.image = nil
            
            let winner = gameWinners.winners![indexPath.row]
            
            cell.winnerUsernameLabel.text = "\(winner.user)"
            
            if(winner.pic == nil || winner.pic.isEmpty ){
                cell.winnerImageView.setImageForName(string: winner.user, backgroundColor: nil, circular: true, textAttributes: nil)
            }else{
                guard let theUrl = URL(string: winner.pic) else {
                    return cell
                }
                cell.winnerImageView.kf.setImage(with: theUrl,
                                                placeholder: UIImage.init(named: "defaultAvatar"),
                                                options: [.transition(ImageTransition.fade(1))],
                                                progressBlock: { receivedSize, totalSize in
                                                    print("profileImage: \(receivedSize)/\(totalSize)")
                },
                                                completionHandler: { image, error, cacheType, imageURL in
                                                    print("profileImage: Finished")
                                                    
                })
            }
            
            
            
            
            let amount = (Double(Int(self.reward!)!) / Double(gameWinners.winnerCount))
//            let formattedString = String(format:"%.2f",amount)
//            amount = Double(formattedString)!
            
            let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
            formatter.locale = Locale(identifier: TQKConstants.LOCALE) // Here indian locale with english language is used
            formatter.numberStyle = .currency               // Change to `.currency` if needed
            
            let asd = formatter.string(from: NSNumber(value: amount)) // "10,00,000"
            
            cell.winningsLabel.text = "\(asd!)"
            
            if(indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
            } else {
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            }
            
            return cell
        }
    }
    
    
}
