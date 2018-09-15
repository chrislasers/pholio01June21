//
//  UpdateVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 9/1/18.
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

class UpdateVC: UIViewController, UITextFieldDelegate, ValidationDelegate {
    func validationSuccessful() {
        
        validator.registerField(username, errorLabel: usernameValid , rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters")])
        
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
    
    
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBOutlet weak var usernameValid: UILabel!
    
    
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
        
        
        usernameValid.isHidden = true
        
        
        dismissKeyboardWhenTouchOutside()
        
        
        signUpButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
        signUpButton(enabled: false)
        
        
        self.signUpButton.backgroundColor = UIColor.black
        
        signUpButton.setTitle("Continue", for: .normal)
        
        signUpButton.layer.borderWidth = 1
        
        signUpButton.layer.borderColor = UIColor.white.cgColor
        
        
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.layer.shadowColor = UIColor.white.cgColor
        signUpButton.layer.shadowRadius = 5
        signUpButton.layer.shadowOpacity = 0.3
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        
        
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin )
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEndOnExit )
        
        
        
        
        /////////////////////////////////////////////
        
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        
        
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin )
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        username.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
        
        
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
    }
    
    private func dismissKeyboardWhenTouchOutside() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getter: tapToChangePic)))
    }
    
    
    
    
    ////TextFIeldDelegates
    
    
    var didSetupWhiteTintColorForClearTextFieldButton = false
    var didsetupWhiteTintColorForClearTextFieldButton = false
    
    
    
    private func setupTintColorForTextFieldClearButtonIfNeeded() {
        // Do it once only
        if didSetupWhiteTintColorForClearTextFieldButton { return }
        
        guard let button = username.value(forKey: "_clearButton") as? UIButton else { return }
        guard let icon = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate) else { return }
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        didSetupWhiteTintColorForClearTextFieldButton = true
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTintColorForTextFieldClearButtonIfNeeded()
    }
    
    
    
    
    
    
    
    private func configureTextFields() {
        
        username.delegate = self
        
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
            username.becomeFirstResponder()
        default:
            username.resignFirstResponder()
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
        
        guard let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.6)  else {return }
        
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
                        print("No ProPic-Download URL")
                    }
                })
                print("Meta data of upload image \(String(describing: uploadMetaData))")
            }
            
            
        }
    }
    
    private func layoutProfile () {
        view.addSubview(profileImageView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                //An array of layout constraints
                profileImageView.widthAnchor.constraint(equalToConstant: 120),
                profileImageView.heightAnchor.constraint(equalToConstant: 120),
                profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                //Prevent "Safe Area" in iPhone X
                profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
                ])
        } else {
            // Fallback on earlier versions
        }
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.masksToBounds = true
        //Now user need to tap to the profile image => choose image
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(pressToChangePic(_:))))
    }
    
    private func layoutChangePicButton() {
        view.addSubview(tapToChangePic)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                //An array of layout constraints
                tapToChangePic.widthAnchor.constraint(equalToConstant: 165),
                tapToChangePic.heightAnchor.constraint(equalToConstant: 120),
                tapToChangePic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                //Prevent "Safe Area" in iPhone X
                tapToChangePic.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88)
                ])
        } else {
            // Fallback on earlier versions
        }
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
        
        
        guard let username = username.text else {return}
        
        guard let image = UIImageJPEGRepresentation(self.profileImageView.image!, 0.6)  else { return }
        guard let img = UIImage(named: "profile") else {return}
        
        
        
        
        
        
        if self.profileImageView?.image != img  { //Now check if the img has changed or not:
            
            
            self.uploadProfileImage(imageData: image) // upload image from here
            
            
            self.performSegue(withIdentifier: "toGallery", sender: self)
            
            
            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).setValue(["Username": self.username.text!])
            
            
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { error in
                
                if error == nil {
                    
                    print("User display changed")
                    
                } else {
                    
                    let loginAlert = UIAlertController(title: "Login Error", message: " Please Provide Valid Username", preferredStyle: .alert)
                    loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(loginAlert, animated: true, completion: nil)
                    
                }
                
            }
            
        } else {
            
            let loginAlert = UIAlertController(title: "Login Error", message: " Please Add Profile Picture", preferredStyle: .alert)
            loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(loginAlert, animated: true, completion: nil)
        }
    }
}


extension UpdateVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
