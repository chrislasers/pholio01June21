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
    let V: String = "V"
    let Guest: String = "Guest"
    let Man: String = "Man"
    let Woman: String = "Woman"
    
    
    let photographer = "Photographer"
    let model = "Model"
    
    
    @IBOutlet weak var firstType: UIButton!
    
    @IBOutlet weak var secondType: UIButton!
    
    @IBOutlet weak var thridType: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstType.center.x = self.view.frame.width + 30
        secondType.center.x = self.view.frame.width + 30
        thridType.center.x = self.view.frame.width + 30

        
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 5, options: [], //options: nil
            animations: ({
            
                self.firstType.center.x = self.view.frame.width / 2
            
        
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 6, options: [], //options: nil
            animations: ({
                
                self.secondType.center.x = self.view.frame.width / 2
                
                
            }), completion: nil)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 4, options: [], //options: nil
            animations: ({
                
                self.thridType.center.x = self.view.frame.width / 2
                
                
            }), completion: nil)
        
        
        firstType.backgroundColor = UIColor.orange
        firstType.layer.borderWidth = 1.5
        firstType.layer.borderColor = UIColor.orange.cgColor
        firstType.layer.cornerRadius = firstType.frame.height / 2
        firstType.layer.shadowColor = UIColor.white.cgColor
        firstType.layer.shadowRadius = 7
        firstType.layer.shadowOpacity = 0.2
        firstType.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        secondType.backgroundColor = UIColor.orange
        secondType.layer.borderWidth = 1.5
        secondType.layer.borderColor = UIColor.orange.cgColor
        secondType.layer.cornerRadius = firstType.frame.height / 2
        secondType.layer.shadowColor = UIColor.white.cgColor
        secondType.layer.shadowRadius = 7
        secondType.layer.shadowOpacity = 0.2
        secondType.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        thridType.backgroundColor = UIColor.orange
        thridType.layer.borderWidth = 1.5
        thridType.layer.borderColor = UIColor.orange.cgColor
        thridType.layer.cornerRadius = firstType.frame.height / 2
        thridType.layer.shadowColor = UIColor.white.cgColor
        thridType.layer.shadowRadius = 7
        thridType.layer.shadowOpacity = 0.2
        thridType.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
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
    
    
    
    @IBAction func pPressed(_ sender: Any) {
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Usertype": photographer])
        
        
        self.performSegue(withIdentifier: "toPair", sender: nil)
        
        print("Photographer Stored")
    }
    
    
    
    
    @IBAction func mPressed(_ sender: Any) {
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Usertype": model])
        
        performSegue(withIdentifier: "toPair", sender: nil)
        
        print("Model Stored")
    }
    
    
    
    
    @IBAction func gPressed(_ sender: Any) {
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Usertype": Guest])
        
        performSegue(withIdentifier: "toPair", sender: nil)
        
        print("Guest Stored")
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
