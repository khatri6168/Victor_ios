//
//  MenuPopup.swift
//  Belboy
//
//  Created by Apple on 16/05/19.
//  Copyright © 2019 iCoderzSolutions. All rights reserved.
//

import UIKit
import Nuke
import ObjectMapper

protocol MenuProtocol : AnyObject {
    func SelctMenuIndex(strSelectIndex : String, popUpSection : Int, popUpIndex : Int, strType : String)
}


class MenuPopup: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    
    var arrList : [String] = [str.strTrackRadio, str.strAddQueue, str.strAddPlaylist, str.strSaveMusic, str.strLyrics, str.strCopyTrack, str.strShare]
    weak var delegate : MenuProtocol? = nil
    var indexRecommended : Int = 0
    var sectionRecommended : Int = 0
    
    var strAlbumImage : String = ""
    var strAlbumName : String = ""
    var strArticstName : String = ""
    var strTYPE : String = ""
    
    //GET IDS
    var strArtistsId : Int = 0
    var strAlbumeId : Int = 0
    var strTrackId : Int = 0
    
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var lblArtistsName: UILabel!
    @IBOutlet var imgAlbum: UIImageView!
    
    @IBOutlet var imgBack: UIImageView!
    @IBOutlet var lblBack: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet weak var con_ViewHeight: NSLayoutConstraint!
    
    var isPlayList : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = setColour()
        
        //SET VIEW
        self.setTheFont()
        self.setPlayList()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if strTYPE == "Header"{
            let MenuID = arrSaveArtists.map{$0.id}
            if MenuID.firstIndex(of: strArtistsId) != nil {
                arrList = [str.strUnfollow, str.strTrackRadio, str.strCopyTrack, str.strShare]
            }
            else{
                arrList = [str.strFollow, str.strTrackRadio, str.strCopyTrack, str.strShare]
            }
            
        }
        else if strTYPE == "Albume"{
            let MenuID = arrSaveAlbume.map{$0.id}
            if MenuID.firstIndex(of: strAlbumeId) != nil {
//                arrList = [str.strAddQueue,  str.strAddPlaylist, str.strRemoveMusic, str.strCopyTrack, str.strShare]
                arrList = [str.strAddQueue, str.strRemoveMusic, str.strCopyTrack, str.strShare]
            }
            else{
//                arrList = [str.strAddQueue,  str.strAddPlaylist, str.strSaveMusic, str.strCopyTrack, str.strShare]

                arrList = [str.strAddQueue, str.strSaveMusic, str.strCopyTrack, str.strShare]
            }
            
        }
        else{
            //CHECK TRACK SAVE OR NOT
            let MenuID = arrSaveTrack.map{$0.id}
            if MenuID.firstIndex(of: strTrackId) != nil {
//                arrList = [str.strTrackRadio, str.strAddQueue, str.strAddPlaylist, str.strRemoveMusic, str.strLyrics, str.strCopyTrack, str.strShare]
                arrList = [str.strTrackRadio, str.strAddQueue, str.strRemoveMusic, str.strLyrics, str.strCopyTrack, str.strShare]
            }
            else{
//                arrList = [str.strTrackRadio, str.strAddQueue, str.strAddPlaylist, str.strSaveMusic, str.strLyrics, str.strCopyTrack, str.strShare]
                arrList = [str.strTrackRadio, str.strAddQueue, str.strSaveMusic, str.strLyrics, str.strCopyTrack, str.strShare]
            }
            
            //CHECK TRACK ADD IN PLAYLIST
            let MenuTrackID = arrMusicPlayList.map{$0.id}
            if MenuTrackID.firstIndex(of: strTrackId) != nil {
                
                let MenuID = arrList.map{$0}
                if let index = MenuID.firstIndex(of: str.strAddQueue)  {
                    self.arrList.remove(at: index)
                    self.arrList.insert(str.strRemoveQueue, at: index)
                }
            }
        }
        
        self.tblView.reloadData()
    }
    
    
    func setTheFont(){
        
        //SET FONT
        lblAlbumName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: strAlbumName)
        lblArtistsName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: strArticstName)
        lblBack.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.Back)
        
        //SET IMAGE
        imgAlbum.backgroundColor = UIColor.grayLight
        imgAlbum.viewCorneRadius(radius: 5.0, isRound: false)
        if self.strAlbumImage != ""{
            let imgURL =  ("\(self.strAlbumImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgAlbum)
            }
        }
        
    }
    
    func setPlayList(){
        imgColor(imgColor: imgBack, colorHex: setTextColour())
        self.con_ViewHeight.constant = 0
        self.imgBack.isHidden = true
        self.lblBack.isHidden = true
        self.viewLine.isHidden = true
        if isPlayList{
            self.imgBack.isHidden = false
            self.lblBack.isHidden = false
            self.viewLine.isHidden = false
            self.con_ViewHeight.constant = manageWidth(size: 40)
        }
    }
}



//MARK: - BUTTON ACTION
extension MenuPopup {
    @IBAction func btnProfileSClicked(_ sender: UIButton) {
        delegate?.SelctMenuIndex(strSelectIndex: str.strProfile, popUpSection: sectionRecommended, popUpIndex: indexRecommended, strType: strTYPE)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnBackPlaylistClicked(_ sender: UIButton) {
        self.isPlayList = false
        self.setPlayList()
        self.tblView.reloadData()
    }
}




class AddNewPlayListCell: UITableViewCell{
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgPlaylist: UIImageView!
    @IBOutlet weak var con_imgSpace: NSLayoutConstraint!
}

class MenuList: UITableViewCell{
    @IBOutlet var lblName: UILabel!
}

extension MenuPopup: UITableViewDelegate,UITableViewDataSource, AddPlayListPROTOCOL{
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPlayList{
            return arrSavePlay_List.count + 1
        }
        else{
            return arrList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if isPlayList{
            if indexPath.row == 0{
                
            }
            let cell = tableView.dequeueReusableCell(withIdentifier:"AddNewPlayListCell", for: indexPath) as! AddNewPlayListCell
            
            //SET FONT
            if indexPath.row == 0{
                cell.con_imgSpace.constant = 16
                cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strPlaylistTitle)
                
                //SET IMAGE
                cell.imgPlaylist.image = UIImage(named: "icon_addPlayList")
                imgColor(imgColor: cell.imgPlaylist, colorHex: UIColor.standard)
            }
            else{
                cell.con_imgSpace.constant = 22
                cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: arrSavePlay_List[indexPath.row - 1].name ?? "")
                
                //SET IMAGE
                cell.imgPlaylist.image = UIImage(named: "icon_songs")
                imgColor(imgColor: cell.imgPlaylist, colorHex: setTextColour())
                
            }
            
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier:"MenuList", for: indexPath) as! MenuList
            
            //SET FONT
            cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: self.arrList[indexPath.row])
            
            return cell
        }
        
        
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isPlayList{
            if indexPath.row == 0{
                let window = UIApplication.shared.keyWindow!
                window.endEditing(true)
                let cartView = AddPlayList(frame: CGRect(x: 0, y: 0 ,width : window.frame.width, height: window.frame.height))
                cartView.delegate = self
                cartView.loadPopUpView(selectValue: "")
                window.addSubview(cartView)
            }
        }
        else{
            if self.arrList[indexPath.row] == str.strAddPlaylist{
                self.isPlayList = true
                self.setPlayList()
                self.tblView.reloadData()
            }
            else{
                delegate?.SelctMenuIndex(strSelectIndex: self.arrList[indexPath.row], popUpSection: sectionRecommended, popUpIndex: indexRecommended, strType: strTYPE)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func addPlayerSuccess() {
        
    }
}





//REGISTER SCREEN ..........................
extension MenuPopup :WebServiceHelperDelegate{
    func getSavePlaylistAPI(strUserId : String){
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
        webHelper.indicatorShowOrHide = true
        webHelper.callAPI()
    }
    
    
    
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        indicatorHide()

        
        if strRequest == "savePlaylist"{
            //GET PLAYLIST
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSavePlay_List = []
                    arrSavePlay_List = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                    self.tblView.reloadData()                    
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

