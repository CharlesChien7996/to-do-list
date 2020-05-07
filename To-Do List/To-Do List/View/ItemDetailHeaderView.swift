//
//  ItemDetailHeaderView.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/2.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit

class ItemDetailHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var checkedImageView: UIImageView! {
        
        didSet {
            
            checkedImageView.image = UIImage(named: "check")
        }
    }

}
