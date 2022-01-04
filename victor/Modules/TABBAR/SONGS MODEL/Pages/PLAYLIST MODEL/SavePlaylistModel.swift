//
//  SavePlaylistModel.swift
//  victor
//
//  Created by Jigar Khatri on 18/11/21.
//

import Foundation
import ObjectMapper



//REGISTER SCREEN ..........................
extension SavePlaylistViewController :WebServiceHelperDelegate{
    
    
    func getSavePlaylistAPI(strUserId : String){
        if UserDefaults.standard.user == nil{
            self.emptyDataView.isHidden = false
            self.viewLine.isHidden = true
            return
        }
        
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.objCollection)
            }
        }
        
        //Declaration URL
        let strURL = "\(Url.updateUserDetails.absoluteString!)\(strUserId)/playlists"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "savePlaylist"
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
    
    
    
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()
        self.isLoading = false
        storeLoading()
        
        
        if strRequest == "savePlaylist"{
            //GET PLAYLIST
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSavePlay_List = []
                    arrSavePlay_List = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                    self.arrSavePlayList = arrSavePlay_List
                    
                    
                    //SET VIEW
                    self.setTheView()
                    self.emptyDataView.isHidden = true
                    self.viewLine.isHidden = false
                    
                    if self.arrSavePlayList.count == 0{
                        self.emptyDataView.isHidden = false
                        self.viewLine.isHidden = true
                    }
                    self.objCollection.reloadData()
                    
                }
            }
        }
    }
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
