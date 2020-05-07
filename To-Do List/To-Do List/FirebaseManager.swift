import Foundation
import Firebase

class FirebaseManager {
    
    static let shared = FirebaseManager()
    private init() { }
    
    let databaseReference: DatabaseReference = Database.database().reference()
    var imageCache = NSCache<NSString, AnyObject>()
    

    // 從 Firebase database 下載資料
    func getData(_ reference: DatabaseQuery, type: DataEventType, completionHandler: @escaping (_ allObjects: [DataSnapshot]) -> Void) {
        
        reference.observe(type) { (snapshot: DataSnapshot) in
            
            completionHandler(snapshot.children.allObjects as! [DataSnapshot])
        }
    }
    
    
    // 從 Firebase storage 下載圖片
    func getImage(urlString: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        guard let imageURL = URL(string: urlString) else {
            
            print("Fail to get imageURL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            
            if let error = error {
                
                print("Download image task fail: \(error.localizedDescription)")
                return
            }
            
            guard let imageData = data else {
                
                print("Fail to get imageData")
                return
            }
            
            let image = UIImage(data: imageData)
            
                completionHandler(image)
            
        }
        
        task.resume()
    }
    
    
    // 將圖片縮圖
    func thumbnail(_ image: UIImage?, widthSize: Int, heightSize: Int) -> UIImage? {
        
        guard let image = image else {
            print("Fail to get image")
            return nil
        }
        
        let thumbnailSize = CGSize(width: widthSize, height: heightSize)
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, scale)
        
        let widthRatio = thumbnailSize.width / image.size.width
        let heightRatio = thumbnailSize.height / image.size.height
        
        let ratio = max(widthRatio, heightRatio)
        
        let imageSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        
        let cgRect = CGRect(x: -(imageSize.width - thumbnailSize.width) / 2, y: -(imageSize.height - thumbnailSize.height) / 2, width: imageSize.width, height: imageSize.height) 
        
        image.draw(in: cgRect)
        
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return smallImage
    }
    
    
    // 上傳圖片至 Firebase storage
    func uploadImage(_ reference: StorageReference, image: UIImage, completionHandler: @escaping (_ imageURL: URL) -> Void){
        
        guard let imageData = image.jpegData(compressionQuality: 1) else{
            print("Fail to get imageData")
            return
        }
        
        reference.putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            reference.downloadURL() { (url, error) in
                
                guard let url = url else{
                    
                    print("error: \(error!)")
                    return
                }
                
                completionHandler(url)
            }
        }
    }
    
}
