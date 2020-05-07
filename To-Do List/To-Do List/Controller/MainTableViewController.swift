//
//  MainTableViewController.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/1.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainTableViewController: UITableViewController {
    
    // Firebase database 的 reference
    let itemReference = FirebaseManager.shared.databaseReference.child("Item")
    
    // 圖片 Cache
    var imageCache = FirebaseManager.shared.imageCache
    
    // 準備空陣列以儲存下載的資料
    var toDoItems: [ToDoItem] = []
    
    // 預設排序方式為由新到舊
    var isDecending: Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 修改 navigationItem 樣式
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.black
        
        // 下載資料
        queryItemData()
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell

        let toDoItem = toDoItems[indexPath.row]
        
        itemCell.itemTitleLabel.text = toDoItem.title
        itemCell.itemDateLabel.text = toDoItem.date
        itemCell.checkImageView.isHidden = toDoItem.isChecked ? false : true
        
        // 判斷圖片是否有 Cache
        if let image = self.imageCache.object(forKey: toDoItem.imageUrl as NSString) as? UIImage {
            
            // 若有 Cache 則無需下載圖片
            itemCell.itemImageView.image = image
            toDoItem.image = image
        }else {
            
            // 沒有 Cache，下載圖片
            FirebaseManager.shared.getImage(urlString: toDoItem.imageUrl) { (image) in
                
                guard let image = image else {
                    
                    print("Fail to get image")
                    return
                }
                
                // 將下載的圖片寫入 Cache
                self.imageCache.setObject(image, forKey: toDoItem.imageUrl as NSString)
                
                DispatchQueue.main.async {
                    
                    itemCell.itemImageView.image = image
                    toDoItem.image = image
                }
            }
        }
        
        return itemCell
    }
    
    
    // 向右滑動
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let check = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            
            let toDoItem = self.toDoItems[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        
            // 滑動後變更 isChecked 的值
            toDoItem.isChecked = toDoItem.isChecked ? false : true
            
            // 判斷 isChecked 的值，決定是否顯示勾勾
            cell.checkImageView.isHidden = toDoItem.isChecked ? false : true
            
            // 將新的值上傳至 Firebase database
            self.itemReference.child(toDoItem.itemId).updateChildValues(["isChecked" : toDoItem.isChecked])

            completionHandler(true)
        }
        
        check.backgroundColor = UIColor.green
        
        // 判斷 isChecked 的值，顯示不同的圖片
        check.image = toDoItems[indexPath.row].isChecked ? UIImage(named: "undo") : UIImage(named: "checkMark")
        
        let swipConfiguraction = UISwipeActionsConfiguration(actions: [check])
        return swipConfiguraction
    }
    
    
    // 向左滑動
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "") { (action, sourceView, completionHandler) in
            
            let itemId = self.toDoItems[indexPath.row].itemId
            
            // 滑動後刪除 Model 與 Firebase database 上的資料
            self.itemReference.child(itemId).removeValue()
            self.toDoItems.remove(at: indexPath.row)

            // 刪除 Table view 上的 row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        
        delete.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
        delete.image = UIImage(named: "trash")
        
        let swipConfiguration = UISwipeActionsConfiguration(actions: [delete])
        return swipConfiguration
    }
    
    
    // 點擊排序按鈕
    @IBAction func sortButtonPressed(_ sender: Any) {
        
        // 排序選單
        let sortMode = UIAlertController(title: "排序方式", message: "", preferredStyle: .alert)
        
        // 由新到舊排序
        let descending = UIAlertAction(title: "由新到舊", style: .default ) { (action) in
            
            self.toDoItems.sort() { (item1, item2) -> Bool in
                
                return item1.date > item2.date
            }
            
            self.isDecending = true
            
            // 更新畫面
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // 由舊到新排序
        let ascending = UIAlertAction(title: "由舊到新", style: .default ) { (action) in
            
            self.toDoItems.sort() { (item1, item2) -> Bool in
                
                return item1.date < item2.date
            }
            
            self.isDecending = false
            
            // 更新畫面
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // 取消動作
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        sortMode.addAction(descending)
        sortMode.addAction(ascending)
        sortMode.addAction(cancel)
        
        present(sortMode, animated: true, completion: nil)
    }
    
    
    // 從 Firebase database 下載資料
    func queryItemData() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show(withStatus: "載入中...")
        
        // 若無資料則停止載入中視窗
        if toDoItems.count == 0 {
            
            SVProgressHUD.dismiss(withDelay: 1.0)

            // 更新畫面
            self.tableView.reloadData()
        }
        
        FirebaseManager.shared.getData(itemReference, type: .value) { (snapshot) in
            
            // 先清空 toDoItems
            self.toDoItems.removeAll()
            
            // 將資料加入 toDoItems
            for snap in snapshot {
                
                let dict = snap.value as! [String : Any]
                let toDoItem = ToDoItem(itemId: dict["itemId"] as! String,
                                        title: dict["title"] as! String,
                                        description: dict["description"] as! String,
                                        date: dict["date"] as! String,
                                        isChecked: dict["isChecked"]! as! Bool,
                                        imageUrl: dict["imageUrl"] as! String)
                
                self.toDoItems.append(toDoItem)
            }
            
            // 判斷排序方式
            if self.isDecending {
                
                self.toDoItems.sort() { (item1, item2) -> Bool in
                    
                    return item1.date > item2.date
                }
            } else {
                
                self.toDoItems.sort() { (item1, item2) -> Bool in
                    
                    return item1.date < item2.date
                }
            }
            
            // 更新畫面
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ItemDetail" {
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                
                return
            }
            
            // 傳遞 toDoItem 的值給 ItemDetailTableViewController
            let itemDetailTableViewController = segue.destination as! ItemDetailTableViewController
            
            itemDetailTableViewController.toDoItem = toDoItems[indexPath.row]
        }
    }

}
