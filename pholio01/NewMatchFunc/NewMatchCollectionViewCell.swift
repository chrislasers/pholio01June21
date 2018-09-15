//
//  NewMatchCollectionViewCell.swift
//  pholio01
//
//  Created by Chris  Ransom on 8/23/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase


class NewMatchCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageARRAY: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageARRAY.layer.cornerRadius = self.imageARRAY.frame.size.height / 2;
        self.imageARRAY.layer.borderColor = UIColor.blue.cgColor
        self.imageARRAY.layer.borderWidth = 2
        self.imageARRAY.clipsToBounds = true
        
        
        
        self.imageARRAY.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        
        self.imageARRAY.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.imageARRAY.widthAnchor.constraint(equalToConstant: 48).isActive = true
        self.imageARRAY.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
}
