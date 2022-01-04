//
//  DownloadViewController.swift
//  victor
//
//  Created by Jigar Khatri on 02/12/21.
//

import UIKit
import GoogleMobileAds
import ObjectMapper

class DownloadViewController: UIViewController{

    
    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    @IBOutlet weak var viewBG: UIView!

    @IBOutlet weak var lblHeader: UILabel!

    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!

    
    var arrDownloadList : [Download] = []
    var arrSearchSongs : [Download] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //SET NODATA
        self.emptyDataView.noDownload()
        self.emptyDataView.isHidden = true

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarPreviousIndexSelect = 2
        
        //SET VIEW
        self.view.backgroundColor = setColour()
  
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
      
        
        //SET FOOTER
        self.tblView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableFooterView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: isAdsShowing ? manageHeight(size: 120) : manageHeight(size: 20))
            self.tblView.tableFooterView = vw_Table
        }

        
        //SET VIEW
        self.setTheFont()
        
        //GET DATA
        self.getDownloadData()
    }
    
    
    func getDownloadData(){
        //GET PROFILE ID
        arrDownloadList = []
        if let objUser = UserDefaults.standard.user{
            let arrData = CoreDBManager.sharedDatabase.getAllData(userID: objUser.id ?? "")
            
            for obj in arrData{
                if obj.isDownload == "true"{
                    arrDownloadList.append(obj)
                }
            }
            
            //RELOAD DATA
            self.emptyDataView.isHidden = false
            self.tblView.isHidden = true
            if arrDownloadList.count != 0{
                self.emptyDataView.isHidden = true
                self.tblView.isHidden = false
            }
            self.tblView.reloadData()
            
            self.setTheView()
        }
    }
    
    func setTheView(){
        tblView.reloadData()
        
        //SET VIEW
        self.viewPlay.backgroundColor = UIColor.standard
        self.viewPlay.dropShadow(bgColour: setTextColour(), radius: 5.0)
        imgColor(imgColor: imgPlay, colorHex: UIColor.primary)
        
        //SET SEARCH VIEW
        self.viewSearch.backgroundColor = .clear
        self.viewSearch.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewSearch.viewBorderCorneRadius(borderColour: .gray)

        self.viewPlay.isHidden = true
        self.lblHeader.text = "\(str.download)"
        if self.arrDownloadList.count != 0{
            self.viewPlay.isHidden = false
            self.lblHeader.text = "\(self.arrDownloadList.count) \(str.download)"
        }
    }
    
    
    func setTheFont(){
        //SET FONT
        lblHeader.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: str.download)
        
        lblPlay.configureLable(textColor: UIColor.primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 12.0, text: str.strPlay)

        
        txtSearch.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: str.songSearchPlaceholder)
        txtSearch.delegate = self
        txtSearch.clearButtonMode = .whileEditing
        txtSearch.text = ""
        
        //SET SEARCH TEXT
        txtSearch.addTarget(self, action: #selector(textFieldDidChangeSearch), for: .editingChanged)
        txtSearch.text = ""
    }
    
    
    // MARK: - UITEXTFIELD
    @objc func textFieldDidChangeSearch() {
        let strSearch = txtSearch.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        
        //GET STORE LIST
        self.arrSearchSongs = []
        self.arrSearchSongs = arrDownloadList.filter { Int((($0.video_name?.lowercased()) as NSString?)?.range(of: strSearch.lowercased()).location ?? 0) != NSNotFound}

        //RELOAD TABLE
        self.tblView.reloadData()
        self.emptyDataView.isHidden = true
        self.viewLine.isHidden = false
        if txtSearch.text != ""{
            if arrSearchSongs.count == 0{
                self.emptyDataView.isHidden = false
                self.viewLine.isHidden = true
            }
        }
    }
}


extension DownloadViewController:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtSearch {
            self.viewSearch.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
}

//.......................... UITABLE VIEW ..........................//


//MARK: -- UITABEL DELEGATE --
extension DownloadViewController : UITableViewDelegate, UITableViewDataSource{

    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        if isAdsShowing{
            if txtSearch.text != ""{
                if self.arrSearchSongs.count > 5{
                    return self.arrSearchSongs.count + 1
                }
                else{
                    return self.arrSearchSongs.count
                }
            }
            else{
                if self.arrDownloadList.count > 5{
                    return self.arrDownloadList.count + 1
                }
                else{
                    return self.arrDownloadList.count
                }
            }
        }
        else{
            if txtSearch.text != ""{
                return self.arrSearchSongs.count
            }
            else{
                return self.arrDownloadList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
        cell.backgroundColor = UIColor.clear
        
        //ADDS
        if isAdsShowing{
            if indexPath.row == 5{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdsCell") as! AdsCell
                cell.backgroundColor = UIColor.clear
                cell.viewAds.backgroundColor = setColour()
                cell.viewAds.adUnitID = Application.gogleBanner
                cell.viewAds.rootViewController = self
                cell.viewAds.load(GADRequest())

                return cell
            }
        }
        
        //SET BUTTON
//        buttonImageColor(btnImage: cell.btnMore, imageName: "icon_remove", colorHex: UIColor.red)

        //GET DATA
        if self.arrDownloadList.count != 0{
            let objData : Download!
            if txtSearch.text != ""{
                if indexPath.row >= 5{
                    objData = self.arrSearchSongs[indexPath.row - 1]
                }
                else{
                    objData = self.arrSearchSongs[indexPath.row]
                }
            }
            else{
                if indexPath.row >= 5{
                    objData = self.arrDownloadList[indexPath.row - 1]
                }
                else{
                    objData = self.arrDownloadList[indexPath.row]
                }
            }
            
            
          
            
            //SET DETAILS
            cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Medium, fontSize: 14.0, text: objData.video_name ?? "")
            cell.lblArtists.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: objData.video_artist_name ?? "")
            
//            //SET BUTTON ACTION
//            cell.btnMore.tag = indexPath.row >= 5 ? indexPath.row - 1 : indexPath.row
//            cell.btnMore.addTarget(self, action: #selector(self.btnMenuClicked(_:)), for: .touchUpInside)

                     
            //CHECK THIS TRACK IS PLAYING
            if isMusicPlayNow{
                if CurrentPlayTrackID == Int(objData.video_id ?? ""){
                    cell.lblName.textColor = UIColor.standard
                    cell.lblArtists.textColor = UIColor.standard
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData : Download!
        if txtSearch.text != ""{
            if indexPath.row >= 5{
                objData = self.arrSearchSongs[indexPath.row - 1]
            }
            else{
                objData = self.arrSearchSongs[indexPath.row]
            }
        }
        else{
            if indexPath.row >= 5{
                objData = self.arrDownloadList[indexPath.row - 1]
            }
            else{
                objData = self.arrDownloadList[indexPath.row]
            }
        }
        

        //SET DATA
        var dicDownloadData : NSDictionary =  NSDictionary()
        dicDownloadData = [
            "id": Int(objData.video_id ?? "") ?? 0,
            "name" : "\(objData.video_name ?? "")",
            "image" : "\(objData.video_img ?? "")",
            "model_type" : "",
            "downloadPlayURL" : "\(objData.download_URL ?? "")",
            "artistsName" : "\(objData.video_artist_name ?? "")",
            "youtubID" : "\(objData.youtubID ?? "")",
            "videoImage" : "\(objData.video_img ?? "")"
        ]
        
        //ADD MUSIC
        var dicNewData : RadioModel!
        dicNewData = Mapper<RadioModel>().map(JSONString: DicToStr(arrayResponse: dicDownloadData))
        arrMusicPlayList = []
        arrMusicPlayList.append(dicNewData)
        self.openMusicBar(isPlayMusic: true)
    }
    
    func openMusicBar(isPlayMusic : Bool){
        isMusicPlayNow = isPlayMusic
        
        guard let controller  = self.tabBarController as? TabbarViewController else {
            return
        }
        controller.setTheTabBarView()
        controller.playMusic()
        if controller._isOpen == false || arrMusicPlayList.count == 0 || arrMusicPlayList.count == 1{
            controller.selectMusicBar()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let alert = UIAlertController(title: Application.appName, message: str.removeDownload, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
                
                //DELETE VALUDE
                let obj : Download!
                if self.txtSearch.text != ""{
                    obj = self.arrSearchSongs[indexPath.row]
                }
                else{
                    obj = self.arrDownloadList[indexPath.row]
                }
                
                if let objUser = UserDefaults.standard.user{
                    CoreDBManager.sharedDatabase.deleteDownloadVideo(userID: objUser.id ?? "", videoID: obj.video_id ?? "") { isDone in

                        if obj.download_URL != ""{
                            let strDownloadURL : NSString = ((GlobalConstants.appDelegate?.myDownloadPath ?? "") as NSString).appendingPathComponent(obj.download_URL ?? "") as NSString
                            try? FileManager.default.removeItem(atPath: "\(strDownloadURL)")
                        }
                        
                        NotificationCenter.default.post(name: .removeLoading, object: nil, userInfo: nil)
                        
                        //GET DATA
                        self.getDownloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
            self.present(alert, animated: true)

        }
    }
    
//    @objc func btnMenuClicked(_ sender: UIButton) {
//        let alert = UIAlertController(title: Application.appName, message: str.removeDownload, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
//
//            //DELETE VALUDE
//            let obj = self.arrDownloadList[sender.tag]
//            if let objUser = UserDefaults.standard.user{
//                CoreDBManager.sharedDatabase.deleteDownloadVideo(userID: objUser.id ?? "", videoID: obj.video_id ?? "") { isDone in
//
//                    if obj.download_URL != ""{
//                        let strDownloadURL : NSString = ((GlobalConstants.appDelegate?.myDownloadPath ?? "") as NSString).appendingPathComponent(obj.download_URL ?? "") as NSString
//                        try? FileManager.default.removeItem(atPath: "\(strDownloadURL)")
//                    }
//
//                    NotificationCenter.default.post(name: .removeLoading, object: nil, userInfo: nil)
//
//                    //GET DATA
//                    self.getDownloadData()
//                }
//            }
//        }))
//        alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
//        self.present(alert, animated: true)
//
//    }
   
    
//    func getSaveFileUrl(fileName: String) -> URL {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let nameUrl = URL(string: fileName)
//        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
//        NSLog(fileURL.absoluteString)
//        return fileURL;
//    }
//
//    @objc func btnMenuClicked(_ sender: UIButton) {
//        //GET DATA
//        let objData = self.arrDownloadList[sender.tag]
//
//
//        let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
//        let popVC = storyboard.instantiateViewController(withIdentifier: "MenuPopup") as! MenuPopup
//
//        popVC.strAlbumName = "\(objData.video_name ?? "")"
//        popVC.strArticstName = "\(objData.video_artist_name ?? "")"
//        popVC.strAlbumImage = "\(objData.video_img ?? "")"
//        popVC.indexRecommended = sender.tag
//        popVC.strTYPE = "Track"
//        popVC.strTrackId = Int(objData.video_id ?? "") ?? 0
//
//
//        popVC.modalPresentationStyle = .popover
//        popVC.delegate = self
//
//        let popOverVC = popVC.popoverPresentationController
//        popOverVC?.delegate = self
//        popOverVC?.backgroundColor = UIColor.white
//        popOverVC?.sourceView = sender
//        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
//        popVC.preferredContentSize = CGSize(width: manageWidth(size: 250.0), height: (manageWidth(size: 400.0)))
//
//        popVC.modalTransitionStyle = .crossDissolve
//        self.present(popVC, animated: true)
//
//    }
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.none
//    }
//
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.none
//    }
    
    
//    //DELEGATE METHOD
//    func SelctMenuIndex(strSelectIndex: String, popUpSection: Int, popUpIndex: Int, strType: String) {
//        if strSelectIndex == str.strProfile{
//
//            //MOVE ALBUME LIST SCREEN
//            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
//            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeListViewController") as? AlbumeListViewController{
//                newViewController.isTrack = true
//                newViewController.strArtistsID = Int(self.arrDownloadList[popUpIndex].video_id ?? "") ?? 0
//                self.navigationController?.pushViewController(newViewController, animated: true)
//            }
//        }
//        else if strSelectIndex == str.strTrackRadio{
//            //GO TO TRACK RADIO
//            //MOVE RADIO SCREEN
//            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
//            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
//                newViewController.isRadioTrack = "Track"
//                newViewController.strRadioID = Int(self.arrDownloadList[popUpIndex].video_id ?? "") ?? 0
//                self.navigationController?.pushViewController(newViewController, animated: true)
//            }
//        }
//        else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
//            //ADD OR REMOVE TRACK IN PLAYLIST
//            if strType == "Track"{
//                let objData = self.arrDownloadList[popUpIndex]
//                let strID = Int(objData.video_id ?? "") ?? 0
//
//                //CHECK
//                if strSelectIndex == str.strAddQueue{
//                    //ADD IN QUEUS
//                    let MenuID = arrMusicPlayList.map{$0.id}
//                    if MenuID.firstIndex(of: strID) == nil{
//                        arrMusicPlayList.append(objData)
//                    }
//                }
//                else{
//                    //REMOVE IN QUEUS
//                    let MenuID = arrMusicPlayList.map{$0.id}
//                    if let index = MenuID.firstIndex(of: strID ) {
//                        if isMusicPlayNow{
//                            if CurrentPlayTrackID == strID{
//                                CurrentPlayTrackID = 0
//                                playerVideo = nil
//                                self.tblView.reloadData()
//                            }
//                        }
//                        arrMusicPlayList.remove(at: index)
//                    }
//                }
//
//                //SET TABBAR
//                if arrMusicPlayList.count <= indexPlayMusic{
//                    if indexPlayMusic != 0{
//                        indexPlayMusic = arrMusicPlayList.count - 1
//                    }
//                }
//                self.openMusicBar(isPlayMusic: false)
//            }
//        }
//    }
    
}


