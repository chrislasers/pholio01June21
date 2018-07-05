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
        if let dictionary = dictionary, let imageURLsDict = dictionary["images"] as? [String: String] {
            let images = imageURLsDict.compactMap({ $0.value as? String })
            self.init(objectID: objectID, imageURLs: images)
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
        guard let imageURLs = imageURLs else {
            return [:]
        }
        
        var imageDicts = [String: String]()
        for (index, url) in imageURLs.enumerated() {
            imageDicts["\(index)"] = url
        }
        return ["images": imageDicts]
    }
    
}

