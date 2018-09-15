//
//  PopUpVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 9/7/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase

class PopUpVC: UIViewController {
    
    
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var signIn: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signUp.backgroundColor = UIColor.clear
        signUp.layer.borderWidth = 1.75
        signUp.layer.borderColor = UIColor.white.cgColor
        signUp.layer.cornerRadius = signUp.frame.height / 2
        signUp.setTitleColor(UIColor.white, for: .normal)
        signUp.layer.shadowColor = UIColor.white.cgColor
        signUp.layer.shadowRadius = 12
        signUp.layer.shadowOpacity = 0.4
        signUp.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        signIn.backgroundColor = UIColor.clear
        signIn.layer.borderWidth = 1.75
        signIn.layer.borderColor = UIColor.white.cgColor
        signIn.layer.cornerRadius = signIn.frame.height / 2
        signIn.setTitleColor(UIColor.white, for: .normal)
        signIn.layer.shadowColor = UIColor.white.cgColor
        signIn.layer.shadowRadius = 12
        signIn.layer.shadowOpacity = 0.4
        signIn.layer.shadowOffset = CGSize(width: 0, height: 0)

        
        signUp.addTarget(self, action: #selector(setButtonSelected(button:)), for: .touchDown);
        signUp.addTarget(self, action: #selector(setButtonUnselected(button:)), for: .touchUpInside)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func presentSignUp(_ sender: Any) {
         self.performSegue(withIdentifier: "showSignUp", sender: nil)
        print("clicked")
        
    }
    
    @IBAction func presentSignIn(_ sender: Any) {
        
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    
    
    @objc func setButtonSelected(button : UIButton) {
        signUp.backgroundColor = UIColor.black
        
        signUp.setTitle("Sign Up", for: .highlighted)
        
        signUp.layer.borderWidth = 1.75
        
        signUp.layer.borderColor = UIColor.white.cgColor
        
        signUp.layer.cornerRadius = signUp.frame.height / 2
        signUp.setTitleColor(UIColor.white, for: .normal)
        signUp.layer.shadowColor = UIColor.white.cgColor
        signUp.layer.shadowRadius = 12
        signUp.layer.shadowOpacity = 0.4
        signUp.layer.shadowOffset = CGSize(width: 0, height: 0)    }
    
    @objc func setButtonUnselected(button : UIButton) {
        
        signUp.setTitle("Sign Up", for: .normal)

        signUp.backgroundColor = UIColor.clear
        
        signUp.layer.borderWidth = 1.75
        
        signUp.layer.borderColor = UIColor.white.cgColor
        
        signUp.layer.cornerRadius = signUp.frame.height / 2
        signUp.setTitleColor(UIColor.white, for: .normal)
        signUp.layer.shadowColor = UIColor.white.cgColor
        signUp.layer.shadowRadius = 12
        signUp.layer.shadowOpacity = 0.4
        signUp.layer.shadowOffset = CGSize(width: 0, height: 0)    }
    
    
    

    @IBAction func closePopUp(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

}
