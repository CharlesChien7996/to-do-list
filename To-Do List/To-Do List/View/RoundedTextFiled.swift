//
//  RoundedTextFiled.swift
//  My Pocket list
//
//  Created by 簡士荃 on 2018/9/19.
//  Copyright © 2018年 Charles. All rights reserved.
//

import UIKit

class RoundedTextFiled: UITextField {
    
    
    // 設定縮排範圍
    let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    // 設定文字縮排
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: insets)
    }

    
    // 設定佔位文字縮排
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: insets)
    }
    
    
    // 設定編輯文字縮排
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: insets)
    }
    
    
    // 設定 TextField 圓角
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
