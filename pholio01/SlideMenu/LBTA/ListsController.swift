//
//  ListsController.swift
//  SlideOutMenuLBTA
//
//  Created by Brian Voong on 10/4/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

class ListsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Lists"
        label.font = UIFont.boldSystemFont(ofSize: 64)
        label.frame = view.frame
        label.textAlignment = .center
        
        view.addSubview(label)
    }

}
