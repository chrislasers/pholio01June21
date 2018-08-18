//
//  UserModel.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

struct UserModel {
    
    var userId: String?
    var userProfilePicDictionary: [String: Any]?
    var profileImageUrl: String?
    
    var username: String?
    
    var items = [[String: Any]]()
    var itemsConverted = [[String: String]]()
    
    init(withUserId userId: String, dictionary: [String: Any]) {
        self.userId = userId
        self.userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
        
        if let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
        let arr = dictionary.map {[$0: $1]}
        
        for (_, value) in arr.enumerated() {
            if let object = value.first?.value as? [String: String] {
                if let username = object["Username"] as? String {
                    self.username = username
                }
            }
        }
        
        let userGalleryItems = dictionary["User-Gallery"] as? [String: Any]
        
        // convert the values to fit the current values that the story feature is using
        if let values = userGalleryItems?.values {
            
            for i in values {
                if let t = i as? [String: Any] {
                    items.append(t)
                }
                
                if let t = i as? [String: String] {
                    itemsConverted.append(t)
                }
            }
        }
        
    }
    
}
