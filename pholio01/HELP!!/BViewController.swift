//
//  BViewController.swift
//  pholio01
//
//  Created by Chris  Ransom on 7/2/18.
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

class BViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    fileprivate var userArr = [[String: Any]]()
    
    
    var ref: DatabaseReference!

    var imageUploadManager: ImageUploadManager?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        ref = Database.database().reference()

        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Entire Profile Created")
                
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        userArr = [
            [ "pro-image" : "pro-img-3",
             "items": [["content" : "image", "item" : "img-3"], ["content" : "video", "item" : "output"], ["content" : "video", "item" : "output2"]]],
            ["pro-image" : "pro-img-1",
             "items": [["content" : "video", "item" : "output3"], ["content" : "image", "item" : "img-4"], ["content" : "image", "item" : "img-5"], ["content" : "video", "item" : "output"]]],
            ["pro-image" : "pro-img-2",
             "items": [["content" : "image", "item" : "img-1"], ["content" : "video", "item" : "output2"]]],
            ["pro-image" : "pro-img-4",
             "items": [["content" : "image", "item" : "img-2"], ["content" : "video", "item" : "output"], ["content" : "image", "item" : "img-3"]]],
            ["pro-image" : "pro-img-3",
             "items": [["content" : "video", "item" : "output"], ["content" : "image", "item" : "img-4"], ["content" : "video", "item" : "output3"], ["content" : "image", "item" : "img-3"]]],
            ["pro-image" : "pro-img-5",
             "items": [["content" : "video", "item" : "output2"], ["content" : "image", "item" : "img-5"], ["content" : "video", "item" : "output3"]]],
        ]
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    
        
        self.addSlideMenuButton()
        // Do any additional setup after loading the view.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    //////////////////////////////////////////////////////////////////////////////////////////////


    
    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return userArr.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
        
        cell.storyImages.image = UIImage(named: userArr[indexPath.row]["pro-image"] as! String)        
        return cell
    }
    
    
    
    // MARK: - UICollectionViewDelegate
    //1
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController
            vc.modalPresentationStyle = .overFullScreen
            vc.pages = self.userArr
            vc.currentIndex = indexPath.row
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    

}
