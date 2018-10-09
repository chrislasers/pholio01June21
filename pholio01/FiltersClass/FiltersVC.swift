//
//  FiltersVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 9/14/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import Firebase

class FiltersVC: UIViewController {
    
    @IBOutlet weak var allUsers: FilterButtons!
    
    @IBOutlet weak var featured: FilterButton02!
    
    @IBOutlet weak var photographer: FilterButton03!
    
    @IBOutlet weak var model: FilterButton04!
    
    @IBOutlet weak var male: FilterButton07!
    
    @IBOutlet weak var guest: FilterButton06!
    
    @IBOutlet weak var female: FilterButton08!
    
    @IBOutlet weak var both: FilterButton09!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var mileSlider: UISlider!
    
    var userRef: DatabaseReference!
    
    var pairingWithArray = [PairingFilter]()
    
    var featuredUsers = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed In")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
        }
        
        userRef = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid)
        
        if Helper.Pholio.currentUser.featuredFilter {
            featured.activateButton(bool: true)
            allUsers.activateButton(bool: false)
            featuredUsers = true
        } else {
            featured.activateButton(bool: false)
            allUsers.activateButton(bool: true)
            featuredUsers = false
        }
        
        switch Helper.Pholio.currentUser.genderFilter {
        case .male?:
            male.activateButton(bool: true)
            female.activateButton(bool: false)
            both.activateButton(bool: false)
            
        case .female?:
            male.activateButton(bool: false)
            female.activateButton(bool: true)
            both.activateButton(bool: false)
            
        case .both?:
            male.activateButton(bool: false)
            female.activateButton(bool: false)
            both.activateButton(bool: true)
            
        default:
            break
        }
        
        switch Helper.Pholio.currentUser.pairingFilter {
        case .photographer?:
            photographer.activateButton(bool: true)
            model.activateButton(bool: false)
            guest.activateButton(bool: false)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(.photographer)
            
        case .model?:
            photographer.activateButton(bool: false)
            model.activateButton(bool: true)
            guest.activateButton(bool: false)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(.model)
            
        case .guest?:
            photographer.activateButton(bool: false)
            model.activateButton(bool: false)
            guest.activateButton(bool: true)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(.guest)
            
        case .all?:
            photographer.activateButton(bool: true)
            model.activateButton(bool: true)
            guest.activateButton(bool: true)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(contentsOf: [.photographer, .model, .guest])
            
        case .photographerAndModel?:
            photographer.activateButton(bool: true)
            model.activateButton(bool: true)
            guest.activateButton(bool: false)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(contentsOf: [.photographer, .model])
            
        case .photographerAndGuest?:
            photographer.activateButton(bool: true)
            model.activateButton(bool: false)
            guest.activateButton(bool: true)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(contentsOf: [.photographer, .guest])
            
        case .modelAndGuest?:
            photographer.activateButton(bool: false)
            model.activateButton(bool: true)
            guest.activateButton(bool: true)
            
            pairingWithArray.removeAll()
            pairingWithArray.append(contentsOf: [.model, .guest])
            
        default:
            break
        }
        
        // add button targets
        male.addTarget(self, action: #selector(malePressed), for: .touchUpInside)
        female.addTarget(self, action: #selector(femalePressed), for: .touchUpInside)
        both.addTarget(self, action: #selector(bothPressed), for: .touchUpInside)
        
        photographer.addTarget(self, action: #selector(photographerPressed), for: .touchUpInside)
        model.addTarget(self, action: #selector(modelPressed), for: .touchUpInside)
        guest.addTarget(self, action: #selector(guestPressed), for: .touchUpInside)
        
        allUsers.addTarget(self, action: #selector(allUsersPressed), for: .touchUpInside)
        featured.addTarget(self, action: #selector(featuredPressed), for: .touchUpInside)
        
        ageSlider.value = Float(Helper.Pholio.currentUser.ageFilter)
        ageLabel.text = String(Int(ageSlider.value))
        
        mileSlider.value = Float(Helper.Pholio.currentUser.milesFilter)
        matchLabel.text = String(Int(mileSlider.value))
    }
    
    @objc func malePressed() {
        male.activateButton(bool: true)
        female.activateButton(bool: false)
        both.activateButton(bool: false)
        
        updateGenderFilter(genderFilter: .male)
    }
    
    @objc func femalePressed() {
        male.activateButton(bool: false)
        female.activateButton(bool: true)
        both.activateButton(bool: false)
        
        updateGenderFilter(genderFilter: .female)
    }
    
    @objc func bothPressed() {
        male.activateButton(bool: false)
        female.activateButton(bool: false)
        both.activateButton(bool: true)
        
        updateGenderFilter(genderFilter: .both)
    }
    
    @objc func photographerPressed() {
        if let index = pairingWithArray.index(where: {$0 == PairingFilter.photographer }) {
            pairingWithArray.remove(at: index)
            photographer.activateButton(bool: false)
            
        } else {
            pairingWithArray.append(.photographer)
            photographer.activateButton(bool: true)
        }
        
        updateUserTypeFilter()
        
    }
    
    @objc func modelPressed() {
        if let index = pairingWithArray.index(where: {$0 == PairingFilter.model }) {
            pairingWithArray.remove(at: index)
            model.activateButton(bool: false)
            
        } else {
            pairingWithArray.append(.model)
            model.activateButton(bool: true)
        }
        
        updateUserTypeFilter()
    }
    
    @objc func guestPressed() {
        if let index = pairingWithArray.index(where: {$0 == PairingFilter.guest }) {
            pairingWithArray.remove(at: index)
            guest.activateButton(bool: false)
            
        } else {
            pairingWithArray.append(.guest)
            guest.activateButton(bool: true)
        }
        
        updateUserTypeFilter()
    }
    
    private func updateGenderFilter(genderFilter: GenderFilter) {
        Helper.Pholio.shouldRefreshFilteredList = true
        
        Helper.Pholio.currentUser.genderFilter = genderFilter
        userRef.child("GenderFilter").setValue(genderFilter.rawValue)
    }
    
    private func updateAgeFilter(ageFilter: Int) {
        Helper.Pholio.currentUser.ageFilter = ageFilter
        userRef.child("AgeFilter").setValue(ageFilter)
    }
    
    private func updateMilesFilter(milesFilter: Int) {
        Helper.Pholio.currentUser.milesFilter = milesFilter
        userRef.child("MilesFilter").setValue(milesFilter)
    }
    
    private func updateUserTypeFilter() {
        Helper.Pholio.shouldRefreshFilteredList = true
        
        var pairingFilter: PairingFilter
        
        if pairingWithArray.count == 3 {
            pairingFilter = .all
            
        } else if pairingWithArray.count == 2 {
            
            if pairingWithArray.contains(.photographer) && pairingWithArray.contains(.model) {
                pairingFilter = .photographerAndModel
                
            } else if pairingWithArray.contains(.photographer) && pairingWithArray.contains(.guest) {
                pairingFilter = .photographerAndGuest
                
            } else {
                pairingFilter = .modelAndGuest
            }
            
        } else {
            
            if let first = pairingWithArray.first {
                pairingFilter = first
            } else {
                pairingFilter = .all
                
                photographer.activateButton(bool: true)
                model.activateButton(bool: true)
                guest.activateButton(bool: true)
                
                pairingWithArray.append(contentsOf: [.photographer, .model, .guest])
            }
        }
        
        Helper.Pholio.currentUser.pairingFilter = pairingFilter
        userRef.child("PairingFilter").setValue(pairingFilter.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateAgeFilter(ageFilter: Int(ageSlider.value))
        updateMilesFilter(milesFilter: Int(mileSlider.value))
        
        Helper.Pholio.currentUser.featuredFilter = featuredUsers
        userRef.child("FeaturedFilter").setValue(featuredUsers)
    }
    
    @IBAction func ageSlider(_ sender: UISlider) {
        Helper.Pholio.shouldRefreshFilteredList = true
        ageLabel.text = String(Int(sender.value))
    }
    
    @IBAction func matchRadiusSlider(_ sender: UISlider) {
        Helper.Pholio.shouldRefreshFilteredList = true
        matchLabel.text = String(Int(sender.value))
    }
    
    
    @objc func allUsersPressed() {
        Helper.Pholio.shouldRefreshFilteredList = true
        
        featuredUsers = false
        
        allUsers.activateButton(bool: true)
        featured.activateButton(bool: false)
    }
    
    @objc func featuredPressed() {
        Helper.Pholio.shouldRefreshFilteredList = true
        
        featuredUsers = true
        
        allUsers.activateButton(bool: false)
        featured.activateButton(bool: true)
    }
    
    var isOn = false
    
}
