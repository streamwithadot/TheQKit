//
//  TQKCardsViewController.swift
//  TheQKit-TheQKit
//
//  Created by Jonathan Spohn on 6/25/19.
//

import UIKit
import Kingfisher

protocol CardCollectionViewCellDelegate {
    func shareToFacebook(image : UIImage)
}

class TQKCardsViewController : UIViewController, CardCollectionViewCellDelegate {
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    var gameInfoGames : TQKGames? {
        didSet {
            print("didset gameinfogames")
            if(didFail){
                var noGameFound = TQKGame()
                noGameFound.title = "Failed"
//                noGameFound.theme.networkBadgeUrl =  TQKConstants.themeNetworkBadgeUrl
                gameInfoGames?.games?.append(noGameFound)
            }else if(gameInfoGames?.games?.count == 0){
                //create no games scheduled card
                var noGameFound = TQKGame()
                noGameFound.title = "No Game Scheduled"
//                noGameFound.theme.networkBadgeUrl =  TQKConstants.themeNetworkBadgeUrl
                gameInfoGames?.games?.append(noGameFound)
            }
            
            cardsCollectionView.reloadData()
        }
    }
    
    
    var didFail : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        self.cardsCollectionView.delegate = self
        self.cardsCollectionView.dataSource = self
        //        let collectionViewLayout = self.cardsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        //        collectionViewLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shareToFacebook(image : UIImage) {
//        let photo = Photo(image: image, userGenerated: false)
//        var content = PhotoShareContent(photos: [photo])
//
//        guard let show = try? ShareDialog.show(from: self, content: content) else {
//            return
//        }
        
    }
    
}


extension TQKCardsViewController : UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = self.cardsCollectionView.indexPathForItem(at: center) {
//            self.lobbyDelegate?.setPC(withIndex: ip.row)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.cardsCollectionView {
            var currentCellOffset = self.cardsCollectionView.contentOffset
            currentCellOffset.x += self.cardsCollectionView.frame.width / 2
            if let indexPath = self.cardsCollectionView.indexPathForItem(at: currentCellOffset) {
                self.cardsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if( self.gameInfoGames != nil && self.gameInfoGames?.games != nil  && !(self.gameInfoGames?.games?.isEmpty)! ){
            guard let game = self.gameInfoGames?.games![indexPath.item] else {
                return
            }
            
            if((game.active)){
//                self.lobbyDelegate?.joinGame(game,manualJoin: true)
            }else{
                if(game.subscriberOnly){
//                    self.lobbyDelegate?.checkToShowFreeTrial(game)
                }
            }
        }
    }
    
}

extension TQKCardsViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let listOfGames = gameInfoGames?.games {
            return listOfGames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let game = gameInfoGames?.games![indexPath.item]
        
//        if(game?.nativeAd != nil){
//
//            let cell = cardsCollectionView.dequeueReusableCell(withReuseIdentifier: "AdCardCell", for: indexPath) as! AdCardCell
//
//
//            cell.backgroundImageView.image = game?.nativeAd?.images![0].image
//
//            cell.nativeAdView.nativeAd = game?.nativeAd
//            cell.nativeAdView.callToActionView?.isUserInteractionEnabled = false
//
//            game?.nativeAd!.delegate = cell
//
//
//            cell.adLabel.isHidden = false
//
//            cell.adLabel.layer.cornerRadius = 5.0
//            cell.adLabel.clipsToBounds = true
//
//            //            cell.backgroundImageView.backgroundColor = UIColor.init((game?.theme.defaultColorCode)!)
//            cell.backgroundImageView.layer.masksToBounds = true
//            cell.backgroundImageView.layer.cornerRadius = 10.0
//            cell.backgroundImageView.contentMode = .scaleAspectFill
//
//            return cell
//
//        }else if(game?.adCode != nil && !((game?.adCode?.isEmpty)!)){
//
//            let cell = cardsCollectionView.dequeueReusableCell(withReuseIdentifier: "AdCardCell", for: indexPath) as! AdCardCell
//
//            ///6499/example/native   /\(Constants.AD_NETWORK_ID)/\(self.game!.adCode!)
//            cell.adLoader = GADAdLoader(adUnitID: "\(game!.adCode!)", rootViewController: self,
//                                        adTypes: [ .unifiedNative ], options: nil)
//            cell.adLoader.delegate = cell
//
//            let request = DFPRequest()
//            //            request.testDevices = [ kGADSimulatorID ]
//            cell.adLoader.load(request)
//
//            cell.adLabel.layer.cornerRadius = 5.0
//            cell.adLabel.clipsToBounds = true
//
//            //            cell.backgroundImageView.backgroundColor = UIColor.init((game?.theme.defaultColorCode)!)
//            cell.backgroundImageView.layer.masksToBounds = true
//            cell.backgroundImageView.layer.cornerRadius = 10.0
//            cell.backgroundImageView.contentMode = .scaleAspectFill
//
//            return cell
//        }else{
            let cell = cardsCollectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
            //
            //TODO - make this much less ugly
            
            //            cell.andLabel.isHidden = false
            //            cell.timeLabel.isHidden = false
            //            cell.dayLabel.isHidden = false
            //            cell.prizeLabel.isHidden = false
            //            cell.optionalPrizeLabel.isHidden = false
            //            cell.logoImageView.isHidden = false
            //            cell.premiumGameLabel.isHidden = false
            //            cell.gameTypeLabel.isHidden = false
            //            cell.triviaLabel.isHidden = false
            //            cell.shareGameButton.isHidden = false
            //
            //
            if let logoUrl = URL(string: (game!.theme.networkBadgeUrl ?? "" )) {
                cell.logoImageView.contentMode = .scaleAspectFit
                #if NEWSCORPUK
                cell.logoImageView.layer.shadowColor = UIColor.black.cgColor
                cell.logoImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
                cell.logoImageView.layer.shadowRadius = 5
                cell.logoImageView.layer.shadowOpacity = 0.5
                #endif
                cell.logoImageView.kf.setImage(with: logoUrl,
                                               placeholder: nil,
                                               options: [.transition(ImageTransition.fade(1))],
                                               progressBlock: { receivedSize, totalSize in
                                                //                                print("\(index + 1): \(receivedSize)/\(totalSize)")
                },
                                               completionHandler: { image, error, cacheType, imageURL in
                                                //                                print("\(index + 1): Finished")
                                                
                })
            }else{
                cell.logoImageView.isHidden = true
            }
            
            if((game?.subscriberOnly)!){
                cell.premiumGameLabel.isHidden = false
            }else{
                cell.premiumGameLabel.isHidden = true
            }
            
            cell.gameTypeLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
            cell.triviaLabel.textColor = UIColor.init((game?.theme.textColorCode)!)
            
            if(game?.gameType == "POPULAR"){
                cell.triviaLabel.text = NSLocalizedString("POPULAR CHOICE", comment: "")
            }else{
                #if BLINQ
                cell.triviaLabel.text = "QUIZ"
                #else
                cell.triviaLabel.text = NSLocalizedString("TRIVIA", comment: "")
                #endif
            }
            
            cell.backgroundImageView.backgroundColor = UIColor.init((game?.theme.defaultColorCode)!)
            cell.backgroundImageView.layer.masksToBounds = true
            cell.backgroundImageView.layer.cornerRadius = 10.0
            cell.backgroundImageView.contentMode = .scaleAspectFill
            
            if(game?.title == "Failed"){
                
                cell.backgroundImageView.image = UIImage(named: "TQKConstants.backgroundURL")
                
                cell.dayLabel.text = NSLocalizedString("Connection failed", comment: "")
                cell.timeLabel.text = NSLocalizedString("Please check your internet", comment: "")
                cell.prizeLabel.text = "    "
                
                cell.optionalPrizeLabel.isHidden = true
                cell.andLabel.isHidden = true
                cell.shareGameButton.isHidden = true
                
                cell.timeLabel.textColor = UIColor.init((game?.theme.textColorCode)!)
                cell.dayLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                cell.prizeLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                
            }else if(game?.title == "No Game Scheduled"){
                
                cell.backgroundImageView.image = UIImage(named: "TQKConstants.backgroundURL")
                
                
                cell.dayLabel.text = NSLocalizedString("UPCOMING GAMES", comment: "")
                cell.timeLabel.text = NSLocalizedString("TO BE ANNOUNCED", comment: "")
                cell.prizeLabel.text = "    "
                
                cell.optionalPrizeLabel.isHidden = true
                cell.andLabel.isHidden = true
                cell.shareGameButton.isHidden = true
                
                cell.timeLabel.textColor = UIColor.init((game?.theme.textColorCode)!)
                cell.dayLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                cell.prizeLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                
            }else{
                var isAdmin = false
                if let myUser = TheQKit.getUser() {
                    isAdmin = myUser.admin
                }
                
                if(game?.eligible == false && isAdmin == false){
                    cell.timeLabel.textColor = UIColor.init((game?.theme.textColorCode)!)
                    cell.timeLabel.text = game?.notEligibleMessage ?? "Not Eligible to Play"
                    cell.andLabel.isHidden = true
                }else{
                    if(game!.active){
                        cell.timeLabel.text = NSLocalizedString(" TAP TO JOIN ", comment: "")
                        cell.dayLabel.text = NSLocalizedString(" Game is Live! ", comment: "")
                    }else{
                        cell.timeLabel.text = " " + self.epochToLocal(epochTime: (game!.scheduled)) + " "
                        cell.dayLabel.text = " " + self.epochToDay(epochTime: (game!.scheduled)) + " "
                    }
                    
                    
                    cell.dayLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                    cell.timeLabel.textColor = UIColor.init((game?.theme.textColorCode)!)
                    cell.prizeLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                    
                    if(game?.customRewardText != nil){
                        cell.optionalPrizeLabel.text = game?.customRewardText
                        cell.optionalPrizeLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                        cell.optionalPrizeLabel.isHidden = false
                        cell.andLabel.textColor = UIColor.init((game?.theme.altTextColorCode)!)
                        cell.andLabel.isHidden = false
                    }else{
                        cell.optionalPrizeLabel.isHidden = true
                        cell.andLabel.isHidden = true
                    }
                    
                    cell.cardCollectionDelegate = self
                    cell.shareGameButton.isHidden = false
                    cell.shareGameButton.setTitleColor(UIColor.init((game?.theme.textColorCode)!), for: .normal)
                    cell.shareGameButton.layer.borderWidth = 2
                    cell.shareGameButton.layer.borderColor = UIColor.init((game?.theme.textColorCode)!, defaultColor: UIColor.clear).withAlphaComponent(1.0).cgColor
                    
                    
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: TQKConstants.LOCALE)
                    formatter.numberStyle = .decimal
                    let asd = formatter.string(from: NSNumber(value: game!.reward))
                    cell.prizeLabel.text = "\(TQKConstants.MONEY_SYMBOL)\(asd!) Prize"
                }
                
                if let backgroundUrl = URL(string: game?.theme.backgroundImageUrl ?? "") {
                    if(game?.adCode == nil){
                        cell.backgroundImageView.kf.setImage(with: backgroundUrl,
                                                             placeholder: nil,
                                                             options: [.transition(ImageTransition.fade(1))],
                                                             progressBlock: { receivedSize, totalSize in
                                                                //                                print("\(index + 1): \(receivedSize)/\(totalSize)")
                        },
                                                             completionHandler: { image, error, cacheType, imageURL in
                                                                //                                print("\(index + 1): Finished")
                                                                
                        })
                    }
                }
            }
            return cell
//        }
    }
    
    
    fileprivate func epochToLocal(epochTime:Double)->String{
        let epochTime1: TimeInterval = epochTime/1000
        let date = NSDate(timeIntervalSince1970: epochTime1)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let timeZone = TimeZone.autoupdatingCurrent.identifier as String
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        dateFormatter.dateFormat = "h:mm a" //Specify your format that you want
        let localDate = dateFormatter.string(from: date as Date)
        
        #if !NEWSCORPUK && !BLINQ && !BRAZIL
        return ("\(localDate) " + dateFormatter.timeZone.abbreviation()!)
        #else
        return localDate
        #endif
    }
    
    fileprivate func epochToDay(epochTime:Double)->String{
        let epochTime1: TimeInterval = epochTime/1000
        let date = NSDate(timeIntervalSince1970: epochTime1)
        
        if(NSCalendar.current.isDateInToday(date as Date) ){
            return NSLocalizedString("Today", comment: "")
        }else if(NSCalendar.current.isDateInTomorrow(date as Date)) {
            return NSLocalizedString("Tomorrow", comment: "")
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            let timeZone = TimeZone.autoupdatingCurrent.identifier as String
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
            dateFormatter.locale = NSLocale.current
            #if NEWSCORPUK || BLINQ || BRAZIL
            dateFormatter.dateFormat = "EEEE dd/MM" //Specify your format that you want
            #else
            dateFormatter.dateFormat = "EEEE M/dd" //Specify your format that you want
            #endif
            let localDate = dateFormatter.string(from: date as Date)
            
            return localDate
        }
    }
}

extension TQKCardsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 50
        let height = self.view.frame.height
        return CGSize(width: width, height: height)
    }
}



class CardCollectionViewCell : UICollectionViewCell, UIActivityItemSource {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var optionalPrizeLabel: UILabel!
    @IBOutlet weak var andLabel: UILabel!
    
    @IBOutlet weak var adLabel: UILabel!
    
    
    @IBOutlet weak var premiumGameLabel: UILabel!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var triviaLabel: UILabel!
    
    @IBOutlet weak var shareGameButton: UIButton!
    
    var cardCollectionDelegate:CardCollectionViewCellDelegate?
    
    var game : TQKGame?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shareGameButton.layer.masksToBounds = true
        self.shareGameButton.layer.cornerRadius = self.shareGameButton.frame.height / 2
    }
    
    @IBAction func shareGameButtonPressed(_ sender: Any) {
        
        let myUser = TheQKit.getUser()!
        
        //        let image = self.textToImage(drawText: "\(dayLabel!), \(timeLabel!)" as NSString, inImage: backgroundImageView.image!, atPoint: CGPoint(x: 700, y: 520))
        //        let image2 = self.textToImage(drawText: "\(prizeLabel!)" as NSString, inImage: image, atPoint: CGPoint(x: 700, y: 520))
        
        //        let activityImage: [AnyObject] = [image as AnyObject]
        self.shareGameButton.isHidden = true
        let image = self.asImage()
        self.shareGameButton.isHidden = false
        
        #if NEWSCORPUK
        let activityViewController = UIActivityViewController(activityItems: [self, image,"I love Q LIVE and I know you will too! It's a live game where you answer trivia to win money. Use my code \"\(myUser.referralCode ?? " ")\" to sign up and earn a free life! https://Q-live.co.uk"], applicationActivities: nil)
        #elseif BLINQ
        let activityViewController = UIActivityViewController(activityItems: [self,image,"Join me on Blinq - the quickfire quiz where the more you revise the bigger the prize! Use my code \"\(myUser.referralCode ?? " ")\" to sign up and earn a free life! https://playblinq.com"], applicationActivities: nil)
        #elseif BRAZIL
        let activityViewController = UIActivityViewController(activityItems: [self,image,"Vem junto comigo no The Q - o game show ao vivo onde você ganha prêmios com dinheiro de verdade! Use meu código  \"\(myUser.referralCode ?? " ")\"  para se inscrever e ganhe uma Vida Extra! http://get.theq.live/"], applicationActivities: nil)
        #else
        let activityViewController = UIActivityViewController(activityItems: [self,image,"Join me on The Q: \(dayLabel.text!), \(timeLabel.text!) for a chance to win a \(prizeLabel.text!)! Use my code \"\(myUser.referralCode ?? " ")\" to sign up and earn a free life! http://get.theq.live/"], applicationActivities: nil)
        #endif
        activityViewController.excludedActivityTypes = [.saveToCameraRoll,.assignToContact,.print]
        
        if let topController = UIApplication.topViewController() {
            topController.present(activityViewController, animated: true, completion: {})
            if let popOver = activityViewController.popoverPresentationController {
                popOver.sourceView = self.shareGameButton
            }
        }
    }
    
    @objc func postToFacebook(){
        
        self.shareGameButton.isHidden = true
        let image = self.asImage()
        self.shareGameButton.isHidden = false
        
        cardCollectionDelegate?.shareToFacebook(image: image)
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == UIActivity.ActivityType.postToFacebook {
            activityViewController.dismiss(animated: false, completion: nil)
            self.perform(#selector(postToFacebook), with: self)
        }
        return nil
    }
    
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
