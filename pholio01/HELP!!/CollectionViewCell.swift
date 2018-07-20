//
//  CollectionViewCell.swift
//  pholio01
//
//  Created by Chris  Ransom on 7/4/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftValidator
import Photos
import FirebaseFirestore
import Alamofire
import FirebaseCore
import SDWebImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyImages: UIImageView!
    
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.storyImages.layer.cornerRadius = self.storyImages.frame.size.height / 2;
        self.storyImages.layer.borderColor = UIColor.red.cgColor
        self.storyImages.layer.borderWidth = 3
        self.storyImages.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        storyImages.hnk_cancelSetImage()
        storyImages.image = nil
        
    }
        
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
