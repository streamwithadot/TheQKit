//
//  WinnerTableViewCell.swift
//  theq
//
//  Created by Jonathan Spohn on 2/19/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit

class WinnerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var winnerImageView: UIImageView!
    @IBOutlet weak var winnerUsernameLabel: UILabel!
    @IBOutlet weak var winningsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        winnerImageView.layer.cornerRadius = winnerImageView.frame.height/2
        winnerImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
