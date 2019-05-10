//
//  CustomImageFlowLayout.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
    super.init()
    setupLayout()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize {
        
        set {}
        
        
        get {
            let numberofColumns: CGFloat = 3
            let itemWidth = (self.collectionView!.frame.width - (numberofColumns - 1)) / numberofColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }

    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }

}
