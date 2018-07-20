//
//  EditProfile.swift
//  pholio01
//
//  Created by Chris  Ransom on 5/24/18.
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
import MapKit
import CoreLocation
import GeoFire

class EditProfile:UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, ValidationDelegate {
    func validationSuccessful() {
        
        validator.registerField(HourlyRate, errorLabel: hrLabel , rules: [RequiredRule(), PasswordRule(message: "Must be 6 characters")])
        
        
        validator.registerField(Age, errorLabel: ageLabel, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
       
        
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
    
    
    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var genderTapped: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var genderTV: UITableView!
    
    
    @IBOutlet weak var HourlyRate: UITextField!
    @IBOutlet weak var hrLabel: UILabel!
    
    
    @IBOutlet weak var Age: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    let validator = Validator()

    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    

    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    
    let userID = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!

    let list = ["Male", "Female"]
    
    

    

    override func viewDidLoad() {
        
        
        Age.keyboardType = .decimalPad

        Age.placeholder = "Age"
        
        HourlyRate.keyboardType = .decimalPad
        HourlyRate.placeholder = "Hourly Rate"
        
        
        super.viewDidLoad()
        
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
        validator.registerField(HourlyRate, errorLabel: hrLabel , rules: [RequiredRule(), FloatRule(message: "This must be a number with or without a decimal")])
        
        
        validator.registerField(Age, errorLabel: ageLabel, rules: [RequiredRule(), FloatRule(message: "This must be a number with or without a decimal")])
        
        
        signUpButton.addTarget(self, action: #selector(confirmBTN), for: .touchUpInside)
        
        signUpButton(enabled: false)
        
        configureTextFields()
        ref = Database.database().reference()

        
        
        
        hrLabel.isHidden = true
        ageLabel.isHidden = true
        
        genderTV.isHidden = true
        genderTV.delegate = self
        genderTV.dataSource = self
        
        map.isHidden = true
        map.showsUserLocation = true
        
        locationManager.delegate = self 
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startUpdatingLocation()
        
        geoFireRef = Database.database().reference()
        
        geoFire = GeoFire(firebaseRef: (geoFireRef?.child("user_locations"))!)
        
        ref = Database.database().reference()
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Pairing Successful")
                
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        Age.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        HourlyRate.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        Age.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin )
        Age.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        Age.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
        HourlyRate.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        HourlyRate.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        HourlyRate.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit )
        
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

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureTextFields() {
        
        Age.delegate = self
        HourlyRate.delegate = self
    }
   
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let spanz:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation,spanz)
        map.setRegion(region, animated: true)
        
        guard locations.last != nil else { return }
        geoFire?.setLocation(location, forKey: (Auth.auth().currentUser?.uid)!)
        
        
        print(location.coordinate)
        
        self.map.showsUserLocation = true
        
        geoFireRef?.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["Location": locationLabel.text!])
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
          if error != nil
            
          {

            print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
            return
            }
            else
          {
            if let place = placemark?[0] {
                
                if place.thoroughfare != nil {
                    
                   
                
               self.locationLabel.text = "\(place.thoroughfare!),\(place.country!)"
                    
                
                }
            }
            }
    }
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
        HourlyRate.becomeFirstResponder
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Age.resignFirstResponder()
        HourlyRate.resignFirstResponder()
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
        case Age:
            HourlyRate.becomeFirstResponder()
        case HourlyRate:
            Age.becomeFirstResponder()
        default:
            Age.resignFirstResponder()
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
    

    ////////////////////////////////////////////////////////
    
    @objc func textFieldDidChange(_ target:UITextField) {
        
        signUpButton.isEnabled = false
        
        guard let age = Age.text,
            
            age != "" else {
                print("Age is empty")
                return
        }
        guard let hourlyrate = HourlyRate.text,
            
            hourlyrate != "" else {
                
                
                print("Hourly Rate 3 is empty")
                return
        }
        // set button to true whenever all textfield criteria is met.
        signUpButton.isEnabled = true
        
    }
    
    
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        
        signUpButton.isEnabled = false
        
        guard let age = Age.text,
            
            age != "" else {
                print("Age is empty")
                return
        }
        guard let hourlyrate = HourlyRate.text,
            
            hourlyrate != "" else {
                
                
                print("Hourly Rate 3 is empty")
                return
        }
       
        // set button to true whenever all textfield criteria is met.
        signUpButton.isEnabled = true
        
    }
   
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            currentLocation = locationManager.location
            
            print(currentLocation.coordinate.longitude)
            print(currentLocation.coordinate.latitude)

            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
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
    
    
    
    @IBAction func gender(_ sender: Any) {
        if genderTV.isHidden {
            
            animate(toggle: true, type: genderTapped)
        }
     else {
            animate(toggle: false, type: genderTapped)
    }
        }


    func animate(toggle: Bool, type: UIButton) {
        if toggle {
            
            UIView.animate(withDuration: 0.3) {
                
                self.genderTV.isHidden = false
            }
            } else {
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.genderTV.isHidden = true
                
            }
        }
    }
   
    @IBAction func confirmBTN(_ sender: Any) {
        
        validator.validate(self)

         guard let Age = Age.text, let hourlyRate = HourlyRate.text else {return}
        
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).childByAutoId().setValue(["Age": Int(Age), "Hourly Rate": Int(hourlyRate)])
        
        self.performSegue(withIdentifier: "toHomePage", sender: self)

    }
    
    
    
    
    
}

extension EditProfile: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        genderTapped.setTitle("\(list[indexPath.row])", for: .normal)
        animate(toggle: false, type: genderTapped)
    }

    
}




