//
//  UseHeartViewController.swift
//  theq
//
//  Created by Jonathan Spohn on 4/11/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit

class UseHeartViewController: UIViewController {

    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    var heartDelegate : HeartDelegate?
    
    @IBOutlet weak var dontUseButton: UIButton!
    @IBOutlet weak var useButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dontUseButton.layer.cornerRadius = dontUseButton.frame.height / 2
        useButton.layer.cornerRadius = useButton.frame.height / 2
        self.view.layer.cornerRadius = 5.0
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func useItPressed(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        self.heartDelegate?.useHeart()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func dontPressed(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        self.dismiss(animated: false, completion: nil)
    }
    
}
