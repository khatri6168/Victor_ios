//
//  SearchModel.swift
//  victor
//
//  Created by Jigar Khatri on 26/11/21.
//

import Foundation
import ObjectMapper

//REGISTER SCREEN ..........................
extension SearchViewController :WebServiceHelperDelegate{
    struct SearchParameater: Codable {
        var query: String
        var types: String = "artist,album,track"
        var limit: String = "20"
    }

    func SearchListAPI(SearchParameater:SearchParameater){
        self.objLoading.isHidden = false
        self.objLoading.startAnimating()
        
        guard let parameater = try? SearchParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
 
        //Declaration URL
        let strURL = "\(Url.searchList.absoluteString!)"
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "searchList"
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

   

    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()
        self.objLoading.isHidden = true
        self.objLoading.stopAnimating()

        print(data)
        if strRequest == "searchList"{
            if let objResults = data["results"] as? NSDictionary{
                if let arrData = objResults["tracks"] as? NSArray{
                    //GET TRACK
                    self.arrTrackList = []
                    arrTrackList = Mapper<RadioModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }

                //GET ARTISTS
                if let arrArtists = objResults["artists"] as? NSArray{
                    self.arrArtistList = []
                    self.arrArtistList = Mapper<ArtistsModel>().mapArray(JSONArray: arrArtists as! [[String : Any]])
                }

                //GET ALBUME
                if let arrArtists = objResults["albums"] as? NSArray{
                    self.arrAlbume = []
                    self.arrAlbume = Mapper<AlbumModel>().mapArray(JSONArray: arrArtists as! [[String : Any]])
                }
                
                //SET VIEW
                self.setSearchView()
            }
            else{
                showAlertMessage(strMessage: str.invalidRequestParamater)
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
