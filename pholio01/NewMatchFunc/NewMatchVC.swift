//
// NewMatchVC.swift
// pholio01
//
// Created by Chris Ransom on 8/23/18.
// Copyright :copyright: 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase
import Pastel
import UserNotifications
import Kingfisher

class NewMatchVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matchedUsers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchCell", for: indexPath) as! NewMatchCollectionViewCell
        
        var imageView = cell.viewWithTag(69) as! UIImageView
        
        let matchedUser = matchedUsers[indexPath.row]
        
        let imageUrl = URL(string: matchedUser.profileImageUrl!)!
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageUrl)
        
        /*
         DispatchQueue.global(qos: .background).async {
         let imageData = NSData(contentsOf: URL(string: matchedUser.profileImageUrl!)!)
         
         DispatchQueue.main.async {
         let profileImage = UIImage(data: imageData! as Data)
         imageView.image = profileImage
         
         ImageService.getImage(withURL: URL(string: matchedUser.profileImageUrl!)!) { image in
         imageView.image = profileImage              }
         
         }
         }
         */
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let day = UIAlertAction(title: "Messages", style: .default) { action in
            
            print("Segue to Chat Completed")
            
            let user = self.matchedUsers[indexPath.row]
            
            self.showChatControllerForUser(user)        }
        
        let night = UIAlertAction(title: "User Gallery", style: .default) { action in
            
            
            
            
            DBService.shared.refreshUser(userId: self.matchedUsers[indexPath.row].userId!) { (refreshedUser) in
                
                if refreshedUser.itemsConverted.count == 0 {
                    // no images uploaded
                    print("no images uploaded")
                    
                } else {
                    self.matchedUsers[indexPath.row] = refreshedUser
                    
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewContentViewController") as! NewContentViewController
                        vc.modalPresentationStyle = .overFullScreen
                        vc.pages = self.matchedUsers
                        vc.currentIndex = indexPath.row
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
            }        }
        
        actionSheet.addAction(day)
        actionSheet.addAction(night)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId , for: indexPath) as! NewMatchTableViewCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("Users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = UserModel(withUserId: snapshot.key, dictionary: dictionary)
            
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.matchTable)
            if let indexPath = matchTable.indexPathForRow(at: touchPoint) {
                
                if indexPath != nil {
                    
                    let signOutAction = UIAlertAction(title: "Report User", style: .destructive) { (action) in
                        
                        //Code that sends reported users to Firebase Database
                        
                        let currentUserId = Auth.auth().currentUser!.uid
                        
                        var blockUserId: String
                        
                        let message = self.messages[indexPath.row]
                        
                        if currentUserId == message.fromId {
                            blockUserId = message.toId ?? ""
                        } else {
                            blockUserId = message.fromId ?? ""
                        }
                        
                        let messageRef = Database.database().reference().child("user-messages")
                        messageRef.child(currentUserId).child(blockUserId).removeValue()
                        messageRef.child(blockUserId).child(currentUserId).removeValue()
                        
                        let userRef = Database.database().reference().child("Users")
                        userRef.child(currentUserId).child("Matched-Users").child(blockUserId).setValue(false)
                        userRef.child(blockUserId).child("Matched-Users").child(currentUserId).setValue(false)
                        
                        Helper.Pholio.currentUser.matchedUsers[blockUserId] = false
                        
                        self.currentUser = Helper.Pholio.currentUser
                        
                        self.getMatchedUsers()
                        
                        for (index, mes) in self.messages.enumerated() {
                            if mes.fromId == currentUserId && mes.toId == blockUserId || mes.fromId == blockUserId && mes.toId == currentUserId {
                                
                                self.messages.remove(at: index)
                            }
                        }
                        
                        self.attemptReloadofTable()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            let successAlert = UIAlertController(title: "Reported", message: "Incident has been reported and further investigation will occur shortly", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            successAlert.addAction(okAction)
                            self.present(successAlert, animated: true, completion: nil)
                            
                            self.newMatch.reloadData()
                            self.matchTable.reloadData()
                            
                            Database.database().reference().child("reported-users").childByAutoId().child("userId").setValue(blockUserId)
                        })
                        
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
                }
            }
        }
    }
    
    //func addGesture() {
    //  let tap = UITapGestureRecognizer(target: self, action: #selector(NewMatchVC.collectionView(_:didSelectItemAt:)))
    //  view.addGestureRecognizer(tap)
    // }
    
    
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 1 second press
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.matchTable.addGestureRecognizer(longPressGesture)
    }
    
    let cellId = "cellId"
    
    var currentUser: UserModel!
    var matchedUsers = [UserModel]()
    
    var usersArray = [UserModel]()
    var seenUsersArray = [UserModel]()
    
    var user = [User]()
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var newMatch: UICollectionView!
    
    @IBOutlet weak var matchTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                
                self.fetchUser()
                
                self.fetchUserTwo()
                
                self.checkIfUserIsLoggedIn()
                
                print("User In MatchVC")
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // addGesture()
        
        
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
        
        setupLongPressGesture()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                
                self.fetchUser()
                
                self.fetchUserTwo()
                
                self.checkIfUserIsLoggedIn()
                
                print("User In MatchVC")
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }
        
        ref = Database.database().reference()
        
        currentUser = Helper.Pholio.currentUser
        
        // navigationItem.title = currentUser.username
        
        getMatchedUsers()
        
        self.newMatch.dataSource = self
        self.newMatch.delegate = self
        
        self.matchTable.dataSource = self
        self.matchTable.delegate = self
        
        observeUserMessages()
        messages.removeAll()
        messagesDictionary.removeAll()
        matchTable.reloadData()
        
        matchTable.register(NewMatchTableViewCell.self, forCellReuseIdentifier: cellId)
        
        matchTable.allowsMultipleSelectionDuringEditing = true
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(userID).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadofTable()
                
                // //this is one way of updating the table, but its actually not that safe..
                // self.messages.removeAtIndex(indexPath.row)
                // self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            })
        }
    }
    
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (DataSnapshot) in
                
                let messageId = DataSnapshot.key
                let messagesReference = Database.database().reference().child("messages").child(messageId)
                
                messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let message = Message(dictionary: dictionary)
                        message.text = dictionary["text"] as? String
                        message.fromId = dictionary["fromId"] as? String ?? "Sender not found"
                        message.toId = dictionary["toId"] as? String ?? "Reciever not found"
                        message.timestamp = dictionary["timestamp"] as? NSNumber
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messagesDictionary[chatPartnerId] = message
                        }
                        self.attemptReloadofTable()
                    }
                }, withCancel: nil)
                
            }, withCancel: { (nil) in
                
            })
            ref.observe(.childRemoved, with: { (snapshot) in
                print(snapshot.key)
                print(self.messagesDictionary)
                
                self.messagesDictionary.removeValue(forKey: snapshot.key)
                self.attemptReloadofTable()
                
            }, withCancel: nil)
        })
    }
    
    private func attemptReloadofTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
        })
        DispatchQueue.main.async {
            self.matchTable.reloadData()
        }
        //        print("table reloaded")
        
    }
    
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            signOut()
        } else {
            observeUserMessages()
            
            // setupNavBarWithUser()
        }
    }
    
    //func fetchUserTitle() {
    
    //guard let userID = Auth.auth().currentUser?.uid else {
    //for some reason uid = nil
    //   return
    //  }
    // Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
    
    //  if let dictionary = snapshot.value as? [String: AnyObject] {
    
    //    let user = UserModel(withUserId: snapshot.key, dictionary: dictionary)
    //   self.setupNavBarWithUser(user)
    
    // }
    
    //}, withCancel: nil)
    // }
    
    
    
    // func setupNavBarWithUser() {
    //commented section to imprvove speed
    //        messages.removeAll()
    //        messagesDictionary.removeAll()
    //        tableView.reloadData()
    
    //  guard let userID = Auth.auth().currentUser?.uid else {
    //    return
    // }
    
    //Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value) { (DataSnapshot) in
    
    
    //  if let dictionary = DataSnapshot.value as? [String: AnyObject] {
    //     let name = dictionary["Username"] as? String
    
    //    let userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
    //   let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String
    
    //   let titleView = UIView()
    //  titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
    // let containerView = UIView()
    // containerView.translatesAutoresizingMaskIntoConstraints = false
    //
    // let nameLabel = UILabel()
    //  nameLabel.text = name
    // nameLabel.translatesAutoresizingMaskIntoConstraints = false
    
    //  let profileImageView = UIImageView()
    // profileImageView.translatesAutoresizingMaskIntoConstraints = false
    //  profileImageView.layer.cornerRadius = 17
    //   profileImageView.clipsToBounds = true
    //   profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl!)
    
    //  titleView.addSubview(containerView)
    // containerView.addSubview(profileImageView)
    // containerView.addSubview(nameLabel)
    
    //contraints for navBar
    //  profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    //  profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    //  profileImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
    //   profileImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
    
    //  nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    //   nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    //   nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    //    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    //    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    //   containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
    //    self.navigationItem.titleView = titleView
    //       }
    //    }
    //    }
    
    
    func fetchUser() {
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("Matched-Users").observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                self.currentUser.userId = snapshot.key
                
                
                print("Matched User Found")
                
                print(dictionary)
            }
        })
    }
    
    func fetchUserTwo() {
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("Matched-Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                self.currentUser.userId = snapshot.key
                
                
                
                
                
                print("Matched User Found")
                
                print(dictionary)
            }
        })
    }
    
    
    func showChatControllerForUser(_ user: UserModel) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    var messagesController: ChatLogController?
    /////////////////////////////////////////
    
    func signOut() {
        
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            let firebaseAuth = Auth.auth()
            
            do {
                
                try firebaseAuth.signOut()
                
                print("User Signed Out")
                
                
            } catch let signOutError as NSError {
                
                Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: NSLocalizedDescriptionKey)
                
                print ("Error signing out: %@", signOutError)
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let OpeningVC = storyboard.instantiateViewController(withIdentifier: "openingVC")
            
            self.present(OpeningVC, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
    }
    
    func getMatchedUsers() {
        matchedUsers.removeAll()
        
        DBService.shared.refreshUser(userId: Helper.Pholio.currentUser.userId!) { (updatedCurrentUser) in
            
            Helper.Pholio.currentUser = updatedCurrentUser
            
            for matchedUser in Helper.Pholio.currentUser.matchedUsers {
                
                guard let matched = matchedUser.value as? Bool else { continue }
                
                if matched {
                    
                    let userId = matchedUser.key
                    
                    DBService.shared.refreshUser(userId: userId) { (userModel) in
                        
                        if userModel.userId != nil {
                            self.matchedUsers.append(userModel)
                            self.newMatch.reloadData()
                            self.matchTable.reloadData()
                        }
                    }
                }
            }
        }
    }
}
