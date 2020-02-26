//
//  ViewController.swift
//  testViews
//
//  Created by Jonathan Spohn on 6/17/18.
//  Copyright © 2018 Stream Live Inc. All rights reserved.
//

import UIKit
import Lottie
import UIColor_Hex_Swift

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
    
    let correctBorderColor = UIColor("#00A878").cgColor
    let neutralBorderColor = UIColor("#FFFFFF").cgColor
    let incorrectBorderColor = UIColor("#E93060").cgColor
    
    let correctImage: UIImage = UIImage(named: "bar_correct", in: TheQKit.bundle, compatibleWith: nil)!
    let incorrectImage: UIImage = UIImage(named: "bar_eliminated", in: TheQKit.bundle, compatibleWith: nil)!
    let neutralImage: UIImage = UIImage(named: "bar_light", in: TheQKit.bundle, compatibleWith: nil)!
    let selectedImage: UIImage = UIImage(named: "bar_white", in: TheQKit.bundle, compatibleWith: nil)!
    let selectedQuestionImage: UIImage = UIImage(named: "bar_white", in: TheQKit.bundle, compatibleWith: nil)!
    
    var gameDelegate : GameDelegate?
    var question : TQKQuestion?
    var result : TQKResult?
    var type : FullScreenType?
    
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
    @IBOutlet weak var triviaTableTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var triviaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
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
                
                
                if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                    tintedView.backgroundColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
                }else{
                    tintedView.backgroundColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
                }

                
            }else if(type == .Correct){
                let animationView = AnimationView(name: "correct", bundle: TheQKit.bundle)
                animationView.frame = self.containerView.bounds
                animationView.backgroundColor = UIColor.clear
                animationView.contentMode = .scaleAspectFit
                animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.containerView.addSubview(animationView)
                
                animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                }
                

                self.perform(#selector(animateOut), with: self, afterDelay: 4.6)
                

                tintedView.backgroundColor = UIColor("#32C274").withAlphaComponent(0.8)


            }else if(type == .Incorrect){
                let animationView = AnimationView(name: "incorrect", bundle: TheQKit.bundle)
                animationView.frame = self.containerView.bounds
                animationView.backgroundColor = UIColor.clear
                animationView.contentMode = .scaleAspectFit
                animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.containerView.addSubview(animationView)
                
                animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                }
                self.perform(#selector(animateOut), with: self, afterDelay: 4.6)

                tintedView.backgroundColor = UIColor("#E63462").withAlphaComponent(0.8)

                
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
        
        
        
        self.view.layoutIfNeeded()
        
        

        var totalResponse = 0
        if(type != .Question){
            for choice in (self.result?.choices!)! {
                totalResponse += choice.responses!
            }
        }
        
        if(self.type == .Question){
            let qNum: Int! = self.question?.number
            
            if(self.question?.questionType == TQKQuestionType.TEXT_SURVEY.rawValue){
                self.timesUpLabel.text = String(format: NSLocalizedString(" Survey ", comment: ""))
            }else{
                self.timesUpLabel.text = String(format: NSLocalizedString(" Question %@ ", comment: ""), "\(String(qNum))")
            }

            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                self.timesUpLabel.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                self.timesUpLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }

            self.timesUpLabel.backgroundColor = UIColor.white
        }else if(self.type == .Correct){
            if(self.question?.questionType == TQKQuestionType.TEXT_SURVEY.rawValue){
                self.timesUpLabel.text = String(format: NSLocalizedString(" Survey Results ", comment: ""))
            }else{
                self.timesUpLabel.text = NSLocalizedString("  Correct!  ", comment: "")
            }
            self.timesUpLabel.textColor = UIColor("#32C274")
            self.timesUpLabel.backgroundColor = UIColor.white

        }else if(self.type == .Incorrect){
            if(self.question?.questionType == TQKQuestionType.TEXT_SURVEY.rawValue){
                self.timesUpLabel.text = String(format: NSLocalizedString(" Survey Results ", comment: ""))
            }else{
                self.timesUpLabel.text = NSLocalizedString("  Wrong Answer!  ", comment: "")
            }
            self.timesUpLabel.textColor = UIColor("#E63462")
            self.timesUpLabel.backgroundColor = UIColor.white

        }
        
        self.triviaTable.reloadData()
        
        
        //get last visible cell
        let lastCell = self.triviaTable.visibleCells.last
        //get distance between the cell and bottom of safe area
        let cellFrame = self.view.convert(lastCell!.frame, from: lastCell!.superview)
        var distance : Double = 0.0
        if #available(iOS 11.0, *) {
            distance = Double((self.view.frame.height - self.view.safeAreaInsets.bottom) - (cellFrame.origin.y + cellFrame.height))
        } else {
            // Fallback on earlier versions
            distance = Double(self.view.frame.height - (cellFrame.origin.y + cellFrame.height))
        }
        
        var count = 0
        if(type == .Question){
            count = self.question!.choices!.count
        }else{
            count = self.result!.choices!.count
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {

            self.questionLabel.alpha = 1.0
            self.questionLabelWidth.constant = self.view.frame.width - 20
            self.timesUpLabel.alpha = 1.0
            self.triviaTable.alpha = 1.0
            
            //adust the trivia table top constraint to half the distance from above
            if(self.triviaTable.visibleCells.count < count){
                let x = count - self.triviaTable.visibleCells.count
                self.triviaViewHeightConstraint.constant = self.triviaViewHeightConstraint.constant + CGFloat(50 * x)
                self.containerViewHeightConstraint.constant = self.containerViewHeightConstraint.constant - CGFloat(50 * x)
                self.view.layoutIfNeeded()
            }else{
                let halfDist = CGFloat(distance / 2)
                self.triviaTableTopConstraint.constant = halfDist <= 5 ? 5 : halfDist
            }
            
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()

        }) { (bool) in
            //na
        }
                
        for index in 0...count{
                    
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
                        cell.progressView.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
                    }
                    if (currentChoice.id == self.result?.selection) {
                        cell.progressView.progressImage = self.selectedImage
                        cell.progressView.layer.borderColor = self.neutralBorderColor
                        cell.progressView.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                        cell.selectedImageView.image = UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
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
                                cell.progressView.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                                cell.selectedImageView.image = UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
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
                            if(self.type == .Correct){
                                if (self.result?.choices?[index].correct)!{
                                    self.showPlusOneFor(view: cell.progressView)
                                }
                            }
                        }
                    }
            }
        }
        
    }
    
    func showPlusOneFor(view : UIView){
        let frame = self.view.convert(view.frame, from: view.superview)
        let correctLabel = UILabel(frame: CGRect(x: frame.width, y: frame.origin.y, width: 30, height: 30))
        correctLabel.text = "+1"
        correctLabel.textAlignment = .center
        correctLabel.textColor = UIColor.white
        

        if(self.result?.categoryId == nil || (self.result?.categoryId!.isEmpty)!){
            correctLabel.backgroundColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
        }else{
            correctLabel.backgroundColor = self.gameDelegate?.getColorForID(catId: (self.result?.categoryId)!).withAlphaComponent(0.8)
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
            self.triviaTable.alpha = 0.0
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()

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
            
            self.timesUpLabel.text = "  Time's up!  "

            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                self.timesUpLabel.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                self.timesUpLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }
            
            self.timesUpLabel.backgroundColor = UIColor.white
            
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
            self.view.makeToast("You already answered the question :)", duration: 2.0, position: .bottom)
        }else if (!(self.gameDelegate?.isQuestionActive)!) {
            self.view.makeToast("Time has expired :(", duration: 2.0, position: .bottom)
        }else{
            
            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                cell.questionLabel.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                cell.questionLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }
            
            cell.progressView.progressImage = self.selectedQuestionImage

            cell.progressView.setProgress(1.0, animated: false)
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: (self.question?.choices?[indexPath.row].id)!, choiceText: (self.question?.choices?[indexPath.row].choice)!)
            
            cell.progressView.alpha = 0.3
                                    
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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

extension FullScreenTriviaViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(type == .Question){
            return self.question!.choices!.count
        }else{
            return self.result!.choices!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fullScreenTriviaCell", for: indexPath) as! FullScreenTriviaCell
        cell.progressView.layer.cornerRadius = cell.progressView.frame.size.height / 2
        cell.progressView.clipsToBounds = true
        cell.progressView.layer.sublayers![1].cornerRadius = cell.progressView.frame.size.height / 2
        cell.progressView.subviews[1].clipsToBounds = true
        if(type == .Question){
            cell.questionLabel.text = self.question?.choices?[indexPath.row].choice
            cell.progressView.progressImage = self.selectedQuestionImage
        }else if (type == .Correct && self.result?.selection != nil){
            
            let currentChoice = self.result!.choices![indexPath.row]
            cell.questionLabel.text = currentChoice.choice
            
            if (currentChoice.correct)!{
                cell.progressView.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
            }
            if (currentChoice.id == self.result?.selection) {
                cell.progressView.progressImage = self.selectedImage
                cell.progressView.layer.borderColor = self.neutralBorderColor
                
                cell.questionLabel.textColor = UIColor("#32C274")
                cell.answerCountLabel.textColor = UIColor("#32C274")
                
                cell.progressView.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                cell.selectedImageView.image = UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
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
                        
                        cell.questionLabel.textColor = UIColor("#E63462")
                        cell.answerCountLabel.textColor = UIColor("#E63462")
                        
                        cell.progressView.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                        cell.selectedImageView.image = UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
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
            progressView.backgroundColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
            answerView.isHidden = true
            progressView.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
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

