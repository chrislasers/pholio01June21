//
//  StorageService.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class StorageService: NSObject {
    
    static var shared: StorageService {
        struct Static {
            static let instance = StorageService()
        }
        return Static.instance
    }
    
    // MARK: - References
    let root = Storage.storage().reference()
    
    var userProfilePics: StorageReference {
        return root.child("UserPro-Pics")
    }
    
    var usersGallery: StorageReference {
        return root.child("User-Gallery").child((Auth.auth().currentUser?.uid)!)
    }
    
}
