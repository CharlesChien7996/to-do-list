//
//  MainTableViewCell.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/1.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView! {
        
        didSet {
            
            checkImageView.image = UIImage(named: "check")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
