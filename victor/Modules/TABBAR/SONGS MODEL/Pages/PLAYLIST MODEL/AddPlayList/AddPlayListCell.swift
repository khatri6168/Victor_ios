//
//  AddPlayListCell.swift
//  victor
//
//  Created by Jigar Khatri on 18/11/21.
//

import UIKit

class AddPlayListCell: UITableViewCell {
    @IBOutlet weak var imgUploadImage: UIImageView!

    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtName: UITextField!

    @IBOutlet weak var lblCollaborative: UILabel!
    @IBOutlet weak var lblCollaborativeDetails: UILabel!

    @IBOutlet weak var lblPublic: UILabel!
    @IBOutlet weak var lblPublicDetails: UILabel!

    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtDescription: UITextView!


    @IBOutlet weak var viewUploadImage: UIView!
    @IBOutlet weak var btnUploadImage: UIButton!

    @IBOutlet weak var objSwitchCollaborative: UISwitch!
    @IBOutlet weak var objSwitchPublic: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setTheView()
        setTheFont()    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTheView(){

        //SET NAME VIEW
        self.viewName.backgroundColor = .clear
        self.viewName.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewName.viewBorderCorneRadiusLight(borderColour: .gray)
    
        self.viewDescription.backgroundColor = .clear
        self.viewDescription.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewDescription.viewBorderCorneRadiusLight(borderColour: .gray)
    }
    
    
    func setTheFont(){
        //SET FONT
        lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strName)
        lblDescription.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strDescription)

        lblCollaborative.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strCollaborative)
        lblCollaborativeDetails.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: str.strCollaborativeDetails)

        lblPublic.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strPublic)
        lblPublicDetails.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: str.strPublicDetails)

        
        txtName.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtName.delegate = self
        
        txtDescription.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "")
        txtDescription.delegate = self

        
        self.viewUploadImage.viewCorneRadius(radius: 5.0, isRound: false)
        btnUploadImage.configureLable(bgColour: UIColor.clear, textColor: UIColor.secondary, fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strUploadImg)

    }
    

}


extension AddPlayListCell:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtName {
            self.viewName.viewBorderCorneRadiusLight(borderColour: UIColor.standard)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
}

extension AddPlayListCell: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        setTheView()
        if textView == txtDescription {
            self.viewDescription.viewBorderCorneRadiusLight(borderColour: UIColor.standard)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setTheView()
    }
}
