//
//  NSUserDefault+Extension.swift
//  Deonde
//
//  Created by Ankit Rupapara on 21/04/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import Foundation
import ObjectMapper

//Never user NSUDKey enum directly, use UserDefaults's Extenion's property only
enum NSUDKey {
    static let deviceToken = "deviceToken"
    static let language = "language"
    static let userData = "userData"
    static let profile = "profile"
    static let userSignUp = "userSignUp"
    static let colourMode = "colourMode"
    static let userRemeber = "userRemeber"
    static let getCoine = "getCoine"

}


extension Notification.Name {
    static let languageUpdate = Notification.Name("languageUpdate")
    static let colourMode = Notification.Name("colourMode")
    static let loginScuuess = Notification.Name("loginScuuess")

    static let videoPlay = Notification.Name("videoPlay")
    static let updateTiming = Notification.Name("updateTiming")
    static let autoPlayNextMusic = Notification.Name("autoPlayNextMusic")

    static let PlayNextMusic = Notification.Name("PlayNextMusic")
    static let PlayPreviousMusic = Notification.Name("PlayPreviousMusic")
    static let PlayerDetails = Notification.Name("PlayerDetails")
    static let PlayPlayMusic = Notification.Name("PlayPlayMusic")
    static let SetTabBarDetails = Notification.Name("SetTabBarDetails")

    static let removeLoading = Notification.Name("removeLoading")
    static let downLoadProgress = Notification.Name("downLoadProgress")
    static let downLoadFinished = Notification.Name("downLoadFinished")
}


extension UserDefaults{
    var user: User? {

        get {
            guard dictionaryRepresentation().keys.contains(NSUDKey.userData)
                else { return nil }

            guard let data = data(forKey: NSUDKey.userData)
                else { return nil }

        
            do {
                if let archivedCategoryNames = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? User {
                    return archivedCategoryNames
                }
            } catch {
                return nil
            }
            
            return nil

        }
        set{
            if newValue == nil {
                removeObject(forKey: NSUDKey.userData)
            }
            else{
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: newValue!, requiringSecureCoding: false)
                    set(data, forKey: NSUDKey.userData)
                    
                } catch {
                }
            }
            synchronize()
        }
    }
    
    var userRemeber: String?{
        get {
            return string(forKey: NSUDKey.userRemeber)
        }
        set {
            if newValue == nil {
                removeObject(forKey: NSUDKey.userRemeber)
            }
            else{
                set(newValue, forKey: NSUDKey.userRemeber)
            }
            synchronize()
        }
    }
    
    var language: String{
        get {
            if let result = string(forKey: NSUDKey.language){
                return result
            }
            else{
                
                if let currentLanguages = NSLocale.preferredLanguages.first{
                    
                    let languageCode = currentLanguages.substring(to: 2)
                    
                    if Bundle.main.localizations.contains(languageCode){
                        set(languageCode, forKey: NSUDKey.language)
                        synchronize()
                        
                        return languageCode
                    }
                    else{
                        if let firstLanguage = Bundle.main.localizations.first{
                            set(firstLanguage, forKey: NSUDKey.language)
                            synchronize()
                            
                            return firstLanguage
                        }
                        else{
                            return "Base"
                        }
                    }
                }
                else{
                    return "Base"
                }
            }
        }
        set {
            set(newValue, forKey: NSUDKey.language)
            synchronize()
            languageChangeNotification()

            NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
        }
    }
    

    var colourMode: String?{
        get {
            return string(forKey: NSUDKey.colourMode)
        }
        set {
            if newValue == nil {
                removeObject(forKey: NSUDKey.colourMode)
            }
            else{
                set(newValue, forKey: NSUDKey.colourMode)
            }
            synchronize()
            
            languageChangeNotification()
            NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
        }
        
    }
    
    
    var getCoine: String?{
        get {
            return string(forKey: NSUDKey.getCoine)
        }
        set {
            if newValue == nil {
                removeObject(forKey: NSUDKey.getCoine)
            }
            else{
                set(newValue, forKey: NSUDKey.getCoine)
            }
            synchronize()
        }
        
    }
    
    var deviceToken: String?{
        get {
            return string(forKey: NSUDKey.deviceToken)
        }
        set {
            if newValue == nil {
                removeObject(forKey: NSUDKey.deviceToken)
            }
            else{
                set(newValue, forKey: NSUDKey.deviceToken)
            }
            synchronize()
        }
    }
    
    var userSignUp: String?{
        get {
            return string(forKey: NSUDKey.userSignUp)
        }
        set {
            if newValue == nil {
                removeObject(forKey: NSUDKey.userSignUp)
            }
            else{
                set(newValue, forKey: NSUDKey.userSignUp)
            }
            synchronize()
        }
    }
    

}
