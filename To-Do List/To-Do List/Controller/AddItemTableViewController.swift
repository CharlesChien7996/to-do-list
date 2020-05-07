//
//  AddItemTableViewController.swift
//  To-Do List
//
//  Created by 簡士荃 on 2018/10/1.
//  Copyright © 2018 Charles. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddItemTableViewController: UITableViewController {
    
    // 標題 & 日期 TextField
    @IBOutlet weak var titleTextField: RoundedTextFiled!
    @IBOutlet weak var dateTextField: RoundedTextFiled!
    
    // 描述 TextView
    @IBOutlet weak var descriptionTextView: UITextView! {
        
        didSet {
            
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    // 圖片
    @IBOutlet weak var itemImageView: UIImageView!
    
    var datePicker: UIDatePicker?
    var dateformatter: DateFormatter?
    
    var itemRef = FirebaseManager.shared.databaseReference.child("Item")
    var isEditingMode = false
    var toDoItem: ToDoItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定日期格式
        dateformatter = DateFormatter()
        dateformatter?.dateFormat = "yyyy-MM-dd"
        
        // 設定 dateTextField 的初始日期為當天
        dateTextField.text = dateformatter?.string(from: Date())
        
        // 實作 datePicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.minimumDate = Date()
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        // 將 dateTextField 的 inputView 換成 datePicker
        dateTextField.inputView = datePicker
        
        // 實作 itemImageView 點擊
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewPressed))
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
        itemImageView.isUserInteractionEnabled = true
        
        // 設定 descriptionTextView 的 delegate
        descriptionTextView.delegate = self
        
        // 判斷是否為編輯模式
        if isEditingMode {
            
            itemImageView.image = toDoItem.image
            titleTextField.text = toDoItem.title
            dateTextField.text = toDoItem.date
            descriptionTextView.text = toDoItem.description
            descriptionTextView.textColor = UIColor.black
        }
    }

    
    // DatePicker 的值改變時呼叫此方法
    @objc func dateChanged(datePicker: UIDatePicker) {
    
        // 設定日期格式
        dateformatter = DateFormatter()
        dateformatter?.dateFormat = "yyyy-MM-dd"
        
        // 將 dateTextField 到的文字改為選擇的日期
        dateTextField.text = dateformatter?.string(from: datePicker.date)
    }
    
    
    // 點擊 itemImageView
    @objc func imageViewPressed() {

        let picker = UIImagePickerController()
        picker.delegate = self
        
        // 選單
        let imageSourceSelector = UIAlertController(title: "", message: "選擇圖片", preferredStyle: .actionSheet)
        
        // 從相機取得圖片
        let camera = UIAlertAction(title: "相機", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                picker.sourceType = .camera
                picker.allowsEditing = false
                
                self.present(picker, animated: true, completion: nil)
            }
        }
        
        // 從相簿取得圖片
        let photoLibrary = UIAlertAction(title: "相簿", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                
                self.present(picker, animated: true, completion: nil)
            }
        }
        
        // 取消
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        imageSourceSelector.addAction(camera)
        imageSourceSelector.addAction(photoLibrary)
        imageSourceSelector.addAction(cancel)
        
        present(imageSourceSelector, animated: true, completion: nil)
    }
    

    //點擊儲存按鈕
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if titleTextField.text?.isEmpty == true || dateTextField.text?.isEmpty == true ||
            descriptionTextView.text.isEmpty == true || descriptionTextView.text == "輸入描述" ||
            descriptionTextView.textColor == UIColor.lightGray {
            
            let alert = UIAlertController(title: "尚未輸入完成！", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 上傳資料
        uploadData()
        
        // 判斷是否為編輯模式
        if isEditingMode {
            
            navigationController?.popToRootViewController(animated: true)
        }else {
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    // 點擊取消按鈕
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        // 選單
        let alert = UIAlertController(title: "內容尚未儲存，確定要返回嗎？", message: nil, preferredStyle: .alert)
        
        // 確定返回
        let ok = UIAlertAction(title: "確定", style: .default) { (alertAction) in
            
            DispatchQueue.main.async {

                // 判斷是否為編輯模式
                if self.isEditingMode {
                    
                    self.navigationController?.popViewController(animated: true)
                }else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        // 取消動作
        let cancel = UIAlertAction(title: "取消", style:.cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // 上傳資料至 Firabase Database
    func uploadData() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show(withStatus: "請稍候...")
        
        var itemId = Database.database().reference().childByAutoId().key
        var isChecked = false
        
        if isEditingMode {
            
            itemId = toDoItem.itemId
            isChecked = toDoItem.isChecked
        }
        
        let imageRef = Storage.storage().reference().child("ItemImage").child(itemId)

        
        // 判斷是否取得圖片
        guard let itemImage = itemImageView.image else {
            
            print("Fail to get itemImage.")
            return
        }
        
        // 判斷是否取得縮圖
        guard let thumbnailImage = FirebaseManager.shared.thumbnail(itemImage, widthSize: 200, heightSize: 200) else {
            
            print("Fail to get image.")
            return
        }
        
        // 上傳圖片
        FirebaseManager.shared.uploadImage(imageRef, image: thumbnailImage) { (url) in
            
            let toDoItem = ToDoItem(itemId: "\(itemId)", title: self.titleTextField.text!, description: self.descriptionTextView.text!, date: self.dateTextField.text!, isChecked: isChecked, imageUrl: "\(url)")

            // 上傳資料
            self.itemRef.child("\(itemId)").setValue(toDoItem.prepareData())
            SVProgressHUD.dismiss()
        }
    }
}


// MARK: - Image picker controller delegate
extension AddItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 選擇圖片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let oringnalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        var editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if editImage == nil {
            
            editImage = oringnalImage
        }
        
        if let finalImage = editImage {
            
            itemImageView.image = finalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Text field delegate
extension AddItemTableViewController: UITextViewDelegate {
    
    // textView的文字輸入框
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descriptionTextView.text == "輸入描述" {
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.black
        }
    }
}
