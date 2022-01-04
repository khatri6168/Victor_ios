//
//  AlbumeListViewController.swift
//  victor
//
//  Created by Jigar Khatri on 17/11/21.
//

import UIKit
import Nuke
import GoogleMobileAds

class AlbumeListViewController: UIViewController, UIGestureRecognizerDelegate, GADFullScreenContentDelegate, GetMorePROTOCOL{
    
    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var objStckView: UIStackView!
    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    
    //LABLE
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!

    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var lblMore: UILabel!
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var btnMore: UIButton!

    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var imgPlayer: UIImageView!

    @IBOutlet weak var lblArtists: UILabel!
    @IBOutlet weak var imgArtists: UIImageView!

    @IBOutlet weak var lblDetails: UILabel!

    //OTHER
    var strArtistsID : Int = 0
    var isShowAllTrack : Bool = false
    var isSelectList : Bool = true

    var strAlbumeImage : String = ""
    var strAlbumesName : String = ""
    var strPlayers : String = ""

    var strArtistsImage : String = ""
    var strArtistsName : String = ""
    var strDate : String = ""
    var getSrtistsID : String = ""
    
    var arrTrackList : [RadioModel] = []

    var arrMenu: [String] = [str.strDiscography, str.strSimilarArtists, str.strAbout]
    var SelectTag : String = str.strDiscography
    var arrSection: [String] = [str.strPopularSongs, str.strAlbums]

    //LOADING
    var _loadingView: UIActivityIndicatorView!
    var bool_Load: Bool = false
    var pageCount : Int = 1
    var isLoading : Bool = true

    var isTrack : Bool = false
    
    //ADS
    var rewardedAd: GADRewardedAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)

        // Do any additional setup after loading the view.
        
        self.setTheView()
        
        //SET NODATA
        self.emptyDataView.noArtists()
        self.emptyDataView.isHidden = true

        //GET DATA
        if let objUser = UserDefaults.standard.user{
            GlobalConstants.appDelegate?.SaveArtistListAPI()
            GlobalConstants.appDelegate?.SavePlaylistAPI(strUserId: objUser.id ?? "")
            GlobalConstants.appDelegate?.SaveTrackListAPI()
            GlobalConstants.appDelegate?.SaveAlbumeListAPI()
        }
        self.AlbumeListAPI(ArtistsParameater: ArtistsParameater(), strID: "\(strArtistsID)")
        
        
        //SET REWARED
        GADRewardedAd.load(withAdUnitID: Application.gogleRewarded, request: GADRequest()) { ad, error in
            if let error = error {
              print("Rewarded ad failed to load with error: \(error.localizedDescription)")
              return
            }
            print("Loading Succeeded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //SET VIEW
        self.view.backgroundColor = setColour()
 
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        
        //SET NAVIGATION BAR
        setNavigationBarFor(controller: self, title: "", isTransperent: true, hideShadowImage: false, leftIcon: "icon_back", rightIcon: "icon_search") { SelectTag in
            self.navigationController?.popViewController(animated: true)
        } rightActionHandler: {SelectTag in
            //SEARCH
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.SEARCH_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        
        //SET FOOTER
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableFooterView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: isAdsShowing ? manageHeight(size: 120) : manageHeight(size: 20))
            self.tblView.tableFooterView = vw_Table
        }
     }
    
    @objc private func updatePlayer(){
        self.tblView.reloadData()
    }
    
    func setTheView(){
        
        //SET VIEW
        self.viewPlay.backgroundColor = UIColor.standard
        self.viewPlay.dropShadow(bgColour: UIColor.red, radius: self.viewPlay.frame.size.height / 2)
        self.btnPlay.btnCorneRadius(radius: 0, isRound: true)

        //SET MORE VIEW
        self.viewMore.backgroundColor = .clear
        self.viewMore.viewCorneRadius(radius: 0, isRound: true)
        self.viewMore.viewBorderCorneRadiusLight(borderColour: UIColor.grayLight)
        self.btnMore.btnCorneRadius(radius: 0, isRound: true)

        //SET PLAYER VIEW
        self.viewPlayer.backgroundColor = UIColor.clear
                
        //SET FONT
        lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: "Loading..")
        lblArtists.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: "Loading..")
        lblDetails.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "Loading..")

        lblPlay.configureLable(textColor: UIColor.primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strPlay)
        imgColor(imgColor: imgPlay, colorHex: UIColor.primary)

        lblMore.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strMore)
        imgColor(imgColor: imgMore, colorHex: setTextColour())
   
        lblPlayer.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: "Loading..")
        imgColor(imgColor: imgPlayer, colorHex: setTextColour())

        //SET HEADER
        self.tblView.isHidden = false
        self.tblView.isUserInteractionEnabled = false
        imgArtists.viewCorneRadius(radius: 0, isRound: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.objStckView.frame.origin.y + self.objStckView.frame.size.height)
            self.tblView.tableHeaderView = vw_Table
        }

    }
    
    func setTheDetails(){
        self.lblName.text = strAlbumesName.capitalizingFirstLetter()
        self.lblPlayer.text = strPlayers
        
    
        
        //SET IMAGE
        imgAlbum.backgroundColor = UIColor.grayLight
        imgAlbum.viewCorneRadius(radius: 5, isRound: false)
        if self.strAlbumeImage != ""{
            let imgURL =  ("\(self.strAlbumeImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgAlbum)
            }
        }
        
        
        //SET ARTISTS DETAILS
        self.lblArtists.text = strArtistsName.capitalizingFirstLetter()
        imgArtists.backgroundColor = UIColor.grayLight
        imgArtists.viewCorneRadius(radius: 0, isRound: true)
        if self.strArtistsImage != ""{
            let imgURL =  ("\(self.strArtistsImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgArtists)
            }
        }
        
        self.lblDetails.text = "\(self.arrTrackList.count) tracks • 42:27 mins • \(strDate)"
        //SET HEADER
        self.tblView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.objStckView.frame.origin.y + self.objStckView.frame.size.height + 50)
            self.tblView.tableHeaderView = vw_Table
        }
    }
}


//MARK: - BUTTON ACTION
extension AlbumeListViewController {
    @IBAction func btnPlayClicked(_ sender: UIButton) {
        playerVideo = nil
        playerVideo?.pause()
        indexPlayMusic = 0
        CurrentPlayTrackID = 0
        self.tblView.reloadData()
        
        //ADD DATA
        arrMusicPlayList = []
        arrMusicPlayList = self.arrTrackList
        
        openMusicBar(isPlayMusic: true)
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
    
    @IBAction func btnArtisteClicked(_ sender: UIButton) {
        //MOVE ARTISTS SCREEN
        let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeViewController") as? AlbumeViewController{
            newViewController.strArtistsID = Int(getSrtistsID ) ?? 0
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    @IBAction func btnMoreClicked(_ sender: UIButton) {
        //GET DATA

        let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "MenuPopup") as! MenuPopup

        popVC.strAlbumName = strAlbumesName
//        popVC.strArticstName = strArtist
        popVC.strAlbumImage = strAlbumeImage
//        popVC.indexRecommended = sender.tag
        popVC.strTYPE = "Albume"
        popVC.strAlbumeId = strArtistsID
        popVC.modalPresentationStyle = .popover
        popVC.delegate = self

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.backgroundColor = UIColor.white
        popOverVC?.sourceView = sender
        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: manageWidth(size: 250.0), height: (manageWidth(size: 350.0)))

        popVC.modalTransitionStyle = .crossDissolve
        self.present(popVC, animated: true)

    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }


    //DELEGATE METHOD
    func SelctMenuIndex(strSelectIndex: String, popUpSection: Int, popUpIndex: Int, strType: String) {
        if strSelectIndex == str.strProfile{
            
            //MOVE ALBUME LIST SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeListViewController") as? AlbumeListViewController{
                newViewController.isTrack = true
                newViewController.strArtistsID = self.arrTrackList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strTrackRadio{
            
            //MOVE RADIO SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                if strType == "Header"{
                    newViewController.strRadioID = strArtistsID
                    newViewController.isRadioTrack = "Artist"
                }
                else{
                    newViewController.strRadioID = self.arrTrackList[popUpIndex].id ?? 0
                    newViewController.isRadioTrack = "Track"
                }
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
            //ADD OR REMOVE TRACK IN PLAYLIST
            if strType == "Track"{
                let objData = self.arrTrackList[popUpIndex]
                let strID = objData.id ?? 0
                
                //CHECK
                if strSelectIndex == str.strAddQueue{
                    //ADD IN QUEUS
                    let MenuID = arrMusicPlayList.map{$0.id}
                    if MenuID.firstIndex(of: strID) == nil{
                        arrMusicPlayList.append(objData)
                    }
                }
                else{
                    //REMOVE IN QUEUS
                    let MenuID = arrMusicPlayList.map{$0.id}
                    if let index = MenuID.firstIndex(of: strID ) {
                        if isMusicPlayNow{
                            if CurrentPlayTrackID == strID{
                                CurrentPlayTrackID = 0
                                playerVideo = nil
                                self.tblView.reloadData()
                            }
                        }
                        arrMusicPlayList.remove(at: index)
                    }
                }
                
                //SET TABBAR
                if arrMusicPlayList.count <= indexPlayMusic{
                    if indexPlayMusic != 0{
                        indexPlayMusic = arrMusicPlayList.count - 1
                    }
                }
                self.openMusicBar(isPlayMusic: false)
            }
            
            
            else if strType == "Albume"{
                for objTrack in self.arrTrackList{
                    //ADD IN QUEUS
                    let MenuID = arrMusicPlayList.map{$0.id}
                    if MenuID.firstIndex(of: objTrack.id) == nil{
                        arrMusicPlayList.append(objTrack)
                    }
                }
                //SET TABBAR
                if arrMusicPlayList.count - 1 < indexPlayMusic{
                    indexPlayMusic = arrMusicPlayList.count - 1
                }
                self.openMusicBar(isPlayMusic: false)
            }
        }
    }
}


//.......................... UITABLE VIEW ..........................//

//MARK: -- UITABEL CELL --


//MARK: -- UITABEL DELEGATE --

extension AlbumeListViewController : UITableViewDelegate, UITableViewDataSource ,MenuProtocol, UIPopoverPresentationControllerDelegate{
 
    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 10
        }
        return self.arrTrackList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func trackListingCell (cell : RadioCell ,index: Int){
        //SET BUTTON
        buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())

        //GET DATA
//        let objData = self.arrTrackList[index]
        let objData : RadioModel!
        if index >= 5{
            objData = self.arrTrackList[index - 1]
        }
        else{
            objData = self.arrTrackList[index]
        }
        
        //SET DETAILS
        cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Medium, fontSize: 14.0, text: objData.name ?? "")


        //GET ARTIST NAME
        var strArtist : String = ""
        for obj in objData.arrArtists{
            if strArtist == ""{
                strArtist = obj.name ?? ""
            }
            else{
                strArtist = "\(strArtist), \(obj.name ?? "")"
            }
        }

        cell.lblArtists.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: strArtist)

        //SET BUTTON ACTION
        cell.btnMore.tag = index
        cell.btnMore.addTarget(self, action: #selector(self.btnTrackMenuClicked(_:)), for: .touchUpInside)
        
        //SET DOWNALOD VIEW
        setTheProgressView(DownloadProgressBar: cell.DownloadProgressBar)
        checkDownlaodCell(cell: cell, videoID: "\(objData.id ?? 0)")
       
        //BUTTON ACTION
        cell.btnDownalod.tag = index
        cell.btnDownalod.addTarget(self, action: #selector(self.btnDownloadClicked(_:)), for: .touchUpInside)

        cell.btnCancelDownalod.tag = index
        cell.btnCancelDownalod.addTarget(self, action: #selector(self.btnCancelDowClicked(_:)), for: .touchUpInside)
        

        //CHECK THIS TRACK IS PLAYING
        if isMusicPlayNow{
            if CurrentPlayTrackID == objData.id{
                cell.lblName.textColor = UIColor.standard
                cell.lblArtists.textColor = UIColor.standard
            }
        }
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
        cell.backgroundColor = UIColor.clear
        if isLoading{
            return cell
        }
        
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
        
        trackListingCell(cell: cell, index: indexPath.row >= 5 ? indexPath.row - 1 : indexPath.row)
        return cell
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let objData = self.arrTrackList[indexPath.row]
        let objData : RadioModel!
        if indexPath.row >= 5{
            objData = self.arrTrackList[indexPath.row - 1]
        }
        else{
            objData = self.arrTrackList[indexPath.row]
        }
        
        //ADD IN QUEUS
        let MenuID = arrMusicPlayList.map{$0.id}
        if let index = MenuID.firstIndex(of: objData.id){
            indexPlayMusic = index
        }
        else{
            indexPlayMusic = 0
            arrMusicPlayList.insert(objData, at: 0)
        }
        self.openMusicBar(isPlayMusic: true)
    }
    
    
    //TABLE ACTION BUTTON
    @objc func btnDownloadClicked(_ sender: UIButton) {
        //GET DATA
        let objData = self.arrTrackList[sender.tag]
        
        if let objUser = UserDefaults.standard.user{
            
            let getPoint : Int = Int(UserDefaults.standard.getCoine ?? "") ?? 0
            if getPoint >= isMinimumCoine{
                let arrData = CoreDBManager.sharedDatabase.getDownloadVideosData(userID: objUser.id ?? "", videoID: "\(objData.id ?? 0)")
                if arrData.count != 0{
                    let obj = arrData[0]
                    if obj.isDownload == "true"{
                        let alert = UIAlertController(title: Application.appName, message: str.removeDownload, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
                            CoreDBManager.sharedDatabase.deleteDownloadVideo(userID: objUser.id ?? "", videoID: "\(objData.id ?? 0)") { done in
                                if done{
                                    if obj.download_URL != ""{
                                        let strDownloadURL : NSString = ((GlobalConstants.appDelegate?.myDownloadPath ?? "") as NSString).appendingPathComponent(obj.download_URL ?? "") as NSString
                                        try? FileManager.default.removeItem(atPath: "\(strDownloadURL)")
                                    }
                                    //RELOAD TABLE
                                    self.tblView.reloadData()
                                }
                            }
                            
                        }))
                        alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                else{
                    //GET ARTIST NAME
                    var strArtist : String = ""
                    for obj in objData.arrArtists{
                        if strArtist == ""{
                            strArtist = obj.name ?? ""
                        }
                        else{
                            strArtist = "\(strArtist), \(obj.name ?? "")"
                        }
                    }
                    
                    if UserDefaults.standard.user != nil{
                        arrLoading.append(objData.id ?? 0)
                        
                        //RELOAD TABLE
                        self.tblView.reloadData()
                        
                        let MenuID = arrMusicPlayList.map{$0.id}
                        if let index = MenuID.firstIndex(of: objData.id) {
                            let objMisucData = arrMusicPlayList[index]
                            
                            if objMisucData.downloadPlayURL != ""{
                                
                                //SAVE VIDEO
                                CoreDBManager.sharedDatabase.saveDownalodURL(objSaveShowData: DownloadVideoParameater(download_percentage: "", download_URL: "", isDownload: "false", session_id: "", userID: objUser.id ?? "", video_artist_name: strArtist, video_id: "\(objData.id ?? 0)", video_img: objMisucData.videoImage , video_name: objData.name ?? "", video_url: objMisucData.downloadPlayURL , youtubID: objMisucData.youtubID )) { isSave in
                                    
                                    //START DOWNLAOD
                                    GlobalConstants.appDelegate?.DownloadVideos(videoURL: URL(string: objMisucData.downloadPlayURL)!, strVideoID: "\(objData.id ?? 0)")
                                }
                                
                                
                            }
                            else if objMisucData.youtubID != ""{
                                self.callOtherDetails(obj: objData, strCurrentYoutubID: objMisucData.youtubID)
                            }
                            else{
                                //SEARCH YOUTUB ID
                                var strName = "\(strArtist)/\(objData.name ?? "")"
                                strName = strName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                self.searchVideoID(index: sender.tag, strID: objData.id ?? 0, strName: strName)
                            }
                            
                        }
                        else{
                            
                            //SEARCH YOUTUB ID
                            var strName = "\(strArtist)/\(objData.name ?? "")"
                            strName = strName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            self.searchVideoID(index: sender.tag, strID: objData.id ?? 0, strName: strName)
                        }
                    }
                }
            }
            else{
                //POPUP GET MORE COINE
                let window = UIApplication.shared.keyWindow!
                window.endEditing(true)
                let cartView = GetMore(frame: CGRect(x: 0, y: 0 ,width : window.frame.width, height: window.frame.height))
                cartView.delegate = self
                cartView.loadPopUpView()
                window.addSubview(cartView)
            }
        }
    }
    
    func selectGetCoine() {
        
        if let ad = rewardedAd {
          ad.present(fromRootViewController: self) {
            let reward = ad.adReward
            print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
              GlobalConstants.appDelegate?.earnCoins(NSInteger(truncating: reward.amount))
            // TODO: Reward the user.
          }
        } else {
          let alert = UIAlertController(
            title: Application.appName,
            message: "Rewarded ad isn't available yet.",
            preferredStyle: .alert)
          let alertAction = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: {action in
            })
          alert.addAction(alertAction)
          self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func btnCancelDowClicked(_ sender: UIButton) {
        
        if let objUser = UserDefaults.standard.user{
            //GET DATA
            let objData = self.arrTrackList[sender.tag]

            let arrData = CoreDBManager.sharedDatabase.getDownloadVideosData(userID: objUser.id ?? "", videoID: "\(objData.id ?? 0)")

            if arrData.count != 0{
                let obj = arrData[0]
                if obj.isDownload != "true"{
                    let alert = UIAlertController(title: Application.appName, message: str.deleteDownload, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
                        
                        CoreDBManager.sharedDatabase.deleteDownloadVideo(userID: objUser.id ?? "", videoID: "\(objData.id ?? 0)") { isDone in
                            if isDone{
                                if obj.download_URL != ""{
                                    let strDownloadURL : NSString = ((GlobalConstants.appDelegate?.myDownloadPath ?? "") as NSString).appendingPathComponent(obj.download_URL ?? "") as NSString
                                    try? FileManager.default.removeItem(atPath: "\(strDownloadURL)")
                                }
                                
                                //RELOAD TABLE
                                self.tblView.reloadData()
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    
    //TABLE ACTION BUTTON
    @objc func btnTrackMenuClicked(_ sender: UIButton) {
        //GET DATA
        let objData = self.arrTrackList[sender.tag]

        //GET ARTIST NAME
        var strArtist : String = ""
        for obj in objData.arrArtists{
            if strArtist == ""{
                strArtist = obj.name ?? ""
            }
            else{
                strArtist = "\(strArtist), \(obj.name ?? "")"
            }
        }

        let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "MenuPopup") as! MenuPopup

        popVC.strAlbumName = "\(objData.name ?? "")"
        popVC.strArticstName = strArtist
        popVC.strAlbumImage = self.strAlbumeImage
        popVC.indexRecommended = sender.tag
        popVC.strTYPE = "Track"
        popVC.strTrackId = objData.id ?? 0

        popVC.modalPresentationStyle = .popover
        popVC.delegate = self

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.backgroundColor = UIColor.white
        popOverVC?.sourceView = sender
        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: manageWidth(size: 250.0), height: (manageWidth(size: 400.0)))

        popVC.modalTransitionStyle = .crossDissolve
        self.present(popVC, animated: true)

    }
}




//MARK: - DOWNALOAD NOTIFICAITON
extension AlbumeListViewController{
    
    func checkDownlaodCell(cell : RadioCell, videoID : String) {
        cell.btnDownalod.isHidden = true
        cell.btnCancelDownalod.isHidden = true
        cell.DownloadProgressBar.isHidden = true
        cell.objLoading.isHidden = true
        cell.objLoading.stopAnimating()
        cell.con_downlaod.constant = 30
        
        if let objUser = UserDefaults.standard.user{
            let arrData = CoreDBManager.sharedDatabase.getDownloadVideosData(userID: objUser.id ?? "", videoID: videoID)
            if arrData.count != 0{
                let obj = arrData[0]
                if obj.isDownload == "true"{
                    cell.btnDownalod.isHidden = false
                    cell.btnDownalod.setImage(UIImage(named: "icon_SelectDownloadVideo"), for: .normal)
                    buttonImageColor(btnImage: cell.btnDownalod, imageName: "icon_SelectDownloadVideo", colorHex: setTextColour())
                }
                else{
                    //CHECK LOADING
                    let progress : Float = Float(obj.download_percentage ?? "") ?? 0.0
                    if progress == 0.0{
                        cell.objLoading.isHidden = false
                        cell.objLoading.startAnimating()
                        cell.DownloadProgressBar.isHidden = true

                    }
                    else{
                        cell.DownloadProgressBar.angle = Double(progress) * 360
                        cell.DownloadProgressBar.isHidden = false
                        cell.objLoading.isHidden = true
                        cell.objLoading.stopAnimating()

                    }
                    
                }
            }
            else{
                let MenuID = arrLoading.map{$0}
                if MenuID.firstIndex(of: Int(videoID) ?? 0) != nil {
                    cell.objLoading.isHidden = false
                    cell.objLoading.startAnimating()
                }
                else{
                    cell.btnDownalod.isHidden = false
                    cell.btnDownalod.setImage(UIImage(named: "icon_download"), for: .normal)
                    buttonImageColor(btnImage: cell.btnDownalod, imageName: "icon_download", colorHex: setTextColour())
                }
            }
        }
        else{
            cell.con_downlaod.constant = 0
        }
    }
    
    
    
    @objc func downLoadProgressNotification(_ notification : Notification) {
        DispatchQueue.main.async {
//            self.checkDownlaod()
            
            if let objProgress = notification.object as? Download{
                let MenuID = self.arrTrackList.map{$0.id}
                if let index = MenuID.firstIndex(of: Int(objProgress.video_id ?? "") ?? 0 ) {
                    
                    
                    //RELOAD MENU CELL
                    DispatchQueue.main.async {
                        let indexRow = index >= 5 ? index + 1 : index
                        let cell = self.tblView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? RadioCell
                        if let MenuCell = cell{
                            self.checkDownlaodCell(cell: MenuCell, videoID: objProgress.video_id ?? "")
                        }
                    }
                }
            }
        }
    }
   
    
    @objc func downloadFinishedNotification(_ notification : Notification) {
        self.tblView.reloadData()
    }
  
    @objc func downLoadFailedNotification(_ notification : Notification) {
    }
}


