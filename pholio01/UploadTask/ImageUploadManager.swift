//
//  ImageUploadManager.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/8/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseCore
import FirebaseAuth


struct Constants {
    
    struct Car {
        static let imagesFolder: String = "User-Gallery"
    }
    
}

let userID = Auth.auth().currentUser?.uid
var ref: DatabaseReference!


class ImageUploadManager: NSObject {
    
    
    
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Float) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        _ = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!)
        
        let uid = Auth.auth().currentUser?.uid
        let imgName = NSUUID().uuidString + ".jpg"
        // storage/carImages/image.jpg
        let imagesReference = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!).child("\(uid!)/photos/\(imgName)")
        
        
        if let imageData =  image.jpegData(compressionQuality: 1.0)  {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = imagesReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                guard metadata != nil else {
                    completionBlock(nil, "Error occured")
                    
                    return
                }
                
                imagesReference.downloadURL(completion: { (metadata, error) in
                    if let downloadUrl = metadata {
                        // Make you download string
                        let downloadString = downloadUrl.absoluteString
                        print(downloadString)
                        self.uploadGalleryUrlToUserNode(contentType: "image", item: downloadString)
                        
                        completionBlock(downloadUrl, nil)
                    } else {
                        // Do something if error
                        completionBlock(nil, "Error")
                    }
                })
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                let percentage = (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                progressBlock(percentage)
            })
        } else {
            completionBlock(nil, "Image couldn't be converted to Data.")
        }
        
    }
    
    
    func uploadGalleryUrlToUserNode(contentType: String, item: String) {
        let galleryDict = ["content": contentType,
                           "item": item]
        
        DBService.shared.currentUser.child("User-Gallery").childByAutoId().updateChildValues(galleryDict)
    }
    
}

