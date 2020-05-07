//
//  ItemDetailTableViewController.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/1.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit

class ItemDetailTableViewController: UITableViewController {
    
    // headerView
    @IBOutlet weak var headerView: ItemDetailHeaderView!

    var toDoItem: ToDoItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 判斷是否有圖片，若有則將 headerView 的 itemImageView.image 改為image
        if let image = toDoItem.image {
            
            headerView.itemImageView.image = image
        }
        
        // headerView 上的標題與勾勾圖片
        headerView.titleLabel.text = toDoItem.title
        headerView.checkedImageView.isHidden = toDoItem.isChecked ? false : true
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        // 日期
        case 0:
            
            let dateCell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DetailDateCell
            dateCell.dateLabel.text = toDoItem.date
            dateCell.iconImageView.image = UIImage(named: "calendar")
            return dateCell
            
        // 描述
        case 1:
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DetailDescriptionCell
            descriptionCell.descriptionLabel.text = toDoItem.description
            
            return descriptionCell
            
        default:
            
            fatalError("Fail to instantiate the table view cell for detail view controller")
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditItem" {
            
            // 傳遞 toDoItem 的值給 AddItemTableViewController 並將 isEditingMode 改為 true
            let addItemTableViewController = segue.destination as! AddItemTableViewController
            addItemTableViewController.isEditingMode = true
            addItemTableViewController.toDoItem = toDoItem
            
            // 將 navigationItem.title 改為編輯
            addItemTableViewController.navigationItem.title = "Editing"
        }
    }
    
}

