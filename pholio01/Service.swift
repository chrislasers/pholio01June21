//
//  Service.swift
//  pholio01
//
//  Created by Chris  Ransom on 5/14/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import JGProgressHUD


class Service {
    
    
    static func showAlert(on: UIViewController, style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        on.present(alert, animated: true, completion: completion)
    }
    
    static func dismissHud(_ hud:JGProgressHUD, text: String, detailText: String, delay: TimeInterval) {
        
        hud.textLabel.text = text
        hud.detailTextLabel.text = detailText
        hud.dismiss(afterDelay: delay, animated: true)
        
    }
    }
