//
//  FiltersVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 9/14/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func ageSlider(_ sender: UISlider) {
        
        ageLabel.text = String(Int(sender.value))
    }
    
    @IBAction func matchRadiusSlider(_ sender: UISlider) {
        
        matchLabel.text = String(Int(sender.value))

    }
    
    
    var isOn = false
    

   
    
    
    
    


}
