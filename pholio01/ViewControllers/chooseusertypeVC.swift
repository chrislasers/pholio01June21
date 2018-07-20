//
//  chooseusertypeVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/26/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage

class chooseusertypeVC: UIViewController {
    
    
    @IBOutlet weak var photoPressed: UIButton!
    
    
    var ref: DatabaseReference!
        

    let userID = Auth.auth().currentUser?.uid
    let Photographer: String = "Photographer"
    let Model: String = "Model"
    let Videographer: String = "Videographer"
    let Guest: String = "Guest"
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
       
        
        ref =
      Database.database().reference()
        
            
            
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Creation of profile SUCCESSFUL")
                
            
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
    
    
    
    
    
    
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func photographerPressed(_ sender: Any) {
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Usertype": Photographer])

        
        
        self.performSegue(withIdentifier: "toPair", sender: nil)
        
        
        print("Photographer Stored")
    }

    
    
    
    @IBAction func modelPressed(_ sender: Any) {
        
         self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["User Type": Photographer])
        
        performSegue(withIdentifier: "toPair", sender: nil)
        
        
        print("Model Stored")
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
