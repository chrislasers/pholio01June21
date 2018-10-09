//
//  openingVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/28/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftValidator
import FBSDKLoginKit


class openingVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
       

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func createPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showSignUp", sender: nil)
        
        
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        performSegue(withIdentifier: "Login", sender: nil)
    }
}
