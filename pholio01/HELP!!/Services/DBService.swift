//
//  DBService.swift
//  pholio01
//
//  Created by Solomon W on 8/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseAuth

class DBService {
    
    // Singleton
    static var shared: DBService {
        struct Static {
            static let instance = DBService()
        }
        return Static.instance
    }
    
    // MARK: - References
    let root = Database.database().reference()
    
    // DB references
    var users: DatabaseReference {
        return root.child("Users")
    }
    
    var currentUser: DatabaseReference {
        return users.child((Auth.auth().currentUser?.uid)!)
    }

    func getAllUsers(pairingWith: String?, completion: @escaping ([UserModel]) -> Void) {
        

        
        users.queryOrdered(byChild: "Usertype").queryEqual(toValue: pairingWith).queryLimited(toFirst: 6).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            
            var usersArray = [UserModel]()
            
            print(snapshot.children.allObjects.count)
            print(snapshot)

            guard let users = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in users {
                if let userDict = user.value as? [String: AnyObject] {
                    
                    let key = user.key
                    
                    if let currentUserId = Auth.auth().currentUser?.uid {
                        
                        print("getAllUsers")
                        // Check here if the user is the same as the current user
                        // if it is dont add it to the user array
                        if key != currentUserId {
                            let beat = UserModel(withUserId: key, dictionary: userDict)
                            usersArray.append(beat)
                        }
                        
                        //let beat = UserModel(withUserId: key, dictionary: userDict)
                        //usersArray.append(beat)
                        
                    }
                }
            }
            completion(usersArray)
        })
    }
    
    func refreshUser(userId: String, completion: @escaping (UserModel) -> Void) {
        users.child(userId).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            
            guard let userDict = snapshot.value as? [String: AnyObject] else { return }
            let key = snapshot.key
            let user = UserModel(withUserId: key, dictionary: userDict)
            
            completion(user)
        })
    }
    
    
}
