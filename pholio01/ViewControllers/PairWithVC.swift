//
//  PairWithVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/14/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage


class PairWithVC: UIViewController {
    
    
    var ref: DatabaseReference!
    
    let userID = Auth.auth().currentUser?.uid
    let P: String = "P"
    let M: String = "M"
    let V: String = "V"
    let Guest: String = "Guest"
    let Man: String = "Man"
    let Woman: String = "Woman"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref =
            Database.database().reference()
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Usertype Successful")
                
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func canceledPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func pPressed(_ sender: Any) {
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Pairing With": Man])
        
        self.performSegue(withIdentifier: "toEditProfile", sender: nil)
        
    }
    
    
    
    
    @IBAction func mPressed(_ sender: Any) {
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Pairing With": Woman])
        
        self.performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    
    
}
