//
//  WinnerStatsTableViewCell.swift
//  theq
//
//  Created by Jonathan Spohn on 2/19/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit

class WinnerStatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var winnerCountLabel: UILabel!
    @IBOutlet weak var prizeAmountLabel: UILabel!
    @IBOutlet weak var prizeLabelHeight: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
