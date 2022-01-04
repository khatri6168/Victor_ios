//
//  Top50Model.swift
//  victor
//
//  Created by Jigar Khatri on 11/11/21.
//

import Foundation
import ObjectMapper

//REGISTER SCREEN ..........................
extension Top50ViewController :WebServiceHelperDelegate{

    func PopularTrackAPI(GenresParameater:GenresParameater ,isLoading : Bool){
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.tblView)
            }
        }
        
        guard let parameater = try? GenresParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
 
        //Declaration URL
        let strURL = "\(Url.popularTrackList.absoluteString!)"
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "popularTrackList"
        webHelper.methodType = "get"
        webHelper.strURL = strURL
        webHelper.dictType = parameater
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = isLoading
        webHelper.callAPI()
    }

   
    func searchVideoID(index : Int, strID : Int, strName : String){
        
        //Declaration URL
        let strURL = "\(Url.searchYoutubID.absoluteString!)/\(strID)/\(strName)"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "searchYoutubID"
        webHelper.selectIndexRow = index
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
        self.stopAnimatingView()
        self.objRefresh?.endRefreshing()
        self.isLoading = false
        storeLoading()
        
        print(data)
        if strRequest == "popularTrackList"{
            if let objChannel = data["channel"] as? NSDictionary{
                if let objContent = objChannel["content"] as? NSDictionary{
                    if let arrData = objContent["data"] as? NSArray{
                        let arr = Mapper<RadioModel>().mapArray(JSONArray: arrData as! [[String : Any]])

                        if arr.count != 0{
                            if pageCount == 1{
                                self.arrPopulerTrackList = []
                            }
                            
                            for obj in arr{
                                self.arrPopulerTrackList.append(obj)
                            }
                            
                            //ADD ADS
                            if isAdsShowing{
                                if arrPopulerTrackList.count > 5{
                                    
                                }
                            }
                            self.pageCount = self.pageCount + 1
                            self.bool_Load = false
                            self.tblView.reloadData()
                        }
                        else{
                            self.bool_Load = true
                        }
                    }
                }
                else{
                    showAlertMessage(strMessage: str.invalidRequestParamater)
                }
            }
            else{
                showAlertMessage(strMessage: str.invalidRequestParamater)
            }
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
        let objData = arrPopulerTrackList[selectIndexRow]

        if strRequest == "searchYoutubID"{
            if arrData.count != 0{
                for i in 0..<arrData.count{
                    let dicData = arrData[i] as? NSDictionary
                    let strCurrentYoutubID = dicData?.getStringForID(key: "id")

                    if strCurrentYoutubID != ""{
                        callOtherDetails(obj: objData, strCurrentYoutubID: strCurrentYoutubID ?? "")
                        break
                    }
                }
            }
            else{
                let MenuID = arrLoading.map{$0}
                if let index = MenuID.firstIndex(of: objData.id ?? 0) {
                    arrLoading.remove(at: index)
                }
            }
        }
    }

    
    func callOtherDetails(obj : RadioModel ,strCurrentYoutubID : String){
        //SET DATA
        var objData = obj
        objData.youtubID = strCurrentYoutubID
       

        //GET URL
        GlobalConstants.appDelegate?.extractInfo(url: URL(string: "\(Url.youtubeURL.absoluteString!)\(strCurrentYoutubID)")!, objData: objData)
    }
    
    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        self.stopAnimatingView()
        self.objRefresh?.endRefreshing()

        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
