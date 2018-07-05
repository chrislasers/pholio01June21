//
//  Datasource.swift
//  GridLayout
//
//  Created by Sztanyi Szabolcs on 2016. 12. 04..
//  Copyright © 2016. Sabminder. All rights reserved.
//

import UIKit
import FirebaseFirestore

class Datasource: NSObject, UICollectionViewDataSource {

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

    // MARK: collectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsToDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemsToDisplay[indexPath.item]
        if item is Car {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.fill(with: Car.self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            return cell
        }
    }

}
