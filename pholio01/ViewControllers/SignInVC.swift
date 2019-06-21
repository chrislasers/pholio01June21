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

public enum Model : String {
    case simulator     = "simulator/sandbox",
    //iPod
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    //iPad
    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPad5              = "iPad 5", //aka iPad 2017
    iPad6              = "iPad 6", //aka iPad 2018
    //iPad mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    //iPad pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    //iPhone
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}



class SignInVC: UIViewController, UITextFieldDelegate, MessagingDelegate, ValidationDelegate, CLLocationManagerDelegate, UICircularProgressRingDelegate {
    
    
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
    
    
    
    
    var ref : DatabaseReference!

    let userID = Auth.auth().currentUser?.uid

    let validator = Validator()
    
    let Model: String = "Model"

    
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBOutlet weak var signInPressed: UIButton!
    
    
    @IBOutlet weak var emailValid: UILabel!
    
    @IBOutlet weak var passwordValid: UILabel!
    
    @IBOutlet weak var fbValid: UILabel!
    
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var signIn: UIButton!
    
    @IBOutlet var forgetPassword: UIButton!
    
    @IBOutlet var newLogo: UIImageView!
    
    
    @IBOutlet var Logo: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        
        ref = Database.database().reference()
        
        var signInWithFbButton: UIButton {
            
            // Add a custom login button to your app
            let myLoginButton = UIButton(type: .custom)
            myLoginButton.backgroundColor = UIColor(r: 73, g: 103, b: 173)
            myLoginButton.frame = CGRect(x: 50, y: 520, width: view.frame.width - 105, height: 47)
            myLoginButton.setTitle("Login with Facebook", for: .normal)
            myLoginButton.setTitleColor(UIColor.white, for: .normal)
            myLoginButton.layer.cornerRadius = 7
            
             myLoginButton.layer.borderColor = UIColor.white.cgColor
            
            myLoginButton.layer.borderWidth = 1.0

            
            
            myLoginButton.setImage(#imageLiteral(resourceName: "flogo_RGB_HEX-144").withRenderingMode(.automatic), for: .normal)
            myLoginButton.tintColor = .white
            myLoginButton.contentMode = .scaleAspectFill
            
            
            myLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize:  16)
            myLoginButton.layer.masksToBounds = true
            // Handle clicks on the button
            myLoginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
            
            _ = UIDevice().type.rawValue
            
            switch UIDevice().type {
                
                
            case .iPhoneSE:
                
                 myLoginButton.frame = CGRect(x: 40, y: 510, width: 253, height: 47)
                
                
            case .iPhone5S:
                
                myLoginButton.frame = CGRect(x: 40, y: 510, width: 253, height: 47)
                
            case .iPhone6, .iPhone7, .iPhone6S,.iPhone8:
                
                myLoginButton.frame = CGRect(x: 50, y: 605, width: view.frame.width - 105, height: 47)
                
            case .iPhone6plus:
                
                myLoginButton.frame = CGRect(x: 50, y: 610, width: view.frame.width - 105, height: 47)

                
            case .iPhone6Splus:
                
                myLoginButton.frame = CGRect(x: 50, y: 610, width: view.frame.width - 100, height: 47)
                
            case .iPhone7plus:
                
                myLoginButton.frame = CGRect(x: 50, y: 615, width: view.frame.width - 105, height: 47)
                
            case .iPhone8plus:
                
                myLoginButton.frame = CGRect(x: 50, y: 610, width: view.frame.width - 98, height: 47)
                
            case .iPhoneX, .simulator:
                myLoginButton.frame = CGRect(x: 50, y: 650, width: view.frame.width - 105, height: 47)
                
            case .iPhoneXS, .iPhoneXR:
                
                myLoginButton.frame = CGRect(x: 50, y: 685, width: view.frame.width - 98, height: 47)
                
                
            case .iPhoneXSMax:
                
                myLoginButton.frame = CGRect(x: 50, y: 660, width: view.frame.width - 100, height: 47)
                
                
            default:break
            }

        
            return myLoginButton
        }
        // Add the button to the view
        view.addSubview(signInWithFbButton)
        
        switch UIDevice().type {
            
            
        case .iPhoneSE:
            
        
        newLogo.frame = CGRect(x: 115, y: 97, width: 100, height: 100)
        
        Logo.frame = CGRect(x: 83, y: 64, width: 165, height: 165)
            
        case .iPhone5S:
          
            
            /////////////////////////////////////
            
            newLogo.frame = CGRect(x: 115, y: 97, width: 100, height: 100)
            
            Logo.frame = CGRect(x: 83, y: 64, width: 165, height: 165)
            
         
            
        case .iPhone7plus:
            
            newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
        
        Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
        
        // Create the view
        let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 57, width: 225, height: 225))
        // Change any of the properties you'd like
        
        
        progressRing.outerRingColor = UIColor.orange
        progressRing.outerRingWidth = 3.0
        progressRing.shouldShowValueText = false
        progressRing.gradientColors = [UIColor.orange]
        //progressRing.minValue = 0
        //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
        // progressRing.valueKnobShadowColor = UIColor.orange
        
        
        progressRing.startProgress(to: 0, duration: 0.0) {
            print("Done animating!")
            
            progressRing.startProgress(to: 100, duration: 0.75)        }
        
        self.view.addSubview(progressRing)
            
        case .iPhone8plus:
            
            newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
        
        Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
        
    
            
            
        case .iPhoneXR:

        newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
        
        Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
            
            
        case .iPhoneXS:
            
            newLogo.frame = CGRect(x: 102, y: 113, width: 170, height: 170)
            
            Logo.frame = CGRect(x: 69, y: 81, width: 235, height: 235)
        
        case .iPhoneXSMax:
            
            newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
            
            Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
            
    
        default:break
        }
        
    
        email.keyboardType = .emailAddress
        //email.placeholder = "Email Address"
        self.view.addSubview(email)
        
        // password.placeholder = "Password"
        self.view.addSubview(password)

        
          self.Logo.layer.cornerRadius = self.Logo.frame.size.height / 2
        
         self.Logo.layer.shadowColor = UIColor.black.cgColor
         self.Logo.layer.shadowRadius = 2.5
         self.Logo.layer.shadowOpacity = 1.0
         self.Logo.layer.shadowOffset = CGSize(width: 1.25, height: 1.25)
        
        
        
        
        signUp.backgroundColor = UIColor.orange
        signUp.setTitle("Sign Up", for: .normal)
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        signUp.layer.borderWidth = 1.5
        signUp.layer.cornerRadius = 4
        signUp.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
       // signUp.layer.shadowRadius = 5
        signUp.layer.shadowOpacity = 0.4
        signUp.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
        signIn.backgroundColor = UIColor.clear
        
        signIn.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
        signIn.layer.borderWidth = 1.5
        signIn.layer.cornerRadius = 4

        signIn.setTitleColor(UIColor.white, for: .normal)
        //signIn.layer.shadowColor = UIColor.white.cgColor
        //signIn.layer.shadowRadius = 12
        signIn.layer.shadowOpacity = 0.4
        signIn.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
        signUp.addTarget(self, action: #selector(setButtonSelected(button:)), for: .touchDown);
        signUp.addTarget(self, action: #selector(setButtonUnselected(button:)), for: .touchUpInside)
        
        configureTextFields()
        
        
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
        
        
        
        
        
        
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid Email")])
        
        
        
        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Invalid Password")])
        
        
        
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
            view.frame.origin.y = -157
        } else {
            
            view.frame.origin.y = 0
            
        }
    }
    
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
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        
        let tf = CustomTextField(padding: 24, height: 44)
        
        tf.layer.cornerRadius =  tf.height / 2
        //tf.placeholder = "Enter Username"
        tf.backgroundColor = .white
        
        email.keyboardType = .emailAddress
        email.placeholder = "Email"
        
        let password: CustomTextField = {
            let tf = CustomTextField(padding: 24, height: 44)
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
            tf.backgroundColor = .white
            return tf
        }()
        

        
        switch UIDevice().type {
            
            
        
            
            
            
            
        case .iPhone5S:
            
            email.frame = CGRect(x: 51, y: 250, width: 220, height: 45)
            
            password.frame = CGRect(x: 238, y: 383, width: 33, height: 16)
            
            
            emailValid.frame = CGRect(x: 238, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 238, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 220, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 220, height: 45)
            
        case .iPhoneX:
            
            
            email.frame = CGRect(x: 51, y: 330, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 407, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 383, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 238, y: 4462, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 519, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 570, width: 275, height: 45)
           
            
        default: break

    }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTintColorForTextFieldClearButtonIfNeeded()
        setUpTintColorForTextFieldClearButtonIfNeeded()
        
        
        switch UIDevice().type {
            
            
        case .iPhoneSE:
            
            
            email.frame = CGRect(x: 42, y: 241, width: 250, height: 45)
            
            password.frame = CGRect(x: 42, y: 318, width: 250, height: 45)
            
            
            emailValid.frame = CGRect(x: 305, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 305, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 115, y: 365, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 42, y: 410, width: 250, height: 45)
            
            signUp.frame = CGRect(x: 42, y: 460, width: 250, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y:55, width: 180, height: 180))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)

            
            
        case .iPhone5S:
            
            email.frame = CGRect(x: 42, y: 241, width: 250, height: 45)
            
            password.frame = CGRect(x: 42, y: 318, width: 250, height: 45)
            
            
            emailValid.frame = CGRect(x: 305, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 305, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 115, y: 365, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 42, y: 410, width: 250, height: 45)
            
            signUp.frame = CGRect(x: 42, y: 460, width: 250, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y:55, width: 180, height: 180))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
        case .iPhone6:
            
            email.frame = CGRect(x: 51, y: 306, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 293, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 275, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y: 57, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
        case .iPhone6plus:
            
            email.frame = CGRect(x: 51, y: 306, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 440, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 314, height: 45)
            
            newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
            
            Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 57, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
            
            
        case .iPhone6S:
            
            email.frame = CGRect(x: 51, y: 306, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 293, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 275, height: 45)
            
            
            newLogo.frame = CGRect(x: 112, y: 97, width: 145, height: 145)
            
            Logo.frame = CGRect(x: 80, y: 64, width: 210, height: 210)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y:55, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
         case .iPhone6Splus:
            
            email.frame = CGRect(x: 51, y: 306, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 440, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 314, height: 45)
            
            newLogo.frame = CGRect(x: 127, y: 97, width: 145, height: 145)
            
            Logo.frame = CGRect(x: 95, y: 64, width: 210, height: 210)
            
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 87, y:55, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
            
        case .iPhone7:
            
            email.frame = CGRect(x: 51, y: 306, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 293, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 275, height: 45)
            
            
            newLogo.frame = CGRect(x: 112, y: 97, width: 145, height: 145)
            
            Logo.frame = CGRect(x: 80, y: 64, width: 210, height: 210)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 72, y: 53, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
        
        case .iPhone7plus:
            
            
            email.frame = CGRect(x: 51, y: 306, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 440, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 314, height: 45)
            
        newLogo.frame = CGRect(x: 136, y: 97, width: 145, height: 145)
    
        Logo.frame = CGRect(x: 103, y: 64, width: 210, height: 210)
        
        // Create the view
        let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 57, width: 225, height: 225))
        // Change any of the properties you'd like
        
        
        progressRing.outerRingColor = UIColor.orange
        progressRing.outerRingWidth = 3.0
        progressRing.shouldShowValueText = false
        progressRing.gradientColors = [UIColor.orange]
        //progressRing.minValue = 0
        //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
        // progressRing.valueKnobShadowColor = UIColor.orange
        
        
        progressRing.startProgress(to: 0, duration: 0.0) {
            print("Done animating!")
            
            progressRing.startProgress(to: 100, duration: 0.75)        }
        
        self.view.addSubview(progressRing)
            
            
        case .iPhone8:
            
            email.frame = CGRect(x: 51, y: 306, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 293, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 446, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 275, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y: 57, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
            
        case .iPhone8plus:
            
            email.frame = CGRect(x: 51, y: 306, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 383, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 359, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 440, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 495, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 548, width: 314, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 57, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
        case .iPhoneX:
            
            
            email.frame = CGRect(x: 51, y: 330, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 407, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 383, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 238, y: 436, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 450, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 519, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 570, width: 275, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 75, y: 55, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
            
         
            
        case .iPhoneXS:
            
            
            
            email.frame = CGRect(x: 51, y: 380, width: 275, height: 45)
            
            password.frame = CGRect(x: 51, y: 457, width: 275, height: 45)
            
            
            emailValid.frame = CGRect(x: 293, y: 433, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 293, y: 510, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 133, y: 520, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 568, width: 275, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 622, width: 275, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 61, y: 72, width: 250, height: 250))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
        case .iPhoneXR:
            
            
            email.frame = CGRect(x: 51, y: 330, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 407, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 383, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 460, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 460, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 519, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 572, width: 314, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 57, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 1.5
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
        case .iPhoneXSMax:
            
            
            email.frame = CGRect(x: 51, y: 330, width: 314, height: 45)
            
            password.frame = CGRect(x: 51, y: 407, width: 314, height: 45)
            
            
            emailValid.frame = CGRect(x: 332, y: 383, width: 33, height: 16)
            
            passwordValid.frame = CGRect(x: 332, y: 460, width: 33, height: 16)
            
            
            forgetPassword.frame = CGRect(x: 155, y: 460, width: 108, height: 27)
            
            
            signIn.frame = CGRect(x: 51, y: 519, width: 314, height: 45)
            
            signUp.frame = CGRect(x: 51, y: 572, width: 314, height: 45)
            
            // Create the view
            let progressRing = UICircularProgressRing(frame: CGRect(x: 95, y: 55, width: 225, height: 225))
            // Change any of the properties you'd like
            
            
            progressRing.outerRingColor = UIColor.orange
            progressRing.outerRingWidth = 3.0
            progressRing.shouldShowValueText = false
            progressRing.gradientColors = [UIColor.orange]
            //progressRing.minValue = 0
            //progressRing.ringStyle = UICircularProgressRingStyle(rawValue: 3)!
            // progressRing.valueKnobShadowColor = UIColor.orange
            
            
            progressRing.startProgress(to: 0, duration: 0.0) {
                print("Done animating!")
                
                progressRing.startProgress(to: 100, duration: 0.75)        }
            
            self.view.addSubview(progressRing)
            
            
        default: break
            
           
            
        }
        
        
      
        
        
        
    }
    
    
    @objc func setButtonSelected(button : UIButton) {
        
        signUp.backgroundColor = UIColor.orange
        
        signUp.setTitle("Sign Up", for: .normal)
        signUp.setTitleColor(UIColor.white, for: .normal)

        
        //signUp.layer.borderWidth = 1.6
        
        //signUp.layer.borderColor = UIColor.white.cgColor
        
        
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        signUp.layer.borderWidth = 1.5
        signUp.layer.cornerRadius = 4
        
        
        //signUp.layer.cornerRadius = signUp.frame.height / 2
        signUp.layer.shadowColor = UIColor.white.cgColor
        signUp.layer.shadowRadius = 2
        signUp.layer.shadowOpacity = 0.2
        signUp.layer.shadowOffset = CGSize(width: 0, height: 0)    }
    
    @objc func setButtonUnselected(button : UIButton) {
        
        signUp.setTitle("Sign Up", for: .normal)
        
        signUp.backgroundColor = UIColor.orange
        
       // signUp.layer.borderWidth = 1.6
        
       // signUp.layer.borderColor = UIColor.white.cgColor
        
       // signUp.layer.cornerRadius = signUp.frame.height / 2
        
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        signUp.layer.borderWidth = 1.5
        signUp.layer.cornerRadius = 4
        
        signUp.setTitleColor(UIColor.white, for: .normal)
        signUp.layer.shadowColor = UIColor.white.cgColor
        signUp.layer.shadowRadius = 2
        signUp.layer.shadowOpacity = 0.2
        signUp.layer.shadowOffset = CGSize(width: 0, height: 0)    }
    
    
  
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        
        //ref = Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("finished")


  

            
            DispatchQueue.main.async {
                
        if Auth.auth().currentUser != nil {
            
            
            
           DBService.shared.users.child(Auth.auth().currentUser!.uid).child("Yes").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
            if snapshot.exists(){

                    
                   print("User Signed In")
                   self.performSegue(withIdentifier: "homepageVC", sender: nil)
                    
               } else {
                   Auth.auth().currentUser?.delete(completion: nil)
                    print("User Didn't Complete Sign In")

                }
            
                        })
                    }
                }

        
        email.resignFirstResponder()
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        
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
        view.insertSubview(pastelView, at: 3)
        
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
                
                
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)
                
                
                
                self.signIntoFirebase()
                
            case .failed(let error):
                Service.dismissHud(self.hud, text: "Error", detailText: "Canceled getting Facebook user: \(error)", delay: 1)
            case .cancelled:
                Service.dismissHud(self.hud, text: "Error", detailText: "Canceled getting Facebook user", delay: 1)
                break
            }
        }
    }
    
    fileprivate func signIntoFirebase() {
        
        guard let authenticationToken = AccessToken.current?.authenticationToken else {return}
        
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                Service.dismissHud(self.hud, text: "Sign Up Error", detailText: error.localizedDescription, delay: 1)
                return
            }
            

            self.performSegue(withIdentifier: "homepageVC", sender: nil)
            print("Successfully logged into Firebase")
            self.hud.dismiss(animated: true)
            
        }
    }
    
   override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
    
    
    
    ref = Database.database().reference()

    
     // if Auth.auth().currentUser != nil {
            
      //  DBService.shared.users.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                
        //       print(snapshot)
                
          //     if (snapshot.value as? [String: Any]) != nil {
           //        print("User Signed In")
            //        self.performSegue(withIdentifier: "homepageVC", sender: nil)
            //    } else {
            //       Auth.auth().currentUser?.delete(completion: nil)
           //    }
         //  })
            
       // } else {
        //    print("User Not Signed In")
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
    
    internal func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
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
        
        signInPressed.backgroundColor = UIColor.white
        
        signInPressed.setTitle("Sign In", for: .normal)
        signInPressed.setTitleColor(UIColor.blue, for: .normal)
        
        
       // signIn.backgroundColor = UIColor.white
        
    }
    
    func signInPressed(enabled:Bool) {
        
        if enabled{
            
    

            signInPressed.alpha = 1.0
            signInPressed.isEnabled = true
            
        } else {
            
            signInPressed.alpha = 0.5
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
    
    
    
    @IBAction func signUpPRESSED(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showSignUp", sender: nil)
        print("clicked")
        
        
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
        
        let dbRef = Database.database().reference()
        dbRef.child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token)
        
        
    }
    
    
    @IBAction func signinPRESSED(_ sender: Any){
        
       // let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        
        validator.validate(self)
        
        guard let email = email.text, let password = password.text else {return}
        
        
        FriendSystem.system.loginAccount(email, password: password) { (success) in
            if success {
                self.performSegue(withIdentifier: "homepageVC", sender: nil)
                
              //  self.postToken(Token: token)
                
                //print(self.userID!)
                
                
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

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            //iPad
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad6,11"  : .iPad5, //aka iPad 2017
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6, //aka iPad 2018
            "iPad7,6"   : .iPad6,
            //iPad mini
            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            //iPad pro
            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,4" : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,5" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            //AppleTV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
