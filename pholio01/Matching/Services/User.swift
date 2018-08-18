//
//  User.swift
//  pholio01
//
//  Created by Chris  Ransom on 8/13/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    init(dictionary: [String: AnyObject]) {
        self.userId = dictionary["userId"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }

}
