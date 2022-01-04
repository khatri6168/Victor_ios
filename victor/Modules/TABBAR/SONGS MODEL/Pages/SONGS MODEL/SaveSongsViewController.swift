//
//  SaveSongsViewController.swift
//  victor
//
//  Created by Jigar Khatri on 18/11/21.
//

import UIKit

class SaveSongsViewController: UIViewController {

    //DECLARE VARIABLE
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewBG: UIView!

    @IBOutlet weak var lblHeader: UILabel!

    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var viewLine: UIView!

    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!

    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    
    var arrSaveSongs : [RadioModel] = []
    var arrSearchSaveSongs : [RadioModel] = []
    var isLoading : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)

        // Do any additional setup after loading the view.
        
        //SET NODATA
        self.emptyDataView.noSaveSongs()
        self.emptyDataView.isHidden = true
        self.viewLine.isHidden = false

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SET VIEW
        self.view.backgroundColor = setColour()
        
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.tabBarController?.tabBar.isHidden = false
        
        
        //SET VIEW AND FONT
        self.setTheFont()
        self.setTheView()

        //GET DATA
        self.getSaveTrackListAPI()
        
    }
 
    @objc private func updatePlayer(){
        self.tblView.reloadData()
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
        self.lblHeader.text = "\(str.strSongTitle)"
        if self.arrSaveSongs.count != 0{
            self.viewPlay.isHidden = false
            self.lblHeader.text = "\(self.arrSaveSongs.count) \(str.strSongTitle)"
        }
    }
    
    func setTheFont(){
        //SET FONT
        lblHeader.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: "\(str.strSongTitle)")
        
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
        self.arrSearchSaveSongs = []
        self.arrSearchSaveSongs = arrSaveSongs.filter { Int((($0.name?.lowercased()) as NSString?)?.range(of: strSearch.lowercased()).location ?? 0) != NSNotFound}

        //RELOAD TABLE
        self.tblView.reloadData()
        self.emptyDataView.isHidden = true
        self.viewLine.isHidden = false
        if txtSearch.text != ""{
            if arrSearchSaveSongs.count == 0{
                self.emptyDataView.isHidden = false
                self.viewLine.isHidden = true
            }
        }
        
    }
}



extension SaveSongsViewController:  UITextFieldDelegate {
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


//MARK: - BUTTON ACTION
extension SaveSongsViewController {
    @IBAction func btnPlayClicked(_ sender: UIButton) {
        playerVideo = nil
        playerVideo?.pause()
        indexPlayMusic = 0
        CurrentPlayTrackID = 0
        self.tblView.reloadData()
        
        //ADD DATA
        arrMusicPlayList = []
        if txtSearch.text != ""{
            arrMusicPlayList = self.arrSearchSaveSongs

        }else{
            arrMusicPlayList = self.arrSaveSongs
        }
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
}


//.......................... UITABLE VIEW ..........................//


//MARK: -- UITABEL DELEGATE --
extension SaveSongsViewController : UITableViewDelegate, UITableViewDataSource ,MenuProtocol, UIPopoverPresentationControllerDelegate{
    
    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading && UserDefaults.standard.user != nil{
            return 10
        }
        else{
            if txtSearch.text != ""{
                return self.arrSearchSaveSongs.count
            }
            else{
                return self.arrSaveSongs.count
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
        
        //SET BUTTON
        buttonImageColor(btnImage: cell.btnMore, imageName: "icon_more", colorHex: setTextColour())
        
        //GET DATA
        if self.arrSaveSongs.count != 0{
            
            //GET DATA
            let objData : RadioModel!
            if txtSearch.text != ""{
                objData = self.arrSearchSaveSongs[indexPath.row]
            }else{
                objData = self.arrSaveSongs[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData : RadioModel!
        if txtSearch.text != ""{
            objData = self.arrSearchSaveSongs[indexPath.row]
        }else{
            objData = self.arrSaveSongs[indexPath.row]
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
    @objc func btnMenuClicked(_ sender: UIButton) {
        //GET DATA
        let objData : RadioModel!
        if txtSearch.text != ""{
            objData = self.arrSearchSaveSongs[sender.tag]
        }else{
            objData = self.arrSaveSongs[sender.tag]
        }
           
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
                newViewController.strArtistsID = self.arrSaveSongs[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strTrackRadio{
            //GO TO TRACK RADIO
            //MOVE RADIO SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                newViewController.isRadioTrack = "Track"
                newViewController.strRadioID = self.arrSaveSongs[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
            //ADD OR REMOVE TRACK IN PLAYLIST
            if strType == "Track"{
                let objData : RadioModel!
                if txtSearch.text != ""{
                    objData = self.arrSearchSaveSongs[popUpIndex]
                }else{
                    objData = self.arrSaveSongs[popUpIndex]
                }
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
        else if strSelectIndex == str.strRemoveMusic || strSelectIndex == str.strSaveMusic{
//            let objData : RadioModel!
//            if txtSearch.text != ""{
//                objData = self.arrSearchSaveSongs[popUpIndex]
//            }else{
//                objData = self.arrSaveSongs[popUpIndex]
//            }
//            let strID = objData.id ?? 0
//
//
//            self.AddOrRemoveTrackAPI(TrackAddRemoveParameater: TrackAddRemoveParameater(likeables: [LikeablesParameater(likeable_id: "\(strID)", likeable_type: "track")], _method: strSelectIndex == str.strSaveMusic ? "" : "DELETE"), isRemove: strSelectIndex == str.strSaveMusic ? false : true)

        }
    }
}
