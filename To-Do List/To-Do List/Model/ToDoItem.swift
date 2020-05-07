//
//  ToDoItem.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/1.
//  Copyright © 2018 Charles. All rights reserved.
//

import Foundation
import UIKit

class ToDoItem {
    
    var itemId: String
    var title: String
    var description: String
    var date: String
    var isChecked: Bool
    var imageUrl: String
    var image: UIImage?
    
    
    init(itemId:String, title: String, description: String, date: String, isChecked: Bool, imageUrl: String) {
        
        self.itemId = itemId
        self.title = title
        self.description = description
        self.date = date
        self.isChecked = isChecked
        self.imageUrl = imageUrl
    }
    
    
    convenience init() {
        
        self.init(itemId: "", title: "", description: "", date: "", isChecked: false, imageUrl: "")
    }
    
    
    func prepareData() -> Any {
        
        return ["itemId": itemId,
                "title": title,
                "description": description,
                "date": date,
                "isChecked": isChecked,
                "imageUrl": imageUrl]
    }
    
}
