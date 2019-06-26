//
//  SSResultsTableViewCell.swift
//  theq
//
//  Created by Jonathan Spohn on 11/19/18.
//  Copyright © 2018 Stream Live. All rights reserved.
//

import UIKit

class SSResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rankLabel.layer.cornerRadius = self.rankLabel.frame.width / 2
        self.rankLabel.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
