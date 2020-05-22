//
//  ViewController.swift
//  testViews
//
//  Created by Jonathan Spohn on 6/17/18.
//  Copyright © 2018 Stream Live Inc. All rights reserved.
//

import UIKit
import Lottie
//import UIColor_Hex_Swift

enum FullScreenType : String {
    case Question
    case Correct
    case Incorrect
    case NoSelect
}

class FullScreenTriviaViewController: UIViewController {

    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    
    let correctBorderColor = TheQKit.hexStringToUIColor(hex: "#00A878").cgColor
    let neutralBorderColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").cgColor
    let incorrectBorderColor = TheQKit.hexStringToUIColor(hex: "#E93060").cgColor
    
    let correctImage: UIImage = UIImage(named: "bar_correct", in: TheQKit.bundle, compatibleWith: nil)!
    let incorrectImage: UIImage = UIImage(named: "bar_eliminated", in: TheQKit.bundle, compatibleWith: nil)!
    let neutralImage: UIImage = UIImage(named: "bar_light", in: TheQKit.bundle, compatibleWith: nil)!
    let selectedImage: UIImage = UIImage(named: "bar_white", in: TheQKit.bundle, compatibleWith: nil)!
    let selectedQuestionImage: UIImage = UIImage(named: "bar_white", in: TheQKit.bundle, compatibleWith: nil)!
    
    var gameDelegate : GameDelegate?
    var question : TQKQuestion?
    var result : TQKResult?
    var type : FullScreenType?
    var gameOptions : TQKGameOptions?
    var theGame : TQKGame?
    
    var useLongTimer : Bool = false
    var didLayout : Bool = false
//    var animationView : LOTAnimationView?

    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var triviaTable: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var timesUpLabel: UILabel!
    @IBOutlet weak var timesUpLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var timesUpLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var triviaTableTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var triviaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var yourAnswerLabel: UILabel!
    @IBOutlet weak var yourAnswerLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.triviaTable.delegate = self
        self.triviaTable.dataSource = self
        
        questionLabel.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.5)
        questionLabel.layer.cornerRadius = 10.0
        questionLabel.clipsToBounds = true
        timesUpLabel.clipsToBounds = true
        timesUpLabel.isHidden = false
        timesUpLabel.alpha = 0.0
        triviaTable.alpha = 0.0
        self.questionLabel.alpha = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        timesUpLabel.layer.cornerRadius = timesUpLabel.frame.size.height / 2
        
        if(!didLayout){
            didLayout = true
            if(type == .Question){
                
                self.timesUpLabel.removeConstraint(self.timesUpLabelWidth)

                var timerString : String
                if(self.useLongTimer){
                     timerString = "TimerUS15"
                }else{
                    timerString = "timer"
                }
                let animationView = AnimationView(name: timerString, bundle: TheQKit.bundle)
                animationView.frame = self.containerView.bounds
                animationView.backgroundColor = UIColor.clear
                animationView.contentMode = .scaleAspectFit
                animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.containerView.addSubview(animationView)
             
                let timeLeft : CGFloat = CGFloat((self.question?.secondsToRespond)!)
                if(self.useLongTimer){
                    let beginProgress : CGFloat = 1.0 - (timeLeft / 15)
                    self.perform(#selector(showTimeIsUp), with: self, afterDelay: TimeInterval(timeLeft))
                    
                    animationView.play(fromProgress: beginProgress, toProgress: 1.0){ (finished) in
                        animationView.removeFromSuperview()
                    }
                }else{
                    let beginProgress : CGFloat = 1.0 - (timeLeft / 10)
                    self.perform(#selector(showTimeIsUp), with: self, afterDelay: TimeInterval(timeLeft))
                    
                    animationView.play(fromProgress: beginProgress, toProgress: 1.0){ (finished) in
                        animationView.removeFromSuperview()
                    }
                }
                
                
                let alpha = self.gameOptions!.questionBackgroundAlpha
                if let cc = self.gameOptions?.colorCode {
                    tintedView.backgroundColor = TheQKit.hexStringToUIColor(hex: cc).withAlphaComponent(alpha)
                }else if(self.gameOptions?.useThemeColors == true){
                    if let dcc = theGame?.theme.defaultColorCode{
                        tintedView.backgroundColor = TheQKit.hexStringToUIColor(hex: dcc).withAlphaComponent(alpha)
                    }else{
                        tintedView.backgroundColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE).withAlphaComponent(alpha)
                    }
                }else{
                    if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                        tintedView.backgroundColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE).withAlphaComponent(alpha)
                    }else{
                        tintedView.backgroundColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(alpha)
                    }
                }
                
            }else{
                
                var lottieName = ""
                if(self.result!.isFreeformText){
                    
                    //Popular choice modes
                    timesUpLabel.removeConstraint(timesUpLabelHeight)
                    yourAnswerLabel.removeConstraint(yourAnswerLabelHeight)
                    timesUpLabelWidth.constant = self.view.frame.width - 20
                    timesUpLabel.textAlignment = .center
                    
                    self.timesUpLabel.textColor = UIColor.white
                    self.timesUpLabel.backgroundColor = UIColor.clear
                    self.timesUpLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
                    self.questionLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
                    
                    let alpha = self.gameOptions!.questionBackgroundAlpha
                    if(type == .Correct){
                        lottieName = "correct_PC"
                        tintedView.backgroundColor = self.gameOptions?.correctBackgroundColor.withAlphaComponent(alpha)
                    }else{
                        lottieName = "incorrect_PC"
                        tintedView.backgroundColor = self.gameOptions?.incorrectBackgroundColor.withAlphaComponent(alpha)
                    }
                    self.perform(#selector(animateOut), with: self, afterDelay: 5.6)
                
                }else{
                    //Multiple choice modes
                    self.timesUpLabel.removeConstraint(self.timesUpLabelWidth)
                    let alpha = self.gameOptions!.questionBackgroundAlpha
                    if(type == .Correct){
                        lottieName = "correct"
                        tintedView.backgroundColor = self.gameOptions?.correctBackgroundColor.withAlphaComponent(alpha)

                     }else if(type == .Incorrect){
                        lottieName = "incorrect"
                        tintedView.backgroundColor = self.gameOptions?.incorrectBackgroundColor.withAlphaComponent(alpha)
                     }
                    
                    self.perform(#selector(animateOut), with: self, afterDelay: 4.6)
                }
                if(self.result?.pointValue != nil){
                    //add a points label instead of a lottie animation
                    if(type == .Correct){
                       self.pointsLabel.text = "+\(self.result!.pointValue!)"
                    }else if(type == .Incorrect){
                      self.pointsLabel.text = "+0"
                    }
                    self.pointsLabel.alpha = 0.0
                    self.pointsLabel.isHidden = false
                    
                
                    UIView.animate(withDuration: 3.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
                       self.pointsLabel.alpha = 1.0
                       self.pointsLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }) { (bool) in
//                        UIView.animate(withDuration: 1.0, delay: 0.25, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .curveLinear, animations: {
//                            self.pointsLabel.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
//                            self.pointsLabel.center = CGPoint(x: self.view.frame.width, y: 0)
//                          }) { (bool) in
//                                self.pointsLabel.removeFromSuperview()
//                          }
                    }

                }else{
                    let animationView = AnimationView(name: lottieName, bundle: TheQKit.bundle)
                    animationView.frame = self.containerView.bounds
                    animationView.backgroundColor = UIColor.clear
                    animationView.contentMode = .scaleAspectFit
                    animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.containerView.addSubview(animationView)
                    animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                       //                animationView.removeFromSuperview()
                    }
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.type == .Question){
            NotificationCenter.default.post(name: .stopQuestionAudio, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if(self.type == .Question){
            NotificationCenter.default.post(name: .playQuestionAudio, object: nil)
        }
        
        questionLabelWidth.constant = 0.0
        questionLabel.text = self.question?.question!
        
        if(self.gameOptions!.useThemeColors){
            questionLabel.textColor = TheQKit.hexStringToUIColor(hex: self.theGame!.theme.textColorCode)
        }
        
        self.view.layoutIfNeeded()
        
        var totalResponse = 0
        if(type != .Question && !self.result!.isFreeformText){
            for choice in (self.result?.choices!)! {
                totalResponse += choice.responses!
            }
        }
        
        self.triviaTable.reloadData()
        var distance : Double = 0.0
        
        if(self.type == .Question){

            let qNum: Int! = self.question?.number
            
            if(self.question?.questionType == TQKQuestionType.CHOICE_SURVEY){
                self.timesUpLabel.text = String(format: NSLocalizedString("  Survey  ", comment: ""))
            }else{
                if(self.question?.pointValue != nil &&  !self.question!.pointOverride){
                    //Show pointvalue here instead
                    self.timesUpLabel.text = String(format: NSLocalizedString("  %@ Points  ", comment: ""), "\(self.question!.pointValue!)")
                }else{
                    self.timesUpLabel.text = String(format: NSLocalizedString("  Question %@  ", comment: ""), "\(String(qNum))")
                }
                
            }
            
            if let cc = self.gameOptions?.colorCode {
                self.timesUpLabel.textColor = TheQKit.hexStringToUIColor(hex: cc)
            }else if(self.gameOptions?.useThemeColors == true){
                if let dcc = theGame?.theme.defaultColorCode{
                    self.timesUpLabel.textColor = TheQKit.hexStringToUIColor(hex: dcc)
                }else{
                    self.timesUpLabel.textColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }
            }else{
                if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                    self.timesUpLabel.textColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }else{
                    self.timesUpLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!)
                }
            }
            
            if(self.question!.isMultipleChoice){
                //get last visible cell
                let lastCell = self.triviaTable.visibleCells.last
                //get distance between the cell and bottom of safe area
                if let cellFrame = self.view?.convert(lastCell!.frame, from: lastCell!.superview) {
                    if #available(iOS 11.0, *) {
                        distance = Double((self.view.frame.height - self.view.safeAreaInsets.bottom) - (cellFrame.origin.y + cellFrame.height))
                    } else {
                        // Fallback on earlier versions
                        distance = Double(self.view.frame.height - (cellFrame.origin.y + cellFrame.height))
                    }
                }
            }

            self.timesUpLabel.backgroundColor = UIColor.white
        }else{
            if(self.result!.isFreeformText){
                //pop choice types
                self.timesUpLabel.text = self.question?.question!
                self.questionLabel.text = self.result?.selection ?? NSLocalizedString("None", comment: "")
                
            }else{
                //multiple choice types
                if(self.type == .Correct){
                    if(self.question?.questionType == TQKQuestionType.CHOICE_SURVEY){
                        self.timesUpLabel.text = String(format: NSLocalizedString("  Survey Results  ", comment: ""))
                    }else{
                        self.timesUpLabel.text = NSLocalizedString("  Correct!  ", comment: "")
                    }
                    self.timesUpLabel.textColor = self.gameOptions?.correctBackgroundColor
                    self.timesUpLabel.backgroundColor = UIColor.white

                }else if(self.type == .Incorrect){
                    if(self.question?.questionType == TQKQuestionType.CHOICE_SURVEY){
                        self.timesUpLabel.text = String(format: NSLocalizedString("  Survey Results  ", comment: ""))
                    }else{
                        self.timesUpLabel.text = NSLocalizedString("  Wrong Answer!  ", comment: "")
                    }
                    self.timesUpLabel.textColor = self.gameOptions?.incorrectBackgroundColor
                    self.timesUpLabel.backgroundColor = UIColor.white
                }
                
                //get last visible cell
                let lastCell = self.triviaTable.visibleCells.last
                //get distance between the cell and bottom of safe area
                if let cellFrame = self.view?.convert(lastCell!.frame, from: lastCell!.superview) {
                    if #available(iOS 11.0, *) {
                        distance = Double((self.view.frame.height - self.view.safeAreaInsets.bottom) - (cellFrame.origin.y + cellFrame.height))
                    } else {
                        // Fallback on earlier versions
                        distance = Double(self.view.frame.height - (cellFrame.origin.y + cellFrame.height))
                    }
                }
                
            }
        }
        
        
        var count = 0
        if(type == .Question){
            count = self.question!.choices!.count
        }else{
            if(self.result!.isFreeformText){
                count = (self.result?.results?.count)! > 3 ? 3 : (self.result?.results?.count)!
            }else{
                count =  self.result!.choices!.count
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {

            self.questionLabel.alpha = 1.0
            self.questionLabelWidth.constant = self.view.frame.width - 20
            self.timesUpLabel.alpha = 1.0
            self.triviaTable.alpha = 1.0
            

            if( (count > 4) && self.triviaTable.visibleCells.count <= count){
                //If we have more cells that can currently be shown, adjust constraints to expand the choices and shrink the area above (lottie)
                let x = (count + 1) - self.triviaTable.visibleCells.count
                self.triviaViewHeightConstraint.constant = self.triviaViewHeightConstraint.constant + CGFloat(50 * x)
                self.containerViewHeightConstraint.constant = self.containerViewHeightConstraint.constant - CGFloat(50 * x)
                self.view.layoutIfNeeded()
            }else{
                //adust the trivia table top constraint to half the distance from above
                    let halfDist = CGFloat(distance / 2)
                    self.triviaTableTopConstraint.constant = halfDist <= 5 ? 5 : halfDist
                
            }
            
            
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()

        }) { (bool) in
            //na
        }
                
        for index in 0...count{
                
            if(type != .Question && self.result!.isFreeformText){
                //pop choice
                if let cell = self.triviaTable.cellForRow(at: IndexPath(row: index, section: 0)) as? SSResultsTableViewCell {
                    //TODO: IF NEEDED?
                }

            }else{
                //multi choice
                if let cell = self.triviaTable.cellForRow(at: IndexPath(row: index, section: 0)) as? FullScreenTriviaCell {
                    
                    cell.progressView.layer.cornerRadius = cell.progressView.frame.size.height / 2
                    cell.progressView.clipsToBounds = true
                    cell.progressView.layer.sublayers![1].cornerRadius = cell.progressView.frame.size.height / 2
                    cell.progressView.subviews[1].clipsToBounds = true
                
                    if(type == .Question){
                        cell.progressView.progressImage = self.selectedQuestionImage
                    }else if (type == .Correct && self.result?.selection != nil){
                        
                        let currentChoice = self.result!.choices![index]
                        
                        if (currentChoice.correct)!{
                            cell.progressView.progressTintColor = TheQKit.hexStringToUIColor(hex: "#152248").withAlphaComponent(0.15)
                        }
                        if (currentChoice.id == self.result?.selection) {
                            cell.progressView.progressImage = self.selectedImage
                            cell.progressView.layer.borderColor = self.neutralBorderColor
                            cell.progressView.backgroundColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.70)
                            
                            let imageView = UIImageView(image: UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil))
                            imageView.setImageColor(color: self.gameOptions!.correctBackgroundColor)
                            cell.selectedImageView.image = imageView.image
                        }else{
                            cell.selectedImageView.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                        }
                    
                    }else if(type == .Incorrect){
                        if(self.result != nil){
                            let currentChoice = self.result!.choices![index]

                            if(currentChoice.correct!){
                                cell.selectedImageView.image = UIImage(named: "qCorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                            }else{
                                cell.selectedImageView.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                            }
                            
                            if(self.result?.selection != nil){
                                if (currentChoice.id == self.result?.selection) {
                                    cell.progressView.progressImage = self.selectedImage
                                    cell.progressView.layer.borderColor = self.neutralBorderColor
                                    cell.progressView.backgroundColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.70)
                                    
                                    let imageView = UIImageView(image: UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil))
                                    imageView.setImageColor(color: self.gameOptions!.correctBackgroundColor)
                                    cell.selectedImageView.image = imageView.image
                                }
                            }
                        }
                    }
                    
                    UIView.animate(withDuration: 0.35, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                        cell.pvWidthConstraint.constant = cell.answerView.frame.width
                        cell.questionLabel.alpha = 1.0
                        if(self.type != .Question){
                            cell.answerCountLabel.alpha = 1.0
                            let b: Int! = self.result?.choices?[index].responses!
                            cell.answerCountLabel.text = String(b)
                            cell.ivWidthConstraint.constant = 30.0
            
                        }
                        self.view.layoutIfNeeded()
            
                    }) { (bool) in
                        if(self.type != .Question){
                            self.setProgressBarFill(bar: cell.progressView, totalResponses: Float(totalResponse), responses: Float((self.result?.choices?[index].responses)!))
                            if(self.type == .Correct && (self.result?.questionType != TQKQuestionType.CHOICE_SURVEY)){
                                if (self.result?.choices?[index].correct)!{
                                    self.showPlusOneFor(view: cell.progressView)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func showPlusOneFor(view : UIView){
        if let frame = self.view?.convert(view.frame, from: view.superview) {
            let correctLabel = UILabel(frame: CGRect(x: frame.width, y: frame.origin.y, width: 30, height: 30))
            correctLabel.text = "+1"
            correctLabel.textAlignment = .center
            
            if let cc = self.gameOptions?.colorCode {
                correctLabel.textColor = UIColor.white
                correctLabel.backgroundColor = TheQKit.hexStringToUIColor(hex: cc)
            }else if(self.gameOptions?.useThemeColors == true){
                correctLabel.textColor = TheQKit.hexStringToUIColor(hex: (theGame?.theme.textColorCode)!)
                if let dcc = theGame?.theme.defaultColorCode{
                    correctLabel.backgroundColor = TheQKit.hexStringToUIColor(hex: dcc)
                }else{
                    correctLabel.backgroundColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }
            }else{
                correctLabel.textColor = UIColor.white
                if(self.result?.categoryId == nil || (self.result?.categoryId!.isEmpty)!){
                    correctLabel.backgroundColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }else{
                    correctLabel.backgroundColor = self.gameDelegate?.getColorForID(catId: (self.result?.categoryId)!)
                }
            }
            
            correctLabel.layer.cornerRadius = 15
            correctLabel.clipsToBounds = true
            
            self.view.addSubview(correctLabel)
            
            //                    correctLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeLinear, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2.0, animations: {
                    //                            correctLabel.transform = .identity
                    correctLabel.frame.origin =  CGPoint(x: correctLabel.frame.origin.x, y: correctLabel.frame.origin.y - 50)
                    correctLabel.alpha = 0.0
                })
            }, completion: {_ in
                correctLabel.removeFromSuperview()
            })
        }
    }
    
    func setProgressBarFill(bar: UIProgressView, totalResponses: Float, responses: Float )
    {
        print("Adjusting progress bar for results")
        let percent:Float = Float(responses/totalResponses)
        print("percentage " + "\(percent)")
        if percent.isInfinite {
            print("progress bar is infinite")
            bar.setProgress(0, animated: true)
        }
        else {
            if(percent <= 0.17){
                bar.setProgress(0.17, animated: true)
            }else{
                bar.setProgress(percent, animated: true)
            }
        }
    }
    
    @objc func removeLottieView(){
//        self.animationView?.play(fromFrame: 0.3, toFrame: 1.0, withCompletion: { (finished) in
//            self.animationView?.removeFromSuperview()
//        })
    }
    
    @objc func animateOut(){
        
        UIView.animate(withDuration: 0.25, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {

            self.view.layoutIfNeeded()
            
        }) { (bool) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {

            self.timesUpLabel.alpha = 0.0
            self.questionLabel.alpha = 0.0
            self.questionLabelWidth.constant = 0.0
            self.triviaTable.alpha = 0.0
            self.view.layoutIfNeeded()

        }) { (bool) in
            //na
        }
    }
    
    @objc func showTimeIsUp() {
        
        self.perform(#selector(animateOut), with: self, afterDelay: 2.0)
        
        UIView.animate(withDuration: 0.20, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            self.timesUpLabel.alpha = 0.0
            
        }) { (bool) in
            //na
            
            self.timesUpLabel.text = NSLocalizedString("  Time's up!  ", comment: "")
//            self.timesUpLabel.backgroundColor = UIColor.white
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                self.timesUpLabel.alpha = 1.0
                
            }) { (bool) in
                //na
                UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    
                    self.timesUpLabel.alpha = 0.0
                    
                }) { (bool) in
                    //na
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fadeAllCellsOut(){
        var count = 0
        if(type == .Question){
            count = self.question!.choices!.count
        }else{
            count = self.result!.choices!.count
        }
        for index in 0...count{
            if let cell = self.triviaTable.cellForRow(at: IndexPath(row: index, section: 0)) as? FullScreenTriviaCell {
                cell.progressView.alpha = 0.0
            }
        }
    }
    
    func fadeAllCellsIn(){
        var count = 0
        if(type == .Question){
            count = self.question!.choices!.count
        }else{
            count = self.result!.choices!.count
        }
        for index in 0...count{
            if let cell = self.triviaTable.cellForRow(at: IndexPath(row: index, section: 0)) as? FullScreenTriviaCell {
                cell.progressView.alpha = 1.0
            }
        }
    }
}


// MARK: TableView Delegate and Datasource
extension FullScreenTriviaViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.type != .Question){
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! FullScreenTriviaCell
        
        if ((self.gameDelegate?.userSubmittedAnswer)!) {
            self.view.makeToast(NSLocalizedString("You already answered the question :)", comment: ""), duration: 2.0, position: .bottom)
        }else if (!(self.gameDelegate?.isQuestionActive)!) {
            self.view.makeToast(NSLocalizedString("Time has expired :(",comment: ""), duration: 2.0, position: .bottom)
        }else{
            
            let alpha = self.gameOptions!.questionBackgroundAlpha
            if let cc = self.gameOptions?.colorCode {
                cell.questionLabel.textColor = TheQKit.hexStringToUIColor(hex: cc)
            }else if(self.gameOptions?.useThemeColors == true){
                if let dcc = theGame?.theme.defaultColorCode{
                    cell.questionLabel.textColor = TheQKit.hexStringToUIColor(hex: dcc)
                }else{
                    cell.questionLabel.textColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }
            }else{
                if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                    cell.questionLabel.textColor = TheQKit.hexStringToUIColor(hex: TQKConstants.GEN_COLOR_CODE)
                }else{
                    cell.questionLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!)
                }
            }
            
            cell.progressView.progressImage = self.selectedQuestionImage

            cell.progressView.setProgress(1.0, animated: false)
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: (self.question?.choices?[indexPath.row].id)!, choiceText: (self.question?.choices?[indexPath.row].choice)!)
            
            cell.progressView.alpha = 0.3
                                    
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(type != .Question && self.result!.isFreeformText){
            let x = tableView.frame.height / 3
            return x >= 90 ? 90 : x
        }else{
        
            var height : CGFloat = 70.0
            if(type == .Question){
                let x = CGFloat(tableView.frame.height) / CGFloat(self.question!.choices!.count)
                height = (x >= 70 ? 70 : x)
            }else{
                let x = CGFloat(tableView.frame.height) / CGFloat(self.result!.choices!.count)
                height = (x >= 70 ? 70 : x)
            }

            return height <= 50 ? 50 : height
        }
        
    }
}

extension FullScreenTriviaViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(type == .Question){
            return self.question!.choices!.count
        }else{
            if(self.result!.isFreeformText){
                if(self.result?.results == nil){
                    return 1
                }else{
                    return (self.result?.results?.count)! > 3 ? 3 : (self.result?.results?.count)!
                }
            }else{
                return self.result!.choices!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(type != .Question && self.result!.isFreeformText){
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
                    cell.backgroundColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.3)
                }
                //            }
                
            }else{
                cell.rankLabel.text = "\(indexPath.row + 1)"
                cell.answerLabel.text = "No Answers!"
                cell.percentageLabel.text = "0%"
            }
            
            if(self.type == .Correct){
                cell.rankLabel.textColor = TheQKit.hexStringToUIColor(hex: "#32C274")
                cell.rankLabel.backgroundColor = UIColor.white
            }else{
                cell.rankLabel.textColor = TheQKit.hexStringToUIColor(hex: "#E63462")
                cell.rankLabel.backgroundColor = UIColor.white
            }
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "fullScreenTriviaCell", for: indexPath) as! FullScreenTriviaCell
            cell.progressView.layer.cornerRadius = cell.progressView.frame.size.height / 2
            cell.progressView.clipsToBounds = true
            cell.progressView.layer.sublayers![1].cornerRadius = cell.progressView.frame.size.height / 2
            cell.progressView.subviews[1].clipsToBounds = true
            if(type == .Question){
                
                let item = self.question?.choices?[indexPath.row]
                if(self.question?.pointValue != nil){
                    //handle points values
                    if(self.question!.pointOverride){
                       // show individual points on questins
                        let pointValue = item!.pointValue != nil ? item!.pointValue : self.question?.pointValue
                        cell.answerCountLabel.text = "+\(pointValue!)"
                        cell.answerCountLabel.alpha = 1.0
                    }
                }
                    
                cell.questionLabel.text = "\(item!.choice!)"
                if(self.gameOptions!.useThemeColors){
                    cell.questionLabel.textColor = TheQKit.hexStringToUIColor(hex: self.theGame!.theme.textColorCode)
                }
                cell.progressView.progressImage = self.selectedQuestionImage
            }else if (type == .Correct && self.result?.selection != nil){
                
                let currentChoice = self.result!.choices![indexPath.row]
                cell.questionLabel.text = currentChoice.choice
                
                if (currentChoice.correct)!{
                    cell.progressView.progressTintColor = TheQKit.hexStringToUIColor(hex: "#152248").withAlphaComponent(0.15)
                }
                if (currentChoice.id == self.result?.selection) {
                    cell.progressView.progressImage = self.selectedImage
                    cell.progressView.layer.borderColor = self.neutralBorderColor
                    
                    cell.questionLabel.textColor = self.gameOptions?.correctBackgroundColor
                    cell.answerCountLabel.textColor = self.gameOptions?.correctBackgroundColor
                    
                    cell.progressView.backgroundColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.70)

                    let imageView = UIImageView(image: UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil))
                    imageView.setImageColor(color: self.gameOptions!.correctBackgroundColor)
                    cell.selectedImageView.image = imageView.image
                }else{
                    cell.selectedImageView.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                }
            
            }else if(type == .Incorrect){
                
                if(self.result != nil){
                    let currentChoice = self.result!.choices![indexPath.row]

                    cell.questionLabel.text = currentChoice.choice
                    
                    if(currentChoice.correct!){
                        cell.selectedImageView.image = UIImage(named: "qCorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    }else{
                        cell.selectedImageView.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    }
                    
                    if(self.result?.selection != nil){
                        if (currentChoice.id == self.result?.selection) {
                            cell.progressView.progressImage = self.selectedImage
                            cell.progressView.layer.borderColor = self.neutralBorderColor
                            
                            cell.questionLabel.textColor = self.gameOptions?.incorrectBackgroundColor
                            cell.answerCountLabel.textColor = self.gameOptions?.incorrectBackgroundColor
                            
                            cell.progressView.backgroundColor = TheQKit.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.70)
                            
                            let imageView = UIImageView(image: UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil))
                            imageView.setImageColor(color: self.gameOptions!.correctBackgroundColor)
                            cell.selectedImageView.image = imageView.image
                        }
                    }
                }
            }
            
            cell.pvWidthConstraint.constant = cell.answerView.frame.width
            cell.questionLabel.alpha = 1.0
            if(self.type != .Question){
                let currentChoice = self.result!.choices![indexPath.row]
                cell.answerCountLabel.alpha = 1.0
                let a: Int! = currentChoice.responses!
                cell.answerCountLabel.text = String(a)
                cell.ivWidthConstraint.constant = 30.0
            }else{
                cell.ivWidthConstraint.constant = 0.0
            }
    //        self.view.layoutIfNeeded()
            

            return cell
        }
    }
    
    
}

class FullScreenTriviaCell : UITableViewCell {
        
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var pvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pvWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerCountLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var ivWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
        
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()

            progressView.layer.borderWidth = 2.0
            progressView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            progressView.clipsToBounds = true
            progressView.backgroundColor = TheQKit.hexStringToUIColor(hex: "#152248").withAlphaComponent(0.15)
            answerView.isHidden = true
            progressView.progressTintColor = TheQKit.hexStringToUIColor(hex: "#152248").withAlphaComponent(0.15)
            progressView.layer.cornerRadius = progressView.frame.size.height / 2
            progressView.clipsToBounds = true
            progressView.layer.sublayers![1].cornerRadius = progressView.frame.size.height / 2
            progressView.subviews[1].clipsToBounds = true
    
        
            progressView.setProgress(0.0, animated: false)
            
            answerView.isHidden = false
        
       }
       
       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
