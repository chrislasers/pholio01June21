//
//  Photo.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/10/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//
import UIKit

class Car: NSObject {
    
    var image: UIImage?
    var objectID: String!
    var imageURL: String!
    var imageURLs: [String]?
    
    convenience init?(dictionary: [String: Any]?, objectID: String, imageURLs: String) {
        
        
        if let imageURLs = dictionary!["images"] as? [String] {
            self.init(objectID: objectID, imageURLs: imageURLs)
        } else {
            return nil
        }
    }
    
    init(objectID: String?, imageURLs: [String]) {
        self.objectID = objectID ?? ""
       
        self.imageURLs = imageURLs
        self.imageURL = imageURLs.first
    }
    
    func dictionary() -> [String: Any] {
        return [ "images": [imageURLs]]
    }
    
}
