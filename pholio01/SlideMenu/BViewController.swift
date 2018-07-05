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

class BViewController: BaseViewController, UICollectionViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gridLayout: GridLayout!
    private var presenter: ViewPresenter!

    var imageUploadManager: ImageUploadManager?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        
      presenter = ViewPresenter(viewController: self)
        
        gridLayout = GridLayout(numberOfColumns: 2)
        
        collectionView.collectionViewLayout = gridLayout
        collectionView.delegate = presenter
        collectionView.dataSource = presenter.datasource
        collectionView.reloadData()
        
        presenter.fetchCars()
        
        
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
    


}
