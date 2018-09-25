//
//  BViewController.swift
//  pholio01
//
//  Created by Chris  Ransom on 7/2/18.
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
import FirebaseFirestore


class BViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //fileprivate var userArr = [[String: Any]]()
    var ref: DatabaseReference!
    var arrImages: [[String: String]] = []
    
    var usersArray = [UserModel]()
    var seenUsersArray = [UserModel]()
    
    lazy var refreshControl:UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
        
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Helper.Pholio.shouldRefreshFilteredList {
            getFilteredUserList(refreshList: true)
            Helper.Pholio.shouldRefreshFilteredList = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed In")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
        }
        
        
        
        collectionView.refreshControl = refreshControl
        
        locationLabel.isHidden = true
        
        map.isHidden = true
        map.showsUserLocation = true
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        geoFireRef = Database.database().reference()
        
        geoFire = GeoFire(firebaseRef: (geoFireRef!.child("user_locations")))
        
        ref = Database.database().reference()
        /*
         userArr = [
         [ "pro-image" : "pro-img-3",
         "items": [["content" : "image", "item" : "img-3"], ["content" : "video", "item" : "output"], ["content" : "video", "item" : "output2"]]],
         ["pro-image" : "pro-img-1",
         "items": [["content" : "video", "item" : "output3"], ["content" : "image", "item" : "img-4"], ["content" : "image", "item" : "img-5"], ["content" : "video", "item" : "output"]]],
         ["pro-image" : "pro-img-2",
         "items": [["content" : "image", "item" : "img-1"], ["content" : "video", "item" : "output2"]]],
         ["pro-image" : "pro-img-4",
         "items": [["content" : "image", "item" : "img-2"], ["content" : "video", "item" : "output"], ["content" : "image", "item" : "img-3"]]],
         ["pro-image" : "pro-img-3",
         "items": [["content" : "video", "item" : "output"], ["content" : "image", "item" : "img-4"], ["content" : "video", "item" : "output3"], ["content" : "image", "item" : "img-3"]]],
         ["pro-image" : "pro-img-5",
         "items": [["content" : "video", "item" : "output2"], ["content" : "image", "item" : "img-5"], ["content" : "video", "item" : "output3"]]],
         ]
         */
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        self.addSlideMenuButton()
        
        // Do any additional setup after loading the view.
        
        getFilteredUserList(refreshList: false)
    }
    
    
    
    private func getFilteredUserList(refreshList: Bool) {
        DBService.shared.currentUser.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userDict = snapshot.value as? [String: AnyObject] else { return }
            
            let currentUser = UserModel(withUserId: snapshot.key, dictionary: userDict)
            Helper.Pholio.currentUser = currentUser
            
            DBService.shared.getFilteredUsers(refreshList: refreshList, completion: { (usersArray) in
                self.usersArray = usersArray
                self.collectionView.reloadData()
            })
            
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    @objc func requestData() {
        
        /*
         DBService.shared.currentUser.observeSingleEvent(of: .value) { (snapshot) in
         
         guard let userDict = snapshot.value as? [String: AnyObject] else { return }
         
         let currentUser = UserModel(withUserId: snapshot.key, dictionary: userDict)
         Helper.Pholio.currentUser = currentUser
         
         guard let pairingWith = currentUser.pairingWith else { return }
         
         DBService.shared.getAllUsers(pairingWith: pairingWith, completion: { (usersArray) in
         
         self.usersArray = usersArray
         self.collectionView.reloadData()
         })
         }
         */
        
        getFilteredUserList(refreshList: false)
        
        print("REQUEST DATA!!!")
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refreshControl.endRefreshing()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let spanz:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation,spanz)
        map.setRegion(region, animated: true)
        
        guard locations.last != nil else { return }
        geoFire!.setLocation(location, forKey: (Auth.auth().currentUser?.uid)!)
        
        
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
    
    
    @IBAction func messagesPressed(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if Helper.Pholio.currentUser == nil {
            
            DBService.shared.refreshUser(userId: userId) { (currentUser) in
                
                if currentUser.userId != nil {
                    Helper.Pholio.currentUser = currentUser
                    
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "NewMatchVC") as! NewMatchVC
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            
        } else {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NewMatchVC") as! NewMatchVC
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
        
        let user = usersArray[indexPath.row]
        
        DispatchQueue.global(qos: .background).async {
            let imageData = NSData(contentsOf: URL(string: user.profileImageUrl!)!)
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: imageData! as Data)
                cell.storyImages.image = profileImage
            }
        }
        
        //cell.storyImages.image = UIImage(named: userArr[indexPath.row]["pro-image"] as! String)
        
        return cell
    }
    
    
    
    // MARK: - UICollectionViewDelegate
    //1
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        DBService.shared.refreshUser(userId: usersArray[indexPath.row].userId!) { (refreshedUser) in
            
            if refreshedUser.itemsConverted.count == 0 {
                // no images uploaded
                print("no images uploaded")
                
            } else {
                self.usersArray[indexPath.row] = refreshedUser
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.pages = self.usersArray
                    vc.currentIndex = indexPath.row
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    
    
}




