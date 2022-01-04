//
//  UserProfileViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit

class UserProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        return
        // Do any additional setup after loading the view.
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = tabBarPreviousIndexSelect
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = tabBarPreviousIndexSelect
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = tabBarPreviousIndexSelect
        }
        

        //SET VIEW
        self.view.backgroundColor = setColour()
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
        //SET NAVIGATION BAR
        //SET NAVIGATION BAR
        setNavigationBarFor(controller: self, title: "", isTransperent: true, hideShadowImage: false, leftIcon: "", rightIcon: "") {SelectTag in
//            self.navigationController?.popViewController(animated: true)
        } rightActionHandler: {SelectTag in
        }
    }
}
