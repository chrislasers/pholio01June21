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
import Photos
import FirebaseFirestore

class SignUpVC: UIViewController, UITextFieldDelegate, ValidationDelegate {
    func validationSuccessful() {
        
        validator.registerField(username, errorLabel: usernameValid , rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters")])
        
        
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters")])
        
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

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBOutlet weak var usernameValid: UILabel!
    
    @IBOutlet weak var emailValid: UILabel!
    
    @IBOutlet weak var passwordValid: UILabel!
    
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tapToChangePic: UIButton!
    
    var imagePicker:UIImagePickerController!
    var selectedImage: UIImage!
    let validator = Validator()
    var ref: DatabaseReference!
    
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    
    let metaData = StorageMetadata()

    
    override func viewDidLoad() {
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
        username.keyboardType = .default
        username.placeholder = "Username"
        
        password.keyboardType = .default
        password.placeholder = "Password"
        
        
        email.keyboardType = .emailAddress
        email.placeholder = "Email Address"
        
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        checkPermission()
        
        layoutProfile()
        layoutChangePicButton()
       
        
        configureTextFields()
        ref = Database.database().reference()
        
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
        validator.registerField(username, errorLabel: usernameValid , rules: [RequiredRule(), PasswordRule()])

        
        validator.registerField(email, errorLabel: emailValid, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        

        validator.registerField(password, errorLabel: passwordValid, rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters long or more.")])
        
        
        
        usernameValid.isHidden = true
        emailValid.isHidden = true
        passwordValid.isHidden = true
        
         dismissKeyboardWhenTouchOutside()
        
       
        signUpButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
        signUpButton(enabled: false)
        
        
        
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin )
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )

        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )

        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )
        
        
       /////////////////////////////////////////////
        
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
     
        
        
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin )
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        password.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
    
        //////////////Listens For Keyboard Events
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
            view.frame.origin.y = -160
        } else {
            
            view.frame.origin.y = 0
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        username.becomeFirstResponder
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        username.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
            }

    private func dismissKeyboardWhenTouchOutside() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getter: tapToChangePic)))
    }
    
    
    ////TextFIeldDelegates
    
    private func configureTextFields() {
        
        username.delegate = self
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
        case username:
            email.becomeFirstResponder()
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
    
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
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
        
        guard let username = username.text,
            
            username != "" else {
            print("TEXTFIELD 2 is empty")
            return
        }
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
      
        guard let username = username.text,
            
            username != "" else {
                print("textField 2 is empty")
                return
        }
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
        dismiss(animated: true, completion: nil)
    }
    
    func signUpButton(enabled:Bool) {
        
        if enabled{
            
            signUpButton.alpha = 1.0
            signUpButton.isEnabled = true
            
        } else {
            signUpButton.alpha = 0.9
            signUpButton.isEnabled = false
        }
    }
   
    //Profile Picture Editing

    @IBAction func pressToChangePic(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    
    func uploadProfileImage(imageData: Data) {
        
        
        let storageReference = Storage.storage().reference()
        
        let profileImageRef = storageReference.child("UserPro-Pics").child((Auth.auth().currentUser?.uid)!)
        
        let userReference = self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("UserPro-Pic")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadMetaData, error) in
            
            if error != nil {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return } else {
                
                
                profileImageRef.downloadURL(completion: { (metadata, error) in
                    if let downloadUrl = metadata {
                        // Make you download string
                        let profileImageURL = downloadUrl.absoluteString
                        userReference.setValue(["profileImageURL": profileImageURL])
                        print(profileImageURL)
                    } else {
                        // Do something if error
                        print("No ProPic-Download URL")
                    }
                })
                print("Meta data of upload image \(String(describing: uploadMetaData))")
            }
            

    }
    }

    private func layoutProfile () {
        view.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            //An array of layout constraints
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //Prevent "Safe Area" in iPhone X
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.masksToBounds = true
        //Now user need to tap to the profile image => choose image
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(pressToChangePic(_:))))
    }
    
    private func layoutChangePicButton() {
        view.addSubview(tapToChangePic)
        NSLayoutConstraint.activate([
            //An array of layout constraints
            tapToChangePic.widthAnchor.constraint(equalToConstant: 165),
            tapToChangePic.heightAnchor.constraint(equalToConstant: 120),
            tapToChangePic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //Prevent "Safe Area" in iPhone X
            tapToChangePic.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88)
            ])
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        validator.validate(self)
        
        
        guard let email = email.text, let password = password.text , let username = username.text else {return}
        
        
        guard  UIImageJPEGRepresentation(self.profileImageView.image!, 0.6) != nil else { return }

   
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
                }
                
            else
            
            {
                

                let optimizedImageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.6)
                
                // upload image from here

                self.uploadProfileImage(imageData: optimizedImageData!)
                
 self.performSegue(withIdentifier: "toEditProfile", sender: self)
                self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).childByAutoId().setValue(["Username": self.username.text])
            
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
            changeRequest?.commitChanges {error in
                
                if error == nil {
                    
                    print("User display changed")
                    
                }

            }
Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    
                    if error != nil {
                        
                        let emailNotSentAlert = UIAlertController(title: "Email Verification", message: "Verification failed to send: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                        emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(emailNotSentAlert, animated: true, completion: nil)
                        
                        print("Email Not Sent")
                    }
                        
                    else {
                        
                        let emailSentAlert = UIAlertController(title: "Email Verification", message: "Verification email has been sent. Please tap on the link in the email to verify your account before you can use the features assoicited within the app", preferredStyle: .alert)
                        emailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(emailSentAlert, animated: true, completion: nil)
                        
                        print("Email Sent")
                    }
                })
            
            }
            }
        }
    }




extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
            
        })
    } else {
        
        if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            
              picker.dismiss(animated: true, completion:nil)
            
            profileImageView.image = profileImage
        }
           
        }
      
    
      
    }
}
