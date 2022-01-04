//
//  LoginViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit

class LoginViewController: UIViewController ,UIGestureRecognizerDelegate{

    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!

    //LABLE
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFreeMusic: UILabel!

    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!

    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var txtPassword: UITextField!

    @IBOutlet weak var btnForgotPassword: UIButton!

    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var lblRememmber: UILabel!

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    //OTHER
    var selectRemember : Bool = true
    var isSignupScreen : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToHomeScreen), name: .loginScuuess, object: nil)

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            //SET THE VIEW
            self.setTheFont()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SET VIEW
        self.view.backgroundColor = setColour()

        imgBG.isHidden = true
        if UserDefaults.standard.colourMode == "light"{
            imgBG.isHidden = false
            imgBG.image = UIImage(named: "icon_BG")
        }
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        
        //SET NAVIGATION BAR
        setNavigationBarFor(controller: self, title: "", isTransperent: true, hideShadowImage: false, leftIcon: "icon_back", rightIcon: "") { SelectTag in
            self.dismiss(animated: true, completion: nil)
        } rightActionHandler: {SelectTag in
        }
        
        //SET VIEW AND FONT
        self.setTheView()

    }
    
    @objc func moveToHomeScreen(){
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        self.tabBarController?.selectedIndex = 0
    }

    
    func setTheView(){
        //SET VIEW
        self.viewBG.backgroundColor = setPopupColour()
        self.viewBG.dropShadow(bgColour: UIColor.red, radius: 5.0)

        //SET EMAIL VIEW
        self.viewEmail.backgroundColor = .clear
        self.viewEmail.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewEmail.viewBorderCorneRadius(borderColour: .gray)
        
        //SET PASSWORD VIEW
        self.viewPassword.backgroundColor = .clear
        self.viewPassword.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewPassword.viewBorderCorneRadius(borderColour: .gray)
        
        //SET IMAGE
        imgSelect.image = UIImage(named: "icon_Select")
        if selectRemember == false{
            imgSelect.image = UIImage(named: "icon_Unselect")
        }
        imgColor(imgColor: imgSelect, colorHex: UIColor.standard)
    }
    
    func setTheFont(){
        //SET FONT
        lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: str.loginTitle)
        lblEmail.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strEmail)
        lblPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strPassword)
        lblRememmber.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strRemember)
        lblFreeMusic.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 10.0, text: str.FreeMusic)
        
        
        txtEmail.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtEmail.delegate = self

        txtPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtPassword.delegate = self
        txtPassword.isSecureTextEntry = true
        
        btnForgotPassword.configureLable(bgColour: UIColor.clear, textColor: UIColor.standard, fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strForgotPassword)
        
        btnLogin.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strContinue)
        btnLogin.btnCorneRadius(radius: 5, isRound: false)

        btnSignUp.configureLable(bgColour: UIColor.clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strSignUp)
        btnSignUp.btnAttributes(str: str.strSignUp, location: 23, lenght: 7)
        
        
        #if DEBUG
        self.txtEmail.text = "khatri6168@gmail.com"
        self.txtPassword.text = "111111"
        #endif

        //SET HEADER
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.lblFreeMusic.frame.origin.y + self.lblFreeMusic.frame.size.height + 20)
            self.tblView.tableHeaderView = vw_Table
        }
    }
}




//MARK: - BUTTON ACTION
extension LoginViewController {
    @IBAction func btnRememberClicked(_ sender: UIButton) {
        if selectRemember == false{
            selectRemember = true
        }
        else{
            selectRemember = false
        }
        setTheView()
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        //CHECK VALIDATION
        let strEmail: String = txtEmail.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
      
        if strEmail == ""{
            showAlertMessage(strMessage: str.errorEmail)
        }
        else if txtPassword.text == ""{
            showAlertMessage(strMessage: str.errorPassword)
        }
        else{
            //CALL API
            clearCache()
            self.loginAPI(LoginParameater: LoginParameater(email: strEmail, password: self.txtPassword.text ?? "", remember: selectRemember))
        }
    }
    
    @IBAction func btnSignUpClicked(_ sender: UIButton) {
        if isSignupScreen {
            self.navigationController?.popViewController(animated: true)
        }
        else{
            //MOVE SIGNUP SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController{
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        
    }
    
}



extension LoginViewController:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtEmail {
            self.viewEmail.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtPassword {
            self.viewPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
}
