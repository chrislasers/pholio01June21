//
//  HomePageVC.swift
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

class HomePageVC: UIViewController {
    
    
    @IBOutlet weak var signOutPressed: UIButton!
    
    @IBOutlet weak var btnMenuButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
         signOutPressed.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            btnMenuButton.target = revealViewController()
            btnMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            //            revealViewController().rightViewRevealWidth = 150
            //            extraButton.target = revealViewController()
            //            extraButton.action = "rightRevealToggle:"
            
            
            
            
        }
    }
        
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func signOut() {
        
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            let firebaseAuth = Auth.auth()
            
            do {
                
                try firebaseAuth.signOut()

                print("User Signed Out")
                
                
            } catch let signOutError as NSError {
                
                Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: NSLocalizedDescriptionKey)
                
                print ("Error signing out: %@", signOutError)
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let OpeningVC = storyboard.instantiateViewController(withIdentifier: "openingVC")
            
         self.present(OpeningVC, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
    }
    
        
    }
   
    
    


