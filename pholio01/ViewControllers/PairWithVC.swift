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
    let Photographer: String = "Photographer"
    let Model: String = "Model"
    let Guest: String = "Guest"
    let Man: String = "Man"
    let Woman: String = "Woman"
    
    @IBOutlet weak var firstPair: UIButton!
    
    @IBOutlet weak var secondPair: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        firstPair.backgroundColor = UIColor.black
        firstPair.layer.borderWidth = 1.5
        firstPair.layer.borderColor = UIColor.white.cgColor
        firstPair.layer.cornerRadius = firstPair.frame.height / 2
        firstPair.layer.shadowColor = UIColor.white.cgColor
        firstPair.layer.shadowRadius = 7
        firstPair.layer.shadowOpacity = 0.2
        firstPair.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        secondPair.backgroundColor = UIColor.black
        secondPair.layer.borderWidth = 1.5
        secondPair.layer.borderColor = UIColor.white.cgColor
        secondPair.layer.cornerRadius = secondPair.frame.height / 2
        secondPair.layer.shadowColor = UIColor.white.cgColor
        secondPair.layer.shadowRadius = 7
        secondPair.layer.shadowOpacity = 0.2
        secondPair.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        
        
        
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
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Pairing With": Photographer])
        
        self.performSegue(withIdentifier: "toEditProfile", sender: nil)
        
    }
    
    
    
    
    @IBAction func mPressed(_ sender: Any) {
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Pairing With": Model])
        
        self.performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    
    
    
}
