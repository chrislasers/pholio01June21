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
    
    //fileprivate var userArr = [[String: Any]]()
    var ref: DatabaseReference!
    var arrImages: [[String: String]] = []
    var displayUserID = ""
    
    var True: String?


    
    var usersArray = [UserModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        

        super.viewWillAppear(animated)
        
        

        DBService.shared.getAllUsers { (usersArray) in
            self.usersArray = usersArray
            self.collectionView.reloadData()
        }
    
        
       // if user["isModel"] == nil {
            
         //   DBService.shared.getAllPhotogs { (usersArray) in
           //     self.usersArray = usersArray
            //    self.collectionView.reloadData()
           //       print("Getting Photogs")
          //  }
      //  } else if user["isInterestedInModel"] == nil {
            
        //    DBService.shared.getAllModels { (usersArray) in
         //       self.usersArray = usersArray
       //         self.collectionView.reloadData()
            //    print("Getting Models")
         //   }
      //  }
       
    
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Firebase User Active In Home")
                
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        ref = Database.database().reference()
        /*
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
         */
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        //collectionView.delegate = self
        // collectionView.dataSource = self
        //collectionView.reloadData()
        
        
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
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func msgTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toMSG", sender: self)

    }
    
   
    
    
    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
        
        let user = usersArray[indexPath.row]
        
        DispatchQueue.global(qos: .background).async {
            let imageData = NSData(contentsOf: URL(string: user.profileImageUrl!)!)
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: imageData! as Data)
                cell.storyImages.image = profileImage
            }
        }
        
        //cell.storyImages.image = UIImage(named: userArr[indexPath.row]["pro-image"] as! String)
        
        return cell
    }
    
    
    
    // MARK: - UICollectionViewDelegate
    //1
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        DBService.shared.refreshUser(userId: usersArray[indexPath.row].userId!) { (refreshedUser) in
            
            if refreshedUser.itemsConverted.count == 0 {
                // no images uploaded
                print("no images uploaded")
                
            } else {
                self.usersArray[indexPath.row] = refreshedUser
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.pages = self.usersArray
                    vc.currentIndex = indexPath.row
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    
    
}


