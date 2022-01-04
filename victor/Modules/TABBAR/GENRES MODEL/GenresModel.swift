//
//  GenresModel.swift
//  victor
//
//  Created by Jigar Khatri on 09/11/21.
//

import Foundation
import ObjectMapper


struct GenresStaticModel{
    var id: Int?
    var name: String?
    var image: String?
    var image_small: String?
    var model_type: String?
    var plays: String?
}

struct GenresModel: Mappable{
    internal var id: Int?
    internal var name: String?
    internal var image: String?
    internal var image_small: String?
    internal var model_type: String?
    internal var plays: String?

    init?(map:Map) {
        mapping(map: map)
    }

    mutating func mapping(map:Map){
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
        image_small <- map["image_small"]
        model_type <- map["model_type"]
        plays <- map["plays"]
    }
}

struct GenresParameater: Codable {
    var forAdmin: String = ""
    var filter: String
    var page: String
}

//REGISTER SCREEN ..........................
extension GenresViewController :WebServiceHelperDelegate{

    func GenresAPI(GenresParameater:GenresParameater){

        if isLoading{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                startLoading(view: self.view)
            }
        }
        
        guard let parameater = try? GenresParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.genresList.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "genresList"
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

    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()
        self.isLoading = false
        self.stopAnimatingView()
        storeLoading()
        self.objRefresh?.endRefreshing()

        
        if strRequest == "genresList"{
            if let objChannel = data["channel"] as? NSDictionary{
                if let objContent = objChannel["content"] as? NSDictionary{
                    if let arrData = objContent["data"] as? NSArray{
                        let arr = Mapper<GenresModel>().mapArray(JSONArray: arrData as! [[String : Any]])

                        if arr.count != 0{
                            if pageCount == 1{
                                self.arrGenresList = []
                            }
                            
                            for obj in arr{
//                                self.arrGenresList.append(obj)
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
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        self.stopAnimatingView()
        self.objRefresh?.endRefreshing()

        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
