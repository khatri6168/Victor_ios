//
//  TabbarViewController.swift
//  Belboy
//
//  Created by Jigar Khatri on 30/04/21.
//

import UIKit
//import AudioTabBarController
import youtube_ios_player_helper
import ObjectMapper
import GoogleMobileAds

class TabbarViewController: UITabBarController, UITabBarControllerDelegate, AccountProtocol, GetMorePROTOCOL, GADFullScreenContentDelegate{

    
    
    var loginNavigation: UINavigationController!
    private var tabbarBottomConstraint: NSLayoutConstraint?
    var isOpneFullScreen : Bool = false
    var isLoading : Bool = false
    var isDownloadURL : Bool = false
    
    //ADS
    var rewardedAd: GADRewardedAd?

    private lazy var musicView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = setColour()
        view.clipsToBounds = true
        view.layer.cornerRadius = 0
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    
    var _isOpen = false {
        didSet {
            view.layoutIfNeeded()
            let height = _isOpen ? -tabBar.frame.size.height : tabBar.frame.size.height + manageWidth(size: 50)
            UIView.animate(withDuration: 0.5) {
                self.tabbarBottomConstraint?.constant = CGFloat(height)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.addItemInCart(notificatio:)), name: .cartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageUpdated(notificatio:)), name: .languageUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageUpdated(notificatio:)), name: .colourMode, object: nil)
        
        //VIDEO NOTIFICAITON
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayer), name: .videoPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.autoPlayNextMusic), name: .autoPlayNextMusic, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnNextClicked(_:)), name: .PlayNextMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnPreviousClicked(_:)), name: .PlayPreviousMusic, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnPlayClicked(_:)), name: .PlayPlayMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setTabBarDetails), name: .SetTabBarDetails, object: nil)
        
        
        configureTabBar()
        
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
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = _isOpen ? -tabBar.frame.size.height : tabBar.frame.size.height + manageWidth(size: 50)
        tabbarBottomConstraint?.constant = CGFloat(height)
    }
    
    
    func selectMusicBar(){
        _isOpen = isAdsShowing ? true : (arrMusicPlayList.count == 0 ? false : true)
    }
    
    @objc func setTabBarDetails(){
        self.setTheTabBarView()
        self.playMusic()
        if _isOpen == false || arrMusicPlayList.count == 0 || arrMusicPlayList.count == 1{
            selectMusicBar()
        }
        NotificationCenter.default.post(name: .videoPlay, object: nil, userInfo: nil)
    }
    
    func setupView() {
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            NSLayoutConstraint.activate([
                self.musicView.heightAnchor.constraint(equalToConstant: manageWidth(size: 120)),
                self.musicView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                self.musicView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                self.tabbarBottomConstraint!
            ])
        }
    }
    
    
    func setTheMusicBarView(viewBg : UIView){
        
        //SET ADDS BUTTONS
        let buttonPoint = UIButton()
        buttonPoint.backgroundColor = UIColor.blue
        buttonPoint.heightAnchor.constraint(equalToConstant: manageWidth(size: 40)).isActive = true
        buttonPoint.widthAnchor.constraint(equalToConstant: manageWidth(size: 160)).isActive = true
        
        let strCoint : String = "\(UserDefaults.standard.getCoine ?? "")"
        buttonPoint.configureLable(bgColour: UIColor.clear, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: "\(str.coins) \(strCoint == "" ? "0" : strCoint)")
        buttonPoint.btnnBorder(bgColour: .primary)
        buttonPoint.btnCorneRadius(radius: 5, isRound: false)
//        buttonPoint.addTarget(self, action: #selector(btnOpneMusicClicked(_:)), for: .touchUpInside)

        
        //Text Label
        let buttonGetPoint = UIButton()
        buttonGetPoint.backgroundColor = UIColor.yellow
        buttonGetPoint.heightAnchor.constraint(equalToConstant: manageWidth(size: 40)).isActive = true
        buttonGetPoint.widthAnchor.constraint(equalToConstant: manageWidth(size: 160)).isActive = true
        
        buttonGetPoint.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.getMoreCoine)
        buttonGetPoint.btnnBorder(bgColour: .primary)
        buttonGetPoint.btnCorneRadius(radius: 5, isRound: false)
        buttonGetPoint.addTarget(self, action: #selector(btnGetMoreClicked(_:)), for: .touchUpInside)

        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = .horizontal
        stackView.distribution  = .fillEqually
        stackView.alignment = .center
        stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(buttonPoint)
        stackView.addArrangedSubview(buttonGetPoint)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        if arrMusicPlayList.count != 0{
            viewBg.backgroundColor = setColour()
            let viewTopLine = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 1))
            viewTopLine.backgroundColor = UIColor.grayLight
            viewBg.addSubview(viewTopLine)
            
            let viewButtomLine = UIView(frame: CGRect(x: 0, y: 69, width: 500, height: 1))
            viewButtomLine.backgroundColor = UIColor.grayLight
            viewBg.addSubview(viewButtomLine)
            
            print(viewButtomLine.frame)
            let viewAddsView = UIView(frame: CGRect(x: 0, y: viewButtomLine.frame.origin.y + 1 ,    width: viewBg.frame.size.width, height: manageWidth(size: 50.0)))
            viewAddsView.backgroundColor = UIColor.clear
            viewBg.addSubview(viewAddsView)
            
            
            
            let imgTop = UIImageView(frame: CGRect(x: 25, y: 25, width: 20, height: 20))
            imgTop.image = UIImage(named: "icon_up")
            imgTop.contentMode = .scaleAspectFit
            imgColor(imgColor: imgTop, colorHex: setTextColour())
            
            //BUTON TOP
            let btnTOP:UIButton = UIButton(frame: CGRect(x: imgTop.frame.origin.x - 15, y: imgTop.frame.origin.y - 15, width: 50, height: 50))
            btnTOP.backgroundColor = UIColor.clear
            btnTOP.addTarget(self, action: #selector(btnOpneMusicClicked(_:)), for: .touchUpInside)
            viewBg.addSubview(btnTOP)
            
            
            //BUTON NEXT
            let buttonNext:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 50, y: 20, width: 30, height: 30))
            buttonNext.backgroundColor = UIColor.clear
            buttonNext.setImage(UIImage(named: "icon_BarplayNext"), for: .normal)
            buttonImageColor(btnImage: buttonNext, imageName: "icon_BarplayNext", colorHex: setTextColour())
            buttonNext.addTarget(self, action: #selector(btnNextClicked(_:)), for: .touchUpInside)
            buttonNext.isEnabled = true
            if indexPlayMusic == arrMusicPlayList.count - 1 || isLoading{
                buttonNext.isEnabled = false
            }
            viewBg.addSubview(buttonNext)
            
            
            //BUTON PLAY
            let buttonPlay:UIButton = UIButton(frame: CGRect(x: buttonNext.frame.origin.x - 35, y: 20, width: 30, height: 30))
            buttonPlay.backgroundColor = UIColor.clear
            buttonPlay.setImage(UIImage(named: isMusicPlayNow ? "icon_Barpush" : "icon_Barplay"), for: .normal)
            buttonImageColor(btnImage: buttonPlay, imageName: isMusicPlayNow ? "icon_Barpush" : "icon_Barplay", colorHex: setTextColour())
            buttonPlay.addTarget(self, action: #selector(btnPlayClicked(_:)), for: .touchUpInside)
            buttonPlay.removeFromSuperview()
            if isLoading == false{
                viewBg.addSubview(buttonPlay)
            }
            
            //SET INDICATOR
            let objLoading:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: buttonPlay.frame.origin.x, y: buttonPlay.frame.origin.y, width: buttonPlay.frame.size.width, height: buttonPlay.frame.size.height))
            objLoading.color = UIColor.standard
            objLoading.isHidden = !isLoading
            if isLoading{
                objLoading.startAnimating()
            }
            else{
                objLoading.stopAnimating()
            }
            viewBg.addSubview(objLoading)
            
            //CALL
            let userInfo = [ "isLoading" : isLoading ]
            NotificationCenter.default.post(name: .PlayerDetails, object: nil, userInfo: userInfo)
            
            
            //BUTON PREVIOUS
            let buttonPrevious:UIButton = UIButton(frame: CGRect(x: buttonPlay.frame.origin.x - 35, y: 20, width: 30, height: 30))
            buttonPrevious.backgroundColor = UIColor.clear
            buttonPrevious.setImage(UIImage(named: "icon_BarplayPrevious"), for: .normal)
            buttonImageColor(btnImage: buttonPrevious, imageName: "icon_BarplayPrevious", colorHex: setTextColour())
            buttonPrevious.addTarget(self, action: #selector(btnPreviousClicked(_:)), for: .touchUpInside)
            buttonPrevious.isEnabled = true
            if indexPlayMusic == 0 || isLoading{
                buttonPrevious.isEnabled = false
            }
            viewBg.addSubview(buttonPrevious)
            
            
            //SET TITLE
            let lblTitle = UILabel(frame: CGRect(x: btnTOP.frame.size.width + 20, y: 10, width: (buttonPrevious.frame.origin.x - 20) - (btnTOP.frame.origin.x + btnTOP.frame.size.width), height: 30))
            lblTitle.textAlignment = .center
            lblTitle.backgroundColor = .clear
            lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 12.0, text: "")
            viewBg.addSubview(lblTitle)
            
            
            
            let lblSubTitle = UILabel(frame: CGRect(x: lblTitle.frame.origin.x, y: lblTitle.frame.size.height + 8, width: lblTitle.frame.size.width, height: 30))
            lblSubTitle.textAlignment = .center
            lblSubTitle.backgroundColor = .clear
            lblSubTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: "")
            viewBg.addSubview(lblSubTitle)
            
            if arrMusicPlayList.count != 0{
                let objData = arrMusicPlayList[indexPlayMusic]
                //GET ARTIST NAME
                var strArtist : String = ""
                if objData.downloadPlayURL != ""{
                    strArtist = "\(objData.artistsName)"
                }
                else{
                    for obj in objData.arrArtists{
                        if strArtist == ""{
                            strArtist = obj.name ?? ""
                        }
                        else{
                            strArtist = "\(strArtist), \(obj.name ?? "")"
                        }
                    }
                }
                
                
                //SET DATA
                lblTitle.text = objData.name ?? ""
                lblSubTitle.text = strArtist
            }
           
            viewBg.addSubview(imgTop)
            
            
            //ADD ADSD VIEW
            if isAdsShowing{
                
                viewBg.addSubview(stackView)
                
                //Constraints
                stackView.centerXAnchor.constraint(equalTo: viewAddsView.centerXAnchor).isActive = true
                stackView.centerYAnchor.constraint(equalTo: viewAddsView.centerYAnchor).isActive = true
            }
        }
        else{
            viewBg.backgroundColor = UIColor.clear
            let viewAddsView = UIView(frame: CGRect(x: 0, y: manageWidth(size: 70) ,width: viewBg.frame.size.width, height: manageWidth(size: 50.0)))
            viewAddsView.backgroundColor = setColour()

            viewBg.addSubview(viewAddsView)

            
            
            viewBg.addSubview(stackView)
            
            //Constraints
            stackView.centerXAnchor.constraint(equalTo: viewAddsView.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: viewAddsView.centerYAnchor).isActive = true
            
        }
    }
    
    func playMusic(){
        //PLAY MUSIC
        if isMusicPlayNow{
            playerVideo = nil
            playerVideo?.pause()
            
            let objData = arrMusicPlayList[indexPlayMusic]
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
            
            //PLAY VIDEO
            CurrentPlayTrackID = objData.id ?? 0
            
            if objData.downloadPlayURL == ""{
                isLoading = true

                if objData.videoPlayURL != ""{
                    GlobalConstants.appDelegate?.playVideo(url: URL(string: objData.videoPlayURL)!)
                }
                else if objData.youtubID == ""{
                    //SEARCH YOUTUB ID
                    var strName = "\(strArtist)/\(objData.name ?? "")"
                    strName = strName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    self.searchVideoID(strID: objData.id ?? 0, strName: strName)
                }
                else{
                    var objData : RadioModel!
                    let map = Map(mappingType: .fromJSON, JSON: [:])
                    objData = RadioModel(map: map)
                    
                    GlobalConstants.appDelegate?.extractInfo(url: URL(string: "\(Url.youtubeURL.absoluteString!)\(objData.youtubID )")!, objData: objData!)
                }
            }else{
                isDownloadURL = true
                isLoading = false
                GlobalConstants.appDelegate?.playLocalVideo(strLocalURL: "\(objData.downloadPlayURL)", strSongName: objData.name ?? Application.appName)
            }
            
            //SET LOADING
            self.setTheTabBarView()
        }
    }
    
    
    @objc func btnGetMoreClicked(_ sender: UIButton){
        //POPUP
        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        let cartView = GetMore(frame: CGRect(x: 0, y: 0 ,width : window.frame.width, height: window.frame.height))
        cartView.delegate = self
        cartView.loadPopUpView()
        window.addSubview(cartView)
    }
    
    func selectGetCoine() {
        
        if let ad = rewardedAd {
          ad.present(fromRootViewController: self) {
            let reward = ad.adReward
            print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            self.earnCoins(NSInteger(truncating: reward.amount))
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
    
    
    fileprivate func earnCoins(_ coins: Int) {
        let strCoin = UserDefaults.standard.getCoine
        var getCoin = Int(strCoin ?? "") ?? 0
        
        getCoin = getCoin + coins
        
        //UPDATE COINT
        UserDefaults.standard.getCoine = "\(getCoin)"
        self.setTheTabBarView()

    }
    
    
    @objc func btnOpneMusicClicked(_ sender: UIButton){
        print("open")
        //        if isOpneFullScreen{
        //            isOpneFullScreen = false
        //        }
        //        else{
        //            isOpneFullScreen =  true
        //        }
        //        GlobalConstants.appDelegate?.playerView()
        
        let ViewController = getTopViewController!
        
        if arrMusicPlayList.count != 0{
            //PLAYER SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.PLAYER_MODEL, bundle: nil)
            if let navView = storyBoard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
                let vieweNavigationController = UINavigationController(rootViewController: navView)
                ViewController.present(vieweNavigationController, animated: true) {
                    let userInfo = [ "isLoading" : self.isLoading ]
                    NotificationCenter.default.post(name: .PlayerDetails, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    
    @objc func autoPlayNextMusic(){
        playerVideo = nil
        if indexPlayMusic != arrMusicPlayList.count - 1 {
            indexPlayMusic = indexPlayMusic + 1
            playMusic()
        }
        else{
            isMusicPlayNow = false
            playerVideo?.pause()
            
            //SET LOADING
            isLoading = false
            self.setTheTabBarView()
        }
        
    }
    @objc func btnNextClicked(_ sender: UIButton){
        print("Next")
        playerVideo = nil
        indexPlayMusic = indexPlayMusic + 1
        playMusic()
        self.setTheTabBarView()
    }
    
    @objc func btnPlayClicked(_ sender: UIButton){
        print("Play")
        if isLoading{
            return
        }
        
        if isDownloadURL{
            isLoading = false
        }
        else{
            isLoading = true
        }
        
        if isMusicPlayNow{
            isMusicPlayNow = false
            playerVideo?.pause()
        }
        else{
            isMusicPlayNow = true
            if playerVideo == nil{
                self.playMusic()
            }
            else{
                playerVideo?.play()
            }
        }
        self.setTheTabBarView()
    }
    
    @objc func btnPreviousClicked(_ sender: UIButton){
        print("Previous")
        playerVideo = nil
        indexPlayMusic = indexPlayMusic - 1
        self.playMusic()
        self.setTheTabBarView()
    }
    
    func setTheTabBarView(){
        
        //SET MUSIC VIEW
        for locView in musicView.subviews {
            print(locView)
            locView.removeFromSuperview()
            
        }
        
        //SET MANIN VIEW
        musicView.backgroundColor = setColour()
        self.setupView()
        self.setTheMusicBarView(viewBg: musicView)
        
        musicView.removeFromSuperview()
        view.addSubview(musicView)
        tabbarBottomConstraint = musicView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
    }
    
    fileprivate func configureTabBar() {
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Regular, size: 12.0)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: SetTheFont(fontName: GlobalConstants.APP_FONT_Regular, size: 12.0)], for: .selected)
        
        tabBar.sizeToFit()
        tabBar.barTintColor = setTextColour()
        tabBar.tintColor = setTextColour()
        tabBar.unselectedItemTintColor = setTextColour()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = setColour()
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        
        self.delegate = self
        
        var controller:[UINavigationController] = []
        
        //HOME TABBAR
        let storyBoardHome: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let tabOne = storyBoardHome.instantiateViewController(withIdentifier: "GenresViewController") as? GenresViewController {
            
            
            
            let item = UITabBarItem()
            item.title = str.genres
            let imgView : UIImageView =  UIImageView(image: UIImage(named: "icon_genres")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            item.image = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.selectedImage = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.imageInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            if safeAreaInset.bottom == 0{
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
            }
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            //                guard let view = item.value(forKey: "view") as? UIView,
            //                      let label = (view.subviews.compactMap{ $0 as? UILabel }).first else { return }
            //
            //                label.numberOfLines = 2
            //                label.textAlignment = .center
            //                label.text = "as \n asdfasdfasdf"
            //                print(label.frame)
            ////                item.imageInsets = UIEdgeInsets(top: -50, left: 0, bottom: -5, right: 0)
            //                label.frame = CGRect(x: label.frame.minX, y: label.frame.minY, width: 100, height: 24)
            //
            //            }
            
            
            
            tabOne.tabBarItem = item
            
            let navigationController = UINavigationController(rootViewController: tabOne)
            navigationController.view.backgroundColor = setColour()
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = self
            controller.append(navigationController)
        }
        
        //SERIES TABBAR
        let storySeries: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let tabTwo = storySeries.instantiateViewController(withIdentifier: "Top50ViewController") as? Top50ViewController {
            
            let item = UITabBarItem()
            item.title = str.top50
            let imgView : UIImageView =  UIImageView(image: UIImage(named: "icon_top50")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            item.image = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.selectedImage = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            if safeAreaInset.bottom == 0{
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
            }
            
            tabTwo.tabBarItem = item
            
            let navigationController = UINavigationController(rootViewController: tabTwo)
            navigationController.view.backgroundColor = setColour()
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = self
            controller.append(navigationController)
        }
        
        //MOVIES TABBAR
        if UserDefaults.standard.user != nil{
            let storyMovies: UIStoryboard = UIStoryboard(name: GlobalConstants.SEARCH_MODEL, bundle: nil)
            if let tabTwo = storyMovies.instantiateViewController(withIdentifier: "DownloadViewController") as? DownloadViewController {
                
                let item = UITabBarItem()
                item.title = str.download
                let imgView : UIImageView =  UIImageView(image: UIImage(named: "icon_download")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
                item.image = imgTabColor(imgColor: imgView, colorHex: setColour()).image
                item.selectedImage = imgTabColor(imgColor: imgView, colorHex: setColour()).image
                item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                
                if safeAreaInset.bottom == 0{
                    item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
                }
                
                tabTwo.tabBarItem = item
                
                let navigationController = UINavigationController(rootViewController: tabTwo)
                navigationController.view.backgroundColor = setColour()
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = self
                controller.append(navigationController)
            }
        }
        
        
        
        //HELLO WEEKEND TABBAR
        let storyBoardCart: UIStoryboard = UIStoryboard(name: GlobalConstants.SONG_MODEL, bundle: nil)
        if let tabThree = storyBoardCart.instantiateViewController(withIdentifier: "SongsViewController") as? SongsViewController {
            
            let item = UITabBarItem()
            item.title = str.songs
            let imgView : UIImageView =  UIImageView(image: UIImage(named: "icon_music")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            item.image = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.selectedImage = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.imageInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            if safeAreaInset.bottom == 0{
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
            }
            tabThree.tabBarItem = item
            
            let navigationController = UINavigationController(rootViewController: tabThree)
            navigationController.view.backgroundColor = setColour()
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = self
            controller.append(navigationController)
        }
        
        
        //MY_ACCOUNT TABBAR
        let storyMyAccount: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let tabFour = storyMyAccount.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
            
            let item = UITabBarItem()
            item.tag = 4
            item.title = str.account
            let imgView : UIImageView =  UIImageView(image: UIImage(named: "icon_user")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
            item.image = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            item.selectedImage = imgTabColor(imgColor: imgView, colorHex: setColour()).image
            
            item.imageInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            if safeAreaInset.bottom == 0{
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
            }
            tabFour.tabBarItem = item
            
            let navigationController = UINavigationController(rootViewController: tabFour)
            navigationController.view.backgroundColor = setColour()
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = self
            controller.append(navigationController)
        }
        viewControllers = controller
    }
    
    
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setupKeyboard(true)
        //SET PHONE VIBRATE
        ImpactGenerator()
        storeLoading()
        
        if item.tag == 4{
            print("select")
            
            //CUSTOME LIST
            let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            view.delegate = self
            view.view.backgroundColor = UIColor.clear
            view.modalPresentationStyle = .overCurrentContext
            self.present(view, animated: false) {
                view.view.backgroundColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.5)
            }
        }
    }
    
    func selectIndex(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            let ViewController = getTopViewController!
            
            if UserDefaults.standard.user == nil{
                if index == 0{
                    //MOVE TO LOGIN SCREEN
                    let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
                    if let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController{
                        self.loginNavigation = UINavigationController(rootViewController: newViewController)
                        self.loginNavigation.modalPresentationStyle = .fullScreen
                        ViewController.present(self.loginNavigation, animated: true, completion: nil)
                    }
                }
                else if index == 1{
                    //MOVE TO REGISTER SCREEN
                    let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
                    if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController{
                        newViewController.isLoginScreen = false
                        self.loginNavigation = UINavigationController(rootViewController: newViewController)
                        self.loginNavigation.modalPresentationStyle = .fullScreen
                        ViewController.present(self.loginNavigation, animated: true, completion: nil)
                    }
                }
            }
            else{
                if index == 1{
                    //NOTIFICATION VIEW
                    
                }
                else if index == 2{
                    //ACCTOUNT SETTING
                    let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                    if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AccountSettingViewController") as? AccountSettingViewController{
                        self.loginNavigation = UINavigationController(rootViewController: newViewController)
                        self.loginNavigation.modalPresentationStyle = .fullScreen
                        ViewController.present(self.loginNavigation, animated: true, completion: nil)
                    }
                }
                else if index == 3{
                    //CHANGE MODE
                    if UserDefaults.standard.colourMode == "dark"{
                        UserDefaults.standard.colourMode = "light"
                    }
                    else{
                        UserDefaults.standard.colourMode = "dark"
                    }
                    NotificationCenter.default.post(name: .colourMode, object: nil, userInfo: nil)
                    
                }
                else if index == 4{
                    //LOG OUT
                    let alert = UIAlertController(title: Application.appName, message: str.areYouSureYouWantToLogout, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: str.yes, style: .default,handler: { (Action) in
                        //REMOVE ALL DATA
                        clearCache()
                        UserDefaults.standard.user = nil
                        UserDefaults.standard.userRemeber = nil
                        NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
                    }))
                    alert.addAction(UIAlertAction(title: str.no, style: .cancel, handler: nil))
                    GlobalConstants.appDelegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
}


extension TabbarViewController{
    
    @objc private func languageUpdated(notificatio: NSNotification?){
        configureTabBar()
    }
    
    @objc private func updatePlayer(){
        if playerVideo != nil{
            isLoading = false
            self.setTheTabBarView()
        }
    }
}

extension TabbarViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}





struct YouTubParameater: Codable {
    var key: String = Application.googleApiKey
    var part: String = "snippet,contentDetails,statistics,status"
}
extension TabbarViewController:WebServiceHelperDelegate{
    
    func searchVideoID(strID : Int, strName : String){
        
        //Declaration URL
        let strURL = "\(Url.searchYoutubID.absoluteString!)/\(strID)/\(strName)"
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "searchYoutubID"
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
    
    func getYouTubPlayerDetailsAPI(YouTubParameater:YouTubParameater, videoID : String){
        guard let parameater = try? YouTubParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        let strURL = "\(Url.viewDetails.absoluteString!)\(videoID)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "viewDetails"
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
        if strRequest == "viewDetails"{
            if let arrItems = data["items"] as? NSArray{
                if let obj = arrItems[0] as? NSDictionary{
                    if let objSnippet = obj["snippet"] as? NSDictionary{
                        if let objThumbnails = objSnippet["thumbnails"] as? NSDictionary{
                            
                            //GET IMAGE
                            var strVideoImage : String = ""
                            if let objStandard = objThumbnails["standard"] as? NSDictionary{
                                strVideoImage = objStandard.getStringForID(key: "url")
                            }
                            else if let objMedium = objThumbnails["medium"] as? NSDictionary{
                                strVideoImage = objMedium.getStringForID(key: "url")
                            }
                            else if let objMaxres = objThumbnails["maxres"] as? NSDictionary{
                                strVideoImage = objMaxres.getStringForID(key: "url")
                            }
                            else if let objHigh = objThumbnails["high"] as? NSDictionary{
                                strVideoImage = objHigh.getStringForID(key: "url")
                            }
                            else if let objDefault = objThumbnails["default"] as? NSDictionary{
                                strVideoImage = objDefault.getStringForID(key: "url")
                            }
                            
                            //UPDATE YOUTUB ID
                            let MenuID = arrMusicPlayList.map{$0.id}
                            if let index = MenuID.firstIndex(of: CurrentPlayTrackID){
                                var objData = arrMusicPlayList[index]
                                objData.videoImage = strVideoImage
                                
                                //SET NEW OBJECT
                                arrMusicPlayList.remove(at: index)
                                arrMusicPlayList.insert(objData, at: index)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
        
        if strRequest == "searchYoutubID"{
            if arrData.count != 0{
                if let dicData = arrData[0] as? NSDictionary{
                    let strCurrentYoutubID = dicData.getStringForID(key: "id")
                    
                    //showAlertMessage(strMessage: strCurrentYoutubID ?? "")
                    
                    //UPDATE YOUTUB ID
                    let MenuID = arrMusicPlayList.map{$0.id}
                    if let index = MenuID.firstIndex(of: CurrentPlayTrackID){
                        var objData = arrMusicPlayList[index]
                        objData.youtubID = strCurrentYoutubID ?? ""

                        //SET NEW OBJECT
                        arrMusicPlayList.remove(at: index)
                        arrMusicPlayList.insert(objData, at: index)
                    }

                    //GET VIDEO URL
                    self.getYouTubPlayerDetailsAPI(YouTubParameater: YouTubParameater(), videoID: strCurrentYoutubID ?? "")

                    //GET URL
                    var objData : RadioModel!
                    let map = Map(mappingType: .fromJSON, JSON: [:])
                    objData = RadioModel(map: map)


                    GlobalConstants.appDelegate?.extractInfo(url: URL(string: "\(Url.youtubeURL.absoluteString!)\(strCurrentYoutubID ?? "")")!, objData: objData!)
                    
                }
            }
            else{
                self.playMusic()
//                showAlertMessage(strMessage: "\(strRequest) - \(str.somethingWentWrong)")
            }
        }
    }
    
    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
