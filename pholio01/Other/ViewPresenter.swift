//
//  ViewPresenter.swift
//  GridLayout
//
//  Created by Sztanyi Szabolcs on 2017. 11. 12..
//  Copyright © 2017. Sabminder. All rights reserved.
//

import UIKit

class ViewPresenter: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private weak var viewController: BViewController?
    private(set) var datasource: Datasource = Datasource()

    init(viewController: BViewController?) {
        self.viewController = viewController
    }

    func fetchCars() {
        datasource.fetchCars { [unowned self] (error) in
            if error != nil {
                // TODO: display errors
            } else {
                self.viewController?.collectionView.reloadData()
            }
        }
    }

    // MARK: CollectionView methods
    //func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)

        //if let selectedCar = datasource.itemAt(indexPath) as? Car {
          //  viewController?.performSegue(withIdentifier: "selectCar", sender: selectedCar)
        //}
    //}

    //func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       // _ = datasource.itemAt(indexPath)
        //if let viewController = viewController {
         //       return viewController.gridLayout.itemSizeFor(2)
       // } else {
       //     return CGSize(width: collectionView.frame.width, height: 100.0)
       // }
   // }

}
