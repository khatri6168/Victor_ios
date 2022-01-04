//
//  GetMore.swift
//  SAMUH
//
//  Created by Jigar Khatri on 23/06/21.
//

import UIKit
protocol GetMorePROTOCOL {
    func selectGetCoine()
}

class GetMore: UIView {
    var delegate : GetMorePROTOCOL? = nil

    //VIEW
    @IBOutlet weak var subView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var viewWhatchAds: UIView!
    @IBOutlet var lblWhatchAds: UILabel!

    
    // method to load reasons xib.
    func loadPopUpView() {
        // ContactUS name of the XIB.
        Bundle.main.loadNibNamed("GetMore", owner:self, options:nil)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        self.subView.layer.cornerRadius = 10.0
        self.mainView.frame = self.bounds
        self.addSubview(self.mainView)
        self.mainView.layoutIfNeeded()
        
      
        

        //SET ANIMATION
        self.subView.transform = CGAffineTransform(scaleX: 0.2, y:0.2)
        UIView.animate(withDuration:1.0, delay: 0.0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: [], animations:
            {
                self.subView.transform = CGAffineTransform(scaleX: 1.0, y:1.0)
        }, completion:nil)
        
       
        
        //SET FONT
        setTheView()
    }
    
    func removeViewWithAnimation(isClose : Bool) {
        self.subView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.1, animations: {
            self.subView.transform = CGAffineTransform(scaleX: 1.01, y:1.01)
        } ,completion:{ (finished) in
            if(finished) {
                self.alpha = 1.0
                UIView.animate(withDuration:0.5, animations: {
                    self.alpha = 0
                    self.subView.transform = CGAffineTransform(scaleX: 0.2, y:0.2)
                }, completion: { (finished) in
                    if(finished) {
                        self.removeFromSuperview()
                    }
                })
            }
        })
    }
    
    //SET THE VIEW
    func setTheView() {
        //SET VIEW
        self.viewWhatchAds.backgroundColor = UIColor.standard
        self.viewWhatchAds.viewCorneRadius(radius: 5.0, isRound: false)

        //SET FONT
        lblTitle.configureLable(textColor: UIColor.secondary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 16.0, text: str.getMoreCoine)
        lblWhatchAds.configureLable(textColor: UIColor.secondary, fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16.0, text: str.whatchAds)

//        btnSave.configureLable(bgColour: UIColor.secondary, textColor: .primary, fontName: GlobalConstants.APP_FONT_POPPINS_Medium, fontSize: 15.0, text: str.strSave)
//        btnSave.btnCorneRadius(radius: 0, isRound: true)
//        
//        btnCancel.configureLable(bgColour: UIColor.clear, textColor: UIColor.background, fontName: GlobalConstants.APP_FONT_POPPINS_Medium, fontSize: 15.0, text: str.strCancel)
//        btnCancel.btnCorneRadius(radius: 0, isRound: true)
//        btnCancel.alpha = 0.5

        //SET VIEW
        self.subView.backgroundColor = UIColor.clear
        self.subView.viewCorneRadius(radius: 10.0, isRound: false)
    }
    
    //......................... OTHER FUNCION .........................//
    @IBAction func btnCloseClicked(_ sender: Any) {
        removeViewWithAnimation(isClose: false)
    }
    
    @IBAction func btnSaveClicked(_ sender: UIButton) {
        self.delegate?.selectGetCoine()
        removeViewWithAnimation(isClose: false)
    }

   
}




