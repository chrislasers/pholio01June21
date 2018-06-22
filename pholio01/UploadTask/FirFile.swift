//
//  FirFile.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/13/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FirFile: NSObject {
    
    // Singleton instance
    static let shared: FirFile = FirFile()
    
    /// Path
    let kFirFileStorageRef = Storage.storage().reference().child("Files")
    
    /// Current uploading task
    var currentUploadTask: StorageUploadTask?
    
    func upload(data: Data,
                withName fileName: String,
                block: @escaping (_ url: String?) -> Void) {
        
        // Create a reference to the file you want to upload
        let fileRef = kFirFileStorageRef.child(fileName)
        
        /// Start uploading
        upload(data: data, withName: fileName, atPath: fileRef) { (url) in
            block(url)
        }
    }
    
    func upload(data: Data,
                withName fileName: String,
                atPath path:StorageReference,
                block: @escaping (_ url: String?) -> Void) {
        
        // Upload the file to the path
        self.currentUploadTask = path.putData(data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return } else {
                
                print("Meta data of upload image \(String(describing: self.currentUploadTask))")
            }
        }
    }
    
    func cancel() {
        self.currentUploadTask?.cancel()
    }
}

