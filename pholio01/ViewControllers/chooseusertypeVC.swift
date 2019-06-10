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
import Pastel

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
        
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "back"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(fbButtonPressed), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 21)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 21)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        
        
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
        firstType.setTitle("Photographer", for: .normal)
        firstType.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        firstType.layer.borderWidth = 1.5
        firstType.layer.cornerRadius = 4
        firstType.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        firstType.layer.shadowOpacity = 0.5
        firstType.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        secondType.backgroundColor = UIColor.orange
        secondType.setTitle("Model", for: .normal)
        secondType.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        secondType.layer.borderWidth = 1.5
        secondType.layer.cornerRadius = 4
        secondType.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        secondType.layer.shadowOpacity = 0.5
        secondType.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        thridType.backgroundColor = UIColor.orange
        thridType.setTitle("Guest", for: .normal)
        thridType.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        thridType.layer.borderWidth = 1.5
        thridType.layer.cornerRadius = 4
        thridType.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        thridType.layer.shadowOpacity = 0.5
        thridType.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
        
       // thridType.backgroundColor = UIColor.orange
       // thridType.layer.borderWidth = 1.5
        //thridType.layer.borderColor = UIColor.orange.cgColor
       // thridType.layer.cornerRadius = firstType.frame.height / 2
       // thridType.layer.shadowColor = UIColor.white.cgColor
      //  thridType.layer.shadowRadius = 7
      //  thridType.layer.shadowOpacity = 0.2
      //  thridType.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        let pastelView = PastelView(frame: view.bounds)
        
        //MARK: -  Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        //MARK: -  Custom Duration
        
        pastelView.animationDuration = 3.00
        
        //MARK: -  Custom Color
        pastelView.setColors([
            
            UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
            
            
            UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
            
            
            
            UIColor(red: 50/255, green: 157/255, blue: 240/255, alpha: 1.0)])
        
        //   UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
        
        
        //  UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 1)
        
        
    }
    
    
    
    @objc func fbButtonPressed() {
        
        dismiss(animated: true, completion: nil)

        
        print("Bar Button Pressed")
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
