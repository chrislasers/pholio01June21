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
import CircleMenu
import FAPanels


extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
}

class BViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, FAPanelStateDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    
    
    @IBAction func button(_ sender: Any) {
    }
    
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
    
    var window: UIWindow?

    
    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("icon_search", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("notifications-btn", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("settings-btn", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ("nearby-btn", UIColor(red: 1, green: 0.39, blue: 0, alpha: 1))
    ]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if Helper.Pholio.shouldRefreshFilteredList {
            getFilteredUserList(refreshList: true)
            Helper.Pholio.shouldRefreshFilteredList = false
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "GillSans-UltraBold", size: 23.0)!]
        
        
        
        
        
        
        let button = UIButton(type: .custom)
       // set image for button
        button.setImage(UIImage(named: "speech-bubble"), for: .normal)
      //  add function for button
        button.addTarget(self, action: #selector(fbButtonPressed), for: .touchUpInside)
       // set frame
        button.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 27)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 27)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
       // assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        
        
        
      //  animateBackgroundColor()
        
        
        
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
            
           // self.animateBackgroundColor()
            
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
              self.collectionView.reloadData()
            
        }

//      setupNavigationItems()
//
//    setupMenuController()
//
// setupPanGesture()
//
//  setupDarkCoverView()

self.addSlideMenuButton()
        
     
        
        
        
       
        
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
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        // set highlited image
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
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
    
     func handleEnded(gesture: UIPanGestureRecognizer) {
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
    var redViewLeadingConstraint: NSLayoutConstraint!
    fileprivate let velocityThreshold: CGFloat = 50
     let velocityOpenThreshold: CGFloat = 500
     let menuWidth: CGFloat = 280
     var isMenuOpened = false
    
     func performAnimations(transform: CGAffineTransform) {
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
        

        
       // panel!.openLeft(animated: true)

        
       isMenuOpened = true
       performAnimations(transform: CGAffineTransform(translationX: self.menuWidth, y: 0))
    }
    
    @objc func handleHide() {
        isMenuOpened = false
        performAnimations(transform: .identity)
        
        
    }
    
    @objc func openMenu() {
        isMenuOpened = true
        redViewLeadingConstraint.constant = menuWidth
        performAnimations()
        print("Menu Open")
    }
    
    @objc func closeMenu() {
       redViewLeadingConstraint.constant = 0
        isMenuOpened = false
        performAnimations()
        print("Menu Closed")

    }
    
    func didSelectMenuItem(indexPath: IndexPath) {
        //        print("Selected menu item:", indexPath.row)
        
        
        
        switch indexPath.row {
            
            
        case 0:
            print("Show Home Screen")
            
            
            let listsController = ListsController()

            
            view.addSubview(listsController.view)

           
                      print("Show Lists Screen")
           // self.openViewControllerBasedOnIdentifier("Home")

            
        case 2:
            
            print("Show Lists Screen")

          // self.openViewControllerBasedOnIdentifier("Request")

        default:
            print("Show Moments Screen")
            closeMenu()

        }
        
       //self.openViewControllerBasedOnIdentifier("Filters")
      //closeMenu()
    }
    
    fileprivate func performAnimations() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // leave a reference link down in desc below
            self.view.layoutIfNeeded()
            self.darkCoverView.alpha = self.isMenuOpened ? 1 : 0
        })
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
        
        setupCircularNavigationButton()
        
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(handleOpen))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(handleHide))
    }
    
    fileprivate func setupCircularNavigationButton() {
        let image = #imageLiteral(resourceName: "girl_profile").withRenderingMode(.alwaysOriginal)
        
        let customView = UIButton(type: .system)
        //        customView.backgroundColor = .orange
        customView.addTarget(self, action: #selector(handleOpen), for: .touchUpInside)
        //        customView.imageView?.image // this is not what you want
        customView.setImage(image, for: .normal)
        customView.imageView?.contentMode = .scaleAspectFit
        
        customView.layer.cornerRadius = 20
        customView.clipsToBounds = true
        
        // this doesn't work
        // custom view uses auto layout to put itself in the nav bar
        //        customView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        customView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let barButtonItem = UIBarButtonItem(customView: customView)
        
        navigationItem.leftBarButtonItem = barButtonItem
        
        // option #1 that doesn't work
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleOpen))
        
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
        
        menuController.view.frame = CGRect(x: 0, y: 0, width: 200, height: 500) // something new

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
        
        
       // animateBackgroundColor()
        
        
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
//                    
//                    let vc = MatchesMessagesController()
//                    navigationController?.pushViewController(vc, animated: true)
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




