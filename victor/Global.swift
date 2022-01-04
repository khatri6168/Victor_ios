//
//  Global.swift
//  Aeshee
//
//  Created by Apple on 25/10/18.
//  Created by Jigar Khatri on 30/04/21.
//

import Foundation
import UIKit
import AVFoundation
import IQKeyboardManagerSwift
import KRProgressHUD
import BBBadgeBarButtonItem
import Nuke
import ObjectMapper

struct GlobalConstants
{
    // Constant define here.
    static let developerTest : Bool = false
    static let appLive : Bool = true
    
    //Implementation View height
    
    
    static let screenHeightDeveloper : Double =  checkDeviceiPad() ? 1024 : 667
    static let screenWidthDeveloper : Double = checkDeviceiPad() ? 575 : 375


    static let PageLimit: Int = 10
    
    
    //Name And Appdelegate Object
    static let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    
    //System width height
    static let windowWidth: Double = UIApplication.shared.statusBarOrientation.isLandscape ? Double(UIScreen.main.bounds.size.height) : Double(UIScreen.main.bounds.size.width)
    static let windowHeight: Double = UIApplication.shared.statusBarOrientation.isLandscape ? Double(UIScreen.main.bounds.size.width) : Double(UIScreen.main.bounds.size.height)

//    static let windowHeight: Double = Double(UIScreen.main.bounds.size.height)
    
    
    //STOREBORD NAME
    static let LOGIN_MODEL = "Login"
    static let TABBAR = "TabBar"
    static let HOME_MODEL = "Home"
    static let SONG_MODEL = "SaveSongs"
    static let PLAYER_MODEL = "Player"
    static let SEARCH_MODEL = "Search"


    
    
    
    //FONT NAME
    static let APP_FONT_Bold = "Roboto-Bold"
    static let APP_FONT_Regular = "Roboto-Regular"
    static let APP_FONT_Medium = "Roboto-Medium"
    static let APP_FONT_Light = "Roboto-Light"
    
    
    //IPHONE NAME
    static let iPhone4_4s = "iPhones4 or 4S"
    static let iPhone5_5c_5s_SE = "iPhones 5/5s/5c/SE"
    static let iPhone6_6s_7_8 = "iPhones 6/6s/7/8"
    static let iPhone6P_6s_6sP_7P_8P = "iPhones 6+/6S+/7+/8+"
    static let iPhoneXR = "iPhone_XR"
    static let iPhoneX_XS = "iPhones X/XS"
    static let iPhoneXSMax = "iPhone XSMax"
    static let iPhoneUnknown = "unknown"
    
    
    
    //Device Token
    static let DeviceToken = UserDefaults.standard.object(forKey: "DeviceToken")
    
}
let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft


//GET VIEW TOP
var getTopViewController: UIViewController? {
    
    guard let rootViewController = GlobalConstants.appDelegate?.window?.rootViewController else {
        return nil
    }
    
    return getVisibleViewController(rootViewController)
}


func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
    
    if let presentedViewController = rootViewController.presentedViewController {
        return getVisibleViewController(presentedViewController)
    }
    
    if let navigationController = rootViewController as? UINavigationController {
        return navigationController.visibleViewController
    }
    
    if let tabBarController = rootViewController as? UITabBarController {
        return tabBarController.selectedViewController
    }
    
    return rootViewController
}
//............................... MANAGE ...............................................//

//MARK: - MANAGE FONT

func CheckFontNameList (){
    //CHECK FONT NAME
    for fontFamilyName in UIFont.familyNames{
        for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
            print("Family: \(fontFamilyName)     Font: \(fontName)")
        }
    }
}

func checkDeviceiPad() -> Bool{
    return UIDevice.current.userInterfaceIdiom == .pad ? true : false
}

func manageFont(font : Double) -> CGFloat{
    let cal : Double = GlobalConstants.windowHeight * (checkDeviceiPad() ? font + 3 : font)
    
    return CGFloat(cal / GlobalConstants.screenHeightDeveloper)
}

//MARK: - MANAGE HEIGHT
func manageHeight(size : Double) -> CGFloat{
    let cal : Double = GlobalConstants.windowHeight * size
    return CGFloat(cal / GlobalConstants.screenHeightDeveloper)
}

//MARK: - MANAGE WIDGH
func manageWidth(size : Double) -> CGFloat{
//    var windoSize : Double = GlobalConstants.windowWidth
//    if checkDeviceiPad(){
//        windoSize = UIApplication.shared.statusBarOrientation.isLandscape ? GlobalConstants.windowHeight : GlobalConstants.windowWidth
//    }
        
    let cal : Double = GlobalConstants.windowWidth * size
    return CGFloat(cal / GlobalConstants.screenWidthDeveloper)
}

//............................... SET COLOR ...............................................//

// MARK: - SET COLOR
func colorFromRGB(valueRed: CGFloat, valueGreen: CGFloat, valueBlue: CGFloat) -> UIColor {
    return UIColor(red: valueRed / 255.0, green: valueGreen / 255.0, blue: valueBlue / 255.0, alpha: 1.0)
    
}

//SET IMAGE COLOR
func imgColor (imgColor : UIImageView ,  colorHex : UIColor?){
    let templateImage = imgColor.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    imgColor.image = templateImage
    imgColor.tintColor = colorHex
}

func imgTabColor (imgColor : UIImageView ,  colorHex : UIColor?) -> UIImageView{
    let templateImage = imgColor.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    imgColor.image = templateImage
    imgColor.tintColor = colorHex
    
    return imgColor
}

func buttonImageColor (btnImage : UIButton, imageName : String , colorHex: UIColor?){
    let buttonImage = UIImage(named: imageName)
    btnImage.setImage(buttonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
    btnImage.tintColor = colorHex
}


//............................... SET THE FONT ...............................................//

func SetTheFont(fontName :String, size :Double) -> UIFont {
    return UIFont(name: fontName, size: manageFont(font: size - 2))!
}

//............................... ALERT MESSAGE ...............................................//
func showAlertMessage(strMessage: String) {
    
    let alert = UIAlertController(title: Application.appName, message: strMessage, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    getTopViewController?.present(alert, animated: true, completion: nil)
}

func showAlertSyncingData(strMessage: String) {
    
    let alert = UIAlertController(title: Application.appName, message: strMessage, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
        if let url = URL(string: UIApplication.openSettingsURLString){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url, completionHandler: nil)
            } else{
                UIApplication.shared.openURL(url)
            }
        }
    }))
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    
    GlobalConstants.appDelegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
}
func convertSeccountToTime(remainingTime : Int) -> String{
    let hours = Int(remainingTime) / 3600
    let minutes = (Int(remainingTime) - hours * 3600) / 60
//    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
    
    var timing : String = ""
    if hours != 0{
        timing = "\(hours)h"
    }
    
    if minutes != 0{
        if timing != ""{
            timing = "\(timing) \(minutes)m"
        }
        else{
            timing = "\(minutes)m"
        }
    }
    
    
//    if seconds != 0{
//        if timing != ""{
//            timing = "\(timing) \(seconds)s"
//        }
//        else{
//            timing = "\(seconds)s"
//        }
//    }
    
    return timing
}

//MARK: - SET KEYBOARD
func setupKeyboard(_ enable: Bool) {
    IQKeyboardManager.shared.enable = enable
    IQKeyboardManager.shared.enableAutoToolbar = enable
    IQKeyboardManager.shared.shouldShowToolbarPlaceholder = !enable
    IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
}

func removeNewLineToSpace(str_Value : String) -> String{
    let newString = str_Value.replacingOccurrences(of: "\n", with: " ")
    return newString
}


//MARK: -- Inicator AND LOADING --
func indicatorShow(){
    KRProgressHUD
        .set(style: .custom(background:  setTextColour(), text: UIColor.white, icon: nil))
        .set(activityIndicatorViewColors: [setColour()])
        .set(font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 14.0))
        .show(withMessage: "Loading...")
}
func indicatorShowEmpty(){
    KRProgressHUD
        .set(style: .custom(background:  UIColor.clear , text: UIColor.white, icon: nil))
        .set(activityIndicatorViewColors: [UIColor.clear])
        .set(font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 14.0))
        .show(withMessage: "")
}
func indicatorHide(){
    KRProgressHUD.dismiss()
}


func startLoading (view : UIView){
//    loadingPlaceholderView.gradientConfiguration.isClourModeDark = false
//    loadingPlaceholderView.setTheMode(isSetMode: UserDefaults.standard.colourMode == "dark" ? true : false)
    loadingPlaceholderView.cover(view, animated: true)
//    loadingPlaceholderView.cover(view, animated: true)
    DispatchQueue.main.async {
        indicatorShowEmpty()
    }
}

func storeLoading(){
    loadingPlaceholderView.uncover()
    indicatorHide()
}



//............................ NAVIGATION BAR ............................................//


//MARK: -- NavigationTitle --
func navigationTitle(NavControl : UINavigationController) {
    
    NavControl.navigationBar.setBackgroundImage(UIImage(), for: .default)
    NavControl.navigationBar.shadowImage = UIImage(named: "")
    NavControl.navigationBar.barTintColor = UIColor.white
    NavControl.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor:  UIColor.primary!,
         NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 18.0) ]
}


fileprivate let whiteImage = UIImage(setColor: UIColor.primary!)
func addNavBarImage(strLogo : String,controller: UINavigationController) -> UIImageView{

    let navController = controller
    
    let image = UIImage(named: strLogo) //Your logo url here
    let imageView = UIImageView(image: image)
    
    let bannerWidth = navController.navigationBar.frame.size.width
    let bannerHeight = navController.navigationBar.frame.size.height
    
    let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
    let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
    
    imageView.frame = CGRect(x: bannerX, y: bannerY, width: 100, height: 35)
    imageView.contentMode = .scaleAspectFit
    
    return imageView
}

class CustomNavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let newSize :CGSize = CGSize(width: self.frame.size.width,height: 84)
        return newSize
    }
}

func setNavigationBarFor(controller: UIViewController,
                         title:String = "",
                         isTransperent:Bool = false,
                         hideShadowImage: Bool = false,
                         leftIcon : String,
                         rightIcon : String,
                         leftActionHandler: ((_ SelectTag : Int) -> Void)? = nil,
                         rightActionHandler: ((_ SelectTag : Int) -> Void)? = nil) {
     
    guard let navigationController = controller.navigationController else{
        return
    }
    
    controller.navigationItem.title = title
    navigationController.view.semanticContentAttribute = UserDefaults.standard.language == "ar" ? .forceRightToLeft : .forceLeftToRight

    if isTransperent {
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    else{
        navigationController.navigationBar.setBackgroundImage(whiteImage, for: .default)
    }

        
    navigationController.navigationBar.barTintColor = setColour()
    navigationController.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: setTextColour(),
         NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 16.0)]
    navigationController.navigationBar.isTranslucent = isTransperent
    navigationController.navigationBar.shadowImage = (hideShadowImage) ? UIImage() : nil

   
    if let actionLeft = leftActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
        let button: UIButton = UIButton(type:.custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: leftIcon), for: .normal)
        buttonImageColor(btnImage: button, imageName: leftIcon, colorHex: setTextColour())
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        if UserDefaults.standard.language == "ar" {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnAction = UIBarButtonItemWithClouser(button: button, actionHandler: actionLeft)
        controller.navigationItem.leftBarButtonItem = btnAction
    }
    
    
    if let actionRight = rightActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
        let button: UIButton = UIButton(type:.custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: rightIcon), for: .normal)
        buttonImageColor(btnImage: button, imageName: rightIcon, colorHex: setTextColour())
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        if UserDefaults.standard.language == "ar" {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnAction = UIBarButtonItemWithClouser(button: button, actionHandler: actionRight)
        controller.navigationItem.rightBarButtonItem = btnAction
    }
}

func setNavigationBarTitleFor(controller: UIViewController,
                         title:String = "",
                         isTransperent:Bool = false,
                         hideShadowImage: Bool = false,
                         leftIcon : String,
                         rightIcon : String,
                         leftActionHandler: ((_ SelectTag : Int) -> Void)? = nil,
                         rightActionHandler: ((_ SelectTag : Int) -> Void)? = nil) {
     

    guard let navigationController = controller.navigationController else{
        return
    }
    
    navigationController.navigationBar.barStyle = UserDefaults.standard.colourMode == "light" ? .default : .black 

    
    controller.navigationItem.title = ""
    navigationController.view.semanticContentAttribute = UserDefaults.standard.language == "ar" ? .forceRightToLeft : .forceLeftToRight

    if isTransperent {
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    else{
        navigationController.navigationBar.setBackgroundImage(whiteImage, for: .default)
    }

        
    navigationController.navigationBar.barTintColor = setColour()
    navigationController.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: setTextColour(),
         NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 16.0)]
    navigationController.navigationBar.isTranslucent = isTransperent
    navigationController.navigationBar.shadowImage = (hideShadowImage) ? UIImage() : nil

   
    if let actionLeft = leftActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
        let button: UIButton = UIButton(type:.custom)
        button.backgroundColor = UIColor.clear
        button.setTitle(title, for: .normal)
        button.configureLable(bgColour: UIColor.clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: title)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 0)

        if UserDefaults.standard.language == "ar" {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnAction = UIBarButtonItemWithClouser(button: button, actionHandler: actionLeft)
        controller.navigationItem.leftBarButtonItem = btnAction
    }
    
    
    if let actionRight = rightActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
        let button: UIButton = UIButton(type:.custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: rightIcon), for: .normal)
        buttonImageColor(btnImage: button, imageName: rightIcon, colorHex: setTextColour())
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        if UserDefaults.standard.language == "ar" {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnAction = UIBarButtonItemWithClouser(button: button, actionHandler: actionRight)
        controller.navigationItem.rightBarButtonItem = btnAction
    }
}


func setNavigationBarTowButtonFor(controller: UIViewController,
                         title:String = "",
                         isTransperent:Bool = false,
                         hideShadowImage: Bool = false,
                         leftIcon : String,
                         rightIcon : String,
                         leftActionHandler: ((_ SelectTag : Int) -> Void)? = nil,
                         rightActionHandler: ((_ SelectTag : Int) -> Void)? = nil) {
     
    guard let navigationController = controller.navigationController else{
        return
    }
    
    controller.navigationItem.title = title
    navigationController.view.semanticContentAttribute = UserDefaults.standard.language == "ar" ? .forceRightToLeft : .forceLeftToRight

    if isTransperent {
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    else{
        navigationController.navigationBar.setBackgroundImage(whiteImage, for: .default)
    }

        
    navigationController.navigationBar.barTintColor = setColour()
    navigationController.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: setTextColour(),
         NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Bold, size: 16.0)]
    navigationController.navigationBar.isTranslucent = isTransperent
    navigationController.navigationBar.shadowImage = (hideShadowImage) ? UIImage() : nil

   
    if let actionLeft = leftActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
        let button: UIButton = UIButton(type:.custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: leftIcon), for: .normal)
        buttonImageColor(btnImage: button, imageName: leftIcon, colorHex: setTextColour())
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        if UserDefaults.standard.language == "ar" {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnAction = UIBarButtonItemWithClouser(button: button, actionHandler: actionLeft)
        controller.navigationItem.leftBarButtonItem = btnAction
    }
    
    
    
    
    
    if let actionRight = rightActionHandler {
        navigationController.navigationItem.setHidesBackButton(true, animated: false)
      
        //SEARCH BUTTON
        let buttonSearch: UIButton = UIButton(type:.custom)
        buttonSearch.backgroundColor = UIColor.clear
        buttonSearch.setImage(UIImage(named: "icon_search"), for: .normal)
        buttonImageColor(btnImage: buttonSearch, imageName: "icon_search", colorHex: setTextColour())
        buttonSearch.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        buttonSearch.tag = 1
        if UserDefaults.standard.language == "ar" {
            buttonSearch.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnSearchAction = UIBarButtonItemWithClouser(button: buttonSearch, actionHandler: actionRight)
        
        
        let buttonRaido: UIButton = UIButton(type:.custom)
        buttonRaido.backgroundColor = UIColor.clear
        buttonRaido.setImage(UIImage(named: rightIcon), for: .normal)
        buttonImageColor(btnImage: buttonRaido, imageName: rightIcon, colorHex: setTextColour())
        buttonRaido.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        buttonRaido.tag = 2

        if UserDefaults.standard.language == "ar" {
            buttonRaido.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        let btnRaidoAction = UIBarButtonItemWithClouser(button: buttonRaido, actionHandler: actionRight)
        
      
        controller.navigationItem.rightBarButtonItems = [btnSearchAction, btnRaidoAction]
    }
}


var safeAreaInset: UIEdgeInsets = {
    
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window!.safeAreaInsets
    }
    else{
        return UIEdgeInsets.zero
    }
}()



func GetBottomSafeAreaHeight() -> CGFloat  {
    //GET SAFE AREA HEIGHT
    var bottomSafeAreaHeight: CGFloat = 0
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
    }
    return bottomSafeAreaHeight
}

func GetTopSafeAreaHeight() -> CGFloat  {
    //GET SAFE AREA HEIGHT
    var topSafeAreaHeight: CGFloat = 0
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        topSafeAreaHeight = safeFrame.minY
    }
    return topSafeAreaHeight
}




func openURL(strURL : String){
    
    if let url = URL(string: "\(strURL)"), !url.absoluteString.isEmpty {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // or outside scope use this
    guard let url = URL(string: "\(strURL)"), !url.absoluteString.isEmpty else {
        return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}

//............................... VALIDATION ...............................................//

//MARK: -- Email Validation --
func validateEmail(enteredEmail:String) -> Bool {
    
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    
    return emailPredicate.evaluate(with: enteredEmail)
}

func validatePhoneNumber(value: String) -> Bool {
    let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
    let inputString = value.components(separatedBy: charcterSet)
    let filtered = inputString.joined(separator: "")
    return  value == filtered
}

//......................... DEVICE INDENTIFIER .....................................//
//MARK: - DEVICE INDENTIFIER
func deviceIdentifier() -> String{
    switch UIScreen.main.nativeBounds.height {
    case 960:
        return GlobalConstants.iPhone4_4s
    case 1136:
        return GlobalConstants.iPhone5_5c_5s_SE
    case 1334:
        return GlobalConstants.iPhone6_6s_7_8
    case 1920, 2208:
        return GlobalConstants.iPhone6P_6s_6sP_7P_8P
    case 1792:
        return GlobalConstants.iPhoneXR
    case 2436:
        return GlobalConstants.iPhoneX_XS
    case 2688:
        return GlobalConstants.iPhoneXSMax
    default:
        return GlobalConstants.iPhoneUnknown
    }
}

//........................ SET VIEW CORNER RADIUS .....................................//

//SET VIEW CORNER RADIUS

func roundCorners(on view: UIImageView?, onTopLeft tl: Bool, topRight tr: Bool, bottomLeft bl: Bool, bottomRight br: Bool, radius: Float) -> UIImageView? {
    if tl || tr || bl || br {
        var corner = UIRectCorner(rawValue: 0)
        if tl {
            corner = UIRectCorner(rawValue: corner.rawValue | UIRectCorner.topLeft.rawValue)
        }
        if tr {
            corner = UIRectCorner(rawValue: corner.rawValue | UIRectCorner.topRight.rawValue)
        }
        if bl {
            corner = UIRectCorner(rawValue: corner.rawValue | UIRectCorner.bottomLeft.rawValue)
        }
        if br {
            corner = UIRectCorner(rawValue: corner.rawValue | UIRectCorner.bottomRight.rawValue)
        }
        
        let roundedView: UIImageView? = view
        var maskPath: UIBezierPath? = nil
        maskPath = UIBezierPath(roundedRect: roundedView?.bounds ?? CGRect.zero, byRoundingCorners: corner, cornerRadii: CGSize(width: CGFloat(radius), height: CGFloat(radius)))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = roundedView?.bounds ?? CGRect.zero
        maskLayer.path = maskPath?.cgPath
        roundedView?.layer.mask = maskLayer
        return roundedView
    }
    return view
}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0...length-1).map{ _ in letters.randomElement()! })
}

func randomNumber(length: Int) -> String {
    let letters = "0123456789"
    return String((0...length-1).map{ _ in letters.randomElement()! })
}


//extension Array {
//
//    var string: String? {
//
//        do {
//
//            let data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
//
//            return String(data: data, encoding: .utf8)
//
//        } catch {
//
//            return nil
//        }
//    }
//}
func ArryToStr(arrayResponse : [RadioModel]) -> String {
    //CONVERT DICTIONARY TO STRING VALUE
    var jsonData: Data? = nil
    do {
        jsonData = try JSONSerialization.data(withJSONObject: arrayResponse, options: [.prettyPrinted])
    } catch {
        print("Error")
    }
    var myString: String? = nil
    if let jsonData = jsonData {
        myString = String(data: jsonData, encoding: .utf8)
    }
    
    return myString ?? ""
}

//............................... SET VALUE  ............................................//
//MARK: --- DICTIONARY TO STRING

func DicToStr(arrayResponse : NSDictionary) -> String {
    //CONVERT DICTIONARY TO STRING VALUE
    var jsonData: Data? = nil
    do {
        jsonData = try JSONSerialization.data(withJSONObject: arrayResponse, options: [])
    } catch {
        print("Error")
    }
    var myString: String? = nil
    if let jsonData = jsonData {
        myString = String(data: jsonData, encoding: .utf8)
    }
    
    return myString ?? ""
}


//MARK: - Manage function for value save -
extension NSDictionary {
    func getStringForID(key: String) -> String! {
        
        var strKeyValue : String = ""
        if self[key] != nil {
            if (self[key] as? Int) != nil {
                strKeyValue = String(self[key] as? Int ?? 0)
            } else if (self[key] as? String) != nil {
                strKeyValue = self[key] as? String ?? ""
            }else if (self[key] as? Double) != nil {
                strKeyValue = String(self[key] as? Double ?? 0)
            }else if (self[key] as? Float) != nil {
                strKeyValue = String(self[key] as? Float ?? 0)
            }else if (self[key] as? Bool) != nil {
                let bool_Get = self[key] as? Bool ?? false
                if bool_Get == true{
                    strKeyValue = "1"
                }else{
                    strKeyValue = "0"
                }
            }
        }
        return strKeyValue
    }
    
    func getArrayVarification(key: String) -> NSArray {
        
        var strKeyValue : NSArray = []
        if self[key] != nil {
            if (self[key] as? NSArray) != nil {
                strKeyValue = self[key] as? NSArray ?? []
            }
        }
        return strKeyValue
    }
}

//func steTheSwitch(Switch: UISwitch, isOn : Bool)  {
//    //SET SWITCH
//    Switch.onTintColor = hexStringToUIColor(hex: GlobalConstants.APPCOLOR_DARK)
//    Switch.layer.borderWidth = 0.5
//    Switch.layer.borderColor = hexStringToUIColor(hex: GlobalConstants.APPCOLOR_DARK).cgColor
//    Switch.layer.cornerRadius = Switch.frame.height / 2
//    Switch.backgroundColor = UIColor.white
//    Switch.isOn = isOn
//    if isOn {
//        Switch.thumbTintColor = UIColor.white
//    }
//    else{
//        Switch.thumbTintColor = hexStringToUIColor(hex: GlobalConstants.APPCOLOR_DARK)
//    }
//}

//............................... CONVERT DATE ............................................//



//............................... CONVERT HTML ............................................//
// MARK: - CONVERT HTML -


extension UIDevice {
    
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}




//URL
enum Url {
    //LOGINA AND REGISTRATION
    static let login = NSURL(string: "\(Application.BaseURL)secure/auth/login")!
    static let register = NSURL(string: "\(Application.BaseURL)secure/auth/register")!

    static let genresList = NSURL(string: "\(Application.BaseURL)secure/channel/genres")!
    static let genreList = NSURL(string: "\(Application.BaseURL)secure/channel/genre")!
    static let updateUserDetails = NSURL(string: "\(Application.BaseURL)secure/users/")!
    static let radioList = NSURL(string: "\(Application.BaseURL)secure/radio/genre/")!
    static let radioTrackList = NSURL(string: "\(Application.BaseURL)secure/radio/track/")!
    static let radioArtistList = NSURL(string: "\(Application.BaseURL)secure/radio/artist/")!

    static let popularTrackList = NSURL(string: "\(Application.BaseURL)secure/channel/popular-tracks")!

    static let artistsList = NSURL(string: "\(Application.BaseURL)secure/artists/")!
    static let albumeList = NSURL(string: "\(Application.BaseURL)secure/albums/")!
    static let trackList = NSURL(string: "\(Application.BaseURL)secure/tracks/")!

    //SEARCH
    static let searchList = NSURL(string: "\(Application.BaseURL)secure/search")!

    static let getTimeZone = NSURL(string: "\(Application.BaseURL)secure/value-lists/timezones,countries,localizations")!
    
    
    //SAVE TRACK
    static let saveTrack = NSURL(string: "\(Application.BaseURL)secure/users/me/liked-tracks")!
    static let addToLibrary = NSURL(string: "\(Application.BaseURL)secure/users/me/add-to-library")!
    static let removeFromLibrary = NSURL(string: "\(Application.BaseURL)secure/users/me/remove-from-library")!
    
    //SAVE ARTISTS
    static let saveArtist = NSURL(string: "\(Application.BaseURL)secure/users/me/liked-artists")!

    //SAVE ALBUME
    static let saveAlbume = NSURL(string: "\(Application.BaseURL)secure/users/me/liked-albums")!

    //UPLOAD IMAGE
    static let uploadImage = NSURL(string: "\(Application.BaseURL)secure/uploads/images")!
    
    //PLAYLIST
    static let addNewPlayList = NSURL(string: "\(Application.BaseURL)secure/playlists")!
    
    //GET YOUTUB DATA
    static let version = "v3"
    static let viewDetails = NSURL(string: "https://www.googleapis.com/youtube/\(version)/videos?id=")!
 
    //SEARCH YOUTUB ID
    static let searchYoutubID = NSURL(string: "\(Application.BaseURL)secure/search/audio")!
    static let youtubeURL =  NSURL(string: "https://www.youtube.com/watch?v=")!

}


extension UIImage {
    
    public convenience init?(setColor: UIColor?, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        setColor?.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

func ImpactGenerator(){
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
    impactFeedbackgenerator.prepare()
    impactFeedbackgenerator.impactOccurred()
}



//CHECK PRODUCT
func isDevelopmentProvisioningProfile() -> Bool {
    return true
    
}


func removeZero(strNumber : String) -> String{
    var arrString = Array(strNumber)
    if arrString.count != 0{
        if arrString[0] == "0"{
            arrString.remove(at: 0)
        }
        
        var Number : String = ""
        for str in arrString{
            Number = "\(Number)\(str)"
        }
        
        return Number
    }
    return ""
}


//MARK: -- Data Formate Convertion --
func convertStringToDate(dateString: String, withFormat format: String) -> Date? {
    if isValidDate(dateString: dateString, currentFormate: Application.strDateFormet) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = Application.strDateFormet

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            return outputFormatter.date(from: outputFormatter.string(from: date))
        }
    }
   
    return Date()
}

func convertDateToString(date: Date, withFormat format: String, newFormate : String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = format
    let strDate = inputFormatter.string(from: date)

    if let date = inputFormatter.date(from: strDate) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = newFormate
        return outputFormatter.string(from: date)
    }
    return strDate
}


func CurrntDateToString( withFormat format: String, newFormate : String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = format
    let strDate = inputFormatter.string(from: Date())
    return strDate
}

//func convertDateFormater(_ OrderDate: String) -> String{
//    
//    if isValidDate(dateString: OrderDate, currentFormate: Application.strDateFormet) {
//        let dateFormatter = DateFormatter()
//        
//        dateFormatter.dateFormat = Application.strDateFormet
//        let date = dateFormatter.date(from: OrderDate)
//        dateFormatter.dateFormat = Application.pickerDateFormet
//        return  dateFormatter.string(from: date!)
//    }
//    return "-"
//}

//func convertDateFormater2(_ OrderDate: String) -> String{
//    
//    if isValidDate(dateString: OrderDate, currentFormate: Application.pickerDateFormet) {
//        let dateFormatter = DateFormatter()
//        
//        dateFormatter.dateFormat = Application.pickerDateFormet
//        let date = dateFormatter.date(from: OrderDate)
//        dateFormatter.dateFormat = Application.strDateFormet
//        return  dateFormatter.string(from: date!)
//    }
//    return "-"
//}


func convertDateFormater(_ OrderDate: String, CurrentDateFormate : String, ChangeDateFormate  :String) -> String{
    
    if isValidDate(dateString: OrderDate, currentFormate: CurrentDateFormate) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = CurrentDateFormate
        let date = dateFormatter.date(from: OrderDate)
        dateFormatter.dateFormat = ChangeDateFormate
        return  dateFormatter.string(from: date!)
    }
    return ""
}




func isValidDate(dateString: String, currentFormate : String?) -> Bool {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = currentFormate
    if let _ = dateFormatterGet.date(from: dateString) {
        //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
        return true
    } else {
        // Invalid date
        return false
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}


extension String {
    func isValidPassword() -> Bool {
        //        let regularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        let regularExpression = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        
        return passwordValidation.evaluate(with: self)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}





func showToast(sender:UIView, message : String) {
    
    let viewBG = UIView(frame: CGRect(x: 0, y: sender.frame.size.height - manageWidth(size: 125), width: sender.frame.size.width, height: manageWidth(size: 50)))
    viewBG.backgroundColor = UIColor.gray
//
//    let toastLabel = UILabel(frame: CGRect(x: 0, y: sender.frame.size.height-115, width: 380, height: 35))
//    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//    toastLabel.textColor = UIColor.white
//    toastLabel.configureLable(textColor: setColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 13, text: "")
//    toastLabel.textAlignment = .center;
//    toastLabel.text = message
//    toastLabel.alpha = 1.0
//    toastLabel.layer.cornerRadius = 10;
//    toastLabel.clipsToBounds  =  true
    sender.addSubview(viewBG)
//    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//        })
//    }
}





//MARK: - OPEN EXTERNAL URL
func opneExternalURL(strURL : String){
    
    // encode a space to %20 for example
    let escapedShareString = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

    // cast to an url
    let url = URL(string: escapedShareString)

    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url!)
    }
}



func bandWidth(birRate : String) -> Double{
    switch (birRate) {
    case "1080":
        return 3471000
    case "720":
        return 1934000
    case "480":
        return 1106000
    case "360":
        return 837000
    case "240":
        return 185000
    default:
        break
    }
    return 0
}


public func clearCache() {
    //Delete Cookies
    if let cookies = HTTPCookieStorage.shared.cookies {
        for cookie in cookies {
            NSLog("\(cookie)")
        }
    }
    
    let storage = HTTPCookieStorage.shared
    for cookie in storage.cookies! {
        storage.deleteCookie(cookie)
    }
}

func showCookies() {

    let cookieName = "MYCOOKIE"
    if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName }) {
        debugPrint("\(cookieName): \(cookie.value)")
    }
}
