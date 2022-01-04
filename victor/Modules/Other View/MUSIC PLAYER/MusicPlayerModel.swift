//
//  MusicPlayerModel.swift
//  victor
//
//  Created by Jigar Khatri on 22/11/21.
//

import Foundation
import ObjectMapper

//REGISTER SCREEN ..........................
extension MusicPlayerViewController :WebServiceHelperDelegate{
    func searchVideoID(strID : Int, strName : String){
        
        //Declaration URL
        let strURL = "\(Url.searchYoutubID.absoluteString!)/\(strID)/\(strName)"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "searchYoutubID"
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

    func getYouTubPlayerDetailsAPI(YouTubParameater:YouTubParameater, videoID : String){
        guard let parameater = try? YouTubParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.viewDetails.absoluteString!)\(videoID)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "viewDetails"
        webHelper.methodType = "get"
        webHelper.strURL = strURL
        webHelper.dictType = parameater
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = false
        webHelper.callAPI()
    }
    
    
    
    func AddOrRemoveTrackAPI(TrackAddRemoveParameater : TrackAddRemoveParameater, isRemove : Bool){
        guard let parameater = try? TrackAddRemoveParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        var strURL : String = ""
        if isRemove{
            strURL = "\(Url.removeFromLibrary.absoluteString!)"
        }
        else{
            strURL = "\(Url.addToLibrary.absoluteString!)"

        }
                
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "TrackAddRemove"
        webHelper.methodType = "post"
        webHelper.strURL = strURL
        webHelper.dictType = parameater
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = true
        webHelper.callAPI()
    }
    
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        if strRequest == "viewDetails"{
            if let arrItems = data["items"] as? NSArray{
                if let obj = arrItems[0] as? NSDictionary{
                    if let objSnippet = obj["snippet"] as? NSDictionary{
                        if let objThumbnails = objSnippet["thumbnails"] as? NSDictionary{
                            
                            //GET IMAGE
                            var strVideoImage : String = ""
                            if let objStandard = objThumbnails["standard"] as? NSDictionary{
                                strVideoImage = objStandard.getStringForID(key: "url")
                            }
                            else if let objMedium = objThumbnails["medium"] as? NSDictionary{
                                strVideoImage = objMedium.getStringForID(key: "url")
                            }
                            else if let objMaxres = objThumbnails["maxres"] as? NSDictionary{
                                strVideoImage = objMaxres.getStringForID(key: "url")
                            }
                            else if let objHigh = objThumbnails["high"] as? NSDictionary{
                                strVideoImage = objHigh.getStringForID(key: "url")
                            }
                            else if let objDefault = objThumbnails["default"] as? NSDictionary{
                                strVideoImage = objDefault.getStringForID(key: "url")
                            }
                            
                            //UPDATE YOUTUB ID
                            let MenuID = arrMusicPlayList.map{$0.id}
                            if let index = MenuID.firstIndex(of: CurrentPlayTrackID){
                                var objData = arrMusicPlayList[index]
                                objData.videoImage = strVideoImage
                                
                                //SET NEW OBJECT
                                arrMusicPlayList.remove(at: index)
                                arrMusicPlayList.insert(objData, at: index)
                            }
                            
                            //SET VIEW
                            self.setPlayerDetails()
                        }
                    }
                }
            }
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {

        if strRequest == "searchYoutubID"{
            if arrData.count != 0{
                if let dicData = arrData[0] as? NSDictionary{
                    let strCurrentYoutubID = dicData.getStringForID(key: "id")
                    
                    //UPDATE YOUTUB ID
                    let MenuID = arrMusicPlayList.map{$0.id}
                    if let index = MenuID.firstIndex(of: CurrentPlayTrackID){
                        var objData = arrMusicPlayList[index]
                        objData.youtubID = strCurrentYoutubID ?? ""
                        
                        //SET NEW OBJECT
                        arrMusicPlayList.remove(at: index)
                        arrMusicPlayList.insert(objData, at: index)
                    }
                    
                    //GET VIDEO URL
                    self.getYouTubPlayerDetailsAPI(YouTubParameater: YouTubParameater(), videoID: strCurrentYoutubID ?? "")
                }
            }
        }
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()

        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
