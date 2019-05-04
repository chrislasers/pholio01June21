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
                
        self.storyImages.layer.cornerRadius = self.storyImages.frame.size.height / 2;
        self.storyImages.layer.borderColor = UIColor.white.cgColor
        self.storyImages.layer.borderWidth = 1.5
        self.storyImages.clipsToBounds = true
        storyImages.contentMode = .scaleAspectFill
        
         self.storyImages.layer.shadowColor = UIColor.white.cgColor

        self.storyImages.layer.shadowRadius = 7
        self.storyImages.layer.shadowOpacity = 2
        self.storyImages.layer.shadowOffset = CGSize(width: 1, height: 1)
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

