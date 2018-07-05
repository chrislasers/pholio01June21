//
//  CollectionViewCell.swift
//  pholio01
//
//  Created by Chris  Ransom on 7/4/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Haneke
import FirebaseUI
import SDWebImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyImages: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        storyImages.hnk_cancelSetImage()
        storyImages.image = nil    }
        
        func fill(with object: Any) {
            if let image = object as? UIImage {
                storyImages.image = image
                print("Image Noticed")
            } else if let urlString = object as? String, let imageURLs = URL(string: urlString) {
                storyImages.hnk_setImage(from: imageURLs)
                print("URL Noticed")
            }
        }
}
