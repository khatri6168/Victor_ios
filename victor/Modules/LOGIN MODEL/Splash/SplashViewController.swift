//
//  SplashViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //CHECK USER REMEMBER
        if UserDefaults.standard.userRemeber == "false" || UserDefaults.standard.userRemeber == nil{
            UserDefaults.standard.user = nil
        }
        
        //MOVE TO TABBAR
        let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.TABBAR, bundle: nil)
        let tabBariewController = storyBoard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        GlobalConstants.appDelegate?.window?.rootViewController = tabBariewController
        GlobalConstants.appDelegate?.window?.makeKeyAndVisible()

    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
