//
//  MusicPlayerViewController.swift
//  victor
//
//  Created by Jigar Khatri on 22/11/21.
//

import UIKit
//import youtube_ios_player_helper
//import YoutubeKit
//import YoutubeDL
import AVKit
import AVFAudio
import MMLoadingButton
import Nuke

class MusicPlayerViewController: UIViewController {

    @IBOutlet var btnPlay: MMLoadingButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnLoop: UIButton!
    @IBOutlet weak var btnRandome: UIButton!

    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblCurrentDuration: UILabel!
    @IBOutlet weak var objSlider: UISlider!

    @IBOutlet weak var objLoading: UIActivityIndicatorView!

    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var imgVideo: UIImageView!

    var isMusicPlay : Bool = false
    var isMusicLoop : Bool = false
    var isMusicRandome : Bool = false

    var strDuration : String = ""
    var hour : Int = 0
    var seconds : Int = 0
    var minites : Int = 0

    var getTabControle : UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //VIDEO PLAYEER
        NotificationCenter.default.addObserver(self, selector: #selector(self.setPlayerDetails), name: .videoPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTime), name: .updateTiming, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setOtherDetails(_:)), name: .PlayerDetails, object: nil)

        
//        let playerLayer = AVPlayerLayer(player: playerVideo)
//        playerLayer.frame = self.viewPlayer.bounds
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerVideo?.currentItem, queue: nil) { (_) in
//            playerVideo?.seek(to: CMTime.zero)
//            playerVideo?.play()
//        }
//        self.viewPlayer.layer.addSublayer(playerLayer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        //SET VIEW
        self.view.backgroundColor = setColour()
      
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        //SET NAVIGATION BAR icon_playlist2
        
        setNavigationBarFor(controller: self, title: "", isTransperent: true, hideShadowImage: false, leftIcon: "icon_down", rightIcon: "") { SelectTag in
            self.dismiss(animated: true, completion: nil)
        } rightActionHandler: {SelectTag in 
            
        }
        
        //SET VIEW
        self.setTheFont()
        self.setPlayerDetails()
//        self.getYouTubPlayerDetailsAPI(YouTubParameater: YouTubParameater(), videoID: "JEgKJZEYsIU")
        }
    
    func setTheFont(){
       
        //SET FONT
        lblCurrentDuration.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "00:00")
        lblTotalTime.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "00:00")
        lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: "")
        lblTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "")

        //SET SLIDER
        objSlider.setValue(0, animated: true)
        objSlider.minimumTrackTintColor = UIColor.standard
        objLoading.isHidden = true
        
        //SET BUTTON
        buttonImageColor(btnImage: btnPrevious, imageName: "icon_playPrevious", colorHex: setTextColour())
        buttonImageColor(btnImage: btnPlay, imageName: "icon_play", colorHex: setTextColour())
        buttonImageColor(btnImage: btnNext, imageName: "icon_playNext", colorHex: setTextColour())
        buttonImageColor(btnImage: btnLoop, imageName: "icon_loop", colorHex: setTextColour())
        buttonImageColor(btnImage: btnRandome, imageName: "icon_randome", colorHex: setTextColour())
    }
    
    
    @objc func setPlayerDetails(){
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
            print(objData.videoPlayURL)
            lblName.text = objData.name ?? ""
            lblTitle.text = strArtist
            
            //CHECK TRACK SAVE OR NOT
            btnLike.setImage(UIImage(named: "icon_unlike"), for: .normal)
            buttonImageColor(btnImage: btnLike, imageName: "icon_unlike", colorHex: setTextColour())
            buttonImageColor(btnImage: btnMore, imageName: "icon_moreH", colorHex: setTextColour())
            let MenuID = arrSaveTrack.map{$0.id}
            if MenuID.firstIndex(of: objData.id) != nil {
                btnLike.setImage(UIImage(named: "icon_like"), for: .normal)
                buttonImageColor(btnImage: btnLike, imageName: "icon_like", colorHex: UIColor.standard)
            }
            
            //CEHCK IMAGE
            imgVideo.image = UIImage(named: "icon_playlistNoData")
            if objData.videoImage == ""{
                //SEARCH YOUTUB ID
                CurrentPlayTrackID = objData.id ?? 0
                var strName = "\(strArtist)/\(objData.name ?? "")"
                strName = strName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                self.searchVideoID(strID: objData.id ?? 0, strName: strName)
            }
            else{
                //LOAD IMAGE
                let imgURL =  ("\(objData.videoImage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
                if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                    Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: imgVideo)
                }
            }
 
        }
    }
    
    @objc func setOtherDetails(_ notification: Notification){
        guard let isLoading = notification.userInfo?["isLoading"] as? Bool else { return }

        //SET BUTTON

        btnNext.isEnabled = true
        if indexPlayMusic == arrMusicPlayList.count - 1 || isLoading{
            btnNext.isEnabled = false
        }
        
        btnPrevious.isEnabled = true
        if indexPlayMusic == 0 || isLoading{
            btnPrevious.isEnabled = false
        }
        
        buttonImageColor(btnImage: btnPlay, imageName: isMusicPlayNow == false ? "icon_play" : "icon_push", colorHex: setTextColour())
        objLoading.isHidden = !isLoading
        if isLoading{
            objLoading.startAnimating()
            btnPlay.setImage(UIImage(named: ""), for: .normal)
        }
        else{
            objLoading.stopAnimating()
        }
    }

    @objc func updateTime() {
        
        if playerVideo == nil{
            return
        }

        buttonImageColor(btnImage: btnPlay, imageName: isMusicPlayNow == false ? "icon_play" : "icon_push", colorHex: setTextColour())
        objLoading.isHidden = true
        objLoading.stopAnimating()


        
        let currentTime = CMTimeGetSeconds((playerVideo?.currentTime())!)
        let maxDuration = CMTimeGetSeconds((playerVideo?.currentItem?.asset.duration)!) / 2
        
        objSlider.setValue(Float(currentTime/maxDuration), animated: true)
        if maxDuration > currentTime {
            lblCurrentDuration.text = secondsToHoursMinutesSeconds(seconds: Int(currentTime))
            lblTotalTime.text = secondsToHoursMinutesSeconds(seconds: Int(maxDuration))
        } else {
            //STOP RECORDING
//            video_pause()
        }
    }
    
    func seekToSec(_ seconds: Float64) {
        let timeScale = playerVideo?.currentItem?.asset.duration.timescale
        let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale!)
        playerVideo?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        if seconds / 3600 == 0 {
            return String(format: "%02d:%02d", (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}


//MARK: - BUTTON ACTION
extension MusicPlayerViewController :UIPopoverPresentationControllerDelegate, MenuProtocol{
    @IBAction func btnPlayClciked(_ sender: UIButton) {
        NotificationCenter.default.post(name: .PlayPlayMusic, object: nil, userInfo: nil)

//        btnPlay.showLoader(userInteraction: true)

//
//        btnPlay.setImage(UIImage(named: ""))
//        btnPlay = LoadingButton(text: "Button", textColor: .black, bgColor: .white)
//
//        btnPlay.indicator = MaterialLoadingIndicator(color: .gray)

//        if isMusicPlay{
//            isMusicPlay = false
//            self.viewPlayer.stopVideo()
//        }
//        else{
//            isMusicPlay = true
//            self.viewPlayer.playVideo()
//        }
//
//
//        buttonImageColor(btnImage: btnPlay, imageName: isMusicPlay == false ? "icon_play" : "icon_push", colorHex: setTextColour())

    }
 
    
    @IBAction func btnLoopClciked(_ sender: UIButton) {
        if isMusicLoop{
            isMusicLoop = false
            buttonImageColor(btnImage: btnLoop, imageName: "icon_loop", colorHex: setTextColour())
        }
        else{
            isMusicLoop = true
            buttonImageColor(btnImage: btnLoop, imageName: "icon_loop", colorHex: UIColor.standard)
        }
    }
    @IBAction func btnRandomeClciked(_ sender: UIButton) {
        if isMusicRandome{
            isMusicRandome = false
            buttonImageColor(btnImage: btnRandome, imageName: "icon_randome", colorHex: setTextColour())
        }
        else{
            isMusicRandome = true
            buttonImageColor(btnImage: btnRandome, imageName: "icon_randome", colorHex: UIColor.standard)
        }
    }
    
    @IBAction func btnNextClciked(_ sender: UIButton) {
        NotificationCenter.default.post(name: .PlayNextMusic, object: nil, userInfo: nil)

    }
    
    @IBAction func btnPreviousClciked(_ sender: UIButton) {
        NotificationCenter.default.post(name: .PlayPreviousMusic, object: nil, userInfo: nil)
    }
    

    
    @IBAction func btnSliderClciked(_ sender: UISlider) {
        print(sender.value)
        if playerVideo != nil{
            
            let maxDuration = CMTimeGetSeconds((playerVideo?.currentItem?.asset.duration)!)
            
            let seekpValue = Float(maxDuration) * sender.value
            seekToSec(Float64(seekpValue))
        }
        
    }
    
    @IBAction func btnMoreClciked(_ sender: UIButton) {
        //GET DATA
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
        
        let storyboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "MenuPopup") as! MenuPopup
        
        popVC.strAlbumName = "\(objData.name ?? "")"
        popVC.strArticstName = strArtist
        popVC.strAlbumImage = "\(objData.objAlbum.image ?? "")"
        popVC.indexRecommended = indexPlayMusic
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
                newViewController.strArtistsID = arrMusicPlayList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strTrackRadio{
            //GO TO TRACK RADIO
            //MOVE RADIO SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                newViewController.isRadioTrack = "Track"
                newViewController.strRadioID = arrMusicPlayList[popUpIndex].id ?? 0
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        else if strSelectIndex == str.strRemoveQueue || strSelectIndex == str.strAddQueue{
            //ADD OR REMOVE TRACK IN PLAYLIST
            if strType == "Track"{
                let objData = arrMusicPlayList[popUpIndex]
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
//                                self.tblView.reloadData()
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
                
                isMusicPlayNow = false
                NotificationCenter.default.post(name: .SetTabBarDetails, object: nil, userInfo: nil)
                if arrMusicPlayList.count == 0{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else{
                    setPlayerDetails()
                }
            }
        }
    }
}


//extension MusicPlayerViewController : YTPlayerViewDelegate{
//    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
//        print(playTime)
//        isMusicPlay = true
//        setButtonandLoading(isLoading: false)
//        buttonImageColor(btnImage: btnPlay, imageName: isMusicPlay == false ? "icon_play" : "icon_push", colorHex: setTextColour())
//
//        //SET TIME
//        lblCurrentDuration.text = self.secondsToHoursMinutesSeconds(seconds: Int(playTime))
//        objSlider.setValue(playTime / Float(hour + minites + seconds), animated: true)
//    }
//
//
//    func setButtonandLoading(isLoading : Bool){
//        btnPlay.isHidden = isLoading
//        objLoading.isHidden = !isLoading
//        if isLoading{
//            objLoading.startAnimating()
//        }
//        else{
//            objLoading.stopAnimating()
//        }
//    }
//
//
//    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
//        setButtonandLoading(isLoading: false)
//        switch state {
//        case .unstarted:
//            print("unstarted")
//        case .ended:
//            print("ended")
//
//        case .playing:
//            print("playing")
//            isMusicPlay = true
//            buttonImageColor(btnImage: btnPlay, imageName: isMusicPlay == false ? "icon_play" : "icon_push", colorHex: setTextColour())
//
//        case .paused:
//            print("paused")
//            isMusicPlay = false
//            buttonImageColor(btnImage: btnPlay, imageName: isMusicPlay == false ? "icon_play" : "icon_push", colorHex: setTextColour())
//
//        case .buffering:
//            print("buffering")
//            setButtonandLoading(isLoading: true)
//
//        case .cued:
//            print("cued")
//
//        case .unknown:
//            print("unknown")
//
//        @unknown default:
//            break
//        }
//    }
//
//
//
//    func getYoutubeFormattedDuration(formattedDuration : String) -> String {
////       4M32S
//
//        let strText = formattedDuration.replacingOccurrences(of: "PT", with: "")
//        if let _ = strText.rangeOfCharacter(from: CharacterSet(charactersIn: "H"), options: .caseInsensitive) {
//            //GET HOURS
//            let arrHour = strText.components(separatedBy: "H")
//            if arrHour.count != 0{
//                hour = (Int(arrHour[0]) ?? 0) * 3600
//            }
//        }
//        else{
//            //GET MINITS
//            if let _ = strText.rangeOfCharacter(from: CharacterSet(charactersIn: "M"), options: .caseInsensitive) {
//                //GET HOURS
//                let arr = strText.components(separatedBy: "M")
//                if arr.count != 0{
//                    minites = (Int(arr[0]) ?? 0) * 60
//
//                    //GET SECOND
//                    if let _ = arr[1].rangeOfCharacter(from: CharacterSet(charactersIn: "S"), options: .caseInsensitive) {
//                        //GET HOURS
//                        let arr = arr[1].components(separatedBy: "S")
//                        if arr.count != 0{
//                            seconds = Int(arr[0]) ?? 0
//
//                        }
//                    }
//                }
//            }
//        }
//
//        //GET TIME
//        let formattedDuration = formattedDuration.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: ":")
//
//        let components = formattedDuration.components(separatedBy: ":")
//        var duration = ""
//        for objData in components {
//
//            if objData != ""{
//                if duration == ""{
//                    duration = objData
//                }
//                else {
//                    duration = "\(duration):\(objData)"
//                }
//            }
//        }
//        return duration
//    }
//
//
//    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
//        let hour = seconds / 3600
//        let second = (seconds % 3600) / 60
//        let mint = (seconds % 3600) % 60
//
//        var duration = ""
//        if hour != 0{
//            if duration == ""{
//                duration = "\(hour)"
//            }
//            else {
//                duration = "\(duration):\(hour)"
//            }
//        }
//
//        if second != 0{
//            if duration == ""{
//                duration = "\(second)"
//            }
//            else {
//                duration = "\(duration):\(second)"
//            }
//        }
//        else{
//            duration = "00"
//        }
//
//        if mint != 0{
//            if duration == ""{
//                duration = "\(mint)"
//            }
//            else {
//                duration = "\(duration):\(mint)"
//            }
//        }
//        else{
//            duration = "00"
//        }
//
//      return duration
//    }
//}



