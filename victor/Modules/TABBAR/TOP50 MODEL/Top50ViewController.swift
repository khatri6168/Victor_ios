//
//  Top50ViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit
import KDCircularProgress
import Alamofire
import GoogleMobileAds
import AVFAudio
import GoogleMobileAds

class Top50ViewController: UIViewController, GADFullScreenContentDelegate, GetMorePROTOCOL {
    //SET VIEW VALUES
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    
    
    //LOAD MORE
    var _loadingView: UIActivityIndicatorView!
    var bool_Load: Bool = false
    var objRefresh : UIRefreshControl?
    
    var arrPopulerTrackList : [RadioModel] = []
    var pageCount : Int = 1
    var isLoading : Bool = true
    
    //ADS
    var rewardedAd: GADRewardedAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .removeLoading, object: nil)

        
        //DOWNALOAD NOTIFICAITON
        NotificationCenter.default.addObserver(self, selector: #selector(self.downLoadProgressNotification), name: .downLoadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadFinishedNotification), name: .downLoadFinished, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.downLoadFailedNotification), name: .downLoadFailed,
        // Do any additional setup after loading the view.
        
        //SET REFRSH CONTROL
        self.objRefresh = UIRefreshControl()
        self.objRefresh?.tintColor = setTextColour()
        self.objRefresh?.addTarget(self, action: #selector(self.refreshList), for: .valueChanged)
        self.tblView.addSubview(self.objRefresh!)
        
        self.refreshList()
        
        //SET REWARED
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "00008020-0009545011C3002E" ] // Sample device ID
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
        tabBarPreviousIndexSelect = 1
        
        //GET DATA
        if let objUser = UserDefaults.standard.user{
            GlobalConstants.appDelegate?.SaveArtistListAPI()
            GlobalConstants.appDelegate?.SavePlaylistAPI(strUserId: objUser.id ?? "")
            GlobalConstants.appDelegate?.SaveTrackListAPI()
            GlobalConstants.appDelegate?.SaveAlbumeListAPI()
        }
        
        //SET VIEW
        self.view.backgroundColor = setColour()
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
        setNavigationBarTitleFor(controller: self, title: str.populerTrack, isTransperent: true, hideShadowImage: false, leftIcon: "", rightIcon: "icon_search") { SelectTag in
        } rightActionHandler: {SelectTag in
            //SEARCH
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.SEARCH_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        
        
        //SET FFONT
        self.setupTableView()
        
        
        //SET FOOTER
        self.tblView.isHidden = false
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
    
    @objc func refreshList() {
        //GET DETAILS
        self.pageCount = 1
        self.arrPopulerTrackList = []
        self.PopularTrackAPI(GenresParameater: GenresParameater(filter: "", page: "\(pageCount)"), isLoading: true)
    }
    
}


//.......................... UITABLE VIEW ..........................//


//MARK: -- UITABEL DELEGATE --
extension Top50ViewController : UITableViewDelegate, UITableViewDataSource ,MenuProtocol, UIPopoverPresentationControllerDelegate{
    
    // MARK: - LODING VIEW
    func setupTableView() {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tblView.frame.size.width, height: 40))
        
        _loadingView = UIActivityIndicatorView(style: .white)
        viewFooter.addSubview(_loadingView)
        tblView.tableFooterView = viewFooter
        _loadingView.isHidden = true
        _loadingView.frame = CGRect(x: viewFooter.frame.size.width / 2 - 15 , y: 0, width: 30, height: 30)
        _loadingView.center = CGPoint(x: viewFooter.frame.size.width / 2, y: _loadingView.center.y)
    }
    
    func startAnimatingView() {
        
        _loadingView.center = CGPoint(x: tblView.frame.size.width / 2, y: _loadingView.center.y)
        _loadingView.startAnimating()
        _loadingView.isHidden = false
    }
    
    func stopAnimatingView() {
        _loadingView.stopAnimating()
        _loadingView.isHidden = true
    }
    
    //MARK: - Scrollview Delegate -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblView{
            if tblView.contentSize.height <= tblView.contentOffset.y + tblView.frame.size.height && tblView.contentOffset.y >= 0 {
                if bool_Load == false && arrPopulerTrackList.count != 0 {
                    
                    //Refresh code
                    self.bool_Load = true
                    
                    //START LOADING
                    startAnimatingView()
                    
                    //GET DETAILS
                    self.PopularTrackAPI(GenresParameater: GenresParameater(filter: "", page: "\(pageCount)"), isLoading: false)
                }
            }
        }
    }
    
    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 10
        }
        else{
            if isAdsShowing{
                if self.arrPopulerTrackList.count > 5{
                    return self.arrPopulerTrackList.count + 1
                }
                else{
                    return self.arrPopulerTrackList.count
                }
                
            }
            else{
                return self.arrPopulerTrackList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
        cell.backgroundColor = UIColor.clear
        if isLoading{
            cell.lblName.text = "Loading.."
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
                cell.viewAds.delegate = self
                cell.viewAds.load(GADRequest())

                return cell
            }
        }
        
        //SET BUTTON
        buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())
        buttonImageColor(btnImage: cell.btnDownalod, imageName: "icon_download", colorHex: setTextColour())

        //GET DATA
        if self.arrPopulerTrackList.count != 0{
            let objData : RadioModel!
            if indexPath.row >= 5{
                objData = self.arrPopulerTrackList[indexPath.row - 1]
            }
            else{
                objData = self.arrPopulerTrackList[indexPath.row]
            }
            
//            let objData = self.arrPopulerTrackList[isAdsShowing ? indexPath.row - Int(indexPath.row / Application.adsValue) : indexPath.row]
            
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
            cell.btnMore.tag = indexPath.row >= 5 ? indexPath.row - 1 : indexPath.row
            cell.btnMore.addTarget(self, action: #selector(self.btnMenuClicked(_:)), for: .touchUpInside)
            
            
            //SET DOWNALOD VIEW
            setTheProgressView(DownloadProgressBar: cell.DownloadProgressBar)
            checkDownlaodCell(cell: cell, videoID: "\(objData.id ?? 0)")
           
            //BUTTON ACTION
            cell.btnDownalod.tag = indexPath.row >= 5 ? indexPath.row - 1 : indexPath.row
            cell.btnDownalod.addTarget(self, action: #selector(self.btnDownloadClicked(_:)), for: .touchUpInside)

            cell.btnCancelDownalod.tag = indexPath.row >= 5 ? indexPath.row - 1 : indexPath.row
            cell.btnCancelDownalod.addTarget(self, action: #selector(self.btnCancelDowClicked(_:)), for: .touchUpInside)

            
            //CHECK THIS TRACK IS PLAYING
            if isMusicPlayNow{
                if CurrentPlayTrackID == objData.id{
                    cell.lblName.textColor = UIColor.standard
                    cell.lblArtists.textColor = UIColor.standard
                }
            }
        }
        
//        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData : RadioModel!
        if indexPath.row >= 5{
            if indexPath.row == 5{
                return
            }
            objData = self.arrPopulerTrackList[indexPath.row - 1]
        }
        else{
            objData = self.arrPopulerTrackList[indexPath.row]
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
        let objData = self.arrPopulerTrackList[sender.tag]

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
            let objData = self.arrPopulerTrackList[sender.tag]

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
    
    
//    func getSaveFileUrl(fileName: String) -> URL {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let nameUrl = URL(string: fileName)
//        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
//        NSLog(fileURL.absoluteString)
//        return fileURL;
//    }
//
    @objc func btnMenuClicked(_ sender: UIButton) {
        //GET DATA
        let objData = self.arrPopulerTrackList[sender.tag]
        
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
        popVC.strAlbumImage = "\(objData.objAlbum.image ?? "")"
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
                newViewController.strArtistsID = self.arrPopulerTrackList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strTrackRadio{
            //GO TO TRACK RADIO
            //MOVE RADIO SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                newViewController.isRadioTrack = "Track"
                newViewController.strRadioID = self.arrPopulerTrackList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
            //ADD OR REMOVE TRACK IN PLAYLIST
            if strType == "Track"{
                let objData = self.arrPopulerTrackList[popUpIndex]
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
        }
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
}


func setTheProgressView(DownloadProgressBar: KDCircularProgress){
    //SET PROGRESS VIEW
    DownloadProgressBar.startAngle = -90
    DownloadProgressBar.trackColor = .lightGray
    DownloadProgressBar.progressThickness = 0.5
    DownloadProgressBar.trackThickness = 0.2
    DownloadProgressBar.clockwise = true
    DownloadProgressBar.gradientRotateSpeed = 2
    DownloadProgressBar.roundedCorners = false
    DownloadProgressBar.glowMode = .forward
    DownloadProgressBar.glowAmount = 0.9
    DownloadProgressBar.set(colors: setTextColour())
    DownloadProgressBar.isHidden = true
//    btnDowCancel.isHidden = true
//    btnDow.isHidden = false
}




//MARK: - DOWNALOAD NOTIFICAITON
extension Top50ViewController{
    
    
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
                let MenuID = self.arrPopulerTrackList.map{$0.id}
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


extension Top50ViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
