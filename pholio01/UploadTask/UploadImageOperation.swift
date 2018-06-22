//
//  UploadImageOperation.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/8/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

class UploadImageOperation: AbstractOperation {
    
    let image: UIImage
    private let uploadManager: ImageUploadManager = ImageUploadManager()

    
    var onDidUpload: ((_ url: URL?) -> Void)!
    var onProgress: ((_ progress: Float) -> Void)!
    
    init(image: UIImage) {
        self.image = image
    }
    
    override func execute() {
        
        uploadImage()
    }
    
    private func uploadImage() {
        DispatchQueue.main.async(execute: {
            self.uploadManager.uploadImage(self.image, progressBlock: self.onProgress)
            { [unowned self] (url, error) in
                self.onDidUpload(url)
                self.finished(error: error)
            }
            
        })
        
    }
    
}
