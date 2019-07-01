//
//  CardsTestViewController.swift
//  TheQKit_Example
//
//  Created by Jonathan Spohn on 7/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import TheQKit

class CardsTestViewController: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    
    var containerViewController: UIViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "cardsSegue" {
            let connectContainerViewController = segue.destination as UIViewController
            containerViewController = connectContainerViewController
            TheQKit.showCardsController(fromViewController: containerViewController!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
