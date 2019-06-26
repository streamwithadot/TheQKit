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
//    var animationView : LOTAnimationView?

    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    @IBOutlet weak var answerViewA: UIView!
    @IBOutlet weak var answerViewB: UIView!
    @IBOutlet weak var answerViewC: UIView!

    
    @IBOutlet weak var progressViewA: UIProgressView!
    @IBOutlet weak var pvaHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pvaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelA: UILabel!
    @IBOutlet weak var answerCountLabelA: UILabel!
    @IBOutlet weak var imageViewA: UIImageView!
    @IBOutlet weak var ivaWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var progressViewB: UIProgressView!
    @IBOutlet weak var pvbHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pvbWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelB: UILabel!
    @IBOutlet weak var answerCountLabelB: UILabel!
    @IBOutlet weak var imageViewB: UIImageView!
    @IBOutlet weak var ivbWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var progressViewC: UIProgressView!
    @IBOutlet weak var pvcHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pvcWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelC: UILabel!
    @IBOutlet weak var answerCountLabelC: UILabel!
    @IBOutlet weak var imageViewC: UIImageView!
    @IBOutlet weak var ivcWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tintedView: UIView!
    
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionLabelWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var timesUpLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        progressViewA.layer.borderWidth = 2.0
        progressViewB.layer.borderWidth = 2.0
        progressViewC.layer.borderWidth = 2.0
        
        progressViewA.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        progressViewB.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        progressViewC.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        questionLabel.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.5)
        questionLabel.layer.cornerRadius = 10.0
        questionLabel.clipsToBounds = true
        
        progressViewA.clipsToBounds = true
        progressViewB.clipsToBounds = true
        progressViewC.clipsToBounds = true
        
        progressViewA.backgroundColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
        progressViewB.backgroundColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
        progressViewC.backgroundColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)

        
        timesUpLabel.clipsToBounds = true
        timesUpLabel.isHidden = false
        timesUpLabel.alpha = 0.0
        
        answerViewA.isHidden = true
        answerViewB.isHidden = true
        answerViewC.isHidden = true
        self.questionLabel.alpha = 0.0

        self.progressViewA.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
        self.progressViewB.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
        self.progressViewC.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)

        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        timesUpLabel.layer.cornerRadius = timesUpLabel.frame.size.height / 2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .stopQuestionAUuio, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: .playQuestionAudio, object: nil)

        if(type == .Question){
            let aGesture = UITapGestureRecognizer(target: self, action: #selector(self.aTapped(_:)))
            let bGesture = UITapGestureRecognizer(target: self, action: #selector(self.bTapped(_:)))
            let cGesture = UITapGestureRecognizer(target: self, action: #selector(self.cTapped(_:)))
            
            answerViewC.addGestureRecognizer(cGesture)
            answerViewC.isUserInteractionEnabled = true
            answerViewA.addGestureRecognizer(aGesture)
            answerViewA.isUserInteractionEnabled = true
            answerViewB.addGestureRecognizer(bGesture)
            answerViewB.isUserInteractionEnabled = true
            
        }

        progressViewA.layer.cornerRadius = progressViewA.frame.size.height / 2
        progressViewA.clipsToBounds = true
        progressViewA.layer.sublayers![1].cornerRadius = progressViewA.frame.size.height / 2
        progressViewA.subviews[1].clipsToBounds = true
        
        progressViewB.layer.cornerRadius = progressViewB.frame.size.height / 2
        progressViewB.clipsToBounds = true
        progressViewB.layer.sublayers![1].cornerRadius = progressViewB.frame.size.height / 2
        progressViewB.subviews[1].clipsToBounds = true
        
        progressViewC.layer.cornerRadius = progressViewC.frame.size.height / 2
        progressViewC.clipsToBounds = true
        progressViewC.layer.sublayers![1].cornerRadius = progressViewC.frame.size.height / 2
        progressViewC.subviews[1].clipsToBounds = true
     
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
            self.containerView.addSubview(animationView)
            
            animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
//                animationView.removeFromSuperview()
            }
            
//            self.perform(#selector(removeLottieView), with: self, afterDelay: 4.5)
            self.perform(#selector(animateOut), with: self, afterDelay: 4.6)
            
//#if !NEWSCORPUK
//            blurView.tintColor = UIColor("#32C274")
            tintedView.backgroundColor = UIColor("#32C274").withAlphaComponent(0.8)

//#endif

        }else if(type == .Incorrect){
            let animationView = AnimationView(name: "incorrect", bundle: TheQKit.bundle)
            animationView.frame = self.containerView.bounds
            animationView.backgroundColor = UIColor.clear
            animationView.contentMode = .scaleAspectFit
            self.containerView.addSubview(animationView)
            
            animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
//                animationView.removeFromSuperview()
            }
//            self.perform(#selector(removeLottieView), with: self, afterDelay: 4.5)
            self.perform(#selector(animateOut), with: self, afterDelay: 4.6)

//#if !NEWSCORPUK
//            blurView.tintColor = UIColor("#E63462")
            tintedView.backgroundColor = UIColor("#E63462").withAlphaComponent(0.8)

//#endif
            
        }
        
        questionLabelWidth.constant = 0.0
        
        pvaWidthConstraint.constant = 0.0
        questionLabelA.alpha = 0.0
        answerCountLabelA.alpha = 0.0
        ivaWidthConstraint.constant = 0.0

        pvbWidthConstraint.constant = 0.0
        questionLabelB.alpha = 0.0
        answerCountLabelB.alpha = 0.0
        ivbWidthConstraint.constant = 0.0

        pvcWidthConstraint.constant = 0.0
        questionLabelC.alpha = 0.0
        answerCountLabelC.alpha = 0.0
        ivcWidthConstraint.constant = 0.0

        
        self.questionLabel.text = self.question?.question!
        if(type == .Question){
            if((self.question?.choices!.count)! > 2){
                self.questionLabelA.text = self.question?.choices?[2].choice
                self.progressViewA.progressImage = self.selectedQuestionImage
            }
            self.questionLabelB.text = self.question?.choices?[1].choice
            self.questionLabelC.text = self.question?.choices?[0].choice
            
            self.progressViewB.progressImage = self.selectedQuestionImage
            self.progressViewC.progressImage = self.selectedQuestionImage

        }else if (type == .Correct && self.result?.selection != nil){
            if((self.result?.choices!.count)! > 2){
                self.questionLabelA.text = self.result?.choices?[2].choice
                if (self.result?.choices?[2].correct)!{
                    self.progressViewA.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
                }
                if (self.result?.choices?[2].id == self.result?.selection) {
                    // set progress view to red
                    self.progressViewA.progressImage = self.selectedImage
                    self.progressViewA.layer.borderColor = self.neutralBorderColor
                    
                    self.questionLabelA.textColor = UIColor("#32C274")
                    self.answerCountLabelA.textColor = UIColor("#32C274")
                    
                    progressViewA.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                    self.imageViewA.image = UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewB.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewC.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                }
            }
            self.questionLabelB.text = self.result?.choices?[1].choice
            self.questionLabelC.text = self.result?.choices?[0].choice
            
            
            
            if (self.result?.choices?[1].correct)!{
                // set progress view collor to green
                self.progressViewB.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
            }
            if (self.result?.choices?[0].correct)!{
                // set progress view collor to green
                self.progressViewC.progressTintColor = UIColor.init("#152248", defaultColor: UIColor.clear).withAlphaComponent(0.15)
            }
            
            if (self.result?.choices?[1].id == self.result?.selection) {
                // set progress view to red
//                #if !NEWSCORPUK
                self.progressViewB.progressImage = self.selectedImage
                self.progressViewB.layer.borderColor = self.neutralBorderColor
                
                self.questionLabelB.textColor = UIColor("#32C274")
                self.answerCountLabelB.textColor = UIColor("#32C274")
                
                progressViewB.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                self.imageViewB.image = UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                self.imageViewA.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                self.imageViewC.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)

//                #endif
            }else if (self.result?.choices?[0].id == self.result?.selection) {
                // set progress view to red
//                #if !NEWSCORPUK
                self.progressViewC.progressImage = self.selectedImage
                self.progressViewC.layer.borderColor = self.neutralBorderColor
                
                self.questionLabelC.textColor = UIColor("#32C274")
                self.answerCountLabelC.textColor = UIColor("#32C274")
                
                progressViewC.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                self.imageViewC.image = UIImage(named: "qCorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                self.imageViewB.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                self.imageViewA.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)

//                #endif
            }
            
            
        }else if(type == .Incorrect){
            
            if(self.result != nil){
                
                if((self.result?.choices!.count)! > 2){
                    self.questionLabelA.text = self.result?.choices?[2].choice
                    if (self.result?.choices?[2].correct)!{
                        self.imageViewA.image = UIImage(named: "qCorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                        self.imageViewB.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                        self.imageViewC.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                        
                    }
                    
                    if(self.result?.selection != nil){
                        if (self.result?.choices?[2].id == self.result?.selection) {
                            // set progress view to red
                            self.progressViewA.progressImage = self.selectedImage
                            self.progressViewA.layer.borderColor = self.neutralBorderColor
                            
                            self.questionLabelA.textColor = UIColor("#E63462")
                            self.answerCountLabelA.textColor = UIColor("#E63462")
                            
                            progressViewA.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                            self.imageViewA.image = UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                        }
                    }
                }
                self.questionLabelB.text = self.result?.choices?[1].choice
                self.questionLabelC.text = self.result?.choices?[0].choice
                
                if (self.result?.choices?[1].correct)!{
                    // set progress view collor to green
                    self.imageViewB.image = UIImage(named: "qCorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewA.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewC.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)

                }else if (self.result?.choices?[0].correct)!{
                    // set progress view collor to green
                    self.imageViewC.image = UIImage(named: "qCorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewB.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                    self.imageViewA.image = UIImage(named: "qIncorrectUnselected.png", in: TheQKit.bundle, compatibleWith: nil)
                }
                
                if(self.result?.selection != nil){
                
                    if (self.result?.choices?[1].id == self.result?.selection) {
                        // set progress view to red
                        self.progressViewB.progressImage = self.selectedImage
                        self.progressViewB.layer.borderColor = self.neutralBorderColor
                        
                        self.questionLabelB.textColor = UIColor("#E63462")
                        self.answerCountLabelB.textColor = UIColor("#E63462")
                        
                        progressViewB.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                        self.imageViewB.image = UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                    }
                    if (self.result?.choices?[0].id == self.result?.selection) {
                        // set progress view to red
                        self.progressViewC.progressImage = self.selectedImage
                        self.progressViewC.layer.borderColor = self.neutralBorderColor
                        
                        self.questionLabelC.textColor = UIColor("#E63462")
                        self.answerCountLabelC.textColor = UIColor("#E63462")
                        
                        progressViewC.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.70)
                        self.imageViewC.image = UIImage(named: "qIncorrectSelected.png", in: TheQKit.bundle, compatibleWith: nil)
                    }
                }
            }
        }
        
        self.view.layoutIfNeeded()
        
        progressViewA.setProgress(0.0, animated: false)
        progressViewB.setProgress(0.0, animated: false)
        progressViewC.setProgress(0.0, animated: false)
        
        answerViewA.isHidden = false
        answerViewB.isHidden = false
        answerViewC.isHidden = false
        
        if(type == .Question){
            if((self.question?.choices!.count)! < 3){
                self.answerViewA.isHidden = true
            }else{
                self.answerViewA.isHidden = false
            }
        }else{
            if((self.result?.choices!.count)! < 3){
                self.answerViewA.isHidden = true
            }else{
                self.answerViewA.isHidden = false
            }
        }
        
        var totalResponse = 0
        if(type != .Question){
            for choice in (self.result?.choices!)! {
                totalResponse += choice.responses!
            }
        }
        
        if(self.type == .Question){
            let qNum: Int! = self.question?.number
            self.timesUpLabel.text = String(format: NSLocalizedString(" Question %@ ", comment: ""), "\(String(qNum))")

            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                self.timesUpLabel.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                self.timesUpLabel.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }

            self.timesUpLabel.backgroundColor = UIColor.white
        }else if(self.type == .Correct){
            self.timesUpLabel.text = NSLocalizedString("  Correct!  ", comment: "")
//#if !NEWSCORPUK
            self.timesUpLabel.textColor = UIColor("#32C274")
            self.timesUpLabel.backgroundColor = UIColor.white
//#else
//            self.timesUpLabel.textColor = UIColor.white
//            self.timesUpLabel.backgroundColor = UIColor("#32C274")
//#endif
        }else if(self.type == .Incorrect){
            self.timesUpLabel.text = NSLocalizedString("  Wrong Answer!  ", comment: "")
//#if !NEWSCORPUK
            self.timesUpLabel.textColor = UIColor("#E63462")
            self.timesUpLabel.backgroundColor = UIColor.white
//#else
//            self.timesUpLabel.textColor = UIColor.white
//            self.timesUpLabel.backgroundColor = UIColor("#E63462")
//#endif
        }
        
        if(  (self.type != .Question && (self.result?.choices!.count)! > 2) ||  (self.type == .Question && (self.question?.choices!.count)! > 2)    ){
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                self.pvaWidthConstraint.constant = self.answerViewA.frame.width
                self.questionLabelA.alpha = 1.0
                if(self.type != .Question){
                    self.answerCountLabelA.alpha = 1.0
                    let a: Int! = self.result?.choices?[2].responses!
                    self.answerCountLabelA.text = String(a)
                    self.ivaWidthConstraint.constant = 30.0
                    
                    
                }
                self.view.layoutIfNeeded()

            }) { (bool) in
                if(self.type != .Question){
                    self.setProgressBarFill(bar: self.progressViewA, totalResponses: Float(totalResponse), responses: Float((self.result?.choices?[2].responses)!))
                    if(self.type == .Correct){
                        if (self.result?.choices?[2].correct)!{
                            self.showPlusOneFor(view: self.progressViewA)
                        }
                    }
                    
                }
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {

            self.pvbWidthConstraint.constant = self.answerViewB.frame.width
            self.questionLabelB.alpha = 1.0
            if(self.type != .Question){
                self.answerCountLabelB.alpha = 1.0
                let b: Int! = self.result?.choices?[1].responses!
                self.answerCountLabelB.text = String(b)
                self.ivbWidthConstraint.constant = 30.0
                
            }
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            if(self.type != .Question){
                self.setProgressBarFill(bar: self.progressViewB, totalResponses: Float(totalResponse), responses: Float((self.result?.choices?[1].responses)!))
                if(self.type == .Correct){
                    if (self.result?.choices?[1].correct)!{
                        self.showPlusOneFor(view: self.progressViewB)
                    }
                }
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.pvcWidthConstraint.constant = self.answerViewC.frame.width
            self.questionLabelC.alpha = 1.0
            if(self.type != .Question){
                self.answerCountLabelC.alpha = 1.0
                let c: Int! = self.result?.choices?[0].responses!
                self.answerCountLabelC.text = String(c)
                self.ivcWidthConstraint.constant = 30.0
            }
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            if(self.type != .Question){
                self.setProgressBarFill(bar: self.progressViewC, totalResponses: Float(totalResponse), responses: Float((self.result?.choices?[0].responses)!))
                if(self.type == .Correct){
                    if (self.result?.choices?[0].correct)!{
                        self.showPlusOneFor(view: self.progressViewC)
                    }
                }
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.questionLabel.alpha = 1.0
            self.questionLabelWidth.constant = self.answerViewC.frame.width
            self.timesUpLabel.alpha = 1.0

            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()
            
        }) { (bool) in
            //na
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
            self.questionLabelA.alpha = 0.0
            self.answerCountLabelA.alpha = 0.0
            self.pvaWidthConstraint.constant = 0.0
            self.ivaWidthConstraint.constant = 0.0
            self.view.layoutIfNeeded()
//            self.view.alpha = 0.0
            //            self.progressViewA.layoutIfNeeded()
        }) { (bool) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            //            self.progressViewC.frame = originalC
            //            self.pvbHeightConstraint.constant = 70.0
            self.questionLabelB.alpha = 0.0
            self.answerCountLabelB.alpha = 0.0
            self.pvbWidthConstraint.constant = 0.0
            self.ivbWidthConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            //            self.progressViewB.layoutIfNeeded()
            
        }) { (bool) in
            //na
            
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            //            self.progressViewC.frame = originalC
            //            self.pvcHeightConstraint.constant = 70.0
            self.answerCountLabelC.alpha = 0.0
            self.pvcWidthConstraint.constant = 0.0
            self.questionLabelC.alpha = 0.0
            self.ivcWidthConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()
            
        }) { (bool) in
            //na
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.timesUpLabel.alpha = 0.0
            self.questionLabel.alpha = 0.0
            self.questionLabelWidth.constant = 0.0
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
    
    @objc func aTapped(_ sender: UITapGestureRecognizer) {
        print("yo we tapped a")
        if ((self.gameDelegate?.userSubmittedAnswer)!) {
            self.view.makeToast("You already answered the question :)", duration: 2.0, position: .bottom)
            
        }else if (!(self.gameDelegate?.isQuestionActive)!) {
            self.view.makeToast("Time has expired :(", duration: 2.0, position: .bottom)
            
            
        }else{
            
            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                questionLabelA.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                questionLabelA.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }
            
            progressViewA.progressImage = self.selectedQuestionImage

            progressViewA.setProgress(1.0, animated: false)
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: (self.question?.choices?[2].id)!, choiceText: (self.question?.choices?[2].choice)!)
            
//            showLoadingIndicatorFor(view: self.progressViewA)
            progressViewA.alpha = 0.3
        }
        
    }
    
    @objc func bTapped(_ sender: UITapGestureRecognizer) {
        print("yo we tapped b")
        if ((self.gameDelegate?.userSubmittedAnswer)!) {
            self.view.makeToast("You already answered the question :)", duration: 2.0, position: .bottom)
            
        } else if (!(self.gameDelegate?.isQuestionActive)!) {
            self.view.makeToast("Time has expired :(", duration: 2.0, position: .bottom)
            
            
        }else{
            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                questionLabelB.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                questionLabelB.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }
            
            progressViewB.progressImage = self.selectedQuestionImage

            progressViewB.setProgress(1.0, animated: false)
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: (self.question?.choices?[1].id)!, choiceText: (self.question?.choices?[1].choice)!)
            
//            showLoadingIndicatorFor(view: self.progressViewB)
            progressViewB.alpha = 0.3
        }
    }
    @objc func cTapped(_ sender: UITapGestureRecognizer) {
        print("yo we tapped c")
        if ((self.gameDelegate?.userSubmittedAnswer)!) {
            self.view.makeToast("You already answered the question :)", duration: 2.0, position: .bottom)
            
        }
        else if (!(self.gameDelegate?.isQuestionActive)!) {
            self.view.makeToast("Time has expired :(", duration: 2.0, position: .bottom)
            
            
        }else{
            if(self.question?.categoryId == nil || (self.question?.categoryId.isEmpty)!){
                questionLabelC.textColor = UIColor(TQKConstants.GEN_COLOR_CODE).withAlphaComponent(0.8)
            }else{
                questionLabelC.textColor = self.gameDelegate?.getColorForID(catId: (self.question?.categoryId)!).withAlphaComponent(0.8)
            }
            
            progressViewC.progressImage = self.selectedQuestionImage

            progressViewC.setProgress(1.0, animated: false)
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: (self.question?.choices?[0].id)!, choiceText: (self.question?.choices?[0].choice)!)
            
//            showLoadingIndicatorFor(view: self.progressViewC)
            progressViewC.alpha = 0.3
        }
    }
    
//    func showLoadingIndicatorFor(view : UIView){
//
//#if !NEWSCORPUK
//        let frame = self.view.convert(view.frame, from: view.superview)
//
//        self.linearBar.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 3)
//        self.linearBar.widthForLinearBar = frame.size.width
//
//        self.linearBar.heightForLinearBar = 3
//        linearBar.backgroundColor = .clear
//        if(self.currentQuestion.categoryId == nil || (self.currentQuestion.categoryId?.isEmpty)!){
//            linearBar.progressBarColor = UIColor.init(Constants.GEN_COLOR_CODE, defaultColor: UIColor.blue)
//        }else{
//            linearBar.progressBarColor = (self.leaderboardDelegate?.getColorForID(catId: self.currentQuestion.categoryId!))!
//        }
//        self.linearBar.startAnimation()
//#endif
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

