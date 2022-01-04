//
//  AccountSettingViewController.swift
//  victor
//
//  Created by Jigar Khatri on 09/11/21.
//

import UIKit
import Photos
import Nuke
import ActionSheetPicker_3_0

class AccountSettingViewController: UIViewController ,UIGestureRecognizerDelegate{
    
    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!


    //LABLE
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!

    //---------------- PROFILE
    @IBOutlet weak var lblUpdateProfileTitle: UILabel!
    @IBOutlet weak var viewUpdateProfile: UIView!

    @IBOutlet weak var viewFiestName: UIView!
    @IBOutlet weak var lblFiestName: UILabel!
    @IBOutlet weak var txtFiestName: UITextField!

    @IBOutlet weak var viewLastName: UIView!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var txtLastName: UITextField!

    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblProfileTitle: UILabel!
    @IBOutlet weak var btnUploadProfile: UIButton!
    @IBOutlet weak var btnSaveProfile: UIButton!
    
    
    //---------------- UPDATE PASSWORD
    @IBOutlet weak var lblUpdatePasswordTitle: UILabel!
    @IBOutlet weak var viewUpdatePassword   : UIView!

    @IBOutlet weak var viewCurrentPassword: UIView!
    @IBOutlet weak var lblCurrentPassword: UILabel!
    @IBOutlet weak var txtCurrentPassword: UITextField!

    @IBOutlet weak var viewNewPassword: UIView!
    @IBOutlet weak var lblNewPassword: UILabel!
    @IBOutlet weak var txtNewPassword: UITextField!

    @IBOutlet weak var viewConfirmPassword: UIView!
    @IBOutlet weak var lblConfirmPassword: UILabel!
    @IBOutlet weak var txtConfirmPassword: UITextField!

    @IBOutlet weak var btnUpdatePassword: UIButton!

    
    
    //---------------- UPDATE PREFERENCES
    @IBOutlet weak var lblUpdatePreferencesTitle: UILabel!
    @IBOutlet weak var viewUpdatePreferences   : UIView!

    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var txtLanguage: UITextField!
    @IBOutlet weak var imgLanguage: UIImageView!

    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var imgCountry: UIImageView!

    @IBOutlet weak var viewTimezone: UIView!
    @IBOutlet weak var lblTimezone: UILabel!
    @IBOutlet weak var txtTimezone: UITextField!
    @IBOutlet weak var imgTimezone: UIImageView!

    @IBOutlet weak var btnUpdatePreferences: UIButton!
    
    //---------------- DELETE ACCOUTN
    @IBOutlet weak var lblDeleteTitle: UILabel!
    @IBOutlet weak var viewDelete   : UIView!

    @IBOutlet weak var btnDelete: UIButton!

    //---------------- LOGOUT
    @IBOutlet weak var lblLogOut: UILabel!
    @IBOutlet weak var viewLogOut: UIView!
    @IBOutlet weak var imgLogOut: UIImageView!

    
    //OTHER
    let picker = UIImagePickerController()

    var arrCountriesList : [CountriesModel] = []
    var arrLanguageList : [LanguageModel] = []
    var arrTimeZoneList : [TimeZoneModel] = []

    var strSelectLanguage : String = ""
    var strSelectLanguageCode : String = ""
    
    var strSelectCountry : String = ""
    var strSelectCountryCode : String = ""
    
    var strSelectTimeZone : String = ""
    var strSelectTimeZoneCode : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToHomeScreen), name: .loginScuuess, object: nil)

        self.getTimeZoneAPI()
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
        self.viewUpdateProfile.backgroundColor = setPopupColour()
        self.viewUpdateProfile.dropShadow(bgColour: UIColor.red, radius: 5.0)
        self.viewUpdateProfile.viewBorderCorneRadiusLight(borderColour: .grayLight)

        self.viewUpdatePassword.backgroundColor = setPopupColour()
        self.viewUpdatePassword.dropShadow(bgColour: UIColor.red, radius: 5.0)
        self.viewUpdatePassword.viewBorderCorneRadiusLight(borderColour: .grayLight)

        self.viewUpdatePreferences.backgroundColor = setPopupColour()
        self.viewUpdatePreferences.dropShadow(bgColour: UIColor.red, radius: 5.0)
        self.viewUpdatePreferences.viewBorderCorneRadiusLight(borderColour: .grayLight)

        self.viewDelete.backgroundColor = setPopupColour()
        self.viewDelete.dropShadow(bgColour: UIColor.red, radius: 5.0)
        self.viewDelete.viewBorderCorneRadiusLight(borderColour: .grayLight)

        self.viewLogOut.backgroundColor = .red
        self.viewLogOut.dropShadow(bgColour: UIColor.red, radius: 5.0)
        self.viewLogOut.viewBorderCorneRadiusLight(borderColour: .red)


        //SET FIRST NAME VIEW
        self.viewFiestName.backgroundColor = .clear
        self.viewFiestName.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewFiestName.viewBorderCorneRadius(borderColour: .gray)
        
        //SET LAST NAME VIEW
        self.viewLastName.backgroundColor = .clear
        self.viewLastName.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewLastName.viewBorderCorneRadius(borderColour: .gray)
     
        //SET CURRENT PASSWORD VIEW
        self.viewCurrentPassword.backgroundColor = .clear
        self.viewCurrentPassword.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewCurrentPassword.viewBorderCorneRadius(borderColour: .gray)
        
        //SET NEW PASSWORD VIEW
        self.viewNewPassword.backgroundColor = .clear
        self.viewNewPassword.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewNewPassword.viewBorderCorneRadius(borderColour: .gray)
        
        //SET CONFIRM PASSWORD VIEW
        self.viewConfirmPassword.backgroundColor = .clear
        self.viewConfirmPassword.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewConfirmPassword.viewBorderCorneRadius(borderColour: .gray)
        
        //SET LANGUAGE VIEW
        self.viewLanguage.backgroundColor = .clear
        self.viewLanguage.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewLanguage.viewBorderCorneRadius(borderColour: .gray)
        
        //SET COUNTRY VIEW
        self.viewCountry.backgroundColor = .clear
        self.viewCountry.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewCountry.viewBorderCorneRadius(borderColour: .gray)
        
        //SET TIMEZONE VIEW
        self.viewTimezone.backgroundColor = .clear
        self.viewTimezone.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewTimezone.viewBorderCorneRadius(borderColour: .gray)
    }
    
    func setTheFont(){
        //SET FONT
        lblHeader.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: str.strAccountSetting)
        lblSubTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: str.AccountSettingTitle)
        
        lblUpdateProfileTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.updateProfile)
        lblUpdatePasswordTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.updatePassword)
        lblUpdatePreferencesTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.updatePreferences)
        lblDeleteTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.deleteAccounttitle)

        lblFiestName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strFirstName)
        lblLastName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strLastName)
        lblProfile.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strProfileImg)
        lblProfileTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: str.strProfileImgTitle)

        lblCurrentPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strCurrentPassword)
        lblNewPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strNewPassword)
        lblConfirmPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strConfirmPass)

        lblLanguage.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strLanguage)
        lblCountry.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strCountry)
        lblTimezone.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strTimezone)

        lblLogOut.configureLable(textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strLogOut)

        txtFiestName.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtFiestName.delegate = self

        txtLastName.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtLastName.delegate = self
        

        txtCurrentPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtCurrentPassword.delegate = self
       
        txtNewPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtNewPassword.delegate = self
       
        txtConfirmPassword.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtConfirmPassword.delegate = self
       
        
        txtLanguage.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtLanguage.delegate = self
       
        txtCountry.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtCountry.delegate = self
       
        txtTimezone.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: "")
        txtTimezone.delegate = self
       
        
       
        btnUploadProfile.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strUploadImage)
        btnUploadProfile.btnCorneRadius(radius: 5, isRound: false)

        btnSaveProfile.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strSave)
        btnSaveProfile.btnCorneRadius(radius: 5, isRound: false)

        btnUpdatePassword.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strUpdate)
        btnUpdatePassword.btnCorneRadius(radius: 5, isRound: false)

       
        btnUpdatePreferences.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strSave)
        btnUpdatePreferences.btnCorneRadius(radius: 5, isRound: false)

        btnDelete.configureLable(bgColour: .red, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.deleteAccount)
        btnDelete.btnCorneRadius(radius: 5, isRound: false)

        //SET IMAGE
        imgProfile.viewCorneRadius(radius: 5, isRound: false)
        imgProfile.backgroundColor = UIColor.grayLight
        if let objUser = UserDefaults.standard.user{
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
                    Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgProfile)
                }
            }
        }
        
        imgLogOut.image = UIImage(named: "icon_logout")
        imgColor(imgColor: imgLogOut, colorHex: .primary)
        imgColor(imgColor: imgLanguage, colorHex: setTextColour())
        imgColor(imgColor: imgCountry, colorHex: setTextColour())
        imgColor(imgColor: imgTimezone, colorHex: setTextColour())
        
        //SET HEADER
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.viewLogOut.frame.origin.y + self.viewLogOut.frame.size.height + 50)
            self.tblView.tableHeaderView = vw_Table
        }
    }
    
    func setTheDetails(){
        //SET DETAILS
        if let objUser = UserDefaults.standard.user{
            
            //SET DETAILS
            self.txtFiestName.text = objUser.firstname ?? ""
            self.txtLastName.text = objUser.lastname ?? ""
            
            //SET IMAGE
            imgProfile.viewCorneRadius(radius: 5, isRound: false)
            imgProfile.backgroundColor = UIColor.grayLight
            if let objUser = UserDefaults.standard.user{
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
                        Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgProfile)
                    }
                }
            }
            
            //SET LANGUAGE
            if objUser.language != ""{
                let MenuID = self.arrLanguageList.map{$0.name?.lowercased()}
                if let index = MenuID.firstIndex(of: objUser.language?.lowercased() ) {
                    self.strSelectLanguage = self.arrLanguageList[index].name ?? ""
                    self.txtLanguage.text = self.strSelectLanguage.capitalizingFirstLetter()
                }
            }
 
            //SET COUNTRY
            if objUser.country != ""{
                let MenuID = self.arrCountriesList.map{$0.code?.lowercased()}
                if let index = MenuID.firstIndex(of: objUser.country?.lowercased() ) {
                    self.strSelectCountry = self.arrCountriesList[index].name ?? ""
                    self.txtCountry.text = self.strSelectCountry.capitalizingFirstLetter()
                }
            }
            
            //SET TIMEZONE
            if objUser.timezone != ""{
                let MenuID = self.arrTimeZoneList.map{$0.value?.lowercased()}
                if let index = MenuID.firstIndex(of: objUser.timezone?.lowercased() ) {
                    self.strSelectTimeZone = self.arrTimeZoneList[index].text ?? ""
                    self.txtTimezone.text = self.strSelectTimeZone.capitalizingFirstLetter()
                }
            }
        }
    }
}




//MARK: - BUTTON ACTION
extension AccountSettingViewController {
    
    @IBAction func btnChangeProfileClicked(_ sender:Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: str.Gallery, style: UIAlertAction.Style.default, handler: { (action) in
            self.showPickerController(self.picker, withSourceType: .photoLibrary)
            
        }))
        alert.addAction(UIAlertAction(title: str.Camera, style: UIAlertAction.Style.default, handler: { (action) in
            self.showPickerController(self.picker, withSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: str.Close, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)


    }
    @IBAction func btnSaveChangeClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        //CHECK VALIDATION
        let strFirstName: String = txtFiestName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        let strLastName: String = txtLastName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""

        if strFirstName == ""{
            showAlertMessage(strMessage: str.errorFirstName)
        }
        else if strLastName == ""{
            showAlertMessage(strMessage: str.errorLastName)
        }
        else{
            //CALL API
            if let objUser = UserDefaults.standard.user{
                self.UploadProfileAPI(UpdateProfileParameater: UpdateProfileParameater(first_name: strFirstName, last_name: strLastName, language: "english", timezone: "Africa/Algiers", country: "tr"), strUserID: objUser.id ?? "")

            }
        }
    }
    
    
    @IBAction func btnLanguClicked(_ sender: UIButton) {
        if arrLanguageList.count != 0{
            actionPicker(sender, strTitle: str.strLanguage, arrData: self.arrLanguageList.compactMap { "\($0.name?.capitalizingFirstLetter() ?? "")" }, selectValue: strSelectLanguage) { (selectIndex, selectValue) in
                
                let obj = self.arrLanguageList[selectIndex]
                self.strSelectLanguage = obj.name ?? ""
                self.strSelectLanguageCode = obj.language ?? ""
                
                self.txtLanguage.text = self.strSelectLanguage.capitalizingFirstLetter()
            }
        }
    }
    
    
    @IBAction func btnCountryClicked(_ sender: UIButton) {
        if arrCountriesList.count != 0{
            actionPicker(sender, strTitle: str.strCountry, arrData: self.arrCountriesList.compactMap { $0.name?.capitalizingFirstLetter() }, selectValue: strSelectCountry) { (selectIndex, selectValue) in
                
                let obj = self.arrCountriesList[selectIndex]
                self.strSelectCountry = obj.name ?? ""
                self.strSelectCountryCode = obj.code ?? ""
                
                self.txtCountry.text = self.strSelectCountry.capitalizingFirstLetter()
            }
        }
    }
 
    
    @IBAction func btnTimeZoneClicked(_ sender: UIButton) {
        if arrTimeZoneList.count != 0{
            actionPicker(sender, strTitle: str.strTimezone, arrData: self.arrTimeZoneList.compactMap { "\($0.type?.capitalizingFirstLetter() ?? "") - \($0.text?.capitalizingFirstLetter() ?? "")" }, selectValue: strSelectLanguage) { (selectIndex, selectValue) in
                
                let obj = self.arrTimeZoneList[selectIndex]
                self.strSelectTimeZone = "\(obj.type ?? "") - \(obj.text ?? "")"
                self.strSelectTimeZoneCode = obj.value ?? ""
                
                self.txtTimezone.text = self.strSelectTimeZone.capitalizingFirstLetter()
            }
        }
    }
    
    
    @IBAction func btnDeleteAccountClicked(_ sender: UIButton) {
        //LOGOUT
        let alert = UIAlertController(title: str.DeleteAccount , message: str.DeleteAccountText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
            if let objUser = UserDefaults.standard.user{
                self.deleteAccountAPI(deleteAccountParameater: deleteAccountParameater(), strUserID: objUser.id ?? "")
            }
        }))
        alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func btnLogOutClicked(_ sender: UIButton) {
        //LOGOUT
        let alert = UIAlertController(title: Application.appName, message: str.areYouSureYouWantToLogout, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
            //REMOVE ALL DATA
            UserDefaults.standard.user = nil
            UserDefaults.standard.userRemeber = nil
            NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
            
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

        
    }
}



extension AccountSettingViewController:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtFiestName {
            self.viewFiestName.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtLastName {
            self.viewLastName.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtCurrentPassword {
            self.viewCurrentPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtNewPassword {
            self.viewNewPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtConfirmPassword {
            self.viewConfirmPassword.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtLanguage {
            self.viewLanguage.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtCountry {
            self.viewCountry.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
        else if textField == txtTimezone {
            self.viewTimezone.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
}




//MARK: - IMAGE PICKER
extension AccountSettingViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    private func showPickerController(_ pickerController: UIImagePickerController,
                                      withSourceType sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image", "public.movie"]
        let show: (UIImagePickerController) -> Void = { [weak self] (pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                self?.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let accessDenied: (_ withSourceType: UIImagePickerController.SourceType) -> Void = { [weak self] (sourceType) in
            let typeName = sourceType == .camera ? "Camera" : "Photos"
            let title = "\(typeName) Access Disabled"
            let message = "You can allow access to \(typeName) in Settings"
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]
                    , completionHandler: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        //Check Access
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
                
            @unknown default:
                print("")
            }
        } else {
            //Photo Library Access
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            case .limited:
                break
            @unknown default:
                print("")
            }
        }     }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgProfile.contentMode = .scaleAspectFill
            imgProfile.image = pickedImage
            
            //UPDATE USRE PROFILE
            if let objUser = UserDefaults.standard.user{
                UploadProfilePicAPI(strUserID: objUser.id ?? "")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}





//MARK: -- Selected Index --
func selectedIndex(arr : NSArray, value : String) -> Int{
    for (index, _) in arr.enumerated() {
        if value == arr[index] as! String {
            return index
        }
    }
    return 0
}

//ACTION PICKER
func actionPicker(_ sender: UIButton, strTitle :String ,arrData :[String], selectValue :String, completion: @escaping (_ index: Int, _ values: String) -> Void) {
    
    let picker = ActionSheetStringPicker(title: strTitle, rows: arrData, initialSelection:selectedIndex(arr: arrData as NSArray, value: selectValue), doneBlock: { (picker, indexes, values) in
        
        completion(indexes , "\(values ?? "")")
        
    }, cancel: {ActionSheetStringPicker in return}, origin: sender)
    
    //        picker?.hideCancel = true
    picker?.setDoneButton(UIBarButtonItem(title: str.streSelect, style: .plain, target: nil, action: nil))
    picker?.setCancelButton(UIBarButtonItem(title: str.strCancel, style: .plain, target: nil, action: nil))
    picker?.toolbarButtonsColor = UIColor.black
    
    picker?.show()
}
