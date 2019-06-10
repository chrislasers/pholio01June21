//
//  BaseSlidingController.swift
//  SlideOutMenuLBTA
//
//  Created by Brian Voong on 9/30/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

class BaseSlidingController: UIViewController {
    
    let redView: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let blueView: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        
        setupViews()
        
        // how do we translate our red view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        var x = translation.x
        
        x = min(menuWidth, x)
        
        redViewLeadingConstraint.constant = x
    }
    
    var redViewLeadingConstraint: NSLayoutConstraint!
    fileprivate let menuWidth: CGFloat = 300
    
    fileprivate func setupViews() {
        view.addSubview(redView)
        view.addSubview(blueView)
        
        // let's go ahead and use Auto Layout
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: view.topAnchor),
            redView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            redView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            blueView.topAnchor.constraint(equalTo: view.topAnchor),
            blueView.trailingAnchor.constraint(equalTo: redView.leadingAnchor),
            blueView.widthAnchor.constraint(equalToConstant: menuWidth),
            blueView.bottomAnchor.constraint(equalTo: redView.bottomAnchor)
            ])
        
        self.redViewLeadingConstraint = redView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
     redViewLeadingConstraint.constant = 150
        redViewLeadingConstraint.isActive = true
    }

}
