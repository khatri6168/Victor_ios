//
//  AccountViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit
import Nuke

protocol AccountProtocol : AnyObject {
    func selectIndex(index : Int)
}


class AccountViewController: UIViewController ,UIGestureRecognizerDelegate{
    weak var delegate : AccountProtocol? = nil

   //SET VIEW VALUES
    @IBOutlet weak var conViewHeader: NSLayoutConstraint!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var conTopView: NSLayoutConstraint!
    @IBOutlet weak var conHeightView: NSLayoutConstraint!
    @IBOutlet weak var conTotlaViewBouttom: NSLayoutConstraint!

    //SET VIEW ANIMATION
    var initialConViewBgTop: CGFloat = 0.0
    var topSpacing: CGFloat = 20.0
    var safeAreaTopPadding: CGFloat = 0.0
    var bgAlpha: CGFloat = 0.8

    var arrList : [MyProfile] = []

    //SET TABLE VALUE
    @IBOutlet weak var viewItemMenu: UIView!
    @IBOutlet weak var tblView: UITableView!


    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = tabBarPreviousIndexSelect
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setTheData), name: .colourMode, object: nil)

        
        //GET SAFEAREA
        if #available(iOS 11.0, *) {
            let window: UIWindow? = UIApplication.shared.keyWindow
            safeAreaTopPadding = (window?.safeAreaInsets.top)!
        } else {
            safeAreaTopPadding = 0.0
        }

        //SET TOTLA VIEW
        let selectedIndex = self.tabBarController?.selectedIndex
        print(selectedIndex as Any)

        conTotlaViewBouttom.constant = manageWidth(size: 50.0)
        if self.tabBarController?.tabBar.selectedItem?.tag == 2{
            conTotlaViewBouttom.constant = manageWidth(size: 90.0)
        }


        //ADD PANGESTURE
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.delegate = self
        viewFilter.addGestureRecognizer(pan)
        view.layoutIfNeeded()
    }

   
    override func viewWillAppear(_ animated: Bool) {
        setTheData()
        
        //SET TO VIEW CONSTANT
        conTopView.constant = self.view.bounds.size.height;
        self.viewItemMenu.backgroundColor = setColour()

        //SET VIEW RADIUS
        let maskLayer = CAShapeLayer()
        maskLayer.frame = viewFilter.bounds
        maskLayer.path = UIBezierPath(roundedRect: viewFilter.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        viewFilter.layer.mask = maskLayer
        viewFilter.layer.masksToBounds = true

    }

    override func viewDidAppear(_ animated: Bool) {
        //SET BG COLOR
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.conTopView.constant = self.topSpacing + self.safeAreaTopPadding
            self.view.backgroundColor = UIColor.black.withAlphaComponent(self.bgAlpha)
            self.view.layoutIfNeeded()
        }) { finished in

        }
    }

    
    
    override func viewWillLayoutSubviews() {
        //VIEW RADIUS
        viewItemMenu.layer.masksToBounds = true
        viewItemMenu.layer.cornerRadius = 5.0

        //SET VIEW CONSTANT
        conHeightView.constant = view.bounds.size.height - (topSpacing + safeAreaTopPadding)
    }


    //..................... OTHER FUNCTION .................//
    @objc func setTheData(){
        //SET LIST
        arrList = []
        if UserDefaults.standard.user == nil{
            conViewHeader.constant = manageWidth(size: 500)
            arrList = [MyProfile(name: str.strLogin, icon: ""), MyProfile(name: str.strRegister, icon: "")]
            tblView.reloadData()
        }
        else{
            conViewHeader.constant = manageWidth(size: 350)
            
            var strMode = str.strDarkMode
            var strIcon = "icon_darckMode"
            if UserDefaults.standard.colourMode == "dark"{
                strMode = str.strLightMode
                strIcon = "icon_lightMode"
            }
            arrList = [MyProfile(name: "Profile", icon: ""),
                       MyProfile(name: str.strNotificaiotn, icon: "icon_notification"),
                       MyProfile(name: str.strAccountSetting, icon: "icon_setting"),
                       MyProfile(name: strMode, icon: strIcon),
                       MyProfile(name: str.strLogOut, icon: "icon_logout")]
            tblView.reloadData()
        }
    }

    //...................... BUTTON ACTION .....................//
    //MARK: - BUTTON ACTION -

}

//.............................. UIPanGestureRecognizer .....................//
//MARK: - UIPanGestureRecognizer -

extension AccountViewController {
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {

        if recognizer.state == .began {
            initialConViewBgTop = conTopView.constant
        }
        else if recognizer.state == .ended || recognizer.state == .failed || recognizer.state
            == .cancelled {

            if (conTopView.constant < conHeightView.constant/manageHeight(size: 4.5)){
                //SET VIEW ON TOP
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                    self.conTopView.constant = self.topSpacing + self.safeAreaTopPadding
                    self.view.backgroundColor = UIColor.black.withAlphaComponent((self.bgAlpha * self.topSpacing) / self.conTopView.constant)
                    self.view.layoutSubviews()
                }) { finished in
                }
            }
            else{
                //DISMISS VIEW
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                    self.conTopView.constant = self.conHeightView.constant + (self.topSpacing + self.safeAreaTopPadding)
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                    self.view.layoutSubviews()
                }) { finished in
                    self.dismiss(animated: false)
                }

            }


        }
        else{

            //SET TOP CONSTANT
            let translatedPoint: CGPoint = recognizer.translation(in: recognizer.view!.superview)
            conTopView.constant = max(initialConViewBgTop + translatedPoint.y, topSpacing)

            //SET BG ALPHA
            let alphaComponent: CGFloat = (bgAlpha * topSpacing) / conTopView.constant
            view.backgroundColor = UIColor.black.withAlphaComponent(alphaComponent)

        }
    }
    
    func closePopup(strIndex : Int){
        //DISMISS VIEW
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.conTopView.constant = self.conHeightView.constant + (self.topSpacing + self.safeAreaTopPadding)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutSubviews()
        }) { finished in
            
            self.dismiss(animated: false) {
                self.delegate?.selectIndex(index: strIndex)
            }
        }
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}




//.......................... UITABLE VIEW ..........................//

//MARK: -- UITABEL CELL --
class AccountCell : UITableViewCell{
    @IBOutlet weak var conImgWidth: NSLayoutConstraint!
    @IBOutlet weak var conImgHeight: NSLayoutConstraint!
    @IBOutlet weak var conImgSpace: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewLine: UIView!
}

//MARK: -- UITABEL DELEGATE --

extension AccountViewController:UITableViewDelegate, UITableViewDataSource{

    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //ACCOUNT
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
        cell.backgroundColor = UIColor.clear
        
        //GET DATA
        let obj = self.arrList[indexPath.row]
        
        //SET PROFILE
        cell.viewLine.isHidden = true
        if obj.name == "Profile"{
            //SET CONSTANT
            cell.viewLine.isHidden = false
            cell.conImgSpace.constant = 16
            cell.conImgWidth.constant = 55
            cell.conImgHeight.constant = 55

            if let objUser = UserDefaults.standard.user{
                //SET IMAGE
                if let strImg = objUser.profile_pic{
                    var strProfileImage : String = ""
                    if strImg.contains("https://") {
                        strProfileImage = strImg
                    }
                    else{
                        strProfileImage = "https://freemusic.digital/\(strImg)"
                    }
                                    
                    let imgURL =  ("\(strProfileImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                    if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                        Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.img)
                    }
                }
                
                //SET FONT AND DETAILS
                cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 16.0, text: objUser.username ?? "")
            }
        }
        else{
            //SET CONSTANT
            cell.conImgSpace.constant = 0
            cell.conImgWidth.constant = 0
            cell.conImgHeight.constant = 25
            if obj.icon != ""{

                cell.conImgSpace.constant = 16
                cell.conImgWidth.constant = 25
                cell.conImgHeight.constant = 25

                //SET IMAGE
                cell.img.image = UIImage(named: obj.icon)
                imgColor(imgColor: cell.img, colorHex: setTextColour())
            }
            
            //SET FONT AND DETAILS

            cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: obj.name)
            
        }
      
        cell.layoutIfNeeded()
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.closePopup(strIndex: indexPath.row)
    }
    
}
