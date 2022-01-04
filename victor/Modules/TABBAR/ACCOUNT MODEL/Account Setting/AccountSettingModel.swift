//
//  AccountSettingModel.swift
//  victor
//
//  Created by Jigar Khatri on 09/11/21.
//

import Foundation
import ObjectMapper

struct TimeZoneModel: Mappable{
    internal var text: String?
    internal var value: String?
    internal var type: String?

    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        text <- map["text"]
        value <- map["value"]
    }
}

struct CountriesModel: Mappable{
    internal var name: String?
    internal var code: String?
    
    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        code <- map["code"]
        name <- map["name"]
    }
}

struct  LanguageModel : Mappable{
    internal var name: String?
    internal var language: String?
    
    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        language <- map["language"]
        name <- map["name"]
    }
}
   



extension AccountSettingViewController :WebServiceHelperDelegate{
    
    func getTimeZoneAPI(){
        indicatorShow()
        //Declaration URL
        let strURL = "\(Url.getTimeZone.absoluteString!)"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "getTimeZone"
        webHelper.methodType = "get"
        webHelper.strURL = strURL
        webHelper.dictType = [:]
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = false
        webHelper.callAPI()
    }
    
    func getUserDetailsAPI(strUserID : String){

        //Declaration URL
        let strURL = "\(Url.updateUserDetails.absoluteString!)\(strUserID)?with=roles,social_profiles"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "getUserDetails"
        webHelper.methodType = "get"
        webHelper.strURL = strURL
        webHelper.dictType = [:]
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = false
        webHelper.callAPI()
    }
    
    
    
    struct UpdateProfileParameater: Codable {
        var first_name: String
        var last_name: String
        var language: String
        var timezone: String
        var country: String
        var _method: String = "PUT"
    }

    struct deleteAccountParameater: Codable {
        var deleteCurrentUser: Bool = true
        var _method: String = "DELETE"
    }
    func UploadProfileAPI(UpdateProfileParameater:UpdateProfileParameater, strUserID : String){

        ImpactGenerator()
        guard let parameater = try? UpdateProfileParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }

        //Declaration URL
        let strURL = "\(Url.updateUserDetails.absoluteString!)\(strUserID)"

        indicatorShow()
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "updateProfile"
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

    func deleteAccountAPI(deleteAccountParameater:deleteAccountParameater, strUserID : String){

        ImpactGenerator()
        guard let parameater = try? deleteAccountParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }

        //Declaration URL
        let strURL = "\(Url.updateUserDetails.absoluteString!)\(strUserID)"

        indicatorShow()
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "deleteAccountParameater"
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
    
    func UploadProfilePicAPI(strUserID : String){
        ImpactGenerator()
        
        //Declaration URL
        let strURL = "\(Url.updateUserDetails.absoluteString!)\(strUserID)/avatar"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "updateProfilePic"
        webHelper.methodType = "post"
        webHelper.strURL = strURL
        webHelper.dictType = [:]
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = true
        webHelper.imageUpload = imgProfile.image
        webHelper.imageUploadName = "file"
        webHelper.startDownloadWithImage()
    }
    
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        if data.getStringForID(key: "status") == "success"{
            if strRequest == "getTimeZone"{
                print(data)
                
                //GET USER DETAILS
                if let objUser = UserDefaults.standard.user{
                    self.getUserDetailsAPI(strUserID: objUser.id ?? "")
                }
                
                //GET COUNTRY
                if let arrData = data["countries"] as? NSArray{
                    self.arrCountriesList = []
                    self.arrCountriesList = Mapper<CountriesModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
                
                //GET LANGUAGE
                if let arrData = data["localizations"] as? NSArray{
                    self.arrLanguageList = []
                    self.arrLanguageList = Mapper<LanguageModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
                
                
                //GET TIMEZONE
                if let dicData = data["timezones"] as? NSDictionary{
                    self.arrTimeZoneList = []
                    let arrKey = dicData.allKeys as! [String]
                    
                    if arrKey.count != 0{
                        for strKey in arrKey{
                            if let arrData = dicData[strKey] as? NSArray{
                                let arr = Mapper<TimeZoneModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                                for i in 0..<arr.count{
                                    var obj = arr[i]
                                    obj.type = strKey
                                    self.arrTimeZoneList.append(obj)
                                }
                            }
                        }
                    }
                }
            }
            
            else if strRequest == "getUserDetails"{
                indicatorHide()
                
                if let userData = data["user"] as? NSDictionary{
                    //SAVE USER DATA
                    let userObj = UserDefaults.standard.user
                    userObj?.firstname = userData.getStringForID(key: "first_name")
                    userObj?.lastname = userData.getStringForID(key: "last_name")
                    userObj?.email = userData.getStringForID(key: "email")
                    userObj?.profile_pic = userData.getStringForID(key: "avatar")
                    userObj?.username = userData.getStringForID(key: "display_name")

                    userObj?.language = userData.getStringForID(key: "language")
                    userObj?.country = userData.getStringForID(key: "country")
                    userObj?.timezone = userData.getStringForID(key: "timezone")

                    //SAVE OBJECT
                    UserDefaults.standard.user = userObj
                  
                    //SET DETAILS
                    self.setTheDetails()
                }
            }
        }
        else{
            indicatorHide()
        }
        
            
        print(data)
    }
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    
    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
