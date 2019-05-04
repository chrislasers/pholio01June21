//
//  UserModel.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Firebase
import Firebase
import FirebaseAuth

class UserModel: NSObject {
    
    var userId: String?
    var email: String?

    
    var userProfilePicDictionary: [String: Any]?
    var profileImageUrl: String?
    var username: String?
    var items = [[String: Any]]()
    var itemsConverted = [[String: String]]()
    
    var pairingWith: String?
    var matchedUsers = [String: Any]()
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var genderFilter: GenderFilter!
    var pairingFilter: PairingFilter!
    var ageFilter: Int!
    var milesFilter: Int!
    
    var gender: String!
    var age: Int!
    var hourlyRate: Int!
    var userType: String!
    var lat_lon: String!
    
    var featured: Bool!
    var featuredFilter: Bool!
    
    var name: String?
    var profession: String?
    //    let imageNames: [String]
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    
    
    
    init(withUserId userId: String, dictionary: [String: Any]) {
        self.userId = userId
        
        //self.email = userEmail
        
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.name = dictionary["fullName"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""

        
        let arr = dictionary.map {[$0: $1]}
        
        for (_, value) in arr.enumerated() {
            if let object = value.first?.value as? [String: String] {
                if let username = object["Username"] {
                    self.username = username
                }
            }
        }
        
        self.userProfilePicDictionary = dictionary["UserPro-Pic"] as? [String: Any]
        
        
        if let profileImageUrl = userProfilePicDictionary!["profileImageURL"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
        if let pairingWith = dictionary["Pairing With"] as? String {
            self.pairingWith = pairingWith
        }
        
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        
        
        let userGalleryItems = dictionary["User-Gallery"] as? [String: Any]
        
        // convert the values to fit the current values that the story feature is using
        if let values = userGalleryItems?.values {
            
            for i in values {
                if let t = i as? [String: Any] {
                    items.append(t)
                }
                
                if let t = i as? [String: String] {
                    itemsConverted.append(t)
                }
            }
        }
        
        if let matchedUsers = dictionary["Matched-Users"] as? [String: Any] {
            self.matchedUsers = matchedUsers
        }
        
        func chatPartnerId() -> String? {
            return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        }
        
        if let genderFilter = dictionary["GenderFilter"] as? String {
            self.genderFilter = GenderFilter(rawValue: genderFilter)
        } else {
            // if no filter exists set to the default which is both genders
            self.genderFilter = .both
        }
        
        if let pairingFilter = dictionary["PairingFilter"] as? String {
            self.pairingFilter = PairingFilter(rawValue: pairingFilter)
        } else {
            // if no filter exists set to the default which is all user types
            self.pairingFilter = .all
        }
        
        if let ageFilter = dictionary["AgeFilter"] as? Int {
            self.ageFilter = ageFilter
        } else {
            // if no filter exists set to the default which is 0
            self.ageFilter = 0
        }
        
        if let milesFilter = dictionary["MilesFilter"] as? Int {
            self.milesFilter = milesFilter
        } else {
            // if no filter exists set to the default which is 0
            self.milesFilter = 0
        }
        
        if let gender = dictionary["Gender"] as? String {
            self.gender = gender
        } else {
            self.gender = GenderFilter.male.rawValue
        }
        
        if let age = dictionary["Age"] as? Int {
            self.age = age
        } else {
            self.age = 18
        }
        
        if let hourlyRate = dictionary["Rate"] as? Int {
            self.hourlyRate = hourlyRate
        } else {
            self.hourlyRate = nil
        }
        
        self.userType = dictionary["Usertype"] as? String
        
        if let lat_lon = dictionary["lat_lon"] as? String {
            self.lat_lon = lat_lon
        } else {
            self.lat_lon = ""
        }
        
        if let featured = dictionary["Featured"] as? Bool {
            self.featured = featured
        } else {
            self.featured = false
        }
        
        if let featuredFilter = dictionary["FeaturedFilter"] as? Bool {
            self.featuredFilter = featuredFilter
        } else {
            self.featuredFilter = false
        }
        
    }
    
    
    
    
    
    
    
    init(userEmail: String, userId: String) {
        self.email = userEmail
        self.userId = userId
    }
    
    static let system = FriendSystem()
    
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
    
    
    /** Gets the current User object for the specified user id */
    func getCurrentUser(_ completion: @escaping (UserModel) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let id = snapshot.key
            completion(UserModel(userEmail: email, userId: id))
        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (UserModel) -> Void) {
        USER_REF.child(userID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let id = snapshot.key
            completion(UserModel(userEmail: email, userId: id))
        })
    }
    
    func postToken(Token: [String : AnyObject]){
        
        print("FCM Token: \(Token)")
        
        //let dbRef = Database.database().reference()
        self.CURRENT_USER_REF.child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token)
        
        // self.ref.child("Users").child(self.userID!).setValue(["tokenid":Token])
        
    }
    
    
    // MARK: - Account Related
    
    /**
     Creates a new user account with the specified email and password
     - parameter completion: What to do when the block has finished running. The success variable
     indicates whether or not the signup was a success
     */
    func createAccount(_ email: String, password: String, name: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]

            
            if (error == nil) {
                // Success
                var userInfo = [String: AnyObject]()
                userInfo = ["email": email as AnyObject, "name": name as AnyObject, "Token": token as AnyObject]
                self.CURRENT_USER_REF.setValue(userInfo)
                
                
                
                completion(true)
            } else {
                // Failure
                completion(false)
            }
            
        })
    }
    
    /**
     Logs in an account with the specified email and password
     
     - parameter completion: What to do when the block has finished running. The success variable
     indicates whether or not the login was a success
     */
    func loginAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if (error == nil) {
                // Success
                completion(true)
            } else {
                // Failure
                completion(false)
                print(error!)
            }
            
        })
    }
    
    /** Logs out an account */
    func logoutAccount() {
        try! Auth.auth().signOut()
    }
    
    
    
    // MARK: - Request System Functions
    
    /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
    }
    
    /** Unfriends the user with the specified id */
    func removeFriend(_ userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
    
    
    // MARK: - All users
    /** The list of all users */
    var userList = [UserModel]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        FriendSystem.system.USER_REF.observe(DataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                if email != Auth.auth().currentUser?.email! {
                    self.userList.append(UserModel(userEmail: email, userId: self.userId!))
                }
            }
            update()
        })
    }
    /** Removes the user observer. This should be done when leaving the view that uses the observer. */
    func removeUserObserver() {
        USER_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
   // var friendList = [User]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
  //  func addFriendObserver(_ update: @escaping () -> Void) {
       // CURRENT_USER_FRIENDS_REF.observe(DataEventType.value, with: { (snapshot) in
        //    self.friendList.removeAll()
         //   for child in snapshot.children.allObjects as! [DataSnapshot] {
          //      let id = child.key
          //      self.getUser(id, completion: { (user) in
           //         self.friendList.append(user)
            //        update()
            //    })
          //  }
            // If there are no children, run completion here instead
        //    if snapshot.childrenCount == 0 {
        //        update()
        //    }
       // })
   // }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
 //   func removeFriendObserver() {
   //     CURRENT_USER_FRIENDS_REF.removeAllObservers()
   // }
    
    
    
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [UserModel]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.requestList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        CURRENT_USER_REQUESTS_REF.removeAllObservers()
    }
    
    
    
}
