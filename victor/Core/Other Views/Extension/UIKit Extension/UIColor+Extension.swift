//
//  UIColor+Extension.swift
//  Deonde
//
//  Created by Ankit Rupapara on 21/04/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import UIKit


//Never user Color enum directly, use UIColor's Extenion's property only
enum Color {
    static let primary = UIColor(named: "primary")
    static let secondary = UIColor(named: "secondary")
    static let secondaryLight = UIColor(named: "secondary_Light")

    static let standard = UIColor(named: "Standard")
    static let grayLight = UIColor(named: "grayLight")

    
    
}

extension UIColor{
    static let primary = Color.primary
    static let secondary = Color.secondary
    static let secondaryLight = Color.secondaryLight
    
    static let standard = Color.standard
    static let grayLight = Color.grayLight
}
