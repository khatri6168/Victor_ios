//
//  RegisterModel.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import Foundation

//REGISTER SCREEN ..........................
extension RegisterViewController :WebServiceHelperDelegate{
    struct RegisterParameater: Codable {
        var email: String
        var password: String
        var password_confirmation: String
        var purchase_code: String
    }

    func registerAPI(RegisterParameater:RegisterParameater){
        ImpactGenerator()
        indicatorShow()
        guard let parameater = try? RegisterParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.register.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "register"
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
            if strRequest == "register"{
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
                            
                            //SAVE OBJECT
                            UserDefaults.standard.user = userObj
                            
                            //MOVE TO BACK SCREEN
                            if isLoginScreen {
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
