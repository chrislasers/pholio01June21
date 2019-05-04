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
import Pastel
import Kingfisher


class BViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    
    
    
    @IBOutlet var coloredImageView: UIImageView!
    
    
    var colorArray: [(color1: UIColor, color2: UIColor)] = []
    
    
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var arrImages: [[String: String]] = []
    
    var usersArray = [UserModel]()
    var seenUsersArray = [UserModel]()
    
    lazy var refreshControl:UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        
        
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
        
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if Helper.Pholio.shouldRefreshFilteredList {
            getFilteredUserList(refreshList: true)
            Helper.Pholio.shouldRefreshFilteredList = false
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "GillSans-UltraBold", size: 23.0)!]
        
        
        
        
        
        
      //  let button = UIButton(type: .custom)
        //set image for button
      //  button.setImage(UIImage(named: "speech-bubble"), for: .normal)
        //add function for button
      //  button.addTarget(self, action: #selector(fbButtonPressed), for: .touchUpInside)
        //set frame
       // button.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        
    //    let widthConstraint = button.widthAnchor.constraint(equalToConstant: 27)
     //   let heightConstraint = button.heightAnchor.constraint(equalToConstant: 27)
   //     heightConstraint.isActive = true
     //   widthConstraint.isActive = true
        
    //    let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
    //    self.navigationItem.rightBarButtonItem = barButton
        
        
        
        
        animateBackgroundColor()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        
        view.addGestureRecognizer(leftSwipe)
        
        
        
        getFilteredUserList(refreshList: false)
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed In")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
            
            self.animateBackgroundColor()
            
        }
        
        
        
        collectionView.refreshControl = refreshControl
        
        locationLabel.isHidden = true
        
        map.isHidden = true
        map.showsUserLocation = true
        map.delegate = self as? MKMapViewDelegate
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        geoFireRef = Database.database().reference()
        
        geoFire = GeoFire(firebaseRef: (geoFireRef!.child("user_locations")))
        
        ref = Database.database().reference()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        DispatchQueue.main.async {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            //  self.collectionView.reloadData()
            
        }
        
        setupNavigationItems()
        
        setupMenuController()
        
        setupPanGesture()
        
        setupDarkCoverView()
       // self.addSlideMenuButton()
        
        
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
        view.insertSubview(pastelView, at: 0)
        
        
    }
    
  
    let darkCoverView = UIView()
    
    fileprivate func setupDarkCoverView() {
        darkCoverView.alpha = 0
        darkCoverView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        darkCoverView.isUserInteractionEnabled = false
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.addSubview(darkCoverView)
        darkCoverView.frame = mainWindow?.frame ?? .zero
    }
    
    fileprivate func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == .changed {
            var x = translation.x
            
            if isMenuOpened {
                // make sure you go through this logic line by line
                x += menuWidth
            }
            
            x = min(menuWidth, x)
            x = max(0, x)
            
            let transform = CGAffineTransform(translationX: x, y: 0)
            menuController.view.transform = transform
            navigationController?.view.transform = transform
            darkCoverView.transform = transform
            
            let alpha = x / menuWidth
            print(x, alpha)
            darkCoverView.alpha = alpha
            
        } else if gesture.state == .ended {
            handleEnded(gesture: gesture)
        }
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let velocity = gesture.velocity(in: view)
        print("Velocity: ",velocity.x)
        
        if isMenuOpened {
            if abs(velocity.x) > velocityOpenThreshold {
                handleHide()
                return
            }
            
            if abs(translation.x) < menuWidth / 2 {
                handleOpen()
            } else {
                handleHide()
            }
        } else {
            if velocity.x > velocityOpenThreshold {
                handleOpen()
                return
            }
            
            if translation.x < menuWidth / 2 {
                handleHide()
            } else {
                handleOpen()
            }
        }
    }
    
    let menuController = MenuController()
    
    fileprivate let velocityOpenThreshold: CGFloat = 500
    fileprivate let menuWidth: CGFloat = 300
    fileprivate var isMenuOpened = false
    
    fileprivate func performAnimations(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.menuController.view.transform = transform
            //            self.view.transform = tranform
            // I'll let you think about this on your own
            self.navigationController?.view.transform = transform
            self.darkCoverView.transform = transform
            
            // ternary operator
            self.darkCoverView.alpha = transform == .identity ? 0 : 1
            
            //            if transform == .identity {
            //                self.darkCoverView.alpha = 0
            //            } else {
            //                self.darkCoverView.alpha = 1
            //            }
            
        })
    }
    
    @objc func handleOpen() {
        isMenuOpened = true
        performAnimations(transform: CGAffineTransform(translationX: self.menuWidth, y: 0))
    }
    
    @objc func handleHide() {
        isMenuOpened = false
        performAnimations(transform: .identity)
    }
    
    // MARK:- Fileprivate
    
    fileprivate func setupMenuController() {
        // initial position
        menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: self.view.frame.height)
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.addSubview(menuController.view)
        addChild(menuController)
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(handleOpen))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(handleHide))
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
        locationManager.delegate = nil
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
            self.locationManager.stopUpdatingLocation()
            
            self.locationManager.delegate = nil
            
            self.map.showsUserLocation = false
            
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        super.viewDidAppear(animated)
        
        
        animateBackgroundColor()
        
        
    }
    
    
    
    
    func animateBackgroundColor() {
        // METHOD 1
        UIView.animate(withDuration: 9, delay: 0, options: [.autoreverse, .repeat, .curveLinear, .allowUserInteraction], animations: {
            let x = -(self.coloredImageView.frame.width - self.view.frame.width)
            self.coloredImageView.transform = CGAffineTransform(translationX: x, y: 0)
            
            self.coloredImageView.transform = CGAffineTransform.identity
            
            
            
        })
        
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .left:
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NewMatchVC") as! NewMatchVC
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        }
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    @objc func requestData() {
        
        UIView.transition(with: collectionView, duration: 0.5, options: .transitionFlipFromTop, animations: {
            //Do the data reload here
            // self.collectionView.reloadData()
            self.getFilteredUserList(refreshList: false)
            
        }, completion: nil)
        
        
        
        // getFilteredUserList(refreshList: false)
        
        print("REQUEST DATA!!!")
        
        
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refreshControl.endRefreshing()
        }
        
        
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let userId = Auth.auth().currentUser?.uid {
            
            let location = locations[0]
            
            let spanz:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation,span: spanz)
            map.setRegion(region, animated: true)
            
            guard locations.last != nil else { return }
            
            geoFire!.setLocation(location, forKey: (userId))
            
            print(location.coordinate)
            
            self.map.showsUserLocation = true
            
            geoFireRef?.child("Users").child(userId).updateChildValues(["Location": locationLabel.text!])
            
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
                            
                            self.locationLabel.text = "(place.thoroughfare!),(place.country!)"
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    @objc func fbButtonPressed() {
        
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
        
        print("Bar Button Pressed")
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
        
        let user = usersArray[indexPath.row]
        
        let imageUrl = URL(string: user.profileImageUrl!)!
        cell.storyImages.kf.indicatorType = .activity
        cell.storyImages.kf.setImage(with: imageUrl)
        
        cell.layoutIfNeeded()
        
        /*
         DispatchQueue.global(qos: .background).async {
         
         let imageData = NSData(contentsOf: URL(string: user.profileImageUrl!)!)
         
         DispatchQueue.main.async {
         
         
         
         let profileImage = UIImage(data: imageData! as Data)
         cell.storyImages.image = profileImage
         
         ImageService.getImage(withURL: URL(string: user.profileImageUrl!)!) { image in
         cell.storyImages.image = profileImage                }
         
         if let profileImage = user.profileImageUrl {
         
         cell.storyImages.loadImageUsingCacheWithUrlString(profileImage)
         
         cell.layoutIfNeeded()
         
         
         }
         
         
         }
         }
         */
        
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
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.pages = self.usersArray
                    vc.currentIndex = indexPath.row
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    
    
}




