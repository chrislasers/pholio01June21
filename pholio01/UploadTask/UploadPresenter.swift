//
//  UploadPresenter.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/2/18.
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
import FirebaseCore

class UploadPresenter: NSObject {
    
    
     weak var viewController: SelectImageVC?
    
    
     let collection = Firestore.firestore().collection("PHOTOS")
    
    private let imageUploadManager = ImageUploadManager()

   

     lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
     var uploadedURLs: [URL] = []
    
    init(viewController: SelectImageVC?) {
        self.viewController = viewController
    }
    
    // MARK: Uploading content
    
    func createCar(with images: [UIImage]) {
        // 1. Upload the images 1-by-1
        for image in images {
            let imageUploadOperation = UploadImageOperation(image: image)
            imageUploadOperation.onProgress = { [unowned self] (progress) in
                if let viewController = self.viewController {
                    let viewWidth = viewController.progressView.frame.width
                    let partWidth = viewWidth / CGFloat(images.count)
                    var progressPart = partWidth * CGFloat(progress)
                    if self.uploadedURLs.count > 0 {
                        progressPart += (CGFloat(self.uploadedURLs.count) * partWidth)
                    }
                    self.viewController?.updateProgressView(with: Float(progressPart)/Float(viewWidth))
                }
            }
            imageUploadOperation.onDidUpload =  { [unowned self] (url) in
                if let url = url {
                    self.uploadedURLs.append(url)
                    print("Success URL")
                } else {
                    print("No Image URLs")
                }
            }
            
            if let lastOp = queue.operations.last {
                
                imageUploadOperation.addDependency(lastOp)
                
            }
            queue.addOperation(imageUploadOperation)
            queue.isSuspended = false


        }
        
        // 2. Create the car object with the image urls, title, price
        let finishOperation = BlockOperation { [unowned self] in
            self.CreateCar(imageURLs: self.uploadedURLs.compactMap({ $0.absoluteString }) )
        }
        if let lastOp = queue.operations.last {
            finishOperation.addDependency(lastOp)
        }
        queue.addOperation(finishOperation)
        
        queue.isSuspended = false
    }
    
     func CreateCar(imageURLs: [String]) {
        let car = Car(objectID: nil, imageURLs: imageURLs)
        collection.addDocument(data: car.dictionary()) { [unowned self] (error) in
                if let error = error {
                    print("Queue Error Occured")
                    print(error.localizedDescription)
                } else {
                    self.viewController?.performSegue(withIdentifier: "toAddPhoto", sender: nil)
                }
            
        }
    }
    
}
