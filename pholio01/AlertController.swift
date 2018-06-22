//
//  AlertController.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/19/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Foundation
import UIKit


class AlertController {
    static func showAlert(_ inViewController: UIViewController, title : String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }
    
}
