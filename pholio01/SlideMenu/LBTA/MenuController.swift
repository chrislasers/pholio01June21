//
//  MenuController.swift
//  SlideOutMenuLBTA
//
//  Created by Brian Voong on 9/25/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

struct MenuItem {
    let icon: UIImage
    let title: String
}

extension MenuController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//       let slidingController = BViewController()
//        slidingController.didSelectMenuItem(indexPath: indexPath)

        
       if(indexPath.row == 0)
       {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "Filters") as! FiltersVC
        
        self.navigationController?.pushViewController(controller, animated: true)


       } else if(indexPath.row == 1) {

           let storyboard = UIStoryboard(name: "Main", bundle: nil)

          let controller = storyboard.instantiateViewController(withIdentifier: "Filters") as! FiltersVC

          self.navigationController?.pushViewController(controller, animated: true)


       }
    }
}

class MenuController: UITableViewController {
    
    let menuItems = [
        MenuItem(icon: #imageLiteral(resourceName: "profile"), title: "Home"),
        MenuItem(icon: #imageLiteral(resourceName: "lists"), title: "Lists"),
        MenuItem(icon: #imageLiteral(resourceName: "bookmarks"), title: "Bookmarks"),
        MenuItem(icon: #imageLiteral(resourceName: "moments"), title: "Moments"),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customHeaderView = CustomMenuHeaderView()
        return customHeaderView
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuItemCell(style: .default, reuseIdentifier: "cellId")
        let menuItem = menuItems[indexPath.row]
        cell.iconImageView.image = menuItem.icon
        cell.titleLabel.text = menuItem.title
        return cell
    }
    
}
