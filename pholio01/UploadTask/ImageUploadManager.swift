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
        
        let starsRef = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!)

        
        // storage/carImages/image.jpg
        let imagesReference = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!)

        
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = imagesReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                storageReference.downloadURL(completion: { (metadata, error) in
                    if (error != nil), let downloadUrl = metadata {
                        // Make you download string
                        let downloadString = downloadUrl.absoluteString
                        print(downloadString)
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
    
}

