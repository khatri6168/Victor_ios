//
//  WebServiceHelper.swift
//  HealthyBlackMen
//
//  Created by Jigar Khatri on 30/04/21.
//

import UIKit
import Alamofire
import AVFoundation

var webservice_Nool_Load : Bool = false

// MARK: - Protocol -
@objc protocol WebServiceHelperDelegate{
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String)
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection : Int, selectIndexRow : Int, request strRequest: String)
    func appDataDidFail(_ error: Error, request strRequest: String)
}

class WebServiceHelper: NSObject,InternetAccessDelegate {

    var strMethodName = ""
    var selectIndexSection : Int = 0
    var selectIndexRow : Int = 0
    
    weak var delegate: WebServiceHelper?
    var strURL : String = ""
    var jsonString = ""
    var methodType : String = ""
    var dictType : [String : Any] = [:]
    var dictHeader : NSDictionary = [:]
    var indicatorShowOrHide : Bool = true
    var serviceWithAlert : Bool = false
    var serviceWithAlertDefault : Bool = false
    var serviceWithAlertErrorMessage : Bool = false
    var imageUpload : UIImage!
    var imageUploadName : String = ""
    var showLogForCallingAPI : Bool = true
    var strAuthorize : String = ""
    var strUploadType : String = ""

    var arr_MutlipleimagesAndVideo : NSMutableArray = []
    var arr_MutlipleimagesAndVideoType : NSMutableArray = []
    var arr_MutlipleimagesAndVideoName : NSMutableArray = []
    var arr_Mutlipleimages : [[String : Any]] = []
    var delegateWeb:WebServiceHelperDelegate?
    
    
    //MARK:- NO INTERNET CONNECTION DELEGATE METHOD
    func ReceiveInternetNotify(strMethodName: String) {
        if strMethodName == "startDownload"{
            callAPI()
        }else if strMethodName == "startDownloadWithImage"{
            startDownloadWithImage()
        }else if strMethodName == "startUploadingMultipleImagesAndVideo"{
            startUploadingMultipleImagesAndVideo()
        }
    }
    
    struct Item: Decodable {
        let id: String
        let sortingId: String
        let name: String
    }

    struct ErrorData : Decodable {
        let status : String
        let msg: String
    }
    
    // MARK: - StartDowload Method -
    func callAPI(){
        
        if NetworkReachabilityManager()!.isReachable {
        
            do {
                
                webservice_Nool_Load = true
                
                DispatchQueue.main.async {
                    if self.indicatorShowOrHide == true{
                        indicatorShow()
                    }
                }

                //Calling service
                let manager = AF
                manager.sessionConfiguration.timeoutIntervalForRequest = 10
                
                manager.request(self.strURL, method: methodType == "post" ? .post : .get, parameters: self.dictType, encoding: URLEncoding.default).responseJSON { response in
    
                    switch response.result {
                    case .success:
               
                        if let dict = response.value as? NSDictionary{
                            
                            //Check condition for response success or not and notificatino show with coming alert in service response
                            if self.validationForServiceResponse(dict){
                                webservice_Nool_Load = false
                                self.delegateWeb?.appDataDidSuccess(dict, request: self.strMethodName)
                            }else{
                                webservice_Nool_Load = false
                                let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                                self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                            }
                            
                        }
                        else if let arr = response.value as? NSArray{
                            self.delegateWeb?.appArrayDataDidSuccess(arr, selectIndexSection: self.selectIndexSection, selectIndexRow: self.selectIndexRow, request: self.strMethodName)
                        }
                       
                        
                    case .failure(_):
                        webservice_Nool_Load = false
                        let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                        self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                    }
                 }
                
            }

        }else{
            webservice_Nool_Load = false

            let ViewController = getTopViewController!
            if let view = ViewController.children.last {
                if !(view.isKind(of: NoInternetViewController.self)){
                    let storyboard = UIStoryboard(name:GlobalConstants.LOGIN_MODEL,bundle: Bundle.main)
                    let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
                    view.modalPresentationStyle = .fullScreen
                    view.strCallingMethodName = "startDownload"
                    
                    view.delegate = self
                    let ViewController = getTopViewController
                    ViewController? .present(view, animated: true, completion: nil)
                }
            }
            else{
                if !(ViewController.isKind(of: NoInternetViewController.self)){
                    let storyboard = UIStoryboard(name:GlobalConstants.LOGIN_MODEL,bundle: Bundle.main)
                    let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
                    view.modalPresentationStyle = .fullScreen
                    view.strCallingMethodName = "startDownload"
                    
                    view.delegate = self
                    let ViewController = getTopViewController
                    ViewController? .present(view, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
  
    func callOtherAPI(){
        
        if NetworkReachabilityManager()!.isReachable {
        
            do {
                
                webservice_Nool_Load = true
                
                DispatchQueue.main.async {
                    if self.indicatorShowOrHide == true{
                        indicatorShow()
                    }
                }

                let accessTokenHeaderFile : HTTPHeaders = [
                    "Accept": "application/json",
                    "Content-Type" :"application/json",
                    "Cookie" : "XSRF-TOKEN=eyJpdiI6ImNCR3lKQmNrSTVBa0lzL2hkd3RLd0E9PSIsInZhbHVlIjoiQlI4Uk5mQ3hoNWdBTHgySllWbTJ3U3FzdS83VHBNd0xJWFJNc1RDMmdYMy9Ib1ZNOUcwNHBJQkpYRFU1cEZucHc1eVBNNEtNamdCd2h1VlQwK29BdWhFRzZEdUhra2ZmRWtYdzhQT3EvK1RtSEJWWW9jT0xWbytLcXJmbEl5YmIiLCJtYWMiOiI1ZDJmY2I5ZGFjZjNlMDg2ODJmOTY5ZGY0MWYwYmUxYThkNGNjMmQxMDI1Y2I1NjZjZmNiMTI3ODVmNDhjOWE0IiwidGFnIjoiIn0%3D; free_music_session=eyJpdiI6IktTNFhZelcrR3J0a3VYZit2N2FjWlE9PSIsInZhbHVlIjoiZjZCdjIya1N0S0JkMWVpamgza1Q5a0tHM0daSnVPWmtLRzNXcXdJbjBrVmhlc3I1TStXbkVXamVpeS9CZXJnVG5yTzcrYXp1YUJvTXVLYzdwbS9CZElPMTNjTE1kMXk0TXVxS3AxaG1tZTlKaDMwdURkSk1FdjJoSmdmOHBUS0ciLCJtYWMiOiI2NGYwOTIzMzU0OThlM2VjOGI3YTY1YjhmNWQ3ZGY4MzJmYjA1NWQ5OTdkODgyMDA5MmIwOTkzMGZjY2QzYTMzIiwidGFnIjoiIn0%3D; theme=light; remember_web_59ba36addc2b2f9401580f014c7f58ea4e30989d=eyJpdiI6IjhjZ2xLSVJLYlYzZVcrU0V1eWY4ZHc9PSIsInZhbHVlIjoiaUt2bFJsUXRJQlVEWHZTWXhaL1p2VFVsVTJuL3I5OXBoZGxEQjNURERXYWlEWlVhenNaNUtGNVAxcURZQUN5L1MvNldFZ3Zaa0FiLzVvNFVoR2x0MnJkK3kzbGkwbU83Ukt4OEZxUFdYSGUwMUk3VkovVXpMU2FCVTF1bzlTSTJXRDVuUnR4VFlIQTJZMmZRV0pST2RlRER0d2xlSXNkYnZRQm1vZFhwMkdtVStHSXN5V1dsNHJiTHdqeVZiR1VraGlUSkxmV1REZG40alR1eXduMnpVZW5aVUoxZEIrU3FIWmhwUHBrV3g5MD0iLCJtYWMiOiI3OTRkOWY4M2NmN2E0NDIzMmY2NDllMDBiOTA1N2Y4OWM0ZTk1MDdiYmQzY2FkZDBjNTMzMTQxZTJjYmE3MzI0IiwidGFnIjoiIn0%3D",
                    "X-XSRF-TOKEN" : "eyJpdiI6ImNCR3lKQmNrSTVBa0lzL2hkd3RLd0E9PSIsInZhbHVlIjoiQlI4Uk5mQ3hoNWdBTHgySllWbTJ3U3FzdS83VHBNd0xJWFJNc1RDMmdYMy9Ib1ZNOUcwNHBJQkpYRFU1cEZucHc1eVBNNEtNamdCd2h1VlQwK29BdWhFRzZEdUhra2ZmRWtYdzhQT3EvK1RtSEJWWW9jT0xWbytLcXJmbEl5YmIiLCJtYWMiOiI1ZDJmY2I5ZGFjZjNlMDg2ODJmOTY5ZGY0MWYwYmUxYThkNGNjMmQxMDI1Y2I1NjZjZmNiMTI3ODVmNDhjOWE0IiwidGFnIjoiIn0%3D"
                ]
                
                //Calling service
                let manager = AF
                manager.sessionConfiguration.timeoutIntervalForRequest = 10
                manager.request(self.strURL, method: .post, parameters: self.dictType, encoding: JSONEncoding.default, headers: accessTokenHeaderFile).responseJSON { response in

//                manager.request(self.strURL, method: methodType == "post" ? .post : .get, parameters: self.dictType, encoding: URLEncoding.httpBody).responseJSON { response in
    
                    switch response.result {
                    case .success:
               
                        if let dict = response.value as? NSDictionary{
                            
                            //Check condition for response success or not and notificatino show with coming alert in service response
                            if self.validationForServiceResponse(dict){
                                webservice_Nool_Load = false
                                self.delegateWeb?.appDataDidSuccess(dict, request: self.strMethodName)
                            }else{
                                webservice_Nool_Load = false
                                let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                                self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                            }
                            
                        }
                        else if let arr = response.value as? NSArray{
                            self.delegateWeb?.appArrayDataDidSuccess(arr, selectIndexSection: self.selectIndexSection, selectIndexRow: self.selectIndexRow, request: self.strMethodName)
                            
                        }
                       
                        
                    case .failure(_):
                        webservice_Nool_Load = false
                        let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                        self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                    }
                 }
                
            }

        }else{
            webservice_Nool_Load = false

            let ViewController = getTopViewController!
            if let view = ViewController.children.last {
                if !(view.isKind(of: NoInternetViewController.self)){
                    let storyboard = UIStoryboard(name:GlobalConstants.LOGIN_MODEL,bundle: Bundle.main)
                    let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
                    view.modalPresentationStyle = .fullScreen
                    view.strCallingMethodName = "startDownload"
                    
                    view.delegate = self
                    let ViewController = getTopViewController
                    ViewController? .present(view, animated: true, completion: nil)
                }
            }
            else{
                if !(ViewController.isKind(of: NoInternetViewController.self)){
                    let storyboard = UIStoryboard(name:GlobalConstants.LOGIN_MODEL,bundle: Bundle.main)
                    let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
                    view.modalPresentationStyle = .fullScreen
                    view.strCallingMethodName = "startDownload"
                    
                    view.delegate = self
                    let ViewController = getTopViewController
                    ViewController? .present(view, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    
    
    func startDownloadWithImage(){
        if NetworkReachabilityManager()!.isReachable {
            do {

                webservice_Nool_Load = true
                //Indication show hide with varible when user calling service
                (self.indicatorShowOrHide == true) ? (indicatorShow()) : (indicatorHide())

                //Base user for calling service
                let headers: HTTPHeaders = [:]
                                
         
                //Calling service
                AF.upload(multipartFormData: { multipartFormData in
                    
                    multipartFormData.append(self.imageUpload!.jpegData(compressionQuality: 0.5)!, withName: self.imageUploadName , fileName: "\(randomString(length: 5)).png", mimeType: "png")

                    for (key, value) in self.dictType  {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key )
                    }
                    
                    print(multipartFormData)
                },
                to: self.strURL,
                usingThreshold: UInt64.init(), method: .post,
                headers: headers).responseJSON { response in
                    print(response)
                    switch response.result {
                    
                    case .success:
                        let dict = response.value as! NSDictionary
                        
                        
                        //Check condition for response success or not and notificatino show with coming alert in service response
                        if self.validationForServiceResponse(dict){
                            webservice_Nool_Load = false
                            self.delegateWeb?.appDataDidSuccess(dict, request: self.strMethodName)
                        }else{
                            webservice_Nool_Load = false
                            let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                            self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                        }
                        
                    case .failure(_):
                        webservice_Nool_Load = false
                        let err = NSError(domain: "data not found", code: 401, userInfo: nil)
                        self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
                    }
                 }
            }


        }else{
            webservice_Nool_Load = false
            let storyboard = UIStoryboard(name:"Other",bundle: Bundle.main)
            let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
            view.modalPresentationStyle = .fullScreen
            view.delegate = self
            view.strCallingMethodName = "startDownloadWithImage"
            let ViewController = getTopViewController
            ViewController? .present(view, animated: true, completion: nil)

            let err = NSError(domain: "data not found", code: 401, userInfo: nil)
            self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
        }
    }
    
    func startUploadingMultipleImagesAndVideo(){
//        if NetworkReachabilityManager()!.isReachable {
//            do {
//                webservice_Nool_Load = true
//
//                //Indication show hide with varible when user calling service
//                (self.indicatorShowOrHide == true) ? (indicatorShow()) : (indicatorHide())
//
//                //Declaratin for Serialization
//                //            print(self.dictType)
//                print(self.arr_MutlipleimagesAndVideo.count)
//                let jsonData = try JSONSerialization.data(withJSONObject: self.dictType, options: .prettyPrinted)
//
//                //Base user for calling service
//                let strUrl = URL(string: self.strURL)!
//                var request = URLRequest(url: strUrl)
//
//                //Declaration for service for get,post or other..
//                request.httpMethod = HTTPMethod.post.rawValue
//
//                //Pass paramater with value data
//                request.httpBody = jsonData
//
//                //Calling service
//                Alamofire.upload(multipartFormData:{ multipartFormData in
//
//                    if self.strUploadType == "OtherItem_Photo"{
//                        for i in (0..<self.arr_Mutlipleimages.count){
//                            let obj = self.arr_Mutlipleimages[i]
//                            let imgData : Data = obj["img"] as! Data
//                            let imgName : String = obj["name"] as! String
//
//                            if self.strUploadType == "OtherItem_Photo"{
//                                multipartFormData.append(imgData, withName: "\(self.imageUploadName)",fileName: imgName, mimeType: "image/jpeg")
//
//                            }
//                        }
//                    }
//                    else{
//
//                        for i in (0..<self.arr_MutlipleimagesAndVideo.count){
//
//                            let imageData = self.arr_MutlipleimagesAndVideo[i]
//                            let imgData : Data = imageData as! Data
//
//                            if (imgData.count != 0){
//
//                                if self.strUploadType == "photo"{
//                                    multipartFormData.append(imgData, withName: "\(self.imageUploadName)",fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
//                                }else{
//                                    multipartFormData.append(imgData, withName: "\(self.imageUploadName)",fileName: "\(Date().timeIntervalSince1970).mov", mimeType: "application/octet-stream")
//                                }
//                            }
//                        }
//                    }
//
//
//                    for (key, value) in self.dictType  {
//                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key as! String)
//                    }
//                },
//                                 usingThreshold:UInt64.init(),
//                                 to:strUrl,
//                                 method:.post,
//                                 headers:dictHeader as? HTTPHeaders,
//                                 encodingCompletion: { encodingResult in
//                                    switch encodingResult {
//                                    case .success(let upload, _, _):
//                                        upload.responseJSON(completionHandler: { response in
//                                            //Redirect caling view if success
//                                            if !(response.result.error != nil){
//                                                //Check condition for response success or not and notificatino show with coming alert in service response
//
//                                                webservice_Nool_Load = false
//
//                                                if self.validationForServiceResponse(response.result.value ?? ""){
//                                                    self.delegateWeb?.appDataDidSuccess(response.result.value ?? "", request: self.strMethodName)
//                                                }
//                                            }else{
//                                                webservice_Nool_Load = false
//
//                                                indicatorHide()
//                                            }
//                                        })
//                                    case .failure(let encodingError):
//                                        indicatorHide()
//                                        print("en eroor :", encodingError)
//                                        webservice_Nool_Load = false
//                                    }
//                })
//            } catch {
//
//                //Alert show for Header
//                messageBar.MessageShow(title: GlobalConstants.appName as NSString, alertType: MessageView.Layout.cardView, alertTheme: .error, TopBottom: true)
//
//                self.validationForServiceResponse(error.localizedDescription)
//
//                webservice_Nool_Load = false
//            }
//
//        }else{
//            webservice_Nool_Load = false
//            let storyboard = UIStoryboard(name:"Other",bundle: Bundle.main)
//            let view = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
//            view.delegate = self
//            view.strCallingMethodName = "startUploadingMultipleImagesAndVideo"
//            let ViewController = getTopViewController
//            ViewController? .present(view, animated: true, completion: nil)
//
//            let err = NSError(domain: "data not found", code: 401, userInfo: nil)
//            self.delegateWeb?.appDataDidFail(err, request: self.strMethodName)
//        }
    }
    
    
    // MARK: - Other Method -
    func validationForServiceResponse(_ response: NSDictionary) -> Bool{

        DispatchQueue.main.async {
            //Indication show hide with varible when user calling service
            if self.indicatorShowOrHide == true{
                indicatorHide()
            }
        }

        if response["code"] != nil{
            let responseKey = Int(response.getStringForID(key: "code")) ?? 0
            
            //101 invalide user or already registartion with current credincial
            switch responseKey {
            case 100,101,102:
                if self.serviceWithAlert || self.serviceWithAlertErrorMessage {
                    indicatorHide()

                    //Alert show for Header
                    showAlertMessage(strMessage: "\(response["msg"] ?? "")")
                }

                return false
            case 401:
                indicatorHide()

                //USER LOG OUT
                LogOutUser()
                
                //Alert show for Header
                showAlertMessage(strMessage: "\(response["msg"] ?? "")")
                return false
            case 105:
//                //USER LOG OUT
//                LogOtuUser()
//                
                return false
            default:
                if self.serviceWithAlert {
                    
//                  messageBar.MessageShow(title: response["msg"]! as! String as NSString, alertType: MessageView.Layout.cardView, alertTheme: .success, TopBottom: true)
                }else if self.serviceWithAlertDefault {
                    indicatorHide()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let alert = UIAlertController(title: Application.appName, message: response["msg"]! as? String, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        GlobalConstants.appDelegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                }
                break
            }
        }
        return true
    }
}


func LogOutUser()  {
//    //DeviceToken Remove
//    if let obj = UserDefaults.standard.user{
//        GlobalConstants.appDelegate?.deleteDeviceTokenAPI(deviceTokenParameater: AppDelegate.DeviceTokenParameater(CustomerId: obj.userID ?? ""))
//    }
//    
//    
//    //REMOVE ALL DETAILS
//    imgNavigation = UIImageView()
//    UserDefaults.standard.deviceToken = ""
//    UserDefaults.standard.user = nil
//    UserDefaults.standard.skipLogin = ""
//    
//    //NVIGATE WELCOME SCREEN
//    let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
//    if let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController{
//        /* Initiating instance of ui-navigation-controller with view-controller */
//        let navigationController = UINavigationController()
//        navigationController.viewControllers = [newViewController]
//        GlobalConstants.appDelegate?.window?.rootViewController = navigationController
//        GlobalConstants.appDelegate?.window?.makeKeyAndVisible()
//
//    }
}

