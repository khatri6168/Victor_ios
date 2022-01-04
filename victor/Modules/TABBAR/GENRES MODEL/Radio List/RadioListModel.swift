//
//  RadioListModel.swift
//  victor
//
//  Created by Jigar Khatri on 11/11/21.
//

import Foundation
import ObjectMapper


struct RadioModel: Mappable{
    internal var id: Int?
    internal var name: String?
    internal var image: String?
    internal var model_type: String?
    internal var arrArtists : [ArtistsModel] = []
    internal var objAlbum : AlbumModel!
    internal var downloadPlayURL : String = ""
    internal var artistsName: String = ""
    internal var youtubID  : String = ""
    internal var videoImage : String = ""
    internal var videoPlayURL : String = ""

    internal var isAds : Bool = false

    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
        model_type <- map["model_type"]
        arrArtists <- map["artists"]
        objAlbum <- map["album"]
        downloadPlayURL <- map["downloadPlayURL"]
        artistsName <- map["artistsName"]
        youtubID <- map["youtubID"]
        videoImage <- map["videoImage"]
    }
}

struct AlbumModel: Mappable{
    internal var id: Int?
    internal var name: String?
    internal var image: String?
    internal var model_type: String?
    internal var plays: String?
    internal var arrArtists : [ArtistsModel] = []
    internal var arrTracks : [RadioModel] = []
    internal var release_date : String?
    
    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
        model_type <- map["model_type"]
        plays <- map["plays"]
        arrArtists <- map["artists"]
        arrTracks <- map["tracks"]
        release_date <- map["release_date"]
    }
}

struct ArtistsModel: Mappable{
    internal var id: Int?
    internal var name: String?
    internal var image_small: String?
    internal var model_type: String?

    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        id <- map["id"]
        name <- map["name"]
        image_small <- map["image_small"]
        model_type <- map["model_type"]
    }
}

//REGISTER SCREEN ..........................
extension RadioListViewController :WebServiceHelperDelegate{


    func RadioListAPI(strID : String){
        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.tblView)
            }
        }
        
        //Declaration URL
        var strURL = "\(Url.radioList.absoluteString!)\(strID)"
        if isRadioTrack == "Artist"{
            strURL = "\(Url.radioArtistList.absoluteString!)\(strID)"
        }
        else if isRadioTrack == "Track"{
            strURL = "\(Url.radioTrackList.absoluteString!)\(strID)"
        }
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "radioList"
        webHelper.methodType = "get"
        webHelper.strURL = strURL
        webHelper.dictType = [:]
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
        
        print(data)
        if strRequest == "radioList"{
            if let objAlbumData = data["seed"] as? NSDictionary{
                
                if isRadioTrack == "Track"{
                    if let objAlbum = objAlbumData["album"] as? NSDictionary{
                        self.strAlbumName = objAlbum.getStringForID(key: "name")
                        self.strAlbumTitle = objAlbum.getStringForID(key: "model_type")
                        self.strAlbumImage = objAlbum.getStringForID(key: "image")
                        if self.strAlbumImage == ""{
                            self.strAlbumImage = objAlbum.getStringForID(key: "image_small")
                        }
                    }
                }
                else{
                    self.strAlbumName = objAlbumData.getStringForID(key: "name")
                    self.strAlbumTitle = objAlbumData.getStringForID(key: "model_type")
                    self.strAlbumImage = objAlbumData.getStringForID(key: "image")
                    if self.strAlbumImage == ""{
                        self.strAlbumImage = objAlbumData.getStringForID(key: "image_small")
                    }
                    
                }
              
                //SET DETAILS
                setTheDetails()
            }
            
            //GET TRACK
            if let arrTrack = data["recommendations"] as? NSArray{
                let arr = Mapper<RadioModel>().mapArray(JSONArray: arrTrack as! [[String : Any]])
                self.emptyDataView.isHidden = true
                self.tblView.isHidden = false
                self.tblView.isUserInteractionEnabled = true

                if arr.count != 0{
                    self.arrRadioList = []
                    self.arrRadioList = arr
                    
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
       
    }
 
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
        let objData = arrRadioList[selectIndexRow]

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
