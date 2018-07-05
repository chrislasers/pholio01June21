//
//  StoryImage.swift
//  pholio01
//
//  Created by Chris  Ransom on 7/4/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct StoryImage {
    
    
    let key:String!
    
    let url:String!
    
    let itemRef: DatabaseReference?
    
    init(url:String, key:String) {
        self.key = key
        self.url = url
        self.itemRef = nil
    }
    
    init(snapshot:DataSnapshot) {
        
        key = snapshot.key
        itemRef = snapshot.ref
        
        let snapshotValue = snapshot.value as? NSDictionary
        if let imageURL = snapshotValue!["url"] as? String {
            
            url = imageURL
        } else {
            
            url = ""
        }
        
    }
    
}
