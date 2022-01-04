//
//  UILabel+Extension.swift
//  Deonde
//
//  Created by Ankit Rupapara on 27/04/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import UIKit

extension UILabel {
    var requiredWidth: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: frame.height))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.width
    }

    var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    func configureLable(textColor:UIColor?, fontName:String, fontSize : Double, text:String) {
        self.textColor = textColor
        self.font = SetTheFont(fontName: fontName, size: fontSize)
        self.text = text
    }
    
    func configureHTMLLable(textColor:UIColor?, fontName:String, fontSize : Double) {
//        self.textColor = textColor
        self.font = SetTheFont(fontName: fontName, size: fontSize)
        self.textAlignment = .center
    }
    
    func addTextSpacing(spacing: CGFloat, color: UIColor) {
        guard let text = text else { return }

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: NSRange(location: 0, length: text.count))

        attributedText = attributedString
    }
    
    func setAttributedHtmlText(_ html: String) {
        #if targetEnvironment(simulator)
        self.text = html
        #else
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
        }
        #endif
    }
}


extension UIButton{
    func configureLable(bgColour : UIColor?, textColor:UIColor?, fontName:String, fontSize : Double, text:String) {
        self.backgroundColor = UIColor.clear
        self.backgroundColor = bgColour
        self.setTitleColor(textColor , for: .normal)
        self.titleLabel?.font = SetTheFont(fontName: fontName, size: fontSize)
        self.setTitle(text, for: .normal)
    }
    
    func btnCorneRadius(radius : CGFloat, isRound : Bool){
        self.layer.masksToBounds = true
        if isRound{
            self.layer.cornerRadius = self.frame.size.height / 2
        }
        else{
            self.layer.cornerRadius = radius
        }
    }
    
    
    func btnnBorder (bgColour : UIColor?){
        self.layer.borderWidth = 1
        self.layer.borderColor =  bgColour?.cgColor
    }

    
  
    func btnAttributes(str : String ,location : Int, lenght : Int){

        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .foregroundColor: setTextColour(),
          .kern: 0.0
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor.standard!, range: NSRange(location: location, length: lenght))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func dropButtonShadow(bgColour : UIColor?) {
        layer.masksToBounds = false
        layer.shadowColor = bgColour?.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 12
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}


extension UITextField{
    func configureText(bgColour : UIColor, textColor:UIColor?, fontName:String, fontSize : Double, text:String, placeholder : String) {
        self.backgroundColor = bgColour

        self.textColor = textColor
        self.font = SetTheFont(fontName: fontName, size: fontSize)
        self.text = text
//        self.placeholder = placeholder
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [NSAttributedString.Key.foregroundColor:  UIColor.lightGray ,NSAttributedString.Key.font:  SetTheFont(fontName: fontName, size: fontSize)])
    }
    
   

}


extension UITextView{
    func configureText(bgColour : UIColor, textColor:UIColor, fontName:String, fontSize : Double, text:String) {
        self.backgroundColor = UIColor.clear
        self.backgroundColor = bgColour

        self.textColor = textColor
        self.font = SetTheFont(fontName: fontName, size: fontSize)
        self.text = text
    }
    
    
    func setAttributedHtmlText(_ html: String) {
        #if targetEnvironment(simulator)
        self.text = html
        #else
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
        }
        #endif
    }
}




