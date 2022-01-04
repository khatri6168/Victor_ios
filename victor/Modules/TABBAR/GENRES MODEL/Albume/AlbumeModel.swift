//
//  AlbumeModel.swift
//  victor
//
//  Created by Jigar Khatri on 12/11/21.
//

import Foundation
import ObjectMapper

struct ArtistsParameater : Codable {
    var autoUpdate: Bool = true
    var defaultRelations: Bool = true
}

struct LikeablesParameater : Codable {
    var likeable_id: String
    var likeable_type: String
}


//REGISTER SCREEN ..........................
extension AlbumeViewController :WebServiceHelperDelegate{
    
    func AlbumeListAPI(ArtistsParameater : ArtistsParameater, strID : String){
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.tblView)
            }
        }
        
        guard let parameater = try? ArtistsParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.artistsList.absoluteString!)\(strID)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "albumeList"
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
        

   
    
    struct ArtistsPageintionParameater: Codable {
        var page: String
    }

    
    func ArtistsAPI(ArtistsPageintionParameater:ArtistsPageintionParameater ,strId : String){

        guard let parameater = try? ArtistsPageintionParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.artistsList.absoluteString!)\(strId)/albums"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "albumeListPagination"
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
        self.isLoading = false
        storeLoading()
        self.tblView.isUserInteractionEnabled = true

        print(data)
        if strRequest == "albumeList"{
            if let objArtistData = data["artist"] as? NSDictionary{
                
                self.strArtistsName = objArtistData.getStringForID(key: "name")
                self.strArtistsImage = objArtistData.getStringForID(key: "image_small")
                
                //SET DETAILS
                setTheDetails()
                
                //GET SIMILAR ARTISTS
                if let arrSimilarArtists = objArtistData["similar"] as? NSArray{
                    self.arrArtistList = []
                    self.arrArtistList = Mapper<ArtistsModel>().mapArray(JSONArray: arrSimilarArtists as! [[String : Any]])
                }
                
                //GET URLS
                if let arrUrl = objArtistData["profile_images"] as? NSArray{
                    self.arrAboutURL = []
                    for i in 0..<arrUrl.count{
                        if let obj = arrUrl[i] as? NSDictionary{
                            self.arrAboutURL.append(obj.getStringForID(key: "url"))
                        }
                    }
                }
                
                //GET ABOUT DETAILS
                if let objProfile = objArtistData["profile"] as? NSDictionary{
                    self.strDescription = objProfile.getStringForID(key: "description")
                }
                
                
                //GET TRACK
                if let arrTrack = objArtistData["top_tracks"] as? NSArray{
                    let arr = Mapper<RadioModel>().mapArray(JSONArray: arrTrack as! [[String : Any]])
                    self.emptyDataView.isHidden = true
                    self.tblView.isHidden = false

                    if arr.count != 0{
                        self.arrTrackList = []
                        self.arrTrackList = arr
                        
                        //RELOAD TABLE
                        self.tblView.reloadData()
                    }
                    else{
                        self.emptyDataView.isHidden = false
                        self.tblView.isHidden = true

                    }
                }
                else{
                    self.emptyDataView.isHidden = false
                    self.tblView.isHidden = true

                }
            }
            
            //GET ALUBUMS
            if let objAlbumData = data["albums"] as? NSDictionary{
                if let arrAlbume = objAlbumData["data"] as? NSArray{
                    self.arrAlbumsList = []
                    self.arrAlbumsList = Mapper<AlbumModel>().mapArray(JSONArray: arrAlbume as! [[String : Any]])

                    //RELOAD TABLE
                    self.pageCount = self.pageCount + 1
                    self.bool_Load = false
                    self.tblView.reloadData()

                }
            }
        }
        else if strRequest == "albumeListPagination"{
            indicatorHide()
            self.stopAnimatingView()

            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    let arr = Mapper<AlbumModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                    if pageCount == 1{
                        self.arrAlbumsList = []
                    }
                    
                    if arr.count != 0{
                       for obj in arr{
                            self.arrAlbumsList.append(obj)
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
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}



//ALBUME LIST SCREEN ..........................
extension AlbumeListViewController :WebServiceHelperDelegate{
    
    func AlbumeListAPI(ArtistsParameater : ArtistsParameater, strID : String){
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.tblView)
            }
        }
        
        guard let parameater = try? ArtistsParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        var strURL = "\(Url.albumeList.absoluteString!)\(strID)"
        if isTrack{
            strURL = "\(Url.trackList.absoluteString!)\(strID)"
        }
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "albumeList"
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
        self.isLoading = false
        storeLoading()
        self.tblView.isUserInteractionEnabled = true

        print(data)
        if strRequest == "albumeList"{
            if isTrack{
                if let objTrackData = data["track"] as? NSDictionary{

                    self.strAlbumesName = objTrackData.getStringForID(key: "name")
                    self.strPlayers = objTrackData.getStringForID(key: "plays")

                    if let objAlbumData = objTrackData["album"] as? NSDictionary{
                        self.strAlbumeImage = objAlbumData.getStringForID(key: "image")
                        self.strDate = objAlbumData.getStringForID(key: "release_date")
                        
                        //GET ARITIST DETAILS
                        if let arrArtistst = objAlbumData["artists"] as? NSArray{
                            if arrArtistst.count != 0{
                                let objData = arrArtistst[0] as! NSDictionary
                                self.strArtistsName = objData.getStringForID(key: "name")
                                self.strArtistsImage = objData.getStringForID(key: "image_small")
                                self.getSrtistsID = objData.getStringForID(key: "id")
                            }
                        }
                        
                        //GET TRACK
                        if let arrTrack = objAlbumData["tracks"] as? NSArray{
                            let arr = Mapper<RadioModel>().mapArray(JSONArray: arrTrack as! [[String : Any]])
                            self.emptyDataView.isHidden = true
                            self.tblView.isHidden = false

                            if arr.count != 0{
                                self.arrTrackList = []
                                self.arrTrackList = arr
                                
                                //RELOAD TABLE
                                self.tblView.reloadData()
                            }
                            else{
                                self.emptyDataView.isHidden = false
                                self.tblView.isHidden = true

                            }
                        }
                        else{
                            self.emptyDataView.isHidden = false
                            self.tblView.isHidden = true

                        }
                        
                        //SET DETAILS
                        setTheDetails()
                    }
                    else{
                        self.emptyDataView.isHidden = false
                        self.tblView.isHidden = true

                    }
                }
            }
            else{
                if let objAlbumData = data["album"] as? NSDictionary{

                    self.strAlbumesName = objAlbumData.getStringForID(key: "name")
                    self.strAlbumeImage = objAlbumData.getStringForID(key: "image")
                    self.strPlayers = objAlbumData.getStringForID(key: "plays")
                    self.strDate = objAlbumData.getStringForID(key: "release_date")

                    //GET ARITIST DETAILS
                    if let arrArtistst = objAlbumData["artists"] as? NSArray{
                        if arrArtistst.count != 0{
                            let objData = arrArtistst[0] as! NSDictionary
                            self.strArtistsName = objData.getStringForID(key: "name")
                            self.strArtistsImage = objData.getStringForID(key: "image_small")
                            self.getSrtistsID = objData.getStringForID(key: "id")
                        }
                    }
                    
                    //GET TRACK
                    if let arrTrack = objAlbumData["tracks"] as? NSArray{
                        let arr = Mapper<RadioModel>().mapArray(JSONArray: arrTrack as! [[String : Any]])
                        self.emptyDataView.isHidden = true
                        self.tblView.isHidden = false

                        if arr.count != 0{
                            self.arrTrackList = []
                            self.arrTrackList = arr
                            
                            //RELOAD TABLE
                            self.tblView.reloadData()
                        }
                        else{
                            self.emptyDataView.isHidden = false
                            self.tblView.isHidden = true

                        }
                    }
                    else{
                        self.emptyDataView.isHidden = false
                        self.tblView.isHidden = true

                    }
                    
                    //SET DETAILS
                    setTheDetails()
                }
            }
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
        let objData = arrTrackList[selectIndexRow]

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
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
