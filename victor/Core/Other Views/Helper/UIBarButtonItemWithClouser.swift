//
//  UIBarButtonItemWithClouser.swift
//  Deonde
//
//  Created by Ankit Rupapara on 28/04/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import UIKit

class UIBarButtonItemWithClouser: UIBarButtonItem {

    private var actionHandler: ((_ SelectTag : Int) -> Void)?
    
    convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: ((_ SelectTag : Int) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.target = self
        self.action = #selector(barButtonItemPressed(sender:))
        self.actionHandler = actionHandler
    }
    
    convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItem.Style, actionHandler: ((_ SelectTag : Int) -> Void)?) {
        
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
        self.target = self
        self.action = #selector(barButtonItemPressed(sender:))
        self.actionHandler = actionHandler
    }
    

    
    convenience init(button: UIButton, actionHandler: ((_ SelectTag : Int) -> Void)?) {
        self.init(customView: button)
        self.tag = button.tag
        button.addTarget(self, action: #selector(barButtonItemPressed(sender:)), for: .touchUpInside)
        self.actionHandler = actionHandler
    }
    
    convenience init(view: UIView, actionHandler: ((_ SelectTag : Int) -> Void)?) {
        self.init(customView: view)
        self.target = self
        self.action = #selector(barButtonItemPressed(sender:))
        self.actionHandler = actionHandler
    }
    
    @objc private func barButtonItemPressed(sender: UIBarButtonItem) {
        if let actionHandler = self.actionHandler {
            actionHandler(self.tag)
        }
    }
}


