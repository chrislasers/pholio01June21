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

class EditProfile: UIViewController, CLLocationManagerDelegate {
    
    
    
    
    @IBOutlet weak var map: MKMapView!
    
    
    @IBOutlet weak var genderTapped: UIButton!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var genderTV: UITableView!
    
    
   
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    

    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    
    var ref: DatabaseReference!
    
    let list = ["Male", "Female"]
    
    let HRlocation = ["$15", "$20", "$25", "$30", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20", "$20"]
    
    let userID = Auth.auth().currentUser?.uid

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            currentLocation = locationManager.location
            print(currentLocation.coordinate.longitude)
            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    
    
    
    @IBAction func cancelPressed(_ sender: Any) {
          dismiss(animated: true, completion: nil)
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




