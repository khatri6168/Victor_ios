//
//  RegisterViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit

class RegisterViewController: UIViewController,UIGestureRecognizerDelegate{
    
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

    @IBOutlet weak var viewConfimrPassword: UIView!
    @IBOutlet weak var lblConfimrPassword: UILabel!
    @IBOutlet weak var txtConfimrPassword: UITextField!

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    //OTHER
    var isLoginScreen : Bool = true
    
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
            if self.isLoginScreen{
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.dismiss(animated: true, completion: nil)
            }
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
        
        //SET PASSWORD VIEW
        self.viewConfimrPassword.backgroundColor = .clear
        self.viewConfimrPassword.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewConfimrPassword.viewBorderCorneRadius(borderColour: .gray)

    }
    
    func setTheFont(){
        //SET FONT
        lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: str.loginTitle)
        lblEmail.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strEmail)
        lblPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strPassword)
        lblConfimrPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strConfirmPass)
        lblFreeMusic.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 10.0, text: str.FreeMusic)
        
        
        txtEmail.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtEmail.delegate = self

        txtPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtPassword.delegate = self
        txtPassword.isSecureTextEntry = true
        
        txtConfimrPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtConfimrPassword.delegate = self
        txtConfimrPassword.isSecureTextEntry = true
        

        btnLogin.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strContinue)
        btnLogin.btnCorneRadius(radius: 5, isRound: false)

        btnSignUp.configureLable(bgColour: UIColor.clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strSignUp)
        btnSignUp.btnAttributes(str: str.strSignUp, location: 23, lenght: 7)
        
        
        
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
extension RegisterViewController {
  
    @IBAction func btnSignupClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        //CHECK VALIDATION
        let strEmail: String = txtEmail.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        

        if strEmail == ""{
            showAlertMessage(strMessage: str.errorEmail)
        }
        else if !validateEmail(enteredEmail: strEmail){
            showAlertMessage(strMessage: str.errorValidEmail)
        }
        else if txtPassword.text == ""{
            showAlertMessage(strMessage: str.errorPassword)
        }
        else if txtConfimrPassword.text == ""{
            showAlertMessage(strMessage: str.errorConfirmPassword)
        }
        else if txtPassword.text?.count ?? 0 < 5{
            showAlertMessage(strMessage: str.errorValidPassword)
        }
        else if txtPassword.text != txtConfimrPassword.text{
            showAlertMessage(strMessage: str.errorPasswordNotMatch)
        }
        else{
            //CALL API
            self.registerAPI(RegisterParameater: RegisterParameater(email: strEmail, password: txtPassword.text ?? "", password_confirmation: txtConfimrPassword.text ?? "", purchase_code: ""))
        }
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        if isLoginScreen{
            self.navigationController?.popViewController(animated: true)
        }
        else{
            //MOVE SIGNUP SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController{
                newViewController.isSignupScreen = true
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        
    }
}



extension RegisterViewController:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtEmail {
            self.viewEmail.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtPassword {
            self.viewPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtConfimrPassword {
            self.viewConfimrPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
}
