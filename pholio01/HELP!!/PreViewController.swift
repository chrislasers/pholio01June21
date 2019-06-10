//
//  PreViewController.swift
//  InstagramStories
//
//  Created by mac05 on 05/10/17.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import CTSlidingUpPanel
import Cosmos
import Firebase
import FirebaseAuth
import Kingfisher

class PreViewController: UIViewController, SegmentedProgressBarDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet var thumbImageView: UIImageView!
    
    @IBOutlet var userGender: UILabel!
    @IBOutlet var userAge: UILabel!
    @IBOutlet var userHR: UILabel!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    
    @IBOutlet var popOver: UIView!
    
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBAction func menuBTN(_ sender: Any) {
        
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 5, options: [], //options: nil
            animations: ({
                
                self.view.addSubview(self.popOver)
                
                
                self.popOver.center.y = self.view.frame.width / 3
                
            }), completion: nil)
        
        
        
        self.view.addSubview(popOver)
        
        
        
        popOver.center = self.view.center
        
    }
    
    
    
    
    var pageIndex : Int = 0
    var items = [[String: Any]]()
    var item = [[String : String]]()
    var SPB: SegmentedProgressBar!
    var player: AVPlayer!
    
    var usersArray = [UserModel]()
    
    
    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /* The user Firebase reference */
    let USER_REF = Database.database().reference().child("users")
    
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser!.uid
        return USER_REF.child("\(id)")
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
    
    @IBOutlet var cosmosView: CosmosView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //cosmosView.settings.updateOnTouch = true
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed Into Swipe Mode")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
        }
        
        
        
        
        
        popOver.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        popOver.layer.borderWidth = 1.5
        popOver.layer.cornerRadius = 7
        
        popOver.layer.shadowColor = UIColor.black.cgColor
        popOver.layer.shadowRadius = 2
        popOver.layer.shadowOpacity = 0.8
        popOver.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        FriendSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        ref = Database.database().reference()
        
        
        
        
        
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.height / 2;
        //userProfileImage.image = UIImage(named: items[pageIndex]["pro-image"] as! String)
        
        let user = usersArray[pageIndex]
        
        let imageUrl = URL(string: user.profileImageUrl!)!
        self.userProfileImage.kf.indicatorType = .activity
        self.userProfileImage.kf.setImage(with: imageUrl)
        
        self.lblUserName.text = user.username
        self.userGender.text = user.userType
        self.userAge.text = String(user.age)
        self.userHR.text = String(user.hourlyRate)
        
        /*
         DispatchQueue.global(qos: .background).async {
         let imageData = NSData(contentsOf: URL(string: user.profileImageUrl!)!)
         
         DispatchQueue.main.async {
         let profileImage = UIImage(data: imageData! as Data)
         self.userProfileImage.image = profileImage
         self.lblUserName.text = user.username
         self.userGender.text = user.userType
         self.userAge.text = String(user.age)
         self.userHR.text = String(user.hourlyRate)
         
         
         ImageService.getImage(withURL: URL(string: user.profileImageUrl!)!) { image in
         self.userProfileImage.image = profileImage
         }
         
         
         
         }
         }
         */
        
        //item = self.items[pageIndex]["items"] as! [[String : String]]
        item = user.itemsConverted
        
        SPB = SegmentedProgressBar(numberOfSegments: self.items.count, duration: 5)
        //SPB = SegmentedProgressBar(numberOfSegments: self.items.count, duration: 5)
        if #available(iOS 11.0, *) {
            SPB.frame = CGRect(x: 18, y: UIApplication.shared.statusBarFrame.height + 5, width: view.frame.width - 35, height: 3)
        } else {
            // Fallback on earlier versions
            SPB.frame = CGRect(x: 18, y: 15, width: view.frame.width - 35, height: 3)
        }
        
        SPB.delegate = self
        SPB.topColor = UIColor.white
        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
        SPB.padding = 2
        SPB.isPaused = true
        SPB.currentAnimationIndex = 0
        view.addSubview(SPB)
        view.bringSubviewToFront(SPB)
        
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(self.tapOn(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        tapGestureImage.numberOfTouchesRequired = 1
        imagePreview.addGestureRecognizer(tapGestureImage)
        
        let tapGestureVideo = UITapGestureRecognizer(target: self, action: #selector(self.tapOn(_:)))
        tapGestureVideo.numberOfTapsRequired = 1
        tapGestureVideo.numberOfTouchesRequired = 1
        videoView.addGestureRecognizer(tapGestureVideo)
        
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        imagePreview.addGestureRecognizer(gesture)
    }
    
    func resetCard() {
        

        
        UIView.animate(withDuration: 0.5, animations: {
            self.imagePreview.alpha = 1
            self.imagePreview.transform = .identity
            self.imagePreview.center = self.view.center
            self.thumbImageView.alpha = 0
            

        })
    }
    
    
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        imagePreview.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - imagePreview.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        imagePreview.transform = scaledAndRotated
        
        // Set Thumb Image
        if xFromCenter > 0 {
            thumbImageView.image = #imageLiteral(resourceName: "ThumpDown")
            thumbImageView.tintColor = UIColor.red
        } else {
            thumbImageView.image = #imageLiteral(resourceName: "ThumpUp")
            thumbImageView.tintColor = UIColor.green
            
        }
        
        // Show Thumb Image
        let alphaValue = abs(xFromCenter/view.center.x)
        thumbImageView.alpha = alphaValue
        
        if gestureRecognizer.state == .ended {
            
            
            if imagePreview.center.x < (view.bounds.width / 2 - 100) {
                print("Not Interested")
                
                // Thumbs Down
                // Move off to the left
                
                self.dismiss(animated: true, completion: nil)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.imagePreview.center = CGPoint(x: self.imagePreview.center.x - 200, y: self.imagePreview.center.y + 100)
                    self.imagePreview.alpha = 0
                })
                return
            }
            
            if imagePreview.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
                
                //self.dismiss(animated: true, completion: nil)

                
                // Thumbs Up
                UIView.animate(withDuration: 0.3, animations: {
                    self.imagePreview.center = CGPoint(x:  self.imagePreview.center.x + 200, y:  self.imagePreview.center.y + 100)
                    self.imagePreview.alpha = 0
                })
                
                
                let matchedUser = usersArray[pageIndex]
                Helper.Pholio.matchedUser = matchedUser
                
                guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                
                DBService.shared.refreshUser(userId: matchedUser.userId!) { (updatedUser) in
                    
                    let matched = updatedUser.matchedUsers[currentUserId] as? Bool
                    
                    self.saveSwipeToFirestore(didLike: 1)


                    
                    if matched == true {
                        DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(true)
                        
                        
                        
                    } else if matched == false {
                        DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(true)
                        DBService.shared.users.child(matchedUser.userId!).child("Matched-Users").child(currentUserId).setValue(true)
                        
                    } else {
                        // Not matched yet
                        DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(false)
                    }
                    
                    self.checkIfMatchExists(cardUID: currentUserId)
                }
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            
            imagePreview.transform = scaledAndRotated
            
            imagePreview.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
        
        resetCard()
        return
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        
        
        
        let matchedUser = usersArray[pageIndex]
        Helper.Pholio.matchedUser = matchedUser
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let documentData = [matchedUser.userId!: didLike]
        
        Firestore.firestore().collection("swipes").document(currentUserId).setData([ matchedUser.userId! : matchedUser.userId! ])
        
        Firestore.firestore().collection("swipes").document(currentUserId).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(currentUserId).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully updated swipe....")
                    
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: currentUserId)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(currentUserId).setData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully saved swipe....")
                    
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: currentUserId)
                    }
                }
            }
        }
    }
    
    
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        // How to detect our match between two users?
        print("Detecting match")
        
        let matchedUser = usersArray[pageIndex]
        Helper.Pholio.matchedUser = matchedUser
        

        
       // guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        
        Firestore.firestore().collection("swipes").document(matchedUser.userId!).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            
            if hasMatched {
                print("Has matched")
                self.presentMatchView(cardUID: cardUID)

                //self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    
    fileprivate var users: Users?

    
   
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.8) {
            self.view.transform = .identity
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.SPB.currentAnimationIndex = 0
            self.SPB.startAnimation()
            self.playVideoOrLoadImage(index: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.SPB.currentAnimationIndex = 0
            self.SPB.isPaused = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - SegmentedProgressBarDelegate
    //1
    func segmentedProgressBarChangedIndex(index: Int) {
        playVideoOrLoadImage(index: index)
    }
    
    //2
    func segmentedProgressBarFinished() {
        if pageIndex == (self.items.count - 1) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func tapOn(_ sender: UITapGestureRecognizer) {
        SPB.skip()
    }
    
    //MARK: - Play or show image
    func playVideoOrLoadImage(index: NSInteger) {
        
        if item[index]["content"] == "image" {
            self.SPB.duration = 5
            self.imagePreview.isHidden = false
            self.videoView.isHidden = true
            
            let content = item[index]["item"]
            
            DispatchQueue.global(qos: .background).async {
                let imageData = NSData(contentsOf: URL(string: content!)!)
                
                DispatchQueue.main.async {
                    let contentImage = UIImage(data: imageData! as Data)
                    self.imagePreview.image = contentImage
                    
                    let user = self.usersArray[self.pageIndex]
                    
                    self.lblUserName.text = user.username
                }
            }
            //let user = usersArray[pageIndex]
            
            // lblUserName.text = user.username
            
            
            //self.imagePreview.image = UIImage(named: item[index]["item"]!)
        }
        else {
            let moviePath = Bundle.main.path(forResource: item[index]["item"], ofType: "mp4")
            if let path = moviePath {
                self.imagePreview.isHidden = true
                self.videoView.isHidden = false
                
                let url = NSURL.fileURL(withPath: path)
                self.player = AVPlayer(url: url)
                
                let videoLayer = AVPlayerLayer(player: self.player)
                videoLayer.frame = view.bounds
                videoLayer.videoGravity = .resizeAspectFill
                self.videoView.layer.addSublayer(videoLayer)
                
                let asset = AVAsset(url: url)
                let duration = asset.duration
                let durationTime = CMTimeGetSeconds(duration)
                
                self.SPB.duration = durationTime
                self.player.play()
                
            }
        }
    }
    
    
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
    }
    
    //MARK: - Button actions
    @IBAction func close(_ sender: Any) {
        
        //sendRequestToUser(userID!)
        
        
        
        self.popOver.removeFromSuperview()
    }
}


extension PreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.index(after: 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        if cell == nil {
            tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        }
        
        // Modify cell
        // cell!.emailLabel.text = self.usersArray[self.pageIndex].email
        
        let user = self.usersArray[self.pageIndex]
        
        self.lblUserName.text = user.username
        
        cell!.setFunction {
            
            print("Interested")
            
            let matchedUser = self.usersArray[self.pageIndex]
            Helper.Pholio.matchedUser = matchedUser
            
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            DBService.shared.refreshUser(userId: matchedUser.userId!) { (updatedUser) in
                
                let matched = updatedUser.matchedUsers[currentUserId] as? Bool
                
                if matched == true {
                    DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(true)
                    
                } else if matched == false {
                    DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(true)
                    DBService.shared.users.child(matchedUser.userId!).child("Matched-Users").child(currentUserId).setValue(true)
                    
                } else {
                    // Not matched yet
                    DBService.shared.currentUser.child("Matched-Users").child(matchedUser.userId!).setValue(false)
                    
                    
                    
                    
                    let user = self.usersArray[self.pageIndex].userId
                    
                    self.sendRequestToUser(user!)
                    
                    print("Request Sent")
                    
                    self.popOver.removeFromSuperview()
                    
                    
                    let emailNotSentAlert = UIAlertController(title: "Request Status", message: "Shoot Request Succesfully Sent", preferredStyle: .alert)
                    emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emailNotSentAlert, animated: true, completion: nil)
                    
                    
                    
                    //let id = FriendSystem.system.userList[indexPath.row].id
                    //FriendSystem.system.sendRequestToUser(id!)
                }
            }
        }
        
        // Return cell
        return cell!
    }
    
}

