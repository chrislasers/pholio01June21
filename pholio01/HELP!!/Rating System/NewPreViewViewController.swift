//
//  NewPreViewViewController.swift
//  pholio01
//
//  Created by Chris  Ransom on 10/19/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import CTSlidingUpPanel
import Cosmos


class NewPreViewViewController: UIViewController, SegmentedProgressBarDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
        
    @IBOutlet var popOver: UIView!
    
    @IBAction func menuBTN(_ sender: Any) {
        
        
        self.view.addSubview(popOver)
        popOver.center = self.view.center
        
    }
    
    
    var pageIndex : Int = 0
    var items = [[String: Any]]()
    var item = [[String : String]]()
    var SPB: SegmentedProgressBar!
    var player: AVPlayer!
    
    var usersArray = [UserModel]()
    
    
    @IBOutlet var cosmosView: CosmosView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosView.settings.updateOnTouch = false
        
        
        
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.height / 2;
        //userProfileImage.image = UIImage(named: items[pageIndex]["pro-image"] as! String)
        
        let user = usersArray[pageIndex]
        
        DispatchQueue.global(qos: .background).async {
            let imageData = NSData(contentsOf: URL(string: user.profileImageUrl!)!)
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: imageData! as Data)
                self.userProfileImage.image = profileImage
                self.lblUserName.text = user.username
                
            }
        }
        
        
        
        
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
    
    
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        imagePreview.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - imagePreview.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        imagePreview.transform = scaledAndRotated
        
        if gestureRecognizer.state == .ended {
            
            
            
            
            
            
            
            if imagePreview.center.x < (view.bounds.width / 2 - 100) {
                print("Not Interested")
                
                self.dismiss(animated: true, completion: nil)
            }
            
            if imagePreview.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
                
                let matchedUser = usersArray[pageIndex]
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
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            
            imagePreview.transform = scaledAndRotated
            
            imagePreview.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        
        
        let matchedUser = usersArray[pageIndex]
        Helper.Pholio.matchedUser = matchedUser
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let cardUID = Helper.Pholio.matchedUser else { return }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully updated swipe....")
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully saved swipe....")
                }
            }
        }
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
                }
            }
            let user = usersArray[pageIndex]
            
            lblUserName.text = user.username
            
            
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
    
    //MARK: - Button actions
    @IBAction func close(_ sender: Any) {
        self.popOver.removeFromSuperview()
    }
}
