//
//  LoginModel.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import Foundation
import ObjectMapper
import Alamofire
import AVFoundation


class User : NSObject,NSCoding {
    var id: String?
    var firstname: String?
    var lastname: String?
    var email: String?
    var profile_pic: String?
    var username: String?

    var language: String?
    var country: String?
    var timezone: String?

    
    override init() {
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(firstname, forKey: "firstname")
        coder.encode(lastname, forKey: "lastname")
        coder.encode(email, forKey: "email")
        coder.encode(profile_pic, forKey: "profile_pic")
        coder.encode(username, forKey: "username")

        coder.encode(language, forKey: "language")
        coder.encode(country, forKey: "country")
        coder.encode(timezone, forKey: "timezone")
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: "id") as? String
        self.firstname = coder.decodeObject(forKey: "firstname") as? String
        self.lastname = coder.decodeObject(forKey: "lastname") as? String
        self.email = coder.decodeObject(forKey: "email") as? String
        self.profile_pic = coder.decodeObject(forKey: "profile_pic") as? String
        self.username = coder.decodeObject(forKey: "username") as? String

        self.language = coder.decodeObject(forKey: "language") as? String
        self.country = coder.decodeObject(forKey: "country") as? String
        self.timezone = coder.decodeObject(forKey: "timezone") as? String
    }
}



struct TrackModel: Mappable{
    internal var id: Int?
    internal var name: String?
    internal var image_small : String?
    internal var image : String?
    
    internal var arrArtists : [ArtistsModel] = []
    
    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        id <- map["id"]
        name <- map["name"]
        image_small <- map["image_small"]
        image <- map["image"]
        arrArtists <- map["artists"]
    }
}


//LOGIN SCREEN ..........................
extension LoginViewController :WebServiceHelperDelegate{
    struct LoginParameater: Codable {
        var email: String
        var password: String
        var remember: Bool
    }

    func loginAPI(LoginParameater:LoginParameater){
        ImpactGenerator()
        indicatorShow()
        guard let parameater = try? LoginParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.login.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "login"
        webHelper.methodType = "post"
        webHelper.strURL = strURL
        webHelper.dictType = parameater
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = false
        webHelper.callAPI()
    }
        

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()

        print(data)
        if data.getStringForID(key: "status") == "success"{
            if strRequest == "login"{
                
                if let strData = data.getStringForID(key: "data"){
                    //CONVERT BASE64 To Json
                    let decodedData = Data(base64Encoded: strData)!
                    let decodedString = String(data: decodedData, encoding: .utf8)!
                    if decodedString != ""{
                        let dicData = convertToDictionary(text: decodedString)
                        if let userData = dicData?["user"] as? NSDictionary{
                            //SAVE USER DATA
                            let userObj = User()
                            userObj.id = userData.getStringForID(key: "id")
                            userObj.firstname = userData.getStringForID(key: "first_name")
                            userObj.lastname = userData.getStringForID(key: "last_name")
                            userObj.email = userData.getStringForID(key: "email")
                            userObj.profile_pic = userData.getStringForID(key: "avatar")
                            userObj.username = userData.getStringForID(key: "display_name")
                            userObj.language = userData.getStringForID(key: "language")
                            userObj.country = userData.getStringForID(key: "country")
                            userObj.timezone = userData.getStringForID(key: "timezone")

                            //SAVE OBJECT
                            if selectRemember{
                                UserDefaults.standard.userRemeber = "true"
                            }else{
                                UserDefaults.standard.userRemeber = "false"
                            }
                            UserDefaults.standard.user = userObj
                            
                            //MOVE TO BACK SCREEN
                            NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
                            if isSignupScreen {
                                NotificationCenter.default.post(name: .loginScuuess, object: nil, userInfo: nil)
                                self.navigationController?.popViewController(animated: true)

                            }
                            else{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    else{
                        showAlertMessage(strMessage: str.invalidRequestParamater)
                    }
                }
            }
        }
        else{
            showAlertMessage(strMessage: str.errorInvalidDetails)
        }
        
       
    }
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
