//
//  SSQuestionViewController.swift
//  theq
//
//  Created by Jonathan Spohn on 10/25/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit
//import AVFoundation
import Lottie
import UIColor_Hex_Swift

class SSQuestionViewController: UIViewController, UITextFieldDelegate {

    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    let correctBorderColor = UIColor("#00A878").cgColor
    let neutralBorderColor = UIColor("#FFFFFF").cgColor
    let incorrectBorderColor = UIColor("#E93060").cgColor
    
    let popularChoiceDefaultColor = UIColor("#468EE5").cgColor
    let popularChoiceDefaultColorString = "#468EE5"
    
    var gameDelegate : GameDelegate?
    var question : TQKQuestion?
    
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var answerViewC: UIView!
    @IBOutlet weak var answerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tintedView: UIView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var timesUpLabel: UILabel!
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var yourAnswerLabel: UILabel!
    @IBOutlet weak var inputAnswerLabel: UILabel!
    
//    var audioPlayer : AVAudioPlayer?
    
    var didLayout : Bool = false
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        yourAnswerLabel.alpha = 0.0
        inputAnswerLabel.alpha = 0.0
        
        questionLabel.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.5)
        questionLabel.layer.cornerRadius = 10.0
        questionLabel.clipsToBounds = true
        
        //        timesUpLabel.layer.cornerRadius = timesUpLabel.frame.size.height / 2
        //        timesUpLabel.clipsToBounds = true
        //        timesUpLabel.isHidden = false
        //        timesUpLabel.alpha = 0.0
        
        
        self.questionLabel.alpha = 0.0
        
        //        if(self.view.frame.height >= 812){
        //            bottomLayoutConstraint.constant = 250
        //        }else if(self.view.frame.height <= 570){
        //            bottomLayoutConstraint.constant = 50
        //        }
        
        
        if(self.view.frame.height >= 812){  //Xs and above
            bottomLayoutConstraint.constant = 250
        }else if(self.view.frame.height <= 670 && self.view.frame.height > 570){  //8
            bottomLayoutConstraint.constant = 150
        }else if(self.view.frame.height <= 570){ //SE
            bottomLayoutConstraint.constant = 100
        }else{
            bottomLayoutConstraint.constant = 150
        }
        
        
    }
    
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        //        let animationCurve = UIViewAnimationOptions.fromRaw(UInt(rawAnimationCurve))!
        
        //        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        if(self.view.frame.height >= 812){
            if(view.bounds.maxY - convertedKeyboardEndFrame.minY < 250 ){
                bottomLayoutConstraint.constant = 250
            }else{
                bottomLayoutConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 5
            }
        }else if(self.view.frame.height <= 670 && self.view.frame.height > 570){
            if(view.bounds.maxY - convertedKeyboardEndFrame.minY < 150 ){
                bottomLayoutConstraint.constant = 150
            }else{
                bottomLayoutConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 25
            }
        }else if(self.view.frame.height <= 570){
            if(view.bounds.maxY - convertedKeyboardEndFrame.minY < 100 ){
                bottomLayoutConstraint.constant = 100
            }else{
                bottomLayoutConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 25
            }
        }else{
            if(view.bounds.maxY - convertedKeyboardEndFrame.minY < 150 ){
                bottomLayoutConstraint.constant = 150
            }else{
                bottomLayoutConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 25
            }
        }
        
        let animationOptions: UIView.AnimationOptions = [animationCurve, .beginFromCurrentState]
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }) { (complate) in
            //do nothing
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        self.gameDelegate?.stopAudio()
//        audioPlayer?.pause()
//        audioPlayer?.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        self.containerView.viewWithTag(589)?.removeFromSuperview()
        if(!didLayout){
            didLayout = true
            
            let animationView = AnimationView(name: "USPopularChoiceTimer", bundle: TheQKit.bundle)
            
//            containerView.setAnimation(named: "USPopularChoiceTimer")
            animationView.frame = self.containerView.bounds
            animationView.backgroundColor = UIColor.clear
            animationView.contentMode = .scaleAspectFit
            self.containerView.addSubview(animationView)
            
            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let timeLeft : CGFloat = CGFloat((self.question?.secondsToRespond)!)
            let beginProgress : CGFloat = 1.0 - (timeLeft / 13)
            self.perform(#selector(showTimeIsUp), with: self, afterDelay: TimeInterval(timeLeft))
            
            animationView.play(fromProgress: beginProgress, toProgress: 1.0){ (finished) in
                animationView.removeFromSuperview()
            }
            
            self.answerTextField.backgroundColor = UIColor.init("#000000", defaultColor: UIColor.clear).withAlphaComponent(0.12)
            self.answerTextField.layer.borderWidth = 1
            self.answerTextField.layer.borderColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.5).cgColor
            self.answerTextField.layer.masksToBounds = true

            self.answerTextField.attributedPlaceholder = NSAttributedString(string: "Your Answer", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.5)])
            
            //            self.submitButton.backgroundColor = UIColor.init("#FFFFFF", defaultColor: UIColor.clear).withAlphaComponent(0.30)
        }
        
        self.answerTextField.layer.cornerRadius = self.answerTextField.frame.height / 2

        
        //        self.submitButton.layer.borderColor = self.neutralBorderColor
        //        self.submitButton.layer.borderWidth = 1.0
        //        self.submitButton.layer.cornerRadius = self.submitButton.frame.height / 2
        //        self.submitButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: TheQKit.bundle.path(forResource: "Countdown", ofType:"wav")!))
////            audioPlayer?.prepareToPlay()
//            //TODO - make atTime work
//            //        var startTime = 15 - self.currentQuestion!.secondsToRespond!
//            //        if startTime < 0 { startTime = 0 }
//            audioPlayer?.volume = 0.4
//            DispatchQueue.global(qos: .background).async {
//                self.audioPlayer?.play()//(atTime: TimeInterval(startTime))
//            }
//        } catch {
//            // couldn't load file :(
//            print("error playing audio")
//        }
//        
//        self.gameDelegate?.beginAudio()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SSQuestionViewController.keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SSQuestionViewController.keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //        progressViewA.layer.cornerRadius = progressViewA.frame.size.height / 2
        //        progressViewA.clipsToBounds = true
        //        progressViewA.layer.sublayers![1].cornerRadius = progressViewA.frame.size.height / 2
        //        progressViewA.subviews[1].clipsToBounds = true
        
        
        
        
        
        
        tintedView.backgroundColor = UIColor(popularChoiceDefaultColorString).withAlphaComponent(0.8)
        
        
        
        //        questionLabelWidth.constant = 0.0
        
        //        pvaWidthConstraint.constant = 0.0
        //        questionLabelA.alpha = 0.0
        //        answerCountLabelA.alpha = 0.0
        //        ivaWidthConstraint.constant = 0.0
//        DispatchQueue.main.async {
            self.questionLabel.text = self.question?.question!
            self.view.layoutIfNeeded()
//        }
        
        //        progressViewA.setProgress(0.0, animated: false)
        //        answerViewA.isHidden = false
        
        //        let qNum: Int! = self.question?.number
        //        self.timesUpLabel.text = "  Question \(String(qNum))  "
        //        #if NEWSCORPUK
        //        self.timesUpLabel.textColor = UIColor(Constants.GEN_COLOR_CODE)
        //        #else
        //        timesUpLabel.textColor = self.leaderboardDelegate?.getColorForID(catId: (self.question?.categoryId)!)
        //        #endif
        //        self.timesUpLabel.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            self.answerTextField.becomeFirstResponder()
        }
        
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            //            self.pvaWidthConstraint.constant = self.answerViewA.frame.width
            //            self.questionLabelA.alpha = 1.0
            //
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            self.questionLabel.alpha = 1.0
            //            self.questionLabelWidth.constant = self.trivi.frame.width
            //            self.timesUpLabel.alpha = 1.0
            
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
            
            //            self.timesUpLabel.alpha = 0.0
            self.questionLabel.alpha = 0.0
            //            self.questionLabelWidth.constant = 0.0
            self.view.layoutIfNeeded()
            //            self.progressViewC.layoutIfNeeded()
            
        }) { (bool) in
            //na
        }
    }
    
    @objc func showTimeIsUp() {
        
        self.perform(#selector(animateOut), with: self, afterDelay: 2.0)
        
        UIView.animate(withDuration: 0.20, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            //            self.timesUpLabel.alpha = 0.0
            
        }) { (bool) in
            //na
            
            //            self.timesUpLabel.text = "  Time's up!  "
            //            //            self.timesUpLabel.textColor = UIColor.white
            //            #if NEWSCORPUK
            //            self.timesUpLabel.textColor = UIColor.init(Constants.GEN_COLOR_CODE)
            //            #else
            //            self.timesUpLabel.textColor = self.leaderboardDelegate?.getColorForID(catId: (self.question?.categoryId)!)
            //            #endif
            //            self.timesUpLabel.backgroundColor = UIColor.white
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                
                //                self.timesUpLabel.alpha = 1.0
                
            }) { (bool) in
                //na
                UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    
                    //                    self.timesUpLabel.alpha = 0.0
                    
                }) { (bool) in
                    //na
                }
            }
        }
        
        
        
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        
        if(self.answerTextField.hasText){
            DispatchQueue.main.async {
                self.answerTextField.resignFirstResponder()
            }
            self.gameDelegate?.submitAnswer(questionId: (self.question?.questionId!)!, responseId: self.answerTextField.text!, choiceText: self.answerTextField.text!)
            
            self.inputAnswerLabel.text = self.answerTextField.text!
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
                
                self.submitButton.alpha = 0.0
                self.answerTextField.isEnabled = false
                self.answerTextField.alpha = 0.0
                
                self.inputAnswerLabel.alpha = 1.0
                self.yourAnswerLabel.alpha = 1.0
            }) { (bool) in
                //na
            }
            
            
            
        }else{
            //show no text entered
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if(textField == self.answerTextField){
            self.submitPressed(self)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 24
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    //    func restoreQuestion(){
    //        self.answerViewHeightConstraint.multiplier = 6.59
    //        self.answerViewHeightConstraint.constant = 0.147
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
