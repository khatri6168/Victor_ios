//
//  Metadata.swift
//  Deonde
//
//  Created by Ankit Rupapara on 26/05/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import Foundation
import UIKit

enum Application {
    
    static let appName: String = str.appName
    
    static let aapBundilID_Dev = "com.samuhbhutan.dev"
    static let supportNumber = ""
    static let contactEmail = ""


    //URL
    static let webURL = "https://freemusic.digital"
    static let termsCondition = ""
    static let privacyPolicy = ""

    //APP STORE URL
    static let appURL = "itms-apps://itunes.apple.com/app/"
    static let appStoreId = Bundle.main.bundleIdentifier == aapBundilID_Dev ? "1572420610" : "1573566575"

    //OTHER KEY
    static let googleApiKey = "AIzaSyA6rvAs2AYruXdASWanoElDh8QWCX4okkU"
    static let VERSION = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"

//    //GOOGLE ADS Live  uncomment while go on live
//    static let googleAppOpen = "ca-app-pub-7646493951374482/8923952188"
//    static let gogleBanner = "ca-app-pub-7646493951374482/4079013135"
//    static let gogleRewarded = "ca-app-pub-7646493951374482/4789459576"
    
    
    
    //GOOGLE ADS Test
    static let googleAppOpen = "ca-app-pub-3940256099942544/5662855259"
    static let gogleBanner = "ca-app-pub-3940256099942544/2934735716"
    static let gogleRewarded = "ca-app-pub-3940256099942544/4806952744"

    
    //Base URL
    static let BaseURL = "https://freemusic.digital/"
    
    
    //DATE FORMET
    static let strDateFormet = "dd MMM yyyy"
    static let pickerDateFormet = "yyyy-MM-dd"
    
    
    //ADDS CELL
    static let adsValue = 5
    

}

func setColour() -> UIColor{
    if UserDefaults.standard.colourMode == "light"{
        return UIColor.primary ?? UIColor.black
    }
    else{
        return UIColor.secondary ?? UIColor.white
    }
}

func setPopupColour() -> UIColor{
    if UserDefaults.standard.colourMode == "light"{
        return UIColor.primary ?? UIColor.black
    }
    else{
        return UIColor.secondaryLight ?? UIColor.white
    }
}


func setTextColour() -> UIColor{
    if UserDefaults.standard.colourMode != "light"{
        return UIColor.primary ?? UIColor.black
    }
    else{
        return UIColor.secondary ?? UIColor.white
    }
}
