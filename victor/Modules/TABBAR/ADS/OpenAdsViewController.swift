//
//  OpenAdsViewController.swift
//  victor
//
//  Created by Jigar Khatri on 13/12/21.
//

import UIKit

class OpenAdsViewController: UIViewController ,AppOpenAdManagerDelegate{
    func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AppOpenAdManager.shared.appOpenAdManagerDelegate = self
            AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        //SET BG COLOR
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { finished in

        }
    }

    
}
