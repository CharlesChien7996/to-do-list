//
//  DetailDateCell.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/2.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit

class DetailDateCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
