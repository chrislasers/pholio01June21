//
//  NewContentViewController.swift
//  pholio01
//
//  Created by Chris  Ransom on 10/19/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit

var NewContentViewControllerVC = NewContentViewController()

class NewContentViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController : UIPageViewController?
    var pages = [UserModel]()
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NewContentViewControllerVC = self
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let startingViewController: NewPreViewViewController = viewControllerAtIndex(index: currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = view.bounds
        
        
        
        
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        view.sendSubviewToBack(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UIPageViewControllerDataSource
    //1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! NewPreViewViewController).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    //2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PreViewController).pageIndex
        if index == NSNotFound {
            return nil
        }
        index += 1
        if (index == self.pages.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    
    //3
    func viewControllerAtIndex(index: Int) -> NewPreViewViewController? {
        if self.pages.count == 0 || index >= self.pages.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPreViewViewController") as! NewPreViewViewController
        vc.pageIndex = index
        
        vc.items = self.pages[index].items
        vc.usersArray = self.pages
        currentIndex = index
        
        vc.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        return vc
    }
    
    // Navigate to next page
    func goNextPage(fowardTo position: Int) {
        let startingViewController: NewPreViewViewController = viewControllerAtIndex(index: position)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: true, completion: nil)
        
    }
    
    // MARK: - Button Actions
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

