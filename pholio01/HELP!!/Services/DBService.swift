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
import MapKit

class DBService {
    
    // number of users to display
    var userLimit = 6
    
    // filtered users
    var filteredUsers = [UserModel]()
    
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
        
        users.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            
            var usersArray = [UserModel]()
            
            print(snapshot.children.allObjects.count)
            print(snapshot)
            
            guard let users = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in users {
                if let userDict = user.value as? [String: AnyObject] {
                    
                    let key = user.key
                    
                    if let currentUserId = Auth.auth().currentUser?.uid {
                        
                        // Check here if the user is the same as the current user
                        // if it is dont add it to the user array
                        if key != currentUserId {
                            let beat = UserModel(withUserId: key, dictionary: userDict)
                            usersArray.append(beat)
                        }
                        
                        //let user = UserModel(withUserId: key, dictionary: userDict)
                        //usersArray.append(user)
                    }
                }
            }
            completion(usersArray)
        })
    }
    
    
    func getFilteredUsers(refreshList: Bool, completion: @escaping ([UserModel]) -> Void) {
        let genderFilter = Helper.Pholio.currentUser.genderFilter!
        let pairingFilter = Helper.Pholio.currentUser.pairingFilter!
        let ageFilter = Helper.Pholio.currentUser.ageFilter!
        let mileFilter = Helper.Pholio.currentUser.milesFilter!
        let featuredFilter = Helper.Pholio.currentUser.featuredFilter!
        
        var usersArray = [UserModel]()
        
        if refreshList {
            
            Helper.Pholio.seenUsers.removeAll()
            Helper.Pholio.allUsers.removeAll()
            
            users.queryOrdered(byChild: "dateCreated").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                
                print(snapshot.children.allObjects.count)
                print(snapshot)
                
                guard let users = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                for user in users {
                    
                    guard let userDict = user.value as? [String: AnyObject] else { continue }
                    
                    let key = user.key
                    let user = UserModel(withUserId: key, dictionary: userDict)
                    
                    if let currentUserId = Auth.auth().currentUser?.uid {
                        if key != currentUserId {
                            Helper.Pholio.allUsers.append(user)
                        }
                    }
                    
                    if user.age >= ageFilter {
                        
                        if genderFilter == .both {
                            // no gender filter
                            if self.pairingFilterCheck(pairingFilter: pairingFilter, user: user) {
                                
                                if self.milesFilterCheck(user: user, filter: mileFilter) {
                                    
                                    if let currentUserId = Auth.auth().currentUser?.uid {
                                        // Check here if the user is the same as the current user
                                        // if it is dont add it to the user array
                                        if key != currentUserId {
                                            
                                            if !self.didSeeUser(user: user) && usersArray.count < self.userLimit {
                                                
                                                if featuredFilter {
                                                    
                                                    if user.featured {
                                                        usersArray.append(user)
                                                        Helper.Pholio.seenUsers.append(user)
                                                    }
                                                    
                                                } else {
                                                    usersArray.append(user)
                                                    Helper.Pholio.seenUsers.append(user)
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            
                            if user.gender == genderFilter.rawValue {
                                
                                if self.pairingFilterCheck(pairingFilter: pairingFilter, user: user) {
                                    
                                    if self.milesFilterCheck(user: user, filter: mileFilter) {
                                        
                                        if let currentUserId = Auth.auth().currentUser?.uid {
                                            // Check here if the user is the same as the current user
                                            // if it is dont add it to the user array
                                            if key != currentUserId {
                                                
                                                if !self.didSeeUser(user: user) && usersArray.count < self.userLimit {
                                                    
                                                    if featuredFilter {
                                                        
                                                        if user.featured {
                                                            usersArray.append(user)
                                                            Helper.Pholio.seenUsers.append(user)
                                                        }
                                                        
                                                    } else {
                                                        usersArray.append(user)
                                                        Helper.Pholio.seenUsers.append(user)
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                completion(usersArray)
            })
            
            
        } else {
            
            print(Helper.Pholio.allUsers.count)
            print(Helper.Pholio.seenUsers.count)
            print(usersArray.count)
            
            if Helper.Pholio.seenUsers.count == Helper.Pholio.allUsers.count {
                
                Helper.Pholio.seenUsers.removeAll()
                Helper.Pholio.allUsers.removeAll()
                
                users.queryOrdered(byChild: "dateCreated").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                    
                    print(snapshot.children.allObjects.count)
                    print(snapshot)
                    
                    guard let users = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    for user in users {
                        
                        guard let userDict = user.value as? [String: AnyObject] else { continue }
                        
                        let key = user.key
                        let user = UserModel(withUserId: key, dictionary: userDict)
                        
                        if let currentUserId = Auth.auth().currentUser?.uid {
                            if key != currentUserId {
                                Helper.Pholio.allUsers.append(user)
                            }
                        }
                        
                        if user.age >= ageFilter {
                            
                            if genderFilter == .both {
                                // no gender filter
                                if self.pairingFilterCheck(pairingFilter: pairingFilter, user: user) {
                                    
                                    if self.milesFilterCheck(user: user, filter: mileFilter) {
                                        
                                        if let currentUserId = Auth.auth().currentUser?.uid {
                                            // Check here if the user is the same as the current user
                                            // if it is dont add it to the user array
                                            if key != currentUserId {
                                                
                                                if !self.didSeeUser(user: user) && usersArray.count < self.userLimit {
                                                    
                                                    if featuredFilter {
                                                        
                                                        if user.featured {
                                                            usersArray.append(user)
                                                            Helper.Pholio.seenUsers.append(user)
                                                        }
                                                        
                                                    } else {
                                                        usersArray.append(user)
                                                        Helper.Pholio.seenUsers.append(user)
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                
                            } else {
                                
                                if user.gender == genderFilter.rawValue {
                                    
                                    if self.pairingFilterCheck(pairingFilter: pairingFilter, user: user) {
                                        
                                        if self.milesFilterCheck(user: user, filter: mileFilter) {
                                            
                                            if let currentUserId = Auth.auth().currentUser?.uid {
                                                // Check here if the user is the same as the current user
                                                // if it is dont add it to the user array
                                                if key != currentUserId {
                                                    
                                                    if !self.didSeeUser(user: user) && usersArray.count < self.userLimit {
                                                        
                                                        if featuredFilter {
                                                            
                                                            if user.featured {
                                                                usersArray.append(user)
                                                                Helper.Pholio.seenUsers.append(user)
                                                            }
                                                            
                                                        } else {
                                                            usersArray.append(user)
                                                            Helper.Pholio.seenUsers.append(user)
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    completion(usersArray)
                })
                
            } else {
                // no need to update list from firebase yet
                usersArray.removeAll()
                filteredUsers.removeAll()
                
                completion(loopThroughUsers())
                
                
                /*
                 for user in Helper.Pholio.allUsers {
                 
                 if !didSeeUser(user: user) && usersArray.count < userLimit {
                 usersArray.append(user)
                 Helper.Pholio.seenUsers.append(user)
                 }
                 
                 if usersArray.count == userLimit {
                 completion(usersArray)
                 
                 }
                 
                 }
                 */
                
                
                
            }
            
        }
        
    }
    
    private func loopThroughUsers() -> [UserModel] {
        
        for user in Helper.Pholio.allUsers {
            
            if !didSeeUser(user: user) && filteredUsers.count < userLimit {
                filteredUsers.append(user)
                Helper.Pholio.seenUsers.append(user)
            }
            
            if filteredUsers.count == userLimit {
                return filteredUsers
                
            } else if Helper.Pholio.allUsers.count == Helper.Pholio.seenUsers.count {
                Helper.Pholio.seenUsers.removeAll()
                
                return loopThroughUsers()
            }
        }
        
        return filteredUsers
    }
    
    
    private func didSeeUser(user: UserModel) -> Bool {
        if Helper.Pholio.seenUsers.contains(where: {$0.userId! == user.userId!}) {
            return true
        } else {
            return false
        }
    }
    
    private func pairingFilterCheck(pairingFilter: PairingFilter, user: UserModel) -> Bool {
        
        if pairingFilter == .photographerAndModel {
            
            if (user.userType == PairingFilter.photographer.rawValue || user.userType == PairingFilter.model.rawValue) {
                return true
            }
            
        } else if pairingFilter == .photographerAndGuest {
            
            if (user.userType == PairingFilter.photographer.rawValue || user.userType == PairingFilter.guest.rawValue) {
                
                return true
            }
            
            
        } else if pairingFilter == .modelAndGuest {
            
            if (user.userType == PairingFilter.model.rawValue || user.userType == PairingFilter.guest.rawValue) {
                return true
            }
            
            
        } else if pairingFilter == .all {
            return true
            
        } else {
            
            if user.userType == pairingFilter.rawValue {
                
                return true
            }
            
        }
        
        return false
        
    }
    
    
    private func milesFilterCheck(user: UserModel, filter: Int) -> Bool {
        
        let lat_lon = user.lat_lon.split(separator: "_")
        let currentUserLat_Lon = Helper.Pholio.currentUser.lat_lon.split(separator: "_")
        
        if let lat = lat_lon.first,
            let lon = lat_lon.last,
            
            let currentUserLat = currentUserLat_Lon.first,
            let currentUserLon = currentUserLat_Lon.last,
            
            let latDegrees = CLLocationDegrees(lat),
            let lonDegrees = CLLocationDegrees(lon),
            
            let currentUserLatDegrees = CLLocationDegrees(currentUserLat),
            let currentUserLonDegrees = CLLocationDegrees(currentUserLon) {
            
            
            // check the distance between the users
            let userLocation = CLLocation(latitude: latDegrees, longitude: lonDegrees)
            let currentUserLocation = CLLocation(latitude: currentUserLatDegrees, longitude: currentUserLonDegrees)
            
            let distanceInMeters = currentUserLocation.distance(from: userLocation)
            let distanceInMiles = distanceInMeters / 1609.344
            
            print(distanceInMiles)
            print("distance in miles")
            
            if distanceInMiles >= Double(filter) {
                return true
            }
        }
        
        return false
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
