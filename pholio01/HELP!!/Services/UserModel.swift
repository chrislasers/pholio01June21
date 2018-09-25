//
//  UserModel.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Firebase

class UserModel: NSObject {
    
    var userId: String?
    var userProfilePicDictionary: [String: Any]?
    var profileImageUrl: String?
    var username: String?
    var items = [[String: Any]]()
    var itemsConverted = [[String: String]]()
    
    var pairingWith: String?
    var matchedUsers = [String: Any]()
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var genderFilter: GenderFilter!
    var pairingFilter: PairingFilter!
    var ageFilter: Int!
    var milesFilter: Int!
    
    var gender: String!
    var age: Int!
    var userType: String!
    var lat_lon: String!
    
    var featured: Bool!
    var featuredFilter: Bool!
    
    init(withUserId userId: String, dictionary: [String: Any]) {
        self.userId = userId
        
        let arr = dictionary.map {[$0: $1]}
        
        for (_, value) in arr.enumerated() {
            if let object = value.first?.value as? [String: String] {
                if let username = object["Username"] {
                    self.username = username
                }
            }
        }
        
        self.userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
        
        if let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
        if let pairingWith = dictionary["Pairing With"] as? String {
            self.pairingWith = pairingWith
        }
        
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        
        
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
        
        if let matchedUsers = dictionary["Matched-Users"] as? [String: Any] {
            self.matchedUsers = matchedUsers
        }
        
        func chatPartnerId() -> String? {
            return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        }
        
        if let genderFilter = dictionary["GenderFilter"] as? String {
            self.genderFilter = GenderFilter(rawValue: genderFilter)
        } else {
            // if no filter exists set to the default which is both genders
            self.genderFilter = .both
        }
        
        if let pairingFilter = dictionary["PairingFilter"] as? String {
            self.pairingFilter = PairingFilter(rawValue: pairingFilter)
        } else {
            // if no filter exists set to the default which is all user types
            self.pairingFilter = .all
        }
        
        if let ageFilter = dictionary["AgeFilter"] as? Int {
            self.ageFilter = ageFilter
        } else {
            // if no filter exists set to the default which is 0
            self.ageFilter = 0
        }
        
        if let milesFilter = dictionary["MilesFilter"] as? Int {
            self.milesFilter = milesFilter
        } else {
            // if no filter exists set to the default which is 0
            self.milesFilter = 0
        }
        
        if let gender = dictionary["Gender"] as? String {
            self.gender = gender
        } else {
            self.gender = GenderFilter.male.rawValue
        }
        
        if let age = dictionary["Age"] as? Int {
            self.age = age
        } else {
            self.age = 18
        }
        
        self.userType = dictionary["Usertype"] as! String
        
        if let lat_lon = dictionary["lat_lon"] as? String {
            self.lat_lon = lat_lon
        } else {
            self.lat_lon = ""
        }
        
        if let featured = dictionary["Featured"] as? Bool {
            self.featured = featured
        } else {
            self.featured = false
        }
        
        if let featuredFilter = dictionary["FeaturedFilter"] as? Bool {
            self.featuredFilter = featuredFilter
        } else {
            self.featuredFilter = false
        }
        
    }
    
    
    
}
