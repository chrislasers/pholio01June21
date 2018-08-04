//
//  GalleryModel.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Firebase

struct GalleryModel {
    
    var userId: String?
    var content: String?
    var url: String?
    
    init(withUserId userId: String, dictionary: [String: Any]) {
        self.userId = userId
        self.userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
        
        if let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
        
        
    }
    
}
