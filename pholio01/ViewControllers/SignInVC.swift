//
//  SignInVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/9/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper
import SwiftValidator
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore
import LBTAComponents
import JGProgressHUD



class SignInVC: UIViewController, UITextFieldDelegate, ValidationDelegate {
   
    
    func validationSuccessful() {
      
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 8 characters. One uppercase. One Lowercase. One number.")])
        
        
        
        
        print("Validation Success!")
        
       
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            
            print("Validation Error!")
            
            
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    
    

    var ref: DatabaseReference!
    
    var userID = Auth.auth().currentUser?.uid
    
    let validator = Validator()

    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBOutlet weak var signInPressed: UIButton!
   
    
    @IBOutlet weak var emailValid: UILabel!
    
    @IBOutlet weak var passwordValid: UILabel!
    
    @IBOutlet weak var fbValid: UILabel!
    

    override func viewDidLoad() {
        
        var signInWithFbButton: UIButton {
            
        // Add a custom login button to your app
            let myLoginButton = UIButton(type: .custom)
        myLoginButton.backgroundColor = UIColor(r: 73, g: 103, b: 173)
        myLoginButton.frame = CGRect(x: 15, y: 620, width: view.frame.width - 30, height: 47)
            myLoginButton.setTitle("Login with Facebook", for: .normal)
            myLoginButton.setTitleColor(UIColor.white, for: .normal)
            myLoginButton.layer.cornerRadius = 7
            
            myLoginButton.setImage(#imageLiteral(resourceName: "flogo_RGB_HEX-144").withRenderingMode(.automatic), for: .normal)
            myLoginButton.tintColor = .white
            myLoginButton.contentMode = .scaleAspectFill
            
            
            myLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize:  16)
            myLoginButton.layer.masksToBounds = true
            // Handle clicks on the button
           myLoginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
            return myLoginButton
        }
        // Add the button to the view
        view.addSubview(signInWithFbButton)
        
        email.keyboardType = .emailAddress
        email.placeholder = "Email Address"
        self.view.addSubview(email)
        
        password.placeholder = "Password"
        self.view.addSubview(password)
        
        
        
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user?.isEmailVerified == true
            {
                print("User Signed In")
                self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        configureTextFields()
        
        ref = Database.database().reference()

        
        emailValid.isHidden = true
        passwordValid.isHidden = true
        fbValid.isHidden = true
        
        
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
                
            }
        }, error:{ (validationError) -> Void in
            print("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        })
        
        
        
        
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
        
        
        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 8 characters. One uppercase. One Lowercase. One number.")])

        
        
        signInPressed.addTarget(self, action: #selector(signinPRESSED), for: .touchUpInside)
        
        signInPressed(enabled: false)
        
        
        email.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        email.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
        email.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEndOnExit )
        
        password.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
        password.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        password.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEndOnExit )
        
        
        
        
        
        //Listens For Keyboard Events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -150
    } else {
            
    view.frame.origin.y = 0
            
    }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        email.resignFirstResponder()
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        email.resignFirstResponder()
        
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    //FACEBOOK INTEGRATION
    
    @objc func loginButtonClicked() {
    
        hud.textLabel.text =  "Logging in with Facebook..."
        hud.show(in: view, animated: true)
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions:
        [ .publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
               

                print("Successfully logged into Facebook")
                
                
                self.performSegue(withIdentifier: "homepageVC", sender: nil)
                
               
                
                self.signIntoFirebase()
                
            case .failed(let error):
                Service.dismissHud(self.hud, text: "Error", detailText: "Canceled getting Facebook user: \(error)", delay: 2)
            case .cancelled:
                Service.dismissHud(self.hud, text: "Error", detailText: "Canceled getting Facebook user", delay: 2)
                break
            }
        }
    }

    fileprivate func signIntoFirebase() {
        
        guard let authenticationToken = AccessToken.current?.authenticationToken else {return}
        
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)

Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
 Service.dismissHud(self.hud, text: "Sign Up Error", detailText: error.localizedDescription, delay: 2)
            return
            }
    
    self.performSegue(withIdentifier: "homepageVC", sender: nil)
            print("Successfully logged into Firebase")
    self.hud.dismiss(animated: true)
    
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    
    //UITextFieldDelegate

    private func configureTextFields() {
        email.delegate = self
        password.delegate = self
        
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        return true
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("You typed : \(string)")

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    
    

override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func textFieldDidChange(_ target:UITextField) {
        
        signInPressed.isEnabled = false
        guard let email = email.text,
            
            email != "" else {
                
                print("textField 1 is empty")
                return
        }
        guard let password = password.text,
            
            password != "" else {
                
                print("textField 2 is empty")
                return
        }
        // set button to true whenever all textfield criteria is met.
        signInPressed.isEnabled = true
        
    }
    
    func signInPressed(enabled:Bool) {
        
        if enabled{
            
            signInPressed.alpha = 1.0
            signInPressed.isEnabled = true
            
        } else {
            signInPressed.alpha = 0.9
            signInPressed.isEnabled = false
        }
    }
    
    
    @IBAction func canclePressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)

    }
    
    
    var badParameters:Bool = true
    

    
    
    @IBAction func forgetPassword(_ sender: Any) {
        
        let forgetPswAlert = UIAlertController(title: "Forgot Password?", message: "Don't Worry. Reset your password here! ", preferredStyle: .alert)
        forgetPswAlert.addTextField {(textField) in
            
            textField.placeholder = "Enter your email address"
        }
        forgetPswAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(forgetPswAlert, animated: true, completion: nil)

            
        forgetPswAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            
           
            let resetEmail = forgetPswAlert.textFields?.first?.text
            
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil {
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error:\(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                } else {
                    
                    let resetFailedAlert = UIAlertController(title: "Reset Email Sent", message: " An email to reset your password has been sent succesfully. Please check email for further instructions", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert,animated: true, completion: nil )
                
        
                }
            })
        }))
    }
    
    
    @IBAction func signinPRESSED(_ sender: Any){
        
        validator.validate(self)

       
        guard email.text != nil else {return}
        guard password.text != nil else {return}
        
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            if user != nil {
                
                self.performSegue(withIdentifier: "homepageVC", sender: nil)
              
                
                
            } else {
            
                    
                let loginAlert = UIAlertController(title: "Login Error", message: "\(error!.localizedDescription) Please Try Agin", preferredStyle: .alert)
                loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(loginAlert, animated: true, completion: nil)
                print("User has Signed In")
                
                }
                        
            }
        }
    }

