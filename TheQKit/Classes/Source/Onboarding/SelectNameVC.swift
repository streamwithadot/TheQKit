//
//  IPhone8VC.swift
//  theq
//
//  Created by Will Jamieson.
//  Copyright © 2017 Stream Live. All rights reserved.
//

// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
// MARK: - Import

import UIKit
import SwiftyJSON
import ObjectMapper
import PopupDialog
import Alamofire

// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
// MARK: - Class
class SelectNameVC: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var userNameTextField: UITextField!
    var loginResponse: TQKLoginResponse!
    var id : String?
    var tokenString : String?
    var loginWithAK : Bool = false
    var partnerCode : String?
    
    @IBOutlet weak var referralTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.setupUI()
        self.setupGestureRecognizers()
        self.setupText()
        NotificationCenter.default.addObserver(self, selector: #selector(SelectNameVC.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectNameVC.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesuter = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesuter)
        
    }
    
    @objc func dismissKeyboard(){
        self.userNameTextField.resignFirstResponder()
        self.referralTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 150 //keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += 150 //= 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for view in self.view.subviews{
            view.alpha = 1.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        confirmButton.layer.cornerRadius = confirmButton.frame.size.height / 2
        confirmButton.layer.shadowColor = UIColor.black.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        confirmButton.layer.shadowRadius = 5
        confirmButton.layer.shadowOpacity = 0.5
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for view in self.view.subviews{
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.0
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("return pressed")
        textField.resignFirstResponder()
        textField.endEditing(true)

        return true
    }

    fileprivate func setupUI() {
        confirmButton.layer.cornerRadius=7.0
         self.userNameTextField.delegate = self
        self.referralTextField.delegate = self
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    fileprivate func setupGestureRecognizers() {

    }

    fileprivate func setupText() {

    }
    
    func saveTokens() {
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    @IBAction func confrimName(_ sender: UIButton) {
        
    //    var authData: ["Facebook"; : ["id" : String] ["accesToken" : String]]
        
        let usernamefield = userNameTextField.text as! String
        let username = usernamefield.trimmingCharacters(in: .whitespacesAndNewlines)
        // let email = fetchProfileEmail()
        
        var params: Parameters
        if(loginWithAK == true){
            let userId:String = self.id!
            let tokenString:String = self.tokenString!
            let akAuth = TQKAccountKitAuth(id: userId, accessToken: tokenString)
            let newUser = TQKAKPlayer(username: username,
                                   email: "",
                                   accountKit: akAuth,
                                   optInBool: false,
                                   apnToken: UserDefaults.standard.string(forKey: "apnToken") ?? "",
                                   firebaseToken: UserDefaults.standard.string(forKey: "firebaseToken") ?? "",
                                   deviceId: UIDevice.current.identifierForVendor!.uuidString,
                                   type: "IOS")
            params = newUser.dictionaryRepresentationAK

        }else{
            let userId:String = self.id!
            let tokenString:String = self.tokenString!
            let fbAuth = TQKFacebookAuth(id: userId, accessToken: tokenString)
            let auth = TQKAuthData(facebook: fbAuth)
            let newUser = TQKPlayer(username: username,
                                 email: "",
                                 authData: auth,
                                 optInBool: false,
                                 apnToken: UserDefaults.standard.string(forKey: "apnToken") ?? "",
                                 firebaseToken: UserDefaults.standard.string(forKey: "firebaseToken") ?? "",
                                 deviceId: UIDevice.current.identifierForVendor!.uuidString,
                                 type: "IOS")
            params = newUser.dictionaryRepresentation
        }
        
        
    
        print(params)
        
        var finalUrl:String = TQKConstants.baseUrl + "users?partnerCode=\(partnerCode!)"
        print("the url to create user " + finalUrl)
        
        if(!(self.referralTextField.text?.isEmpty)!){
            let trimmedString = self.referralTextField.text?.lowercased().removingWhitespaces()
            finalUrl = finalUrl + "?referralCode=\(trimmedString ?? "")?partnerCode=\(partnerCode!)"
        }
        
        Alamofire.request(finalUrl, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            response.result.ifFailure {
                let title = "Error"
                let message = "Error has occured, please try again"
                let popup = PopupDialog(title: title, message: message)
                let buttonTwo = DefaultButton(title: "Okay", dismissOnTap: true) {
                    
                }
                popup.buttonAlignment = .horizontal
                popup.addButtons([buttonTwo])
                
                // Present dialog
                self.present(popup, animated: true, completion: nil)
            }
            
            if let json = response.result.value as? [String: Any] {
                
                if ( !(json["success"] as! Bool) ) {
                    let title = "Error"
                    let message : String! = String(describing: json["errorMessage"] ?? "Error" )
                    let popup = PopupDialog(title: title, message:message)
                    let buttonTwo = DefaultButton(title: "Okay", dismissOnTap: true) {
                        
                    }
                    popup.buttonAlignment = .horizontal
                    popup.addButtons([buttonTwo])
                    
                    // Present dialog
                    self.present(popup, animated: true, completion: nil)
                
                }else{
                    
                    print("JSON: \(json)") // serialized json response
                    
                    //                    var requesRes: String = String(describing: response.response)
                    
                    self.loginResponse =  TQKLoginResponse(JSON: json)
                    
                    
                    //saves tokens to device
                    let preferences = UserDefaults.standard
                    
                    let key = "token"
                    let token:String = (self.loginResponse.oauth?.accessToken)!
                    
                    preferences.set(token, forKey: key)
                    //
                    let refreshKey = "refreshToken"
                    let refreshToken:String = (self.loginResponse.oauth?.refreshToken)!
                    preferences.set(refreshToken, forKey: refreshKey)
                    let userId: String = (self.loginResponse.user?.id)!
                    preferences.set(userId, forKey: "userId")
                    
                    preferences.set(self.loginResponse.user?.propertyListRepresentation, forKey: "myUser")
                    preferences.set(self.loginResponse.oauth?.propertyListRepresentation, forKey: "myTokens")
                    
                    //  Save to disk
                    let didSave = preferences.synchronize()
                    
                    if !didSave {
                        //  Couldn't save (I've never seen this happen in real world testing)
                    }
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)") // original server data as UTF8 string
                    }
                    
                    
                    print("showing new UI")
                    self.dismiss(animated: true, completion: {
                        //stuff here
                    })
                }
            }
        }
    }
}


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}






