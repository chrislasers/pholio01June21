//
//  Datasource.swift
//  GridLayout
//
//  Created by Sztanyi Szabolcs on 2016. 12. 04..
//  Copyright © 2016. Sabminder. All rights reserved.
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

class Datasource: NSObject {//UICollectionViewDataSource, UICollectionViewDelegate {

    var itemsToDisplay: [Any] = []
    
    var imageURLs: [String]?
    
    
    var listener: ListenerRegistration?
    
    func baseQuery() -> Query {
        return Firestore.firestore().collection("PHOTOS").limit(to: 50)
    }
    
    func fetchCars(_ completion: @escaping (_ error: String?) -> Void) {
        listener = baseQuery().addSnapshotListener({ [unowned self] (snapshot, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                
                self.itemsToDisplay = snapshot.documents.compactMap({ (document) -> Car? in
                    
                    print("Items To Display")
                    
                    return Car(objectID: document.documentID, imageURLs: self.imageURLs!)
                })
                
                completion(nil)
            }
        })
    }
    
    func stopObserveQuery() {
        listener?.remove()
    }
    
    func itemAt(_ indexPath: IndexPath) -> Any {
        return itemsToDisplay[indexPath.item]
    }
    
    
    
    
    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return itemsToDisplay.count
    }
    
    //3
    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemsToDisplay[indexPath.item]
        
        if let car = item as? Car {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
            
            //cell.fill(with: car)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
            return cell
        }
    }
}
