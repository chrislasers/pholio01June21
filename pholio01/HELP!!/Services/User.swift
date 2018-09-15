//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class User: NSObject {
    var userId: String?
    var username: String?
    var profileImageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        self.userId = dictionary[userID!] as? String
        self.username = dictionary["Username"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
