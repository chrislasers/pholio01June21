//
//  EditProfileVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

class EditGalleryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    
    @IBAction func addPhoto(_ sender: Any) {
        self.performSegue(withIdentifier: "toaddPhoto", sender: nil)
        
    }
    
    
    @IBAction func toImages(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "toaddPhoto", sender: nil)
        
    }
    
    
    
    
}
