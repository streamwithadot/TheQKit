//
//  GameViewController.swift
//  theq
//
//  Created by Will Jamieson on 10/25/17.
//  Copyright © 2017 Stream Live. All rights reserved.
//

import UIKit
import AVFoundation
import VideoToolbox

import IJKMediaFramework

import Toast_Swift
import Alamofire
import UIColor_Hex_Swift
import ObjectMapper
import SwiftyJSON
import Lottie

import IKEventSource

import Mixpanel

//test
// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Class

protocol HeartDelegate {
    func useHeart()
}

protocol GameDelegate {
    func submitAnswer(questionId: String, responseId: String, choiceText: String?)
    func getColorForID(catId: String) -> UIColor
    
    var userSubmittedAnswer : Bool { get }
    var isQuestionActive : Bool { get }
//    var leaderboardDelegate : LeaderboardDelegate { get }
//    var colorArray : Dictionary<String, String> { get }
}

class GameViewController: UIViewController, HeartDelegate, GameDelegate {
    
    func getColorForID(catId: String) -> UIColor {
        if(colorOverride != nil){
            return UIColor.init(colorOverride!, defaultColor: UIColor.init(TQKConstants.GEN_COLOR_CODE))
        }
        let colorIndex = colorDict.index(forKey: catId)
        if colorIndex != nil {
            return UIColor.init(colorDict[colorIndex!].value, defaultColor: UIColor.init(TQKConstants.GEN_COLOR_CODE))
        } else {
            return UIColor.init(TQKConstants.GEN_COLOR_CODE, defaultColor: UIColor.init(TQKConstants.GEN_COLOR_CODE))
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Properties
    var colorOverride : String?
    var colorDict : Dictionary = ["815b2a99-e94b-4bcd-912c-6c0338bf6efa" : "#32C274",
                                    "c25df7d4-8c06-426c-8cb3-40d30c7ad095" : "#26D8B0",
                                    "01fb6f5a-eaa7-4e70-98e8-d1bd467b3f2c" : "#F24EBC",
                                    "3e58c238-0fb0-4625-9d7a-f3010a5c4290" : "#E32C42",
                                    "c43c7b30-613d-4e5d-8a90-8e975492f3bc" : "#E63462",
                                    "e081c916-8bf5-4632-9ded-c5ce2e6d3253" : "#00CCCC",
                                    "cb356359-a861-41da-9f77-65f0b7dcfb05" : "#F5A623",
                                    "0d9264c0-fb8d-4f25-93fa-fefe36114677" : "#DA5650",
                                    "0c1d2089-4fa7-4755-a0d5-b5ba1a869142" : "#8B34D8",
                                    "b31613fe-e175-4fbd-b329-ba6dc0bf7f55" : "#D2D8F4",
                                    "9ad53f44-fe4b-4c97-93fe-7376385ae02d" : "#4A90E2",
                                    "37aefe58-1b3e-41e9-8202-f5c763fbf8d9" : "#8B34D8",
                                    "af1849ef-360b-44af-84e1-a24b9c27f52d" : "#E32C42",
                                    "2cfa4ff4-8ecc-4d21-81cc-a61facd640f3" : "#F5A623",
                                    "99ea7424-80ae-46fc-8958-b44274c92b4d" : "#DA5650",
                                    "02016318-bcc4-4337-a7e0-2479a94821e4" : "#F24EBC",
                                    "79ef9fe5-8a1f-4786-beb1-f91a8033ae47" : "#32C274",
                                    "0b4b643b-8a44-410b-bccb-8cffcdd374c7" : "#26D8B0",
                                    "0efde751-aca2-4c8a-8a2a-c92af3ff7b88" : "#4A90E2"]
    
    
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    var completed : ((Bool) -> Void)?
    
    @IBOutlet weak var spinnerView: SpinnerView!
    
    @IBOutlet weak var previewView: UIView!
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Setup
    
    var player: IJKFFMoviePlayerController!


    @IBOutlet weak var viewCount: UILabel!
    
    var myGameId:String?
    var host:String?
    var sseHost:String?
    
    var useLongTimer:Bool = false
   
    var selectionChoiceText: String?
    
    var currentQuestion: TQKQuestion!
    var currentResult: TQKResult!
    var currentEndQuestion : TQKResult?
    var videoView: UIView!
    var gameLocked: Bool!
    var userEliminated: Bool = false
    var myAnswerId: String!
    var userSubmittedAnswer: Bool = false
    var rtmpUrl: String!
    var isQuestionActive: Bool = false
    var timerIsOn = false
    var timeRemaining: Int!
    @IBOutlet weak var countdownLabel: UILabel!

    
    var hasJoined = false
    var playbackStarted = false
    var maxdelay = 1
    private var playbackDelay = 0
    private var lastBufferStart = 0
    var reloadVideoTimer:Timer!
    var lastPlayerTimeStamp : TimeInterval = 0.0
    var reconnectTimer : Timer!
    var shouldReconnect : Bool = false
    
    var joinedLate : Bool = false

    
    @IBOutlet weak var exitButton: UIButton!

    
    var eSource: EventSource?
    
    var lastBufferDate : NSDate?
    var currentBufferDate : NSDate?
    var bufferTimer : Timer!
    var bufferTime : Double = 0
    
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!

    @IBOutlet weak var eliminatedLabel: UILabel!
    
    @IBOutlet weak var getReadyView: UIView!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var gameWarnCountdownLabel: UILabel!
    
    var gameWarnTimer : Timer!
    var gameWarnTimerLimit : TimeInterval!
    
    var reward: String?

    var gameWinnersViewController : GameWinnersViewController?
    var fullScreenTriviaViewController : FullScreenTriviaViewController?
    var ssQuestionViewController : SSQuestionViewController?
//    var ssResultsViewController : SSResultViewController?
    
    var didOfferFreeTrial: Bool = false
    
    var shouldUseHeart : Bool = false
    var didUseHeart : Bool = false
    var lastQuestionHeartEligible : Int = 0
    var heartsEnabled : Bool = false
    
    @IBOutlet weak var heartContainerView: UIView!
//    var heartPopup : PopupDialog?
//    var heartAnimationView : LOTAnimationView?
    var gameStatusReceivedCount : Int = 0
    
    @IBOutlet weak var gameHeaderView: UIView!
    @IBOutlet weak var leftHeaderView: UIView!
    @IBOutlet weak var centerHeaderView: UIView!
    @IBOutlet weak var rightHeaderView: UIView!
    
    @IBOutlet weak var eliminationHeaderView: UIView!
    
    var theGame : TQKGame?
    var didPurchaseSubscriptionFromApple : Bool = false
    
    var start : CFTimeInterval?
    var version : String?
    
    var customBackgroundImageView : UIImageView?

    var isAudioSessionUsingAirplayOutputRoute: Bool {
        
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        for outputPort in currentRoute.outputs {
            if convertFromAVAudioSessionPort(outputPort.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.airPlay) {
                return true
            }
        }
        
        return false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupUI()
        // self.setUpAV()
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionSuccess), name: Notification.Name("currentSubSetNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appleSubscriptionSuccess), name: Notification.Name("SubscriptionServiceRestoreSuccessfulNotification"), object: nil)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(checkIFScreenIsCapture), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        if #available(iOS 10.0, *) {
            if(!self.theGame!.videoDisabled){
                NotificationCenter.default.addObserver(self, selector: #selector(callDisconnected), name: NSNotification.Name("DISCONNECTED_CALL"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(callConnected), name: NSNotification.Name("CONNECTED_CALL"), object: nil)
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        let tapGesuter = UITapGestureRecognizer(target: self, action: #selector(self.showExitDialog(_:)))
        self.leftHeaderView.addGestureRecognizer(tapGesuter)
        self.leftHeaderView.isUserInteractionEnabled = true
    }
    
    @objc func callConnected(){
        self.player.playbackVolume = 0.0
    }
    
    @objc func callDisconnected(){
        self.player.playbackVolume = 1.0
    }
    
    @objc func checkIFScreenIsCapture(notification:Notification){
        guard let screen = notification.object as? UIScreen else { return }
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "myUser") != nil {
            let myUser = TQKUser(dictionary: userDefaults.object(forKey: "myUser") as! [String : Any])!
        
            if #available(iOS 11.0, *) {
                if screen.isCaptured == true && myUser.admin == false {
                    //screen is being captured by non admin
                    self.blockScreen()
                }else{
                    self.unblockScreen()
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func checkIfScreenIsCapturedNoNotification(){
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "myUser") != nil {
            let myUser = TQKUser(dictionary: userDefaults.object(forKey: "myUser") as! [String : Any])!
            if #available(iOS 11.0, *) {
                if UIScreen.screens[0].isCaptured == true && myUser.admin == false {
                    //screen is being captured by non admin
                    self.blockScreen()
                }else{
                    self.unblockScreen()
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func unblockScreen(){
        if(self.view.viewWithTag(888) != nil){
            self.view.viewWithTag(888)?.removeFromSuperview()
            self.player.playbackVolume = 1.0
        }
    }
    
    func blockScreen(){
        
        //double check if airplay is the cause
        if(!isAudioSessionUsingAirplayOutputRoute){
        
            let fullScreenView = UIView.init(frame: self.view.frame)
            fullScreenView.backgroundColor = .black
            fullScreenView.tag = 888
            
            let label = UILabel()
            label.text = "Screen Recording Not Allowed"
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            fullScreenView.addSubview(label)
            
            label.widthAnchor.constraint(equalToConstant: 250).isActive = true
            label.heightAnchor.constraint(equalToConstant: 100).isActive = true
            label.centerXAnchor.constraint(equalTo: fullScreenView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: fullScreenView.centerYAnchor).isActive = true
            
            self.view.addSubview(fullScreenView)
            self.view.bringSubviewToFront(fullScreenView)
            
            self.player.playbackVolume = 0.0
            
            let userDefaults = UserDefaults.standard
            if userDefaults.object(forKey: "myUser") != nil {
                let myUser = TQKUser(dictionary: userDefaults.object(forKey: "myUser") as! [String:Any])!
                let object : Properties = ["gameID" : self.theGame!.id!,
                                             "userID" : myUser.id!,
                                             "username" : myUser.username!,
                                             "numberOfScreens" : "\(UIScreen.screens.count)" ]
                NotificationCenter.default.post(name: .screenRecordingDetected, object: object)
            }
        }else{
            let userDefaults = UserDefaults.standard
            if userDefaults.object(forKey: "myUser") != nil {
                let myUser = TQKUser(dictionary: userDefaults.object(forKey: "myUser") as! [String:Any])!
                let object : Properties = ["gameID" : self.theGame!.id!,
                                             "userID" : myUser.id!,
                                             "username" : myUser.username!]
                NotificationCenter.default.post(name: .airplayDetected, object: object)
            }
        }
    }
    
    @objc func applicationWillResignActive(_ notification: NSNotification) {

    }
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {

    }
    
    @objc func applicationDidEnterBackground(_ notification: NSNotification) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func applicationWillEnterForeground(_ notification: NSNotification) {
        // Reconnect
        if(!self.theGame!.videoDisabled){
            spinnerView.animate()
            self.stopStreamAndReset()
        }
    }
    
    @objc func reconnectTimerCheck() {
        
        //        if(player.isPlaying()){
        
        //            if(lastPlayerTimeStamp == 0.0){
        //                lastPlayerTimeStamp = player.currentPlaybackTime
        //            }else{
        //
        if(lastPlayerTimeStamp == player.currentPlaybackTime && shouldReconnect){
            //they haven't moved - reconnect if not buffering
            lastPlayerTimeStamp = 0.0
            self.stopStreamAndReset()
        }else{
            //they have moved
            lastPlayerTimeStamp = player.currentPlaybackTime
        }
    }
    
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.completed!(true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func handleQuestionEnd() {
        
        self.isQuestionActive = false
//        self.linearBar.stopAnimation()
        
        DispatchQueue.main.async(execute: {
            
//            if(self.heartPopup != nil){
//                self.heartPopup?.dismiss()
//            }
            
            if(self.currentEndQuestion != nil && (self.currentEndQuestion?.selection == nil || (self.currentEndQuestion?.selection.isEmpty)! || self.currentEndQuestion?.selection == "") && self.userSubmittedAnswer == true){
                
                let alert = UIAlertController(title: "Answer submission timed out", message: "We did not receive your answer in time due to a network issue. Please use wifi if it is avaliable! You may keep playing even when eliminated", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue Playing", style: .default, handler: { (alertAction) in
                    //add an action if needed
                }))
            
                if let topController = UIApplication.topViewController() {
                    topController.present(alert, animated: true) {}
                }
            }
        })
        
    }
    
    func setProgressBarFill(bar: UIProgressView, totalResponses: Float, responses: Float )
    {
        let percent:Float = Float(responses/totalResponses)
        if percent.isInfinite {
            bar.setProgress(0, animated: true)
        }
        else {
            if(percent <= 0.13){
                bar.setProgress(0.13, animated: true)
            }else{
                bar.setProgress(percent, animated: true)
            }
        }
    }
    
    func stopVideoTimer()
    {
        if reloadVideoTimer != nil {
            reloadVideoTimer!.invalidate()
            reloadVideoTimer = nil
        }
    }

    func handleQuestionResult() {
        
        self.currentEndQuestion = nil
        self.isQuestionActive = false
        
        DispatchQueue.main.async(execute: {
            // update label here
            var totalResponse = 0
            if(self.currentResult.choices != nil){
                for choice in self.currentResult.choices! {
                    totalResponse += choice.responses!
                }
            }
           
            if( self.currentResult.active == false ){
                //if question tells me user is still active
                if(self.currentResult.canRedeemHeart){
                    self.eliminateAndShowHeartOption()
                }else{
                    self.eliminateUser()
                }
            }else{
                //user is still in game, maybe ensure that?
                self.undoElimination()
            }
            
            if(self.currentResult.questionType == TQKQuestionType.TEXT_SURVEY || self.currentResult.questionType == TQKQuestionType.CHOICE_SURVEY){
                //TODO: Default the UI to the correct
                self.launchFullScreenTrivia(.Correct)
                
            }else if ((self.currentResult.selection != nil && !(self.currentResult.selection?.isEmpty)!) && (self.currentResult.answerId == self.currentResult.selection ||  self.currentResult.correctResponse == self.currentResult.selection)) {
                //Check to see if the user responded to the question before checking if the result is correct/incorrect
                //Launch full screen trivia view with correct style
               self.launchFullScreenTrivia(.Correct)
                
                if(self.currentQuestion != nil && !self.currentQuestion.wasMarkedIneligibleForTracking){
                    
                    let object : Properties = ["gameID" : self.myGameId!,
                                                 "questionID" : self.currentResult.questionId!,
                                                 "choiceID" : self.currentResult.selection!,
                                                 "eliminatedFlag": self.userEliminated,
                                                 "questionNumber" : self.currentQuestion.number,
                                                 "questionText" : self.currentQuestion.question!,
                                                 "choiceText": self.selectionChoiceText ?? ""]
                    
                    NotificationCenter.default.post(name: .correctAnswerSubmitted, object: object)

                }else{
                    let object : Properties = ["gameID" : self.myGameId!,
                                                 "questionID" : self.currentResult.questionId!,
                                                 "choiceID" : self.currentResult.selection!,
                                                 "eliminatedFlag": self.userEliminated]
                    NotificationCenter.default.post(name: .correctAnswerSubmitted, object: object)

                }
                
                
            }else {

                //Check here to launch the game sub offer
                
                let userDefaults = UserDefaults.standard
                let myUser = TQKUser(dictionary: userDefaults.object(forKey: "myUser") as! [String:Any])!
                let heartCount = myUser.heartPieceCount

                if(self.currentResult.canUseSubscription && !self.didOfferFreeTrial && heartCount < 4){
                    //show offer for free trial
                    self.launchFullScreenTrivia(.Incorrect)

                    var currentQuestionNum = 0
                    var currentQuestionTotal = 0
                    
                    if(self.currentQuestion == nil){
                        currentQuestionNum = 0
                        currentQuestionTotal = 0
                    }else{
                        currentQuestionNum = self.currentQuestion.number
                        currentQuestionTotal = self.currentQuestion.total
                    }
                    
                    //TODO: notify the notification center that the app should present the subscriptions dialogue
                    let object: Properties = ["gameID": self.theGame!.id!,
                                              "hostUrl": self.theGame!.host!,
                                                 "currentQuestionNumber":currentQuestionNum,
                                                 "currentQuestionTotal":currentQuestionTotal]
                    
                    NotificationCenter.default.post(name: .showGameSubs, object: object)
                    
                    self.didOfferFreeTrial = true
                }else{
                    self.launchFullScreenTrivia(.Incorrect)
                }
                
                if(self.currentResult.selection != nil){
                    if(self.currentQuestion != nil){
                        
                        let object : Properties = ["gameID" : self.myGameId!,
                                                     "questionID" : self.currentResult.questionId!,
                                                     "choiceID" : self.currentResult.selection!,
                                                     "eliminatedFlag": self.userEliminated,
                                                     "questionNumber" : self.currentQuestion.number,
                                                     "questionText" : self.currentQuestion.question!,
                                                     "choiceText": self.selectionChoiceText ?? ""]
                        
                        NotificationCenter.default.post(name: .incorrectAnswerSubmitted, object: object)

                    }else{
                        
                        let object : Properties = ["gameID" : self.myGameId!,
                                                     "questionID" : self.currentResult.questionId!,
                                                     "choiceID" : self.currentResult.selection!,
                                                     "eliminatedFlag": self.userEliminated]
                        
                        NotificationCenter.default.post(name: .incorrectAnswerSubmitted, object: object)

                    }
                }
            }
            
        })
        
    }
    
    @objc func appleSubscriptionSuccess(_ notification: NSNotification) {
        self.didPurchaseSubscriptionFromApple = true
        self.shouldUseHeart = true
    }
    
    @objc func subscriptionSuccess(_ notification: NSNotification) {
        //Handle the subscription being made
        self.didPurchaseSubscriptionFromApple = true
        
        NotificationCenter.default.post(name: .removeGameSubs, object: nil)

        //set the user to use a heart
        self.useHeart()
    }
    
    func showPlusOneFor(view : UIView){
        let frame = self.view.convert(view.frame, from: view.superview)
        let correctLabel = UILabel(frame: CGRect(x: frame.width, y: frame.origin.y, width: 30, height: 30))
        correctLabel.text = "+1"
        correctLabel.textAlignment = .center
        correctLabel.textColor = UIColor.white
       
        correctLabel.backgroundColor = UIColor(TQKConstants.GEN_COLOR_CODE)
        
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
    
    fileprivate func launchFullScreenTrivia(_ type: FullScreenType){
        
        if(type == .Question){
            if(self.currentQuestion.isFreeformText){
                self.showPopularChoiceQuestion()
            }else{ // trivia
                self.showTriviaScreen(withType: type)
            }
        }else{ // we are a result
            
            if(self.theGame?.winCondition == TQKWinCondition.POINTS){
                                
                var lottieName = ""
                if(self.currentResult.isFreeformText){

                    if(type == .Correct){
                       lottieName = "correct_PC"
                   }else{
                       lottieName = "incorrect_PC"
                   }
                }else{
                    //Multiple choice modes
                    if(type == .Correct){
                        lottieName = "correct"
                    }else if(type == .Incorrect){
                        lottieName = "incorrect"
                    }
                  
                }
                let animationView = AnimationView(name: lottieName, bundle: TheQKit.bundle)
                animationView.frame = self.centerHeaderView.bounds
                animationView.backgroundColor = UIColor.clear
                animationView.contentMode = .scaleAspectFit
                animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.centerHeaderView.addSubview(animationView)
                animationView.play(fromProgress: 0.0, toProgress: 1.0){ (finished) in
                }
            }
            
            self.showTriviaScreen(withType: type)
            
        }
    }
    
    fileprivate func showPopularChoiceQuestion(){
        
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let sb = UIStoryboard(name: TQKConstants.STORYBOARD_STRING, bundle: bundle)
        
        self.ssQuestionViewController = sb.instantiateViewController(withIdentifier: "SSQuestionViewController") as? SSQuestionViewController
        self.ssQuestionViewController?.view.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        self.ssQuestionViewController?.view.alpha = 1.0
        self.ssQuestionViewController?.gameDelegate = self
        self.ssQuestionViewController?.question = self.currentQuestion
       
        self.addChild(self.ssQuestionViewController!)
        self.view.insertSubview(self.ssQuestionViewController!.view, aboveSubview: self.previewView)
        self.ssQuestionViewController?.didMove(toParent: self)
    }
    
    fileprivate func showTriviaScreen(withType type:FullScreenType){
        //Ne game mode - check for Question vs result then proceeds
        let podBundle = Bundle(for: TheQKit.self)
        let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let sb = UIStoryboard(name: TQKConstants.STORYBOARD_STRING, bundle: bundle)
        
        self.fullScreenTriviaViewController = sb.instantiateViewController(withIdentifier: "FullScreenTriviaViewController") as? FullScreenTriviaViewController
        self.fullScreenTriviaViewController!.useLongTimer = self.useLongTimer
        self.fullScreenTriviaViewController?.view.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        self.fullScreenTriviaViewController?.view.alpha = 1.0
        self.fullScreenTriviaViewController?.gameDelegate = self
        self.fullScreenTriviaViewController?.type = type
        switch type {
        case .Correct:
            self.fullScreenTriviaViewController?.result = self.currentResult
            self.fullScreenTriviaViewController?.question = self.currentQuestion
        case .Incorrect:
            self.fullScreenTriviaViewController?.result = self.currentResult
            self.fullScreenTriviaViewController?.question = self.currentQuestion
        case .Question:
            self.fullScreenTriviaViewController?.question = self.currentQuestion
        case .NoSelect:
            self.fullScreenTriviaViewController?.result = nil
            self.fullScreenTriviaViewController?.question = nil
        }
        
        self.addChild(self.fullScreenTriviaViewController!)
        self.view.insertSubview(self.fullScreenTriviaViewController!.view, aboveSubview: self.previewView)
        self.fullScreenTriviaViewController?.didMove(toParent: self)
    }
    
    func setUpEventSource() {
        
        //        let gameUrl = Constants.EVENT_FEED_URL //+ "/event-feed/games/" + (myGameId!)
        let baseUrl:String = "https://\(self.sseHost!)/v2/"
        let gameUrl = baseUrl + "event-feed/games/" + (myGameId!)
        guard let newUrl = URL(string: gameUrl) else {
            self.dismiss(animated: true){
                self.completed!(true)
            }
            return
        }
        
        if(eSource != nil){
            eSource?.disconnect()
            eSource = nil
        }
        
        let myTokens =  TQKOAuth(dictionary: UserDefaults.standard.object(forKey: "myTokens") as! [String : Any])!
        let finalBearerToken:String = "Bearer " + myTokens.accessToken!
        eSource = EventSource(url: newUrl, headers: ["Authorization": finalBearerToken])
                
        eSource?.onOpen { [weak self] in
            print("onOpen")
        }
        
        eSource?.onMessage({ (idString, eventString, dataString) in
            //This is onMessage
            print("id: %@", idString!)
            print("event: %@", eventString!)
            print("data: %@", dataString!)
        })
        
        eSource?.addEventListener("GameReset") { [weak self] id, event, data in
            let json = JSON.init(parseJSON: data!)
            print("gamereset")
            print(json)
            
            self?.removeAllChildScreens()
            
            let resetData = TQKResetMsg(JSONString: data!)
            //Reset state of game to a brand new one
            self?.shouldUseHeart = false
            self?.currentResult = nil
            self?.currentQuestion = nil
            self?.currentQuestionNumberLabel.text = " "
            self?.currentQuestionNumberLabel.isHidden = true
            self?.undoElimination()
            self?.heartsEnabled = resetData!.heartEligible
            if(self!.heartsEnabled){
                           
               DispatchQueue.main.async(execute: {
                   let heartImageView = UIImageView(image: UIImage(named: "heartAvaliable", in: TheQKit.bundle, compatibleWith: nil))
                   heartImageView.contentMode = .scaleAspectFit
                   heartImageView.frame = CGRect(x: 0, y: 2, width: 20, height: 20)//self.heartContainerView.bounds
                   self!.heartContainerView.addSubview(heartImageView)
                   UIView.animate(withDuration: 1.0, animations: {
                       self!.heartContainerView.alpha = 1.0
                   })
               })
               
               self!.didUseHeart = false
           }
        }
        
        eSource?.addEventListener("QuestionReset") { [weak self] id, event, data in
            let json = JSON.init(parseJSON: data!)
            print("questionreset")
            print(json)
            
            self?.removeAllChildScreens()
            
            let resetData = TQKResetMsg(JSONString: data!)

            //Reset the current question
//            self?.shouldUseHeart = false
            self?.currentResult = nil
            self?.currentQuestion = nil
            self?.currentQuestionNumberLabel.text = " "
            self?.currentQuestionNumberLabel.isHidden = true
            self?.heartsEnabled = resetData!.heartEligible
            if(resetData!.active){
                self?.undoElimination()
            }
            
            if(self!.didUseHeart && resetData!.canRedeemHeart){
                self?.shouldUseHeart = true
            }
            
            if(resetData!.active == true && self!.heartsEnabled){
                
                DispatchQueue.main.async(execute: {
                    let heartImageView = UIImageView(image: UIImage(named: "heartAvaliable", in: TheQKit.bundle, compatibleWith: nil))
                    heartImageView.contentMode = .scaleAspectFit
                    heartImageView.frame = CGRect(x: 0, y: 2, width: 20, height: 20)//self.heartContainerView.bounds
                    self!.heartContainerView.addSubview(heartImageView)
                    UIView.animate(withDuration: 1.0, animations: {
                        self!.heartContainerView.alpha = 1.0
                    })
                })
                
                self!.didUseHeart = false
            }
            
        }
        
        eSource?.addEventListener("QuestionStart") { [weak self] id, event, data in
                        
            NotificationCenter.default.post(name: .removeGameSubs, object: nil)
            
            self?.start = CACurrentMediaTime()
            
            self?.currentQuestion = TQKQuestion(JSONString: data!)
            
            self?.currentEndQuestion = nil
            self?.userSubmittedAnswer = false
            self?.isQuestionActive = true
            
            
            DispatchQueue.main.async(execute: {
                let num : String = String(describing: self!.currentQuestion.number)
                let total : String = String(describing: self!.currentQuestion.total)
                if(self!.currentQuestion.total != 0){
                    self!.currentQuestionNumberLabel.text = "\(num) / \(total)"
                    self!.currentQuestionNumberLabel.isHidden = false
                    //                self.currentQuestionNumberLabel.sizeToFit()
                    
                }else{
                    self!.currentQuestionNumberLabel.text = "Q \(num)"
                    self!.currentQuestionNumberLabel.isHidden = false
                    //                self.currentQuestionNumberLabel.sizeToFit()
                }
            })
            
            if(self!.currentQuestion.number >= self!.lastQuestionHeartEligible){
                //                self.heartAnimationView?.removeFromSuperview()
                //                UIView.animate(withDuration: 1.0, animations: {
                for views in (self?.heartContainerView.subviews)! {
                    views.removeFromSuperview()
                }
                
                DispatchQueue.main.async(execute: {
                    let heartImageView = UIImageView(image: UIImage(named: "heartUnavaliable", in: TheQKit.bundle, compatibleWith: nil))
                    heartImageView.contentMode = .scaleAspectFit
                    heartImageView.frame = CGRect(x: 0, y: 2, width: 20, height: 20)//self.heartContainerView.bounds
                    self?.heartContainerView.addSubview(heartImageView)
                })
            }
            
            DispatchQueue.main.async(execute: {
                
                self?.launchFullScreenTrivia(.Question)
                
            })
        }
        
        eSource?.addEventListener("QuestionEnd") { [weak self] id, event, data in
            self?.currentEndQuestion =  TQKResult(JSONString: data!)
            self?.handleQuestionEnd()
            
            /*
             QuestionEnd %@ {
             "gameId" : "3499d74d-b825-4b96-8dcd-60805a9bfbf2",
             "selection" : "c29c883d-2c59-11e8-870e-ed96b952a681",
             "id" : 1521563873051,
             "questionId" : "c29c883c-2c59-11e8-870e-ed96b952a681"
             }
             
             QuestionEnd %@ {
             "gameId" : "3499d74d-b825-4b96-8dcd-60805a9bfbf2",
             "selection" : null,
             "id" : 1521563890552,
             "questionId" : "c29c8840-2c59-11e8-870e-ed96b952a681"
             }
             */
        }
        
        eSource?.addEventListener("QuestionResult") { [weak self] id, event, data in
            var json = JSON.init(parseJSON: data!)
            print(json)
            self?.currentResult = TQKResult(JSONString: data!)
            self?.handleQuestionResult()
        }
        
        eSource?.addEventListener("GameEnded") { [weak self] id, event, data in
            var json = JSON.init(parseJSON: data!)
            self?.eSource?.disconnect()
            self?.eSource = nil
            self?.dismiss(animated: true, completion: {
                if(self!.userEliminated){
                    NotificationCenter.default.post(name: .gameEndedAndEliminated, object: json.dictionaryObject)
                }
                self?.completed!(true)
            })
        }
        
        eSource?.addEventListener("ViewCountUpdate") { [weak self] id, event, data in
            var json = JSON.init(parseJSON: data!)
            DispatchQueue.main.async(execute: {
                self?.viewCount.text = json["viewCnt"].stringValue
                
            })
        }
        
//        eSource?.addEventListener("GameWarn") { [weak self] id, event, data in
//            //            var json = JSON.parse((e?.data)!)
//            let seconds : TimeInterval = 20 //TimeInterval(json["duration"].doubleValue).truncatingRemainder(dividingBy: 60)
//            let interval = seconds / 5
//
//            DispatchQueue.main.async(execute: {
//                //vibrate 5 times over 20 seconds
//                self.perform(#selector(self.vibrate), with: nil, afterDelay: interval)
//                self.perform(#selector(self.vibrate), with: nil, afterDelay: interval * 2)
//                self.perform(#selector(self.vibrate), with: nil, afterDelay: interval * 3)
//                self.perform(#selector(self.vibrate), with: nil, afterDelay: interval * 4)
//                self.perform(#selector(self.vibrate), with: nil, afterDelay: interval * 5)
//
//
//                //show "get ready" screen for 1 x interval
//                //                self.getReadyView.isHidden = false
//                self.perform(#selector(self.hideGetReadyView), with: nil, afterDelay: 5.0)
//
//                //show "countdown" screen for 4 x interval
//                let secondsToShow = Int(seconds) - 5
//                self.gameWarnCountdownLabel.text = String(secondsToShow)
//                self.perform(#selector(self.hideCountdownView), with: nil, afterDelay: interval * 5)
//            })
//        }
        eSource?.addEventListener("GameWinners") { [weak self] id, event, data in
            //show winners screen
            let gameWinners = GameWinners(JSONString: data!)
            
            DispatchQueue.main.async(execute: {
                
                //gonna setup the leaderboards to swipe up here
                // I'm using a storyboard.
                let podBundle = Bundle(for: TheQKit.self)
                let bundleURL = podBundle.url(forResource: "TheQKit", withExtension: "bundle")
                let bundle = Bundle(url: bundleURL!)!
                let sb = UIStoryboard(name: TQKConstants.STORYBOARD_STRING, bundle: bundle)                // I have identified the view inside my storyboard.
                self?.gameWinnersViewController = sb.instantiateViewController(withIdentifier: "GameWinnersViewController") as? GameWinnersViewController
                
                // These values can be played around with, depending on how much you want the view to show up when it starts.
                self?.gameWinnersViewController?.view.frame = CGRect(x:0, y:0, width: (self?.view.frame.width)!, height: (self?.view.frame.height)!)
                self?.gameWinnersViewController?.view.alpha = 1.0
                
                self?.gameWinnersViewController?.reward = self?.reward
                self?.gameWinnersViewController?.gameWinners = gameWinners
                
                self?.addChild((self?.gameWinnersViewController!)!)
                
                self?.view.insertSubview((self?.gameWinnersViewController!.view)!, belowSubview: self!.exitButton)
                
                self?.gameWinnersViewController?.didMove(toParent: self!)
                
                self?.gameWinnersViewController?.gameWinnerTableView.reloadData()
                
            })
        }
        
        eSource?.addEventListener("GameWon") { [weak self] id, event, data in
            //listen for gamewon event
            DispatchQueue.main.async(execute: {
                
                var json = JSON.init(parseJSON: data!)

                NotificationCenter.default.post(name: .gameWon, object: json.dictionaryObject)

                let amount = json["amount"]
                let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
                formatter.locale = Locale(identifier: TQKConstants.LOCALE) // Here indian locale with english language is used
                formatter.numberStyle = .currency               // Change to `.currency` if needed
                let asd = formatter.string(from: NSNumber(value: amount.floatValue)) // "10,00,000"
                
                let title =  NSLocalizedString("Winner!", comment: "")

                var message = ""
                if(self!.useLongTimer){
                    message = "You WON \(asd ?? " ") voucher! Congrats and thanks for playing \(TQKConstants.appName)! Your balance usually updates within 5 minutes."
                }else{
                    message = String(format: NSLocalizedString("You WON %@! Congrats and thanks for playing %@! Your balance usually updates within 5 minutes.", comment: ""), asd ?? " ", TQKConstants.appName)
                }

                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                    //add an action if needed
                }))
            
                if let topController = UIApplication.topViewController() {
                    topController.present(alert, animated: true) {}
                }
                
            })
        }
        
        eSource?.addEventListener("GameStatus") { [weak self] id, event, data in
            
            let gameStatus = TQKGameStatus(JSONString: data!)
            
            //Always keep heart status up to date
            self!.heartsEnabled = (gameStatus?.heartEligible)!
            if(gameStatus?.active == true && self!.heartsEnabled){
                
                DispatchQueue.main.async(execute: {
                    let heartImageView = UIImageView(image: UIImage(named: "heartAvaliable", in: TheQKit.bundle, compatibleWith: nil))
                    heartImageView.contentMode = .scaleAspectFit
                    heartImageView.frame = CGRect(x: 0, y: 2, width: 20, height: 20)//self.heartContainerView.bounds
                    self!.heartContainerView.addSubview(heartImageView)
                    UIView.animate(withDuration: 1.0, animations: {
                        self!.heartContainerView.alpha = 1.0
                    })
                })
                
                //see if we have left the game and came back and used the heart - may not be needed anymore with question result event tracking - TODO
                let userDefaults = UserDefaults.standard
                self!.didUseHeart = userDefaults.bool(forKey: "usedHeartFor\(self!.myGameId!)")
            }else{
                //eliminated or hearts disabled - either way this variable keeps it from being used by accident
                self!.didUseHeart = true
            }

            //TODO add - don't make this happen on a reconnect (maybe count how many times per games we recieve this)
            self!.gameStatusReceivedCount += 1
            if(self!.gameStatusReceivedCount > 1){
                //case for reconnect
                if(gameStatus?.question != nil && self!.isQuestionActive == false ){
                    //show question to user maybe?
                    self!.currentQuestion = gameStatus?.question
                    self!.currentEndQuestion = nil
                    if(self!.currentQuestion.questionId == nil){
                        self!.currentQuestion.questionId = gameStatus?.question?.id
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self!.isQuestionActive = true
                        self!.start = CACurrentMediaTime()

                        self!.launchFullScreenTrivia(.Question)
                    })

                }
            }else{
                //case for initial state
                
                if(gameStatus?.active == false){
                    DispatchQueue.main.async(execute: {
                        
                        let userDefaults = UserDefaults.standard
                        let answersSaved = userDefaults.object(forKey: self!.myGameId!) as? String
                        if (answersSaved != "eliminated"){
                            let alert = UIAlertController(title: "Sorry, you've joined late, or were previously eliminated", message: "Either you joined late or missed a question due to network issues. You are not able to win this game, but are able to continue playing", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Continue Playing", style: .default, handler: { (alertAction) in
                                //add an action if needed
                            }))
                        
                            if let topController = UIApplication.topViewController() {
                                topController.present(alert, animated: true) {}
                            }
                        }
                        
                        self!.eliminateUser()
                        
                    })
                    
                }
                
                if(gameStatus?.question != nil && self!.isQuestionActive == false ){
                    //show question to user maybe?
                    self!.currentQuestion = gameStatus?.question
                    self!.currentEndQuestion = nil
                    if(self!.currentQuestion.questionId == nil){
                        self!.currentQuestion.questionId = gameStatus?.question?.id
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self!.isQuestionActive = true
                        self!.start = CACurrentMediaTime()
                        self!.launchFullScreenTrivia(.Question)
                    })

                }
            }
        }
        
        eSource?.connect()

    }
    
//    @objc func countdownGameWarn(){
//        let currentTime = (self.gameWarnCountdownLabel.text! as NSString).integerValue
//
//        self.gameWarnCountdownLabel.text = String(currentTime - 1)
//
//        if(currentTime - 1 <= 0){
//            self.gameWarnTimer.invalidate()
//            self.gameWarnTimer = nil
//        }
//    }
    
//    @objc func hideCountdownView(){
//        self.countdownView.isHidden = true
//    }
    
//    @objc func hideGetReadyView(){
//        self.getReadyView.isHidden = true
//        self.countdownView.isHidden = false
//
//        if(self.gameWarnTimer != nil){
//            self.gameWarnTimer.invalidate()
//            self.gameWarnTimer = nil
//        }
//        self.gameWarnTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdownGameWarn), userInfo: nil, repeats: true)
//
//    }
    
//    @objc func vibrate(){
//        if #available(iOS 10.0, *) {
//            let generator = UINotificationFeedbackGenerator()
//            //            generator.prepare()
//            generator.notificationOccurred(.error)
//
//            let feedback = UIDevice.current.value(forKey: "_feedbackSupportLevel") as! Int
//            if (feedback == 0 || feedback == 1){
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//            }
//
//        }else{
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//        }
//    }
    
    @IBAction func showExitDialog(_ sender: Any) {
        
        // Prepare the popup assets
        let title = "Are You Sure?"
        let message = "The game is in progress are you sure you want to leave?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stay", style: .default, handler: { (alertAction) in
            //add an action if needed
        }))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (alertAction) in
            self.dismiss(animated: true){
                if(self.userEliminated && (self.currentQuestion != nil && (self.currentQuestion.number == self.currentQuestion.total))){
                    NotificationCenter.default.post(name: .gameEndedAndEliminated, object: nil)
                }
                self.completed!(true)
            }
        }))
        
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true) {}
        }
        
    }
    
    
    fileprivate func setupUI() {
        
        if(self.theGame?.winCondition == TQKWinCondition.POINTS){
            //show the points header instead of old header
            self.gameHeaderView.isHidden = false
            self.eliminationHeaderView.isHidden = true

        }else{
            self.eliminationHeaderView.isHidden = false
            self.gameHeaderView.isHidden = true
        }
        
        //If game object has a background, use it
        if(self.theGame?.backgroundImageUrl != nil && !(self.theGame?.backgroundImageUrl!.isEmpty)!){
            self.customBackgroundImageView = UIImageView(frame: self.view.bounds)
            self.customBackgroundImageView!.contentMode = .scaleAspectFit
            self.customBackgroundImageView!.backgroundColor = UIColor.clear
            self.view.addSubview(self.customBackgroundImageView!)
            self.view.insertSubview(self.customBackgroundImageView!, aboveSubview: self.previewView)
            self.customBackgroundImageView!.load(url: URL(string: self.theGame!.backgroundImageUrl!)!)
        }
        
        
        if(self.useLongTimer == true){
            //swap out exist button
            exitButton.setImage(UIImage(named: "qTriviaNetworkLogo"), for: .normal)
            exitButton.layer.cornerRadius = 5.0
            exitButton.clipsToBounds = true
            exitButton.imageView?.contentMode = .scaleAspectFit

        }else{
        
            exitButton.imageView?.contentMode = .scaleAspectFit
        }
        
        currentQuestionNumberLabel.layer.cornerRadius = currentQuestionNumberLabel.frame.size.height / 2
        currentQuestionNumberLabel.clipsToBounds = true
        currentQuestionNumberLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        eliminatedLabel.layer.cornerRadius = eliminatedLabel.frame.size.height / 2
        eliminatedLabel.clipsToBounds = true
        
        eliminatedLabel.text = NSLocalizedString("Eliminated", comment: "")
        
        if(!self.theGame!.videoDisabled){
            spinnerView.animate()
            self.spinnerView.isHidden = false
            initializePlayer(url: self.rtmpUrl)
        }else{
            self.spinnerView.isHidden = true
        }
        
        
        currentQuestionNumberLabel.isHidden = true
        getReadyView.isHidden = true
        countdownView.isHidden = true
    }
    
    func initializePlayer(url: String) {
        
        player = nil
        player = IJKFFMoviePlayerController(contentURLString: url, with: IJKFFOptions.byDefault())
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_SILENT)
        IJKFFMoviePlayerController.setLogReport(false)
        //        IJKFFMonitor
//        if(TQKConstants.SHOULD_SHOW_HUD){
//            player.shouldShowHudView = true
//        }else{
            player.shouldShowHudView = false
//        }
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.scalingMode = .aspectFill;
        player.view.frame = previewView.bounds
        
       
        previewView.addSubview(player.view)

        
        player.prepareToPlay()
        print("Player is preparing to play")
        print("player is going to play again")
        
        self.initObservers()
        
        playStream()
    }
    
    @objc func playStream() {
        print("reloading the video to buffering")
        
        player.play()
        shouldReconnect = true
        self.reconnectTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(reconnectTimerCheck), userInfo: nil, repeats: true)
    }
    
    func initObservers(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player, queue: OperationQueue.main, using: { [weak self] notification in
            
            guard let this = self else {
                return
            }
            
            //I have no idea why this case happens - TODO
            if(this.player == nil){
                return
            }
            
            let state = this.player.loadState
            
            switch state {
            case IJKMPMovieLoadState.playable:
                print("Playable")
                //                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self?.bufferTimer?.invalidate()
                self?.bufferTimer = nil
                self?.player.play()
            case IJKMPMovieLoadState.playthroughOK:
                self?.spinnerView.isHidden = true
                print( "Playing")
                //                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self?.bufferTimer?.invalidate()
                self?.bufferTimer = nil
                self?.player.play()
                
            case IJKMPMovieLoadState.stalled:
                print("Buffering in load state")
                //                self?.playStream()
                self?.spinnerView.isHidden = false
                
                if(self?.bufferTimer != nil){
                    self?.bufferTimer?.invalidate()
                    self?.bufferTimer = nil
                }
                self?.bufferTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self!, selector: #selector(self?.timerAction), userInfo: nil, repeats: true)
                //                self?.bufferTimer?.fire()
                //reset after 2 seconds unless default is hit
                //self?.perform(#selector(self?.stopStreamAndReset), with: nil, afterDelay: 1.5)
                
                
            default:
                self?.spinnerView.isHidden = true
                print("Playing")
                
                //Kill the operation
                //                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self?.bufferTimer?.invalidate()
                self?.bufferTimer = nil
                self?.player.play()
            }
        })
    }
    
    @objc func timerAction(){
        bufferTime += 0.01
        
        print("current buffer accumulation: " + String(bufferTime))
        
        if(bufferTime > 1.5){
            bufferTimer?.invalidate()
            bufferTimer = nil
            bufferTime = 0
            stopStreamAndReset()
        }
        
    }
    
    func stopStreamAndReset() {
        print("stopping the stream")
        
        
        if(self.reconnectTimer != nil){
            self.reconnectTimer.invalidate()
            self.reconnectTimer = nil
        }
        shouldReconnect = false
        
        player.stop()
        
        NotificationCenter.default.removeObserver(player)
        
        print("resetting the stream")
        player.view.removeFromSuperview()
        
        player.shutdown()
        
        if(!self.theGame!.videoDisabled){
            self.initializePlayer(url: self.rtmpUrl)
        }
        
    }
    
    func reloadVideo() {
        playbackStarted = false
        playbackDelay = 0
        lastBufferStart = 0
        
        if reloadVideoTimer == nil {
            reloadVideoTimer = Timer.scheduledTimer(timeInterval: 2,
                                                    target: self,
                                                    selector: #selector(self.playStream),
                                                    userInfo: nil,
                                                    repeats: false)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        eliminatedLabel.isHidden = true
        
        print("viewWillAppear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("player is shutting down")
        print("viewWillDisappear")
        
        if(self.gameWinnersViewController != nil){
            self.gameWinnersViewController?.dismiss(animated: false, completion: nil)
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        NotificationCenter.default.removeObserver(self)
        if(!self.theGame!.videoDisabled){
            NotificationCenter.default.removeObserver(player)
        }
        
        if(self.eSource != nil){
            self.eSource?.disconnect()
            self.eSource = nil
        }
        if(self.reconnectTimer != nil){
            self.reconnectTimer.invalidate()
            self.reconnectTimer = nil
        }
        if(self.bufferTimer != nil){
            self.bufferTimer?.invalidate()
            self.bufferTimer = nil
        }
        if(self.player != nil){
            self.player.stop()
            self.player.shutdown()
            self.player = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        self.checkIfScreenIsCapturedNoNotification()
        
        if (myGameId != nil && !(myGameId?.isEmpty)!) {
            print("loading event source")
            self.setUpEventSource()
            
            let userDefaults = UserDefaults.standard
            let alreadyJoined = userDefaults.bool(forKey: self.myGameId! + "joined")
            if (!alreadyJoined){
                
                userDefaults.setValue(true, forKey: self.myGameId! + "joined") // fill data
                
                let i = userDefaults.integer(forKey: TQKConstants.RUNNING_JOIN_GAME_COUNT)
                let joinedCount = i + 1
                userDefaults.set(joinedCount, forKey: TQKConstants.RUNNING_JOIN_GAME_COUNT)
                userDefaults.synchronize()
                
                let object : Properties = ["gameID" : myGameId!,
                                           "gameTitle": (theGame?.theme.displayName)!,
                                             "scheduled": String(format:"%f", (theGame?.scheduled)!),
                                             "count" : joinedCount]
                
                NotificationCenter.default.post(name: .enteredGame, object: object)
            }
        }else{
            //Game ID is missing - exit the game before bad things happen
            self.dismiss(animated: true){
                self.completed!(true)
            }
        }
        
    }
    
    func submitAnswer(questionId: String, responseId: String, choiceText: String?){
        
        print("submitted answer")
        print(questionId)
        print(responseId)
        self.userSubmittedAnswer = true
        
        if(self.currentQuestion.isFreeformText){
            self.selectionChoiceText = responseId
        }else{
            self.selectionChoiceText = choiceText
        }
        
        var submitUrl:String
        let baseURL: String = "https://\(self.host!)/v2/games/\(self.myGameId!)"
        submitUrl = baseURL + "/questions/" + questionId + "/responses"
        
        //print(submitUrl)
        
        let preferences = UserDefaults.standard
        let key = "token"
        let bearerToken = preferences.string(forKey: key)
        let userId = preferences.string(forKey: "userId")
        let finalBearerToken:String = "Bearer " + (bearerToken as! String)
        let headers: HTTPHeaders = [
            "Authorization": finalBearerToken,
            "Accept": "application/json"
        ]
        
        let params : Parameters = [
            "userId":(userId)!,
            "uid":(userId)!
        ]
        
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        let escapedString = responseId.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        
        if(self.shouldUseHeart){
            submitUrl = baseURL + "/questions/" + questionId + "/responses?response=\(escapedString!)&useHeart=\(self.shouldUseHeart)"
        }else{
            submitUrl = baseURL + "/questions/" + questionId + "/responses?response=\(escapedString!)"
        }
        
        let object : Properties = ["gameID" : self.myGameId!,
                                     "questionID" : questionId,
                                     "choiceID" : responseId,
                                     "questionNumber" : self.currentQuestion.number,
                                     "questionText" : self.currentQuestion.question!,
                                     "choiceText": choiceText!,
                                     "eliminatedFlag": self.userEliminated,
                                     "usedHeart" : self.shouldUseHeart]
        
        NotificationCenter.default.post(name: .choiceSelected, object: object)
        
        Alamofire.request(submitUrl, method: .post, parameters: params, headers: headers).responseJSON
        { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                //let them select again?
                var style = ToastStyle()
                style.backgroundColor = .red
                self.view.makeToast(NSLocalizedString("Network Failure - Try Submitting Again!", comment: ""), duration: 1.0, position: .bottom, style: style)
                
                self.userSubmittedAnswer = false
                self.isQuestionActive = true
                
                if(self.currentQuestion.isMultipleChoice){
                    DispatchQueue.main.async(execute: {

//                        self.fullScreenTriviaViewController?.progressViewA.alpha = 1.0
//                        self.fullScreenTriviaViewController?.progressViewB.alpha = 1.0
//                        self.fullScreenTriviaViewController?.progressViewC.alpha = 1.0
                        self.fullScreenTriviaViewController?.fadeAllCellsIn()
                        
                    })
                }else{
                    DispatchQueue.main.async(execute: {

                        self.ssQuestionViewController?.submitButton.alpha = 1.0
                        self.ssQuestionViewController?.answerTextField.alpha = 1.0
                        self.ssQuestionViewController?.answerTextField.isEnabled = true
                        self.ssQuestionViewController?.answerTextField.text = ""
                        self.ssQuestionViewController?.inputAnswerLabel.alpha = 0.0
                        self.ssQuestionViewController?.yourAnswerLabel.alpha = 0.0
                        
                    })
                }
            }
            
            response.result.ifSuccess{
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    //failure
                    if ( !(json["success"] as! Bool) ) {
                        
                        /*
                         Possible error messages
                         QUESTION_NOT_ACTIVE
                         USER_NOT_PARTICIPANT
                         USER_ELIMINATED
                         USER_ALREADY_ANSWERED
                         INVALID_CHOICE
                         */
                        var errorMessage:String
                        if (String(describing: json["errorCode"]!) == "QUESTION_NOT_ACTIVE") {
                            errorMessage = NSLocalizedString("We did not receive your answer in time. This may be caused by a poor network connection. Please use wifi if it is avaliable!", comment: "")
                            print("An error has occured QUESTION_NOT_ACTIVE")
                            self.currentQuestion.wasMarkedIneligibleForTracking = true
                            
                        }else if (String(describing: json["errorCode"]!) == "USER_ALREADY_ANSWERED") {
                            errorMessage = NSLocalizedString("You have already answered this question. Only one answer per account is allowed.", comment: "")
                            print("You have already answered from this account USER_ALREADY_ANSWERED")
                            self.currentQuestion.wasMarkedIneligibleForTracking = true
                            
                        }else if (String(describing: json["errorCode"]!) == "INVALID_CHOICE") {
                            errorMessage = NSLocalizedString("This choice was invalid.", comment: "")
                            print("This choice was invalid INVALID_CHOICE")
                            self.currentQuestion.wasMarkedIneligibleForTracking = true
                            
                        }else if (String(describing: json["errorCode"]!) == "INVALID_ANSWER_LENGTH") {
                            errorMessage = NSLocalizedString("Please choose a shorter answer.", comment: "")
                            self.currentQuestion.wasMarkedIneligibleForTracking = true
                            if(self.currentQuestion.isMultipleChoice){
                                DispatchQueue.main.async(execute: {
                                    
//                                    self.fullScreenTriviaViewController?.progressViewA.alpha = 1.0
//                                    self.fullScreenTriviaViewController?.progressViewB.alpha = 1.0
//                                    self.fullScreenTriviaViewController?.progressViewC.alpha = 1.0
                                    self.fullScreenTriviaViewController?.fadeAllCellsIn()
                                    
                                })
                            }else{
                                DispatchQueue.main.async(execute: {
                                    
                                    self.ssQuestionViewController?.submitButton.alpha = 1.0
                                    self.ssQuestionViewController?.answerTextField.alpha = 1.0
                                    self.ssQuestionViewController?.answerTextField.isEnabled = true
                                    self.ssQuestionViewController?.answerTextField.text = ""
                                    self.ssQuestionViewController?.inputAnswerLabel.alpha = 0.0
                                    self.ssQuestionViewController?.yourAnswerLabel.alpha = 0.0
                                    
                                })
                            }
                        }else{
                            errorMessage = NSLocalizedString("An error occured recording your answer.", comment: "")
                            print("An error occured recording your answer.")
                            self.currentQuestion.wasMarkedIneligibleForTracking = true
                        }
                                                
                        // Prepare the popup assets
                        let title = NSLocalizedString("Sorry, an error has occured", comment: "")
                        let message = errorMessage + NSLocalizedString(" You may keep playing to increase your score on the Leaderboard!", comment: "")
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (alertAction) in
                            //add an action if needed
                        }))
                                                    
                        if(self.currentEndQuestion == nil && self.isQuestionActive != false){
                            if let topController = UIApplication.topViewController() {
                                topController.present(alert, animated: true) {}
                            }
                        }
                        
                        
                        let object : Properties = ["gameID" : self.myGameId!,
                                                     "questionID" : questionId,
                                                     "choiceID" : responseId,
                                                     "errorCode" : String(describing: json["errorCode"]!),
                                                     "questionNumber" : self.currentQuestion.number,
                                                     "questionText" : self.currentQuestion.question!,
                                                     "choiceText": choiceText!,
                                                     "eliminatedFlag": self.userEliminated]
                        NotificationCenter.default.post(name: .errorSubmittingAnswer, object: object)
                        
                    }else{
                        //Was success
                        self.currentQuestion.wasMarkedIneligibleForTracking = false
                        
                        UIView.animate(withDuration: 1.0, animations: {

                            if(self.currentQuestion.isMultipleChoice){
//                                self.fullScreenTriviaViewController?.progressViewA.alpha = 1.0
//                                self.fullScreenTriviaViewController?.progressViewB.alpha = 1.0
//                                self.fullScreenTriviaViewController?.progressViewC.alpha = 1.0
                                self.fullScreenTriviaViewController?.fadeAllCellsIn()
                            }
//                                self.linearBar.stopAnimation()
                        })
                        
                        //check if we used a heart
                        let usedHeart = (json["usedHeart"] as? Bool) ?? false
                        self.didUseHeart = usedHeart
                        if(!usedHeart && self.shouldUseHeart){
                            //Heart redemption failed - let user know heart wasn't used
                            let title = NSLocalizedString("Heart Redemption Failed", comment: "")
                            let message = NSLocalizedString("Looks like you tried to redeem an extra life but it was either the last question of the game or some network error occured. Your extra life was not used and is avaliable for use in the next game.", comment: "")

                            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (alertAction) in
                                //add an action if needed
                            }))
                        
                            if let topController = UIApplication.topViewController() {
                                topController.present(alert, animated: true) {}
                            }
                            
                        }
                        
                        
                        if(self.shouldUseHeart){
                            //TODO what really needs to happen here?
                            self.shouldUseHeart = false
                            self.didUseHeart = true
                            
                            //track this user defaults
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(true, forKey: "usedHeartFor\(self.myGameId!)") // fill data
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    func useHeart(){
        
        let animationView = AnimationView(name: "heartUse", bundle: TheQKit.bundle)
        animationView.frame = self.view.bounds
        animationView.contentMode = .scaleAspectFill
        self.view.addSubview(animationView)
        animationView.play { (true) in
            animationView.removeFromSuperview()
            UIView.animate(withDuration: 1.0, animations: {
                self.heartContainerView.alpha = 0
            })
        }
        
        self.shouldUseHeart = true
        //        self.didUseHeart = true
        self.eliminatedLabel.isHidden = true
        self.userEliminated = false
        
        //No longer eliminated
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: self.myGameId!)
        
        //track this user defaults
        userDefaults.set(true, forKey: "usedHeartFor\(self.myGameId!)") // fill data
        userDefaults.synchronize()
        
    }
    
    fileprivate func eliminateAndShowHeartOption(){
        
        self.eliminateUser()
        //check if already eliminated, if not then this is the first time and check to see if they can use a heart and present that dialogue
            //show heart use dialogue
        let useHeartViewController = UseHeartViewController(nibName: "UseHeartView", bundle: TheQKit.bundle)
        useHeartViewController.heartDelegate = self
        
        self.addChild(useHeartViewController)
        self.view.addSubview(useHeartViewController.view)
        self.view.bringSubviewToFront(useHeartViewController.view)
        useHeartViewController.didMove(toParent: self)
        
    }
    
    fileprivate func undoElimination(){
        self.userEliminated = false
        self.eliminatedLabel.isHidden = true
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: self.myGameId!)
        userDefaults.synchronize()
    }
    
    fileprivate func eliminateUser(){
        self.userEliminated = true
        self.eliminatedLabel.isHidden = false
        
        //keep track of this incase we exist the game and rejoin
        let userDefaults = UserDefaults.standard
        userDefaults.setValue("eliminated", forKey: self.myGameId!) // fill data
        userDefaults.synchronize()
        
        UIView.animate(withDuration: 1.0, animations: {
            self.heartContainerView.alpha = 0
        })
    }
    
    fileprivate func removeAllChildScreens(){
        if(self.fullScreenTriviaViewController != nil){
            self.fullScreenTriviaViewController?.willMove(toParent: nil)
            self.fullScreenTriviaViewController?.view.removeFromSuperview()
            self.fullScreenTriviaViewController?.removeFromParent()
        }
        if(self.ssQuestionViewController != nil){
            self.ssQuestionViewController?.willMove(toParent: nil)
            self.ssQuestionViewController?.view.removeFromSuperview()
            self.ssQuestionViewController?.removeFromParent()
        }
//        if(self.ssResultsViewController != nil){
//            self.ssResultsViewController?.willMove(toParent: nil)
//            self.ssResultsViewController?.view.removeFromSuperview()
//            self.ssResultsViewController?.removeFromParent()
//        }
    }
    
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as! CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionPort(_ input: AVAudioSession.Port) -> String {
	return input.rawValue
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
