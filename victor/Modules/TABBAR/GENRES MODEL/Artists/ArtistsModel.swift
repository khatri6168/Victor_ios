//
//  ArtistsModel.swift
//  victor
//
//  Created by Jigar Khatri on 10/11/21.
//

import Foundation
import ObjectMapper

//REGISTER SCREEN ..........................
extension ArtistsViewController :WebServiceHelperDelegate{

    func ArtistsAPI(GenresParameater:GenresParameater){
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
        let strURL = "\(Url.genreList.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "artistsList"
        webHelper.methodType = "get"
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
        indicatorHide()
        self.stopAnimatingView()
        self.objRefresh?.endRefreshing()
        self.isLoading = false
        storeLoading()

        print(data)
        if strRequest == "artistsList"{
            if let objChannel = data["channel"] as? NSDictionary{
                if let objContent = objChannel["content"] as? NSDictionary{
                    if let arrData = objContent["data"] as? NSArray{
                        let arr = Mapper<GenresModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                        if pageCount == 1{
                            self.arrArtistsList = []
                        }
                        self.tblView.isHidden = false

                        if arr.count != 0{
                           for obj in arr{
                                self.arrArtistsList.append(obj)
                            }
                            self.pageCount = self.pageCount + 1
                            self.bool_Load = false
                            self.tblView.reloadData()
                        }
                        else{
                            
                            self.emptyDataView.isHidden = true
                            if arrArtistsList.count == 0{
                                self.tblView.isHidden = true
                                self.emptyDataView.isHidden = false
                            }
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
    func appDataArraySuccess(_ arr: NSArray, request strRequest: String) {
    }
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        self.stopAnimatingView()
        self.objRefresh?.endRefreshing()

        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
