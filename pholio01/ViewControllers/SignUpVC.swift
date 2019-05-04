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
import FacebookShare
import LBTAComponents
import JGProgressHUD
import Photos
import FirebaseFirestore
import Pastel
import InstagramLogin



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
    
    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /* The user Firebase reference */
    let USER_REF = Database.database().reference().child("users")
    
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser?.uid
        return USER_REF.child(id!)
    }
    
    /** The Firebase reference to the current user's friend tree */
    var CURRENT_USER_FRIENDS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    /** The Firebase reference to the current user's friend request tree */
    var CURRENT_USER_REQUESTS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("requests")
    }
    
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = Auth.auth().currentUser!.uid
        return id
    }

    
    override func viewDidLoad() {
        
        
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
            myLoginButton.frame = CGRect(x: 50, y: 470, width: view.frame.width - 105, height: 47)
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
            
            
            
            _ = UIDevice().type.rawValue
            
            switch UIDevice().type {
                
            case .iPhone5,.iPhone5S, .iPhoneSE:
                
                myLoginButton.frame = CGRect(x: 40, y: 450, width: 253, height: 47)
            
                
            default:break
            }
            
            
            return myLoginButton
        }
        // Add the button to the view
        view.addSubview(signInWithFbButton)
        
        
        let tf = CustomTextField(padding: 24, height: 44)
        
        tf.layer.cornerRadius =  tf.height / 2
        
        tf.placeholder = "Enter Username"
        tf.backgroundColor = .white
        
        password.keyboardType = .default
        password.placeholder = "Enter Password"
        
        
        email.keyboardType = .emailAddress
        email.placeholder = "Enter Email "
        
        super.viewDidLoad()
        
        fbValid.isHidden = true
        
        signUpButton.backgroundColor = UIColor.orange
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        signUpButton.layer.borderWidth = 1.5
        signUpButton.layer.cornerRadius = 4
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        signUpButton.layer.shadowOpacity = 0.5
        signUpButton.layer.shadowOffset = CGSize(width: 1, height: 1)


     
       
        
        
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
        
        let pastelView = PastelView(frame: view.bounds)
        
        //MARK: -  Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        //MARK: -  Custom Duration
        
        pastelView.animationDuration = 3.75

        //MARK: -  Custom Color
        pastelView.setColors([
            
            
            // UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
            
            // UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
            
            UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1.0),
            
            
            UIColor(red: 0/255, green: 0/255, blue: 100/255, alpha: 1.0)])
        
        
        // UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0)])
        
        
        //   UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
        
        
        //  UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 1)
        
        
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
    
    
    @objc func fbButtonPressed() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signinvc = storyboard.instantiateViewController(withIdentifier: "signinvc")
        
        self.present(signinvc, animated: true, completion: nil)
        
        print("Bar Button Pressed")
    }
    
    
    //FACEBOOK INTEGRATION
    
    @objc func loginButtonClicked() {
        
        hud.textLabel.text =  "Logging in with Facebook..."
        hud.show(in: view, animated: true)
        
        let loginManager = LoginManager()
        
        
        
         //   loginManager.loginBehavior = .web
        
        
        if let currentAccessToken = FBSDKAccessToken.current(), currentAccessToken.appID != FBSDKSettings.appID()
        {
            loginManager.logOut()
        }
        
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
            
            self.getFacebookData()
            

            
            self.performSegue(withIdentifier: "toEditProfile", sender: nil)
            print("Successfully logged into Firebase")
            self.hud.dismiss(animated: true)
            
        }
    }

    private func getFacebookData() {
        
  
        let params: [String:String] = ["fields": "email, id"]
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            
            if error == nil {
                if let facebookData = result as? NSDictionary {
                    if let publicProfile = facebookData.value(forKey: FacebookPermission.PublicProfile) as? NSDictionary {
                        print("fb public profile: \(publicProfile)")
                    }
                    
                    if let email = facebookData.value(forKey: FacebookPermission.Email) as? String {
                        
                        var userInfo = [String: AnyObject]()
                        userInfo = ["email": email as AnyObject]
                        self.CURRENT_USER_REF.setValue(userInfo)
                        print("fb email: \(email)")
                    }
                    
                    if let userPhotos = facebookData.value(forKey: FacebookPermission.UserPhotos) as? NSDictionary {
                        print("fb photos: \(userPhotos)")
                    }
                }
                
                
                if let values: [String:AnyObject] = result as? [String : AnyObject] {
                
                // update our databse by using the child database reference above called usersReference
                    

                    self.CURRENT_USER_REF.setValue(values, withCompletionBlock: { (err, ref) in
                    // if there's an error in saving to our firebase database
                    if err != nil {
                        print(err!)
                        return
                    }
                    // no error, so it means we've saved the user into our firebase database successfully
                    print("Save the user successfully into Firebase database")
                })
            }
            }
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
    
    func presentSignupAlertView() {
        let alertController = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentLoginAlertView() {
        let alertController = UIAlertController(title: "Error", message: "Email/password is incorrect", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func postToken(Token: [String : AnyObject]){
        
        print("FCM Token: \(Token)")
        
       
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("fcmToken").child(Messaging.messaging().fcmToken!).updateChildValues(Token)
        
       // self.ref.child("Users").child(self.userID!).setValue(["tokenid":Token])
        
    }
    
    
    
   
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        validator.validate(self)
        
        let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        

        
        
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
        
        
        FriendSystem.system.createAccount(email, password: password) { (success) in
            if success {
                self.performSegue(withIdentifier: "toEditProfile", sender: self)
                //print(self.userID!)
                
                self.postToken(Token: token)
                

                // let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //let signinvc = storyboard.instantiateViewController(withIdentifier: "Home")
                
                // self.present(signinvc, animated: true, completion: nil)
                print("User has Signed In")
            } else {
                // Error
                self.presentSignupAlertView()
            }
        }
    }
    }

struct FacebookPermission
{
    static let Email: String = "email"
    static let UserPhotos: String = "user_photos"
    static let PublicProfile: String = "public_profile"
}



