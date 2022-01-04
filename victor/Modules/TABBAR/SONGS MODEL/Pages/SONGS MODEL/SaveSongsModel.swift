//
//  SaveSongsModel.swift
//  victor
//
//  Created by Jigar Khatri on 18/11/21.
//

import Foundation
import ObjectMapper


extension SaveSongsViewController :WebServiceHelperDelegate{
    func getSaveTrackListAPI(){
        if UserDefaults.standard.user == nil{
            self.emptyDataView.isHidden = false
            self.viewLine.isHidden = true
            return
        }
        
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.tblView)
            }
        }
        
        //Declaration URL
        let strURL = "\(Url.saveTrack.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "saveTrack"
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
        webHelper.callOtherAPI()
    }
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()
        self.isLoading = false
        storeLoading()
        
       if strRequest == "saveTrack"{
            print(data)
            
            //GET TRACK
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    //SAVE DETAILS
                    arrSaveTrack = []
                    arrSaveTrack = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])

                    
                    //SET DETAILS
                    self.emptyDataView.isHidden = true
                    self.viewLine.isHidden = false
                    self.arrSaveSongs = []
                    self.arrSaveSongs = Mapper<RadioModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                    
                    if self.arrSaveSongs.count == 0{
                        self.emptyDataView.isHidden = false
                        self.viewLine.isHidden = true
                    }
                    
                    //RELOAD TABLE
                    self.setTheView()
                    self.tblView.reloadData()
                }
            }
        }
        else if strRequest == "TrackAddRemove"{
//            self.SaveArtistListAPI()
//            self.SaveAlbumeListAPI()
//            self.SaveTrackListAPI()
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
