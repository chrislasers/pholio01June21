//
//  InstagramLogInVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 1/18/19.
//  Copyright © 2019 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftValidator
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore
import LBTAComponents
import JGProgressHUD
import MapKit
import CoreLocation
import GeoFire
import Pastel
import FirebaseMessaging
import FacebookShare
import FirebaseInstanceID
import UICircularProgressRing
import InstagramLogin



class InstagramLogInVC: UIViewController, InstagramLoginViewControllerDelegate {
    
    
    
    var instagramLogin: InstagramLoginViewController!
    
    @IBOutlet var yesInsta: UIButton!
    

    @IBOutlet var noInsta: UIButton!
    
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
        
        
        
        yesInsta.center.x = self.view.frame.width + 30
        noInsta.center.x = self.view.frame.width + 30
        
        
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 5, options: [], //options: nil
            animations: ({
                
                self.yesInsta.center.x = self.view.frame.width / 2
                
                
            }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 6, options: [], //options: nil
            animations: ({
                
                self.noInsta.center.x = self.view.frame.width / 2
                
                
            }), completion: nil)
        
        
        
        
        
        yesInsta.backgroundColor = UIColor.orange
        yesInsta.setTitle("Yes", for: .normal)
        yesInsta.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        yesInsta.layer.borderWidth = 1.5
        yesInsta.layer.cornerRadius = 4
        yesInsta.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        yesInsta.layer.shadowOpacity = 0.5
        yesInsta.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        noInsta.backgroundColor = UIColor.orange
        noInsta.setTitle("No", for: .normal)
        noInsta.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        noInsta.layer.borderWidth = 1.5
        noInsta.layer.cornerRadius = 4
        noInsta.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        noInsta.layer.shadowOpacity = 0.5
        noInsta.layer.shadowOffset = CGSize(width: 1, height: 1)

        // Do any additional setup after loading the view.
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
    
    
    @IBAction func noInstagram(_ sender: Any) {
        
        
        performSegue(withIdentifier: "yesInsta", sender: nil)

        
    }
    

    @IBAction func instagramLogin(_ sender: Any) {
        
        
        instagramLogin = InstagramLoginViewController(clientId: ConstantsTwo.clientId, redirectUri: ConstantsTwo.redirectUri)
        instagramLogin.delegate = self
        instagramLogin.scopes = [.all]
        
        instagramLogin.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissLoginViewController))
        instagramLogin.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPage))
        
        present(UINavigationController(rootViewController: instagramLogin), animated: true)
        
      

        
    }
    
    func showAlertView(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let backToSignIn = UIAlertAction(title: "OK", style: .cancel, handler: { action in self.performSegue(withIdentifier: "noInsta", sender: self)})

        alertView.addAction(backToSignIn)

        present(alertView, animated: true)
    }
    
    @objc func dismissLoginViewController() {
        instagramLogin.dismiss(animated: true)
    }
    
    @objc func refreshPage() {
        instagramLogin.reloadPage()
    }
    
    func instagramLoginDidFinish(accessToken: String?, error: InstagramError?) {
        dismissLoginViewController()
        
        if accessToken != nil {
            
            
            showAlertView(title: "Successfully logged in! 👍", message: "")
            
            
        } else {
            showAlertView(title: "\(error!.localizedDescription) 👎", message: "")
        }
    }
    
    
}


