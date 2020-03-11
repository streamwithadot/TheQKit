//
//  SSResultViewController.swift
//  theq
//
//  Created by Jonathan Spohn on 10/25/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
import Lottie
import UIColor_Hex_Swift

class SSResultViewController: UIViewController {
    
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    let correctBorderColor = UIColor("#00A878").cgColor
    let neutralBorderColor = UIColor("#FFFFFF").cgColor
    let incorrectBorderColor = UIColor("#E93060").cgColor
    
    var gameDelegate : GameDelegate?
    var result : TQKResult?
    var question : TQKQuestion?
    var type : FullScreenType?
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tintedView: UIView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var timesUpLabel: UILabel!
    
    @IBOutlet weak var resultsTableView: UITableView!
    

    var didLayout : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        //        resultsTableView.rowHeight = UITableView.automaticDimension
        //        resultsTableView.estimatedRowHeight = 90
        
        questionLabel.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.5)
        questionLabel.layer.cornerRadius = 10.0
        questionLabel.clipsToBounds = true
        
        timesUpLabel.alpha = 0.0
        
        resultsTableView.alpha = 0.0
        
        self.questionLabel.alpha = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(!didLayout){
            didLayout = true
            
        }
        
        //        timesUpLabel.layer.cornerRadius = timesUpLabel.frame.size.height / 2
        timesUpLabel.clipsToBounds = true
        timesUpLabel.isHidden = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.resultsTableView.reloadData()
        
        self.questionLabel.text = self.question?.question! ?? ""
        self.view.layoutIfNeeded()
        
        if(type == .Correct){
            let animationView = AnimationView(name: "correct_PC", bundle: TheQKit.bundle)
            animationView.frame = self.containerView.bounds
            animationView.backgroundColor = UIColor.clear
            animationView.contentMode = .scaleAspectFit
            self.containerView.addSubview(animationView)
            
            animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                //                animationView.removeFromSuperview()
            }
            
            self.perform(#selector(animateOut), with: self, afterDelay: 5.6)
            
            tintedView.backgroundColor = UIColor("#32C274").withAlphaComponent(0.8)
            
        }else{
            let animationView = AnimationView(name: "incorrect_PC", bundle: TheQKit.bundle)
            animationView.frame = self.containerView.bounds
            animationView.backgroundColor = UIColor.clear
            animationView.contentMode = .scaleAspectFit
            self.containerView.addSubview(animationView)
            
            animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                //                animationView.removeFromSuperview()
            }
            self.perform(#selector(animateOut), with: self, afterDelay: 5.6)
            
            tintedView.backgroundColor = UIColor("#E63462").withAlphaComponent(0.8)
        }
        
        self.timesUpLabel.text = self.result?.selection ?? NSLocalizedString("None", comment: "")
        self.timesUpLabel.textColor = UIColor.white
        self.timesUpLabel.backgroundColor = UIColor.clear
        
        
        UIView.animate(withDuration: 0.35, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.questionLabel.alpha = 1.0
            self.questionLabelWidth.constant = self.view.frame.width - 30
            self.timesUpLabel.alpha = 1.0
            self.resultsTableView.alpha = 1.0
            
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()
            
        }) { (bool) in
            //na
        }
    }
    
    @objc func removeLottieView(){
        //        self.animationView?.play(fromFrame: 0.3, toFrame: 1.0, withCompletion: { (finished) in
        //            self.animationView?.removeFromSuperview()
        //        })
    }
    
    @objc func animateOut(){
        
        UIView.animate(withDuration: 0.25, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            //            self.progressViewC.frame = originalC
            
            //            self.pvaHeightConstraint.constant = 70.0
            //            self.questionLabelA.alpha = 0.0
            //            self.answerCountLabelA.alpha = 0.0
            //            self.pvaWidthConstraint.constant = 0.0
            //            self.ivaWidthConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            //            self.view.alpha = 0.0
            //            self.progressViewA.layoutIfNeeded()
        }) { (bool) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.timesUpLabel.alpha = 0.0
            self.questionLabel.alpha = 0.0
            self.questionLabelWidth.constant = 0.0
            self.resultsTableView.alpha = 0.0
            
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()
            
        }) { (bool) in
            //na
        }
    }
    
}

extension SSResultViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let x = tableView.frame.height / 3
        return x >= 90 ? 90 : x
    }
}

extension SSResultViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.result?.results == nil){
            return 1
        }else{
            return (self.result?.results?.count)! > 3 ? 3 : (self.result?.results?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSResultsTableViewCell", for: indexPath) as! SSResultsTableViewCell
        
        if(self.result?.results != nil && !(self.result?.results?.isEmpty)!){
            let popularChoice = self.result?.results![indexPath.row]
            
            cell.rankLabel.text = "\(indexPath.row + 1)"
            cell.answerLabel.text = popularChoice!.response ?? "No Answers!"
            let userResponseRatio = popularChoice!.userResponseRatio ?? 0
            
            if(userResponseRatio < 1){
                cell.percentageLabel.text = "<1%"
            }else{
                let myInt = Int(userResponseRatio.rounded(.up))
                cell.percentageLabel.text = "\(myInt)%"
            }
            
            //            if((popularChoice?.correct)!){
            if(self.result?.selection != nil && self.result?.results?[indexPath.row].response == self.result?.selection){
                cell.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.30)
            }
            //            }
            
        }else{
            cell.rankLabel.text = "\(indexPath.row + 1)"
            cell.answerLabel.text = "No Answers!"
            cell.percentageLabel.text = "0%"
        }
        
        if(self.type == .Correct){
            cell.rankLabel.textColor = UIColor("#32C274")
            cell.rankLabel.backgroundColor = UIColor.white
        }else{
            cell.rankLabel.textColor = UIColor("#E63462")
            cell.rankLabel.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    
}
