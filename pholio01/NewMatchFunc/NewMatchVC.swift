//
//  NewMatchVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 8/23/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase


class NewMatchVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matchedUsers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchCell", for: indexPath) as! NewMatchCollectionViewCell
        
        let imageView = cell.viewWithTag(69) as! UIImageView
        
        let matchedUser = matchedUsers[indexPath.row]
        
        
        
        DispatchQueue.global(qos: .background).async {
            let imageData = NSData(contentsOf: URL(string: matchedUser.profileImageUrl!)!)
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: imageData! as Data)
                imageView.image = profileImage
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Segue to Chat Completed")
        
        let user = self.matchedUsers[indexPath.row]
        
        self.showChatControllerForUser(user)
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
                    
                    
                    
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
            }
            }
        }
    }
        
        func setupLongPressGesture() {
            let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
            longPressGesture.minimumPressDuration = 1.0 // 1 second press
            longPressGesture.delegate = self as? UIGestureRecognizerDelegate
            self.matchTable.addGestureRecognizer(longPressGesture)
        }
    
    let cellId = "cellId"
    
    var currentUser: UserModel!
    var matchedUsers = [UserModel]()
    
    var user = [User]()
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var newMatch: UICollectionView!
    
    @IBOutlet weak var matchTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLongPressGesture()

        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                
                self.fetchUser()
                
                
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
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
                
                //                //this is one way of updating the table, but its actually not that safe..
                //                self.messages.removeAtIndex(indexPath.row)
                //                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
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
            
            setupNavBarWithUser()
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
    
    
    
    func setupNavBarWithUser() {
        //commented section to imprvove speed
        //        messages.removeAll()
        //        messagesDictionary.removeAll()
        //        tableView.reloadData()
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value) { (DataSnapshot) in
            
            
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                let name = dictionary["Username"] as? String
                
                let userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
                let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String
                
                let titleView = UIView()
                titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                let nameLabel = UILabel()
                nameLabel.text = name
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let profileImageView = UIImageView()
                profileImageView.translatesAutoresizingMaskIntoConstraints = false
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.cornerRadius = 17
                profileImageView.clipsToBounds = true
                profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl!)
                
                titleView.addSubview(containerView)
                containerView.addSubview(profileImageView)
                containerView.addSubview(nameLabel)
                
                //contraints for navBar
                profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                profileImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
                profileImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
                
                nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
                nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
                
                containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
                
                self.navigationItem.titleView = titleView
            }
        }
    }
    
    
    func fetchUser() {
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).child("Matched-Users").observe(.value, with: { (snapshot) in
            
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
