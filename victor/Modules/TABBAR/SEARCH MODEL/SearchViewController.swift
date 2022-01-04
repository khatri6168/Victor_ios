//
//  SearchViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit
import Nuke
import GoogleMobileAds

class SearchViewController: UIViewController {

    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var objCollectionMenu: UICollectionView!

    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var objLoading: UIActivityIndicatorView!

    @IBOutlet weak var viewResult: UIView!

    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    
    var arrMenu: [String] = [str.topResults, str.strArtists, str.songs, str.strAlbums]
    var SelectTag : String = str.topResults

    var arrTrackList : [RadioModel] = []
    var arrArtistList : [ArtistsModel] = []
    var arrAlbume : [AlbumModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)

        // Do any additional setup after loading the view.
        self.setSearchView()

        DispatchQueue.main.async {
            //SET THE VIEW
            self.setTheFont()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
   
        //SET VIEW
        self.view.backgroundColor = setColour()
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
        setNavigationBarFor(controller: self, title: str.search, isTransperent: true, hideShadowImage: false, leftIcon: "icon_back", rightIcon: "") { SelectTag  in
            self.navigationController?.popViewController(animated: true)
        } rightActionHandler: {SelectTag in
        }
        
        //SET VIEW AND FONT
        self.setTheView()

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

        //SET SEARCH VIEW
        self.viewSearch.backgroundColor = .clear
        self.viewSearch.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewSearch.viewBorderCorneRadius(borderColour: .gray)
        
     
    }
    
    @objc func setSearchView(){
        //SET VIEW
        self.viewResult.isHidden = true
        self.emptyDataView.isHidden = false
        self.objLoading.isHidden = true
        self.emptyDataView.noSearchData(strTitle: str.SearchData, strDetails: str.SearchDetails)
        if txtSearch.text != ""{
            if arrTrackList.count == 0 && arrArtistList.count == 0 && arrAlbume.count == 0{
                self.emptyDataView.noSearchData(strTitle: "\(str.noSearchData) \(txtSearch.text ?? "") »", strDetails: str.noSearchDetails)

                self.viewResult.isHidden = true
                self.emptyDataView.isHidden = false
            }
            else{
                self.viewResult.isHidden = false
                self.emptyDataView.isHidden = true

            }
        }
        
        //RELAOD TABLE
        self.tblView.reloadData()
    }
    
 
    func setTheFont(){
        //SET FONT
//        lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: str.loginTitle)
//        lblEmail.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strEmail)
//        lblPassword.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: str.strPassword)
//        lblRememmber.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: str.strRemember)
//        lblFreeMusic.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 10.0, text: str.FreeMusic)
//
        
        txtSearch.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: str.searchTitle)
        txtSearch.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.txtSearch.becomeFirstResponder()
        }
        //SET SEARCH TEXT
//        txtSearch.addTarget(self, action: #selector(textFieldDidChangeSearch), for: .editingChanged)

        //SET NODATA
        self.emptyDataView.noSearchData(strTitle: str.SearchData, strDetails: str.SearchDetails)
        self.emptyDataView.isHidden = false

        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //SET TABLE HEADER
            let vw_Table = self.tblView.tableHeaderView
            vw_Table?.frame = CGRect(x: 0, y: 0, width: self.tblView.frame.size.width, height: self.objCollectionMenu.frame.origin.y + self.objCollectionMenu.frame.size.height + 20)
            self.tblView.tableHeaderView = vw_Table
        }
    }

}


extension SearchViewController:  UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTheView()
        if textField == txtSearch {
            self.viewSearch.viewBorderCorneRadius(borderColour: UIColor.standard)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTheView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)

        print(textField.text ?? "")
        textFieldDidChangeSearch(strSearch: textField.text ?? "")
        return true
    }
    
    // MARK: - UITEXTFIELD
    @objc func textFieldDidChangeSearch(strSearch : String) {
        let strSearch = strSearch.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print(strSearch)
            
        if strSearch != ""{
            self.SearchListAPI(SearchParameater: SearchParameater(query: strSearch))
        }
    }
}



//.......................... UITABLE VIEW ..........................//


//MARK: -- UITABEL DELEGATE --
extension SearchViewController : UITableViewDelegate, UITableViewDataSource ,MenuProtocol, UIPopoverPresentationControllerDelegate{

    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        if SelectTag == str.topResults{
            return 3
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        //SET HEADER HEIGHT
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.backgroundColor = setColour()
        
        //SET FONT
        cell.lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16, text:  str.strArtists)

        //SET BUTTON
        cell.btnGrid.configureLable(bgColour: UIColor.clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "(See all)")
               
        //SET BUTTON
        cell.btnGrid.addTarget(self, action: #selector(btnGridClicked(_:)), for: .touchUpInside)

        return cell
    }
    
   
    @objc func btnGridClicked(_ sender: UIButton){
        
        //RELOAD TABLE
//        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0{
            return 0
        }
        else if arrArtistList.count == 0{
            return 0
        }
        else if arrAlbume.count == 0{
            return 0
        }
        else{
            return manageWidth(size: 65.0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if SelectTag == str.topResults || SelectTag == str.songs{
                if arrTrackList.count != 0{
                    if SelectTag == str.songs{
                        return self.arrTrackList.count + 1
                    }
                    else{
                        return self.arrTrackList.count < 5 ? self.arrTrackList.count + 1 : 6
                    }
                }
                else{
                    return 0
                }
            }
            else{
                return 1
            }
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if SelectTag == str.topResults || SelectTag == str.songs{
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
                buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())
                
                //GET DATA
                if self.arrTrackList.count != 0{
                    
                    let objData : RadioModel!
                    if indexPath.row >= 5{
                        objData = self.arrTrackList[indexPath.row - 1]
                    }
                    else{
                        objData = self.arrTrackList[indexPath.row]
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
                    cell.btnMore.tag = indexPath.row
                    cell.btnMore.addTarget(self, action: #selector(self.btnMenuClicked(_:)), for: .touchUpInside)
                    
                    //CHECK THIS TRACK IS PLAYING
                    if isMusicPlayNow{
                        if CurrentPlayTrackID == objData.id{
                            cell.lblName.textColor = UIColor.standard
                            cell.lblArtists.textColor = UIColor.standard
                        }
                    }
                }
                
                cell.layoutIfNeeded()
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell") as! GenresCell
                cell.backgroundColor = UIColor.clear
                
                if SelectTag == str.strArtists{
                    cell.objCollection.tag = 1
                    cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 55)) * (CGFloat((self.arrArtistList.count + 1) / 2))
                }
                else{
                    cell.objCollection.tag = 2
                    cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 80)) * (CGFloat((self.arrAlbume.count + 1) / 2))
                }
                
                //RELOAD COLLECTION VIEW
                cell.objCollection.reloadData()
                            
                cell.layoutIfNeeded()
                return cell
            }

        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell") as! GenresCell
            cell.backgroundColor = UIColor.clear

            //SET HEADER COLLECTION VIEW
            cell.objCollection.accessibilityIdentifier = str.strSimilarArtists
            cell.objCollection.tag = indexPath.row
            
            
            
            if indexPath.section == 1{
                cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 55)) * (CGFloat(((self.arrArtistList.count < 5 ? self.arrArtistList.count : 5) + 1) / 2))
            }
            else{
                cell.con_CollectionViewHeight.constant = (((tableView.frame.size.width - 60) / 2) +  manageWidth(size: 80)) * (CGFloat(((self.arrAlbume.count < 5 ? self.arrAlbume.count : 5) + 1) / 2))
            }
            
            //RELOAD COLLECTION VIEW
            cell.objCollection.tag = indexPath.section
            cell.objCollection.reloadData()
                        
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SelectTag == str.topResults || SelectTag == str.songs{
            let objData = self.arrTrackList[indexPath.row]
            
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
    @objc func btnMenuClicked(_ sender: UIButton) {
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
                newViewController.strArtistsID = self.arrTrackList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strTrackRadio{
            //GO TO TRACK RADIO
            //MOVE RADIO SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                newViewController.isRadioTrack = "Track"
                newViewController.strRadioID = self.arrTrackList[popUpIndex].id ?? 0
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
                if arrMusicPlayList.count - 1 < indexPlayMusic{
                    indexPlayMusic = arrMusicPlayList.count - 1
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



extension SearchViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == objCollectionMenu{
            return arrMenu.count
        }
        else{
            if collectionView.tag == 1{
                if self.arrArtistList.count != 0{
                    if SelectTag == str.strArtists{
                        return self.arrArtistList.count
                    }
                    else{
                        return self.arrArtistList.count < 5 ? self.arrArtistList.count : 5
                    }
                }
                else{
                    return 0
                }
            }
            else{
                if self.arrAlbume.count != 0{
                    if SelectTag == str.strAlbums{
                        return self.arrAlbume.count
                    }
                    else{
                        return self.arrAlbume.count < 5 ? self.arrAlbume.count : 5
                    }
                }
                else{
                    return 0
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == objCollectionMenu{
            let label = UILabel(frame: CGRect.zero)
            label.text = arrMenu[indexPath.row]
            label.sizeToFit()
            
            var width : CGFloat = 0
            width = label.frame.width + 30
            if label.frame.width < 50{
                width = label.frame.width + 30
            }
            return CGSize(width: width , height: collectionView.frame.size.height)
        }
        else{
            return CGSize(width: (collectionView.frame.size.width - 60) / 2 , height: ((collectionView.frame.size.width - 60) / 2) + manageWidth(size: 80))
        }
      
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

            
            if collectionView.tag == 1{

                let obj = self.arrArtistList[indexPath.row]
                cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16.0, text: obj.name?.capitalizingFirstLetter() ?? "")
                cell.lblSubTitle.text = ""
                
                //SET IMAGE
                cell.con_ImgHeight.constant = (collectionView.frame.size.width - 60) / 2
                cell.imgVideo.backgroundColor = UIColor.grayLight
                if let strImg = obj.image_small{
                    let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                    if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                        Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
                    }
                }
            }
            else{
                
                let obj = self.arrAlbume[indexPath.row]
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
            }
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == objCollectionMenu{
            //SELECT TAG and RELOAD
            SelectTag = arrMenu[indexPath.row]
            objCollectionMenu.reloadData()
            tblView.reloadData()
        }
        else{
            if collectionView.tag == 1{
                //MOVE ARTISTS SCREEN
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeViewController") as? AlbumeViewController{
                    newViewController.strArtistsID = self.arrArtistList[indexPath.row].id ?? 0
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            else {
                //MOVE ALBUME LIST SCREEN
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeListViewController") as? AlbumeListViewController{
                    newViewController.strArtistsID = self.arrAlbume[indexPath.row].id ?? 0
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
        }
    }
}
