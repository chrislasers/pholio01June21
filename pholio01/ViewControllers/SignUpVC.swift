//
//  SignUpVC.swift
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
import SwiftValidator
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore
import LBTAComponents
import JGProgressHUD
import Photos
import FirebaseFirestore

class SignUpVC: UIViewController, UITextFieldDelegate, ValidationDelegate {
    func validationSuccessful() {
        
    
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters")])
        
        print("Validation Success!")
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            
            print("Validation Error!")

            
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 0.2
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
    

    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    @IBOutlet weak var emailValid: UILabel!
    
    @IBOutlet weak var passwordValid: UILabel!
    
    
    @IBOutlet weak var fbValid: UILabel!
    
    
    @IBOutlet var orBTN: UILabel!
    
    var imagePicker:UIImagePickerController!
    var selectedImage: UIImage!
    let validator = Validator()
    var ref: DatabaseReference!
    
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    
    let metaData = StorageMetadata()

    
    override func viewDidLoad() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed In")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
        }
        
        
        var signInWithFbButton: UIButton {
            
            // Add a custom login button to your app
            let myLoginButton = UIButton(type: .custom)
            myLoginButton.backgroundColor = UIColor(r: 73, g: 103, b: 173)
            myLoginButton.frame = CGRect(x: 50, y: 465, width: view.frame.width - 105, height: 47)
            myLoginButton.setTitle("Login with Facebook", for: .normal)
            myLoginButton.setTitleColor(UIColor.white, for: .normal)
            myLoginButton.layer.cornerRadius = 7
            
            myLoginButton.setImage(#imageLiteral(resourceName: "flogo_RGB_HEX-144").withRenderingMode(.automatic), for: .normal)
            myLoginButton.tintColor = .white
            myLoginButton.contentMode = .scaleAspectFill
            
            
            myLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize:  18)
            myLoginButton.layer.masksToBounds = true
            // Handle clicks on the button
            myLoginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
            return myLoginButton
        }
        // Add the button to the view
        view.addSubview(signInWithFbButton)
        
        
        
        password.keyboardType = .default
        //password.placeholder = "Password"
        
        
        email.keyboardType = .emailAddress
        //email.placeholder = "Email Address"
        
        super.viewDidLoad()
        
        fbValid.isHidden = true

        
        
        self.signUpButton.backgroundColor = UIColor.orange
        signUpButton.setTitle("Continue", for: .normal)
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.orange.cgColor
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowRadius = 5
        signUpButton.layer.shadowOpacity = 0.3
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

    
        
        configureTextFields()
        ref = Database.database().reference()
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.2
                
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
        

        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters long or more.")])
        
        
        
        emailValid.isHidden = true
        passwordValid.isHidden = true
        
        
       
        signUpButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
        signUpButton(enabled: false)
        
        
        
        
        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
     
        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )

        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )
        
        
       /////////////////////////////////////////////
        
       
        
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
     
        
       
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
    
        //////////////Listens For Keyboard Events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -160
        } else {
            
            view.frame.origin.y = 0
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        email.becomeFirstResponder
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        email.resignFirstResponder()
        password.resignFirstResponder()
            }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // sender object is an instance of UITouch in this case
        let touch = sender as! UITouch
        
        // Access the circleOrigin property and assign preferred CGPoint
        (segue as! OHCircleSegue).circleOrigin = touch.location(in: view)
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
                
                
                self.performSegue(withIdentifier: "toEditProfile", sender: nil)
                
                
                
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
            
            self.performSegue(withIdentifier: "toEditProfile", sender: nil)
            print("Successfully logged into Firebase")
            self.hud.dismiss(animated: true)
            
        }
    }


   
    
    
    ////TextFIeldDelegates
    
    
    var didSetupWhiteTintColorForClearTextFieldButton = false
    var didsetupWhiteTintColorForClearTextFieldButton = false
    
    
    
    private func setupTintColorForTextFieldClearButtonIfNeeded() {
        // Do it once only
        if didSetupWhiteTintColorForClearTextFieldButton { return }
        
        guard let button = email.value(forKey: "_clearButton") as? UIButton else { return }
        guard let icon = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate) else { return }
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        didSetupWhiteTintColorForClearTextFieldButton = true
    }
    
    private func setUpTintColorForTextFieldClearButtonIfNeeded() {
        // Do it once only
        if didsetupWhiteTintColorForClearTextFieldButton { return }
        
        guard let button = password.value(forKey: "_clearButton") as? UIButton else { return }
        guard let icon = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate) else { return }
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        didSetupWhiteTintColorForClearTextFieldButton = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTintColorForTextFieldClearButtonIfNeeded()
        setUpTintColorForTextFieldClearButtonIfNeeded()
    }
    
   
    
    
    private func configureTextFields() {
        
        email.delegate = self
        password.delegate = self
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true}
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("You typed : \(string)")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case email:
            password.becomeFirstResponder()
        default:
            password.resignFirstResponder()
        }
        return true
    }
    
    
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            
            return true
        }
    
        
    private func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            return
        }
    
    //////////////////////////////////////////////
    
    
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
    ////////////////////////////////////////////////////////
    
     @objc func textFieldDidChange(_ target:UITextField) {
        
     signUpButton.isEnabled = false
        
      
        guard let email = email.text,
            
            email != "" else {
            print("TEXTFIELD 3 is empty")
            return
        }
        guard let password = password.text,
            
            password != "" else {
            print("TEXTFIELD 4 is empty")
            return
        }
        // set button to true whenever all textfield criteria is met.
        signUpButton.isEnabled = true

    }
    
    
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        
        signUpButton.isEnabled = false
        
        
     
        guard let email = email.text,
            
            email != "" else {
                
                
                print("textField 3 is empty")
                return
        }
        guard let password = password.text,
            
            password != "" else {
                

                print("textField 4 is empty")
                return
        }
        // set button to true whenever all textfield criteria is met.
        signUpButton.isEnabled = true
        
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signinvc = storyboard.instantiateViewController(withIdentifier: "signinvc")
        
        self.present(signinvc, animated: true, completion: nil)    }
    
    func signUpButton(enabled:Bool) {
        
        if enabled{
            

            signUpButton.alpha = 1.0
            signUpButton.isEnabled = true
            
        } else {
            signUpButton.alpha = 0.9
            signUpButton.isEnabled = false
        }
    }
   

   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    

    
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        validator.validate(self)
        
        
        guard let email = email.text, let password = password.text else {return}
       
        Auth.auth().fetchProviders(forEmail: self.email.text!, completion: {
            (providers, error) in
            
            if let error = error {
                print(error.localizedDescription)
                print("Email Address Already In Use")
            } else if let providers = providers {
                print(providers)
            }
        })

   
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                
                let emailNotSentAlert = UIAlertController(title: "Email Verification", message: "Email failed to send: \(String(describing: error?.localizedDescription) as Any)", preferredStyle: .alert)
                  emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   self.present(emailNotSentAlert, animated: true, completion: nil)
                
                return
                }
            else
                {
                    self.performSegue(withIdentifier: "toEditProfile", sender: self)
                
            }
        }
    }
}
