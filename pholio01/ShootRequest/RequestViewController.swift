//
//  RequestViewController.swift
//  pholio01
//
//  Created by Chris  Ransom on 11/9/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Pastel

class RequestViewController: UIViewController {
    
    
    
    var pageIndex : Int = 0
    var items = [[String: Any]]()
    var item = [[String : String]]()
    //var SPB: SegmentedProgressBar!
    //var player: AVPlayer!
    
    var usersArray = [UserModel]()
    
    
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        print(FriendSystem.system.requestList)
        
       
        UserModel.system.addRequestObserver {
            print(FriendSystem.system.requestList)
            self.tableView.reloadData()
        }
    }
    
}

extension RequestViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.system.requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserCellTwo") as? UserCell
        if cell == nil {
            tableView.register(UINib(nibName: "UserCellTwo", bundle: nil), forCellReuseIdentifier: "UserCellTwo")
            cell = tableView.dequeueReusableCell(withIdentifier: "UserCellTwo") as? UserCell
        }
        
        // Modify cell
        cell!.button.setTitle("Accept Shoot", for: UIControl.State())
        cell!.emailLabel.text = UserModel.system.requestList[indexPath.row].email 
        
        cell!.setFunction {
            
            let id = UserModel.system.requestList[indexPath.row].userId
            UserModel.system.acceptFriendRequest(id!)
            
             print("Interested")
            
            
            let matchedUser = UserModel.system.requestList[indexPath.row]
            
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
            }
        }
        
        // Return cell
        return cell!
    }
    
}

