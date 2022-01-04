//
//  NoInternetViewController.swift
//  Belboy
//
//  Created by Jigar Khatri on 30/04/21.
//

import UIKit
import Alamofire
import AVFoundation

protocol InternetAccessDelegate {
    func ReceiveInternetNotify(strMethodName: String)
}

class NoInternetViewController: UIViewController{

    @IBOutlet weak var lblConnectionTitle : UILabel!
    @IBOutlet weak var lblConnectionSubTitle : UILabel!
    @IBOutlet weak var imgLogo : UIImageView!
    @IBOutlet weak var btnRetry : UIButton!
    var strCallingMethodName : String = ""
    var delegate: InternetAccessDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SetFontAndColors()
    }
    
    //MARK:- SET FONT AND COLORS
    func SetFontAndColors(){
        self.view.backgroundColor = UIColor.primary

        //SET FONT
        lblConnectionTitle.configureLable(textColor: setColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 16.0, text: str.noNetTitle)
        lblConnectionSubTitle.configureLable(textColor: setColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.noNetTitle2)

        btnRetry.configureLable(bgColour: UIColor.secondary, textColor: .primary, fontName: GlobalConstants.APP_FONT_Medium, fontSize: 15.0, text: str.strRetry)
        btnRetry.dropShadow(bgColour: .secondary, radius: btnRetry.frame.size.height / 2)

//        imgColor(imgColor: imgLogo, colorHex: .primary)
        
    }
    
    @IBAction func btnRetryClick(_ sender : UIButton){
        if NetworkReachabilityManager()!.isReachable {
            self.delegate?.ReceiveInternetNotify(strMethodName: strCallingMethodName)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
