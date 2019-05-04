//
//  UserCell.swift
//  pholio01
//
//  Created by Chris  Ransom on 11/9/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    
    
    
    
    
    
   
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    
    
    
    
    var buttonFunc: (() -> (Void))!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonFunc()
    }
    
    func setFunction(_ function: @escaping () -> Void) {
        self.buttonFunc = function
        
       // button.backgroundColor = UIColor(r: 73, g: 103, b: 173)
       //  button.frame = CGRect(x: 95, y: 11, width: 254, height: 20)
        //signUpButton.setTitle("Sign Up", for: .normal)
        
        self.button.clipsToBounds = true
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 25
        button.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
    }
    
}
