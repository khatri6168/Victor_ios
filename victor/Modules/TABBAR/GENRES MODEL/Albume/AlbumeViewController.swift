//
//  AlbumeViewController.swift
//  victor
//
//  Created by Jigar Khatri on 11/11/21.
//

import UIKit
import Nuke
import GoogleMobileAds

class AlbumeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var objCollectionMenu: UICollectionView!
    @IBOutlet weak var con_ObjCollectionHeight: NSLayoutConstraint!

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

    @IBOutlet weak var viewADS: GADBannerView!
    @IBOutlet weak var con_ADSHeight: NSLayoutConstraint!

    

    //OTHER
    var strArtistsID : Int = 0
    var isShowAllTrack : Bool = false
    var isSelectList : Bool = true

    var strArtistsImage : String = ""
    var strArtistsName : String = ""
    
    var arrTrackList : [RadioModel] = []
    var arrAlbumsList : [AlbumModel] = []
    var arrArtistList : [ArtistsModel] = []
    var arrAboutURL : [String] = []
    var strDescription : String = ""

    var arrMenu: [String] = [str.strDiscography, str.strSimilarArtists, str.strAbout]
    var SelectTag : String = str.strDiscography
    var arrSection: [String] = [str.strPopularSongs, str.strAlbums]

    //LOADING
    var _loadingView: UIActivityIndicatorView!
    var bool_Load: Bool = false
    var pageCount : Int = 1
    var isLoading : Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)

        // Do any additional setup after loading the view.
        
        self.setTheView()
        self.setupTableView()
        
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
     }
    
    @objc private func updatePlayer(){
        self.tblView.reloadData()
    }
    
    func setTheView(){
        con_ObjCollectionHeight.constant = manageWidth(size: 50.0)
        
        //SET VIEW
        self.viewPlay.backgroundColor = UIColor.standard
        self.viewPlay.dropShadow(bgColour: UIColor.red, radius: self.viewPlay.frame.size.height / 2)
        self.btnPlay.btnCorneRadius(radius: 0, isRound: true)

        //SET MORE VIEW
        self.viewMore.backgroundColor = .clear
        self.viewMore.viewCorneRadius(radius: 0, isRound: true)
        self.viewMore.viewBorderCorneRadiusLight(borderColour: UIColor.grayLight)
        self.btnMore.btnCorneRadius(radius: 0, isRound: true)

                
        //SET FONT
        lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: "Loading..")
        
        lblPlay.configureLable(textColor: UIColor.primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strPlay)
        imgColor(imgColor: imgPlay, colorHex: UIColor.primary)

        lblMore.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strMore)
        imgColor(imgColor: imgMore, colorHex: setTextColour())
   
        //SET HEADER
        self.tblView.isHidden = false
        self.tblView.isUserInteractionEnabled = false
        imgAlbum.viewCorneRadius(radius: 0, isRound: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.objCollectionMenu.frame.origin.y + self.objCollectionMenu.frame.size.height)
            self.tblView.tableHeaderView = vw_Table
        }

    }
    
    func setTheDetails(){
        self.lblName.text = strArtistsName.capitalizingFirstLetter()
        
        //SET IMAGE
        imgAlbum.backgroundColor = UIColor.grayLight
        imgAlbum.viewCorneRadius(radius: 0, isRound: true)
        if self.strArtistsImage != ""{
            let imgURL =  ("\(self.strArtistsImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgAlbum)
            }
        }
        
        //SET ADS
        con_ADSHeight.constant = 0
        if isAdsShowing{
            con_ADSHeight.constant = manageWidth(size: 200)
            viewADS.backgroundColor = setColour()
            viewADS.adUnitID = Application.gogleBanner
            viewADS.rootViewController = self
            viewADS.load(GADRequest())
        }
        
        //SET HEADER
        self.tblView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.viewADS.frame.origin.y + self.viewADS.frame.size.height)
            self.tblView.tableHeaderView = vw_Table
        }
    }
}


//MARK: - BUTTON ACTION
extension AlbumeViewController {
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
    
    
    @IBAction func btnMoreClicked(_ sender: UIButton) {
        //GET DATA

        let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "MenuPopup") as! MenuPopup

        popVC.strAlbumName = strArtistsName
//        popVC.strArticstName = strArtist
        popVC.strAlbumImage = strArtistsImage
//        popVC.indexRecommended = sender.tag
        popVC.strTYPE = "Header"
        popVC.strArtistsId = strArtistsID
        popVC.modalPresentationStyle = .popover
        popVC.delegate = self

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.backgroundColor = UIColor.white
        popOverVC?.sourceView = sender
        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: manageWidth(size: 250.0), height: (manageWidth(size: 300.0)))

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
        if strType == "Header"{
            if strSelectIndex == str.strFollow || strSelectIndex == str.strUnfollow{
                
                GlobalConstants.appDelegate?.AddOrRemoveTrackAPI(TrackAddRemoveParameater: TrackAddRemoveParameater(likeables: [LikeablesParameater(likeable_id: "\(strArtistsID)", likeable_type: "artist")], _method: strSelectIndex == str.strFollow ? "" : "DELETE"), isRemove: strSelectIndex == str.strFollow ? false : true)
            }
            else if strSelectIndex == str.strTrackRadio{
                
                //MOVE RADIO SCREEN
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                    if strType == "Header"{
                        newViewController.strRadioID = strArtistsID
                        newViewController.isRadioTrack = "Artist"
                    }
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            else if strSelectIndex == str.strShare{
                shareActivicty()
            }
        }
        else{
            if strSelectIndex == str.strProfile{
                
                //MOVE ALBUME LIST SCREEN
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeListViewController") as? AlbumeListViewController{
                    
                    if strType == "Albume" || strType == "Track_2"{
                        newViewController.isTrack = true
                        newViewController.strArtistsID = self.arrAlbumsList[popUpSection].arrTracks[popUpIndex].id ?? 0
                    }
                    else if strType == "Track"{
                        newViewController.isTrack = true
                        newViewController.strArtistsID = self.arrTrackList[popUpIndex].id ?? 0
                    }
                    
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
                        if strType == "Track_2"{
                            newViewController.strRadioID = self.arrAlbumsList[popUpSection].arrTracks[popUpIndex].id ?? 0
                        }else{
                            newViewController.strRadioID = self.arrTrackList[popUpIndex].id ?? 0
                        }
                        newViewController.isRadioTrack = "Track"
                    }
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            
            else if strSelectIndex == str.strSaveMusic || strSelectIndex == str.strRemoveMusic{
                
                var strID : String = ""
                if strType == "Track"{
                    strID = "\(self.arrTrackList[popUpIndex].id ?? 0)"
                }
                else if strType == "Track_2"{
                    strID = "\(self.arrAlbumsList[popUpSection].arrTracks[popUpIndex].id ?? 0)"
                }
                else if strType == "Albume"{
                    strID = "\(self.arrAlbumsList[popUpIndex].id ?? 0)"
                }
                
                GlobalConstants.appDelegate?.AddOrRemoveTrackAPI(TrackAddRemoveParameater: TrackAddRemoveParameater(likeables: [LikeablesParameater(likeable_id: strID, likeable_type: strType == "Albume" ? "album" : "track")], _method: strSelectIndex == str.strSaveMusic ? "" : "DELETE"), isRemove: strSelectIndex == str.strSaveMusic ? false : true)
            }
            
            else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
                //ADD OR REMOVE TRACK IN PLAYLIST
                if strType == "Track" || strType == "Track_2"{
                    var strID : Int = 0
                    var objData : RadioModel!
                    if strType == "Track"{
                        objData = self.arrTrackList[popUpIndex]
                        strID = objData.id ?? 0

                    }
                    else if strType == "Track_2"{
                        objData = self.arrAlbumsList[popUpSection].arrTracks[popUpIndex]
                        strID = objData.id ?? 0
                    }
                    
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
                    let objData = self.arrAlbumsList[popUpIndex]
                    for objTrack in objData.arrTracks{
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
    
    func shareActivicty(){
        let activityVC = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        activityVC.excludedActivityTypes = []

//        if UIDevice.current.userInterfaceIdiom == .pad {
//            activityVC.popoverPresentationController?.sourceView = self.view
//            activityVC.popoverPresentationController?.sourceRect = btnShare.frame
//        }
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

extension AlbumeViewController: UIActivityItemSource {
    
    // The placeholder the share sheet will use while metadata loads
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return str.appName
    }
    
    // The item we want the user to act on.
    // In this case, it's the URL to the Wikipedia page
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return URL(string: "https://i.scdn.co/image/ab676161000051748777e097ef122463984c708f")
    }
}




//.......................... UITABLE VIEW ..........................//

//MARK: -- UITABEL CELL --

class HeaderCell : UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnList: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    @IBOutlet weak var viewLine: UIView!
}

class ArtistsHeaderCell : UITableViewCell{
    @IBOutlet weak var imgArtists: UIImageView!
    @IBOutlet weak var lblArtists: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var objCollection: UICollectionView!
    @IBOutlet weak var con_CollectionViewHeight: NSLayoutConstraint!

    @IBOutlet weak var viewADS: GADBannerView!
    @IBOutlet weak var con_ADSHeight: NSLayoutConstraint!
}

class AboutUsCell : UITableViewCell{
    @IBOutlet weak var lblDetails: UILabel!

    @IBOutlet weak var objCollection: UICollectionView!
    @IBOutlet weak var con_CollectionViewHeight: NSLayoutConstraint!

    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
}

class ShowMoreCell : UITableViewCell{
    @IBOutlet weak var btnShowMore: UIButton!
}

//MARK: -- UITABEL DELEGATE --

extension AlbumeViewController : UITableViewDelegate, UITableViewDataSource ,MenuProtocol, UIPopoverPresentationControllerDelegate{
 
    
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
        if SelectTag != str.strSimilarArtists && SelectTag != str.strAbout{
            if scrollView == tblView {
                if tblView.contentSize.height <= tblView.contentOffset.y + tblView.frame.size.height && tblView.contentOffset.y >= 0 {
                    if bool_Load == false && self.arrAlbumsList.count != 0 {

                        //Refresh code
                        self.bool_Load = true

                        //START LOADING
                        startAnimatingView()
                        
                        //GET DETAILS
                        self.ArtistsAPI(ArtistsPageintionParameater: ArtistsPageintionParameater(page: "\(self.pageCount)"), strId: "\(strArtistsID)")
                    }
                }
            }
        }
    }
    
    
    
    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading || SelectTag == str.strSimilarArtists || SelectTag == str.strAbout{
            return 1
        }
        return self.arrSection.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        //SET HEADER HEIGHT
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.backgroundColor = setColour()
        if isLoading{
            cell.viewLine.isHidden = true
            cell.lblTitle.text = "Loading.."
            return cell
        }
        
        //SET FONT
        cell.lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16, text:  self.arrSection[section])

        //SET BUTTON
        buttonImageColor(btnImage: cell.btnList, imageName: "icon_list", colorHex: setTextColour())
        buttonImageColor(btnImage: cell.btnGrid, imageName: "icon_grid", colorHex: setTextColour())
        
        if isSelectList{
            buttonImageColor(btnImage: cell.btnList, imageName: "icon_list", colorHex: UIColor.standard)
        }
        else{
            buttonImageColor(btnImage: cell.btnGrid, imageName: "icon_grid", colorHex: UIColor.standard)
        }
       
        
        //SET BUTTON
        cell.btnList.addTarget(self, action: #selector(btnListClicked(_:)), for: .touchUpInside)
        cell.btnGrid.addTarget(self, action: #selector(btnGridClicked(_:)), for: .touchUpInside)

        //SET BUTTON SHOWING
        cell.btnList.isHidden = true
        cell.btnGrid.isHidden = true
        cell.viewLine.isHidden = true
        if section == 1{
            cell.btnList.isHidden = false
            cell.btnGrid.isHidden = false
            cell.viewLine.isHidden = false
        }
        return cell
    }
    
    @objc func btnListClicked(_ sender: UIButton){
        isSelectList = true
        
        //RELOAD TABLE
        self.tblView.reloadData()
    }
    
    @objc func btnGridClicked(_ sender: UIButton){
        isSelectList = false
        
        //RELOAD TABLE
        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  SelectTag == str.strSimilarArtists || SelectTag == str.strAbout{
            return 0
        }
        return manageWidth(size: 65.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 10
        }
        else{
            if  SelectTag == str.strSimilarArtists || SelectTag == str.strAbout{
                return 1
            }
            else{
                if section == 0{
                    
                    if self.arrTrackList.count > 5{
                        return isShowAllTrack ? self.arrTrackList.count + 1 : (self.arrTrackList.count != 0 ? 6 : 0)
                    }
                    else{
                        return self.arrTrackList.count
                    }
                    
                }
                else{
                    return isSelectList ? self.arrAlbumsList.count : 1
                }
            }
        }
     
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func trackListingCell (cell : RadioCell ,index: Int){
        //SET BUTTON
        buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())

        //GET DATA
        let objData = self.arrTrackList[index]

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

        //CHECK THIS TRACK IS PLAYING
        if isMusicPlayNow{
            if CurrentPlayTrackID == objData.id{
                cell.lblArtists.textColor = UIColor.standard
                cell.lblName.textColor = UIColor.standard
            }
        }
        
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  SelectTag == str.strSimilarArtists {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell") as! GenresCell
            cell.backgroundColor = UIColor.clear

            //SET HEADER COLLECTION VIEW
            cell.objCollection.accessibilityIdentifier = str.strSimilarArtists
            cell.objCollection.tag = indexPath.row
            cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 55)) * (CGFloat((self.arrArtistList.count + 1) / 2))
            
            //RELOAD COLLECTION VIEW
            cell.objCollection.reloadData()
                        
            cell.layoutIfNeeded()
            return cell
        }
        else if SelectTag == str.strAbout{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutUsCell") as! AboutUsCell
            cell.backgroundColor = UIColor.clear

            cell.lblDetails.numberOfLines = 0
            cell.lblDetails.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: self.strDescription)

            
            //SET HEADER COLLECTION VIEW
            cell.objCollection.accessibilityIdentifier = str.strAbout
            cell.objCollection.tag = indexPath.row
            cell.con_CollectionViewHeight.constant = manageWidth(size: 250)
            
            //RELOAD COLLECTION VIEW
            cell.objCollection.reloadData()
                
            
            //SET EMTY DETAILS
            cell.emptyDataView.noAboutUs(str: "\(str.noDataFountAboutUs) \(self.strArtistsName)")
            cell.emptyDataView.isHidden = true
            
            if self.arrAboutURL.count == 0 && self.strDescription == ""{
                cell.emptyDataView.isHidden = false
            }
            cell.layoutIfNeeded()
            return cell
        }
        else{
            if indexPath.section == 0{
                
                if self.arrTrackList.count > 5{
                    //GET COUNT
                    let countCell : Int = isShowAllTrack ? self.arrTrackList.count + 1 : (self.arrTrackList.count != 0 ? 6 : 0)
                    
                    if countCell - 1 > indexPath.row{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
                        cell.backgroundColor = UIColor.clear

                        var index = indexPath.row
                        if isAdsShowing{
                            if indexPath.row == 4{
                                index = indexPath.row >= 4 ? indexPath.row - 1 : indexPath.row

                                let cell = tableView.dequeueReusableCell(withIdentifier: "AdsCell") as! AdsCell
                                cell.backgroundColor = UIColor.clear
                                cell.viewAds.backgroundColor = setColour()
                                cell.viewAds.adUnitID = Application.gogleBanner
                                cell.viewAds.rootViewController = self
                                cell.viewAds.load(GADRequest())

                                return cell
                            }
                        }
                        
                        
                        trackListingCell(cell: cell, index: index)
                        return cell
                    }
                    else{
                        //SHOW MORE
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreCell") as! ShowMoreCell
                        cell.backgroundColor = UIColor.clear

                        //SET BUTTON
                        cell.btnShowMore.configureLable(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strShowMore)
                        cell.btnShowMore.btnCorneRadius(radius: 5, isRound: false)
                        cell.btnShowMore.btnnBorder(bgColour: UIColor.grayLight)
                        
                       
                        //SET BUTTON ACTION
                        cell.btnShowMore.tag = indexPath.row
                        cell.btnShowMore.addTarget(self, action: #selector(self.btnShowMoreClicked(_:)), for: .touchUpInside)
                        
                        cell.layoutIfNeeded()
                        return cell
                    }
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
                    cell.backgroundColor = UIColor.clear
                    if isLoading{
                        return cell
                    }
                    trackListingCell(cell: cell, index: indexPath.row)
                    return cell
                }
                
               
            }
            else{
                
                if isSelectList{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistsHeaderCell") as! ArtistsHeaderCell
                    cell.backgroundColor = UIColor.clear
                    
                    
                    //GET DATA
                    let obj = self.arrAlbumsList[indexPath.row]
                    cell.con_ADSHeight.constant = 0
//                    if indexPath.row == 0{
//                        if isAdsShowing{
//                            cell.con_ADSHeight.constant = manageWidth(size: 55)
//                            cell.viewADS.backgroundColor = setColour()
//                            cell.viewADS.adUnitID = Application.gogleBanner
//                            cell.viewADS.rootViewController = self
//                            cell.viewADS.load(GADRequest())
//                        }
//                    }
                    cell.lblArtists.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16.0, text: obj.name?.capitalizingFirstLetter() ?? "")
                    cell.lblDate.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: obj.release_date ?? "")

                    //SET IMAGE
                    cell.imgArtists.backgroundColor = UIColor.grayLight
                    cell.imgArtists.layer.masksToBounds = true
                    cell.imgArtists.layer.cornerRadius = 5
                    if let strImg = obj.image{
                        let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                        if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                            Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgArtists)
                        }
                    }


                    //SET BUTTON
                    cell.btnMore.configureLable(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: str.strMore2)
                    cell.btnMore.btnCorneRadius(radius: 0, isRound: true)
                    cell.btnMore.btnnBorder(bgColour: setTextColour())
                    
                    //SET BUTTON ACTION
                    cell.btnMore.tag = indexPath.row
                    cell.btnMore.addTarget(self, action: #selector(self.btnAlbumMenuClicked(_:)), for: .touchUpInside)

                    
                    
                    //SET HEADER COLLECTION VIEW
                    cell.con_CollectionViewHeight.constant = manageWidth(size: 60) * CGFloat(arrAlbumsList[indexPath.row].arrTracks.count)

                    //RELOAD COLLECTION VIEW
                    cell.objCollection.accessibilityIdentifier = "Track"
                    cell.objCollection.tag = indexPath.row
                    cell.objCollection.reloadData()

                    cell.layoutIfNeeded()
                    return cell
                    
                }
                else{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell") as! GenresCell
                    cell.backgroundColor = UIColor.clear

                    //SET HEADER COLLECTION VIEW
                    cell.objCollection.accessibilityIdentifier = "Albums"
                    cell.objCollection.tag = indexPath.row
                    cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 80)) * (CGFloat((arrAlbumsList.count + 1) / 2))
                    
                    //RELOAD COLLECTION VIEW
                    cell.objCollection.reloadData()
                                
                    cell.layoutIfNeeded()
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let objData = self.arrTrackList[indexPath.row]
//            let objData : RadioModel!
//            if indexPath.row >= 4{
//                objData = self.arrTrackList[indexPath.row - 1]
//            }
//            else{
//                objData = self.arrTrackList[indexPath.row]
//            }
            
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
    }
    
    
    //TABLE ACTION BUTTON
    @objc func btnShowMoreClicked(_ sender: UIButton) {
        if isShowAllTrack{
            isShowAllTrack = false
        }
        else{
            isShowAllTrack = true
        }
        
        //RELOAD TABLE
        self.tblView.reloadData()
//        self.tblView.reloadSections(IndexSet(integer: 0), with: .top)
    }
    
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
        popVC.strAlbumImage = "\(objData.objAlbum.image ?? "")"
        popVC.indexRecommended = sender.tag
        popVC.strTrackId = objData.id ?? 0
        popVC.strTYPE = "Track"
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
    
    @objc func btnAlbumMenuClicked(_ sender: UIButton) {
        //GET DATA
        let objData = self.arrAlbumsList[sender.tag]

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
        popVC.strAlbumImage = "\(objData.image ?? "")"
        popVC.indexRecommended = sender.tag
        popVC.strTYPE = "Albume"
        popVC.strAlbumeId = objData.id ?? 0
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
}


//MARK: - Collection View -

class MenuCollectionCell: UICollectionViewCell {
    @IBOutlet weak var viewSelect: UIView!
    @IBOutlet weak var lblName: UILabel!
}



class AlbumsCell: UICollectionViewCell {
    @IBOutlet weak var imgAlbums: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
}


class AlbumsTrackCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
}


extension AlbumeViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.accessibilityIdentifier == "Track"{
            return self.arrAlbumsList[collectionView.tag].arrTracks.count
        }
        else if collectionView.accessibilityIdentifier == str.strSimilarArtists{
            return self.arrArtistList.count
        }
        else if collectionView.accessibilityIdentifier == str.strAbout{
            return self.arrAboutURL.count
        }
        else{
            return collectionView == objCollectionMenu ? arrMenu.count : self.arrAlbumsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.accessibilityIdentifier == "Track"{
            return CGSize(width: collectionView.frame.size.width , height: manageWidth(size: 60))
        }
        else if collectionView.accessibilityIdentifier == str.strSimilarArtists{
            return CGSize(width: (collectionView.frame.size.width - 60) / 2 , height: ((collectionView.frame.size.width - 60) / 2) + manageWidth(size: 55))
        }
        else if collectionView.accessibilityIdentifier == str.strAbout{
            return CGSize(width: (collectionView.frame.size.width - 60) / 2.3 , height: manageWidth(size: 250))
        }
        else{
            if collectionView == objCollectionMenu{
                let label = UILabel(frame: CGRect.zero)
                label.text = arrMenu[indexPath.row]
                label.sizeToFit()
                
                var width : CGFloat = 0
                width = label.frame.width + 30
                if label.frame.width < 50{
                    width = label.frame.width + 40
                }
                return CGSize(width: width , height: collectionView.frame.size.height)

            }
            else{
                return CGSize(width: (collectionView.frame.size.width - 60) / 2 , height: ((collectionView.frame.size.width - 60) / 2) + manageWidth(size: 80))
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.accessibilityIdentifier == "Track"{
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsTrackCell", for: indexPath) as! AlbumsTrackCell
            cell.backgroundColor = UIColor.clear
      
            //SET BUTTON
            buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())
            
            //GET DATA
            let objData = self.arrAlbumsList[collectionView.tag].arrTracks[indexPath.row]
            
            //SET DETAILS
            cell.lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Medium, fontSize: 14.0, text: objData.name ?? "")

            
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
            
            cell.lblSubTitle.configureLable(textColor: setTextColour(), fontName:  GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: strArtist)
                        
            //SET BUTTON ACTION
            cell.btnMore.accessibilityIdentifier = "\(collectionView.tag)"
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(self.btnTrack2MenuClicked(_:)), for: .touchUpInside)
                
            //CHECK THIS TRACK IS PLAYING
            if isMusicPlayNow{
                if CurrentPlayTrackID == objData.id{
                    cell.lblTitle.textColor = UIColor.standard
                    cell.lblSubTitle.textColor = UIColor.standard
                }
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        else if collectionView.accessibilityIdentifier == str.strSimilarArtists{
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresListCell", for: indexPath) as! GenresListCell
            cell.backgroundColor = UIColor.clear
            cell.imgVideo.viewCorneRadius(radius: 5.0, isRound: false)

            let obj = self.arrArtistList[indexPath.row]
            cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: obj.name?.capitalizingFirstLetter() ?? "")
            
            cell.lblSubTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: "" )

            
            //SET IMAGE
            cell.con_ImgHeight.constant = (collectionView.frame.size.width - 60) / 2
            cell.imgVideo.backgroundColor = UIColor.grayLight
            if let strImg = obj.image_small{
                let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                    Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
                }
            }
            
            cell.layoutIfNeeded()
            return cell

        }
        else if collectionView.accessibilityIdentifier == str.strAbout{
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresListCell", for: indexPath) as! GenresListCell
            cell.backgroundColor = UIColor.clear
            cell.imgVideo.viewCorneRadius(radius: 5.0, isRound: false)
            
            let obj = self.arrAboutURL[indexPath.row]
            
            //SET IMAGE
            cell.imgVideo.backgroundColor = UIColor.grayLight
            if obj != ""{
                let imgURL =  ("\(obj)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                    Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
                }
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        else{
            
            if collectionView == objCollectionMenu{
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionCell", for: indexPath) as! MenuCollectionCell
                cell.backgroundColor = UIColor.clear
                
                //SET FONT
                cell.lblName.configureLable(textColor: UIColor.gray, fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: arrMenu[indexPath.row])
                
                //SET VIEW
                cell.viewSelect.backgroundColor = .clear

                
                //CHECK SELECT TAG
                if SelectTag == arrMenu[indexPath.row]{
                    cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: arrMenu[indexPath.row])

                    //SET VIEW
                    cell.viewSelect.backgroundColor = UIColor.standard
                    
                }
                
                cell.layoutIfNeeded()
                return cell
            }
            else{
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresListCell", for: indexPath) as! GenresListCell
                cell.backgroundColor = UIColor.clear
                cell.imgVideo.viewCorneRadius(radius: 5.0, isRound: false)

                let obj = self.arrAlbumsList[indexPath.row]
                cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16.0, text: obj.name?.capitalizingFirstLetter() ?? "")
                
                //GET ARTIST NAME
                var strArtist : String = ""
                for obj in obj.arrArtists{
                    if strArtist == ""{
                        strArtist = obj.name ?? ""
                    }
                    else{
                        strArtist = "\(strArtist), \(obj.name ?? "")"
                    }
                }
                
                cell.lblSubTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: strArtist.capitalizingFirstLetter() )

                
                //SET IMAGE
                cell.con_ImgHeight.constant = (collectionView.frame.size.width - 60) / 2
                cell.imgVideo.backgroundColor = UIColor.grayLight
                if let strImg = obj.image{
                    let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                    if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                        Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
                    }
                }
                
                cell.layoutIfNeeded()
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == objCollectionMenu{
            //SELECT TAG and RELOAD
            SelectTag = arrMenu[indexPath.row]
            objCollectionMenu.reloadData()
            tblView.reloadData()
        }
        else if collectionView.accessibilityIdentifier == str.strSimilarArtists{
            //MOVE ARTISTS SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeViewController") as? AlbumeViewController{
                newViewController.strArtistsID = self.arrArtistList[indexPath.row].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if collectionView.accessibilityIdentifier == "Albums"{
            
        }
        
        
        
        else if collectionView.accessibilityIdentifier == "Track"{
            if indexPath.section == 0{
                let objData = self.arrAlbumsList[collectionView.tag].arrTracks[indexPath.row]

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
        }
    }
    
    
    
    @objc func btnTrack2MenuClicked(_ sender: UIButton) {
        //GET DATA
        let strSection : Int = Int(sender.accessibilityIdentifier ?? "") ?? 0
        let objData = self.arrAlbumsList[strSection].arrTracks[sender.tag]

//        let objData = self.arrTrackList[sender.tag]

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
        popVC.strAlbumImage = "\(self.arrAlbumsList[strSection].image ?? "")"
        popVC.indexRecommended = sender.tag
        popVC.sectionRecommended = strSection
        popVC.strTYPE = "Track_2"
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
