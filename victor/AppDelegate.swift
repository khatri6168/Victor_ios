//
//  AppDelegate.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit
import LoadingPlaceholderView
import ObjectMapper
import youtube_ios_player_helper
import AVFAudio
import PythonSupport
import AVKit
import AVFoundation
import YoutubeDL
import PythonKit
import MZDownloadManager
import GoogleMobileAds
import MediaPlayer

let loadingPlaceholderView = LoadingPlaceholderView()
var tabBarPreviousIndexSelect : Int = 0
let objTabbar = TabbarViewController()

//MUSIC ITEMS
var arrMusicPlayList : [RadioModel] = []
var indexPlayMusic : Int = 0
var isMusicPlayNow : Bool = false
var CurrentPlayTrackID : Int = 0
var isAppOpneAds : Bool = false

//SAVE DATA
var arrSaveArtists : [TrackModel] = []
var arrSaveAlbume : [TrackModel] = []
var arrSaveTrack : [TrackModel] = []
var arrSavePlay_List : [TrackModel] = []

var arrLoading : [Int] = []

//ADS ARE SHOWING
var isAdsShowing : Bool = true
var isMinimumCoine : Int = 2

struct SessionModel{
    var session: String
    let videoID: String
}
var arrSession : [SessionModel] = []
var strPlayLocalURL : String = ""

//PLAYER
var playerVideo: AVPlayer?
var playerItem: AVPlayerItem!
let av1CodecPrefix = "av01."
extension Format {
    var isRemuxingNeeded: Bool { isVideoOnly || isAudioOnly }
    
    var isTranscodingNeeded: Bool {
        self.ext == "mp4"
            ? (self.vcodec ?? "").hasPrefix(av1CodecPrefix)
            : self.ext != "m4a"
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    //DOWNALOAD
    var countDownloading : Int = 0
    var tasks: [URLSessionTask] = []
    private var urlSession: URLSession!
    var backgroundSessionCompletionHandler : (() -> Void)?
    let myDownloadPath = baseFilePath + "/My Downloads"
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: backgroundSessionCompletionHandler)
        return downloadmanager
    }()
    
    
    //ALLOCATE DOWNLOAD VIDEO VALUES
//    var objData : RadioModel!
//    var url: URL? {
//        didSet {
//            guard let url = url else {
//                return
//            }
//            
//            let map = Map(mappingType: .fromJSON, JSON: [:])
//            objData = RadioModel(map: map)
//            extractInfo(url: url, objData: objData)
//        }
//    }
    var youtubeDL: YoutubeDL?
    var isTranscodingEnabled = true
    let av1CodecPrefix = "av01."
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        arrMusicPlayList = []
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playAVPlayerItemFailedToPlayToEndTime), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playAVPlayerItemPlaybackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playAVPlayerItemNewAccessLogEntry), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playAVPlayerItemNewErrorLogEntry), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
        
        
        // Override point for customization after application launch.
        PythonSupport.initialize()


        //SET URL URLSession
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        //SET MODE
        if UserDefaults.standard.colourMode == "" || UserDefaults.standard.colourMode == nil {
            UserDefaults.standard.colourMode = "dark"
        }
        
        /// working code
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
     
        //downloadFile()
//        clearCache()
        createFolder()

        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AppOpenAdManager.shared.loadAd()

        return true
    }
    
    func setCode(){
        showAlertMessage(strMessage: YoutubeDL.pythonModuleURL.path)
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let rootViewController = application.windows.first(
            where: { $0.isKeyWindow })?.rootViewController
        if let rootViewController = rootViewController {
            // Do not show app open ad if the current view controller is SplashViewController.
            if rootViewController is SplashViewController {
                return
            }
            AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func createFolder(){
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
   
    public static let baseFilePath: String = {
        return (NSHomeDirectory() as NSString).appendingPathComponent("Documents") as String
    }()

    
    func playerView(){
        let ViewController = getTopViewController!

        if arrMusicPlayList.count != 0{

            //PLAYER SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.PLAYER_MODEL, bundle: nil)
            if let navView = storyBoard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController {
                let vieweNavigationController = UINavigationController(rootViewController: navView)
                ViewController.present(vieweNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func earnCoins(_ coins: Int) {
        let strCoin = UserDefaults.standard.getCoine
        var getCoin = Int(strCoin ?? "") ?? 0
        
        getCoin = getCoin + coins
        
        //UPDATE COINT
        UserDefaults.standard.getCoine = "\(getCoin)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.default.post(name: .SetTabBarDetails, object: nil, userInfo: nil)
        }
    }
    
    func removeCoins() {
        let strCoin = UserDefaults.standard.getCoine
        var getCoin = Int(strCoin ?? "") ?? 0
        
        getCoin = getCoin - isMinimumCoine
        
        //UPDATE COINT
        UserDefaults.standard.getCoine = "\(getCoin)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.default.post(name: .SetTabBarDetails, object: nil, userInfo: nil)
        }
    }
}



struct TrackAddRemoveParameater: Codable {
    var likeables: [LikeablesParameater]
    var _method : String
}

//REGISTER SCREEN ..........................
extension AppDelegate :WebServiceHelperDelegate{
    
    func SaveTrackListAPI(){

        //Declaration URL
        let strURL = "\(Url.saveTrack.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "saveTrack"
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
    
    
    func SavePlaylistAPI(strUserId : String){

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
        webHelper.indicatorShowOrHide = false
        webHelper.callAPI()
    }
    
    
    func SaveArtistListAPI(){

        //Declaration URL
        let strURL = "\(Url.saveArtist.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "saveArtist"
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
    
    func SaveAlbumeListAPI(){

        //Declaration URL
        let strURL = "\(Url.saveAlbume.absoluteString!)"
        
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "saveAlbume"
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


    
    func AddOrRemoveTrackAPI(TrackAddRemoveParameater : TrackAddRemoveParameater, isRemove : Bool){
        guard let parameater = try? TrackAddRemoveParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }
        
        //Declaration URL
        var strURL : String = ""
        if isRemove{
            strURL = "\(Url.removeFromLibrary.absoluteString!)"
        }
        else{
            strURL = "\(Url.addToLibrary.absoluteString!)"

        }
                
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "TrackAddRemove"
        webHelper.methodType = "post"
        webHelper.strURL = strURL
        webHelper.dictType = parameater
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = true
        webHelper.callAPI()
    }
    
    func appDataDidSuccess(_ data: NSDictionary, request strRequest: String) {
        if strRequest == "saveArtist"{
            //GET ARTIST
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSaveArtists = []
                    arrSaveArtists = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
            }
        }
        else if strRequest == "saveAlbume"{
            //GET ALBUME
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSaveAlbume = []
                    arrSaveAlbume = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
            }
        }
        else if strRequest == "saveTrack"{
            print(data)
            
            //GET TRACK
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSaveTrack = []
                    arrSaveTrack = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
            }
        }
        else if strRequest == "savePlaylist"{
            
            //GET PLAYLIST
            if let objData = data["pagination"] as? NSDictionary{
                if let arrData = objData["data"] as? NSArray{
                    arrSavePlay_List = []
                    arrSavePlay_List = Mapper<TrackModel>().mapArray(JSONArray: arrData as! [[String : Any]])
                }
            }
        }
        else if strRequest == "TrackAddRemove"{
            self.SaveArtistListAPI()
            self.SaveAlbumeListAPI()
            self.SaveTrackListAPI()
        }
    }

    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}






//MARK: - DOWNALOAD YOUTUB VIDEO -
extension AppDelegate {
    func loadPythonModule(url: URL, objData : RadioModel) {
        guard FileManager.default.fileExists(atPath: YoutubeDL.pythonModuleURL.path) else {
            downloadPythonModule(url: url, objData: objData)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.youtubeDL = try YoutubeDL()
                DispatchQueue.main.async {
                    
                    self.extractInfo(url: url, objData: objData)
                }
            }
            catch {
                print(#function, error)

            }
        }
    }
    
    func downloadPythonModule(url: URL, objData : RadioModel) {
        YoutubeDL.downloadPythonModule { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    return
                }

                self.loadPythonModule(url: url, objData: objData)
            }
        }
    }

    func extractInfo(url: URL, objData : RadioModel){
        guard let youtubeDL = youtubeDL else {
            loadPythonModule(url: url, objData: objData)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let (_, info) = try youtubeDL.extractInfo(url: url)
                DispatchQueue.main.async {
//                    print(info?.formats)
                    self.checkOutVideoUrl(info: info, objData: objData)
                }
            }
            catch {
            }
        }
    }
    
    
 
    func checkOutVideoUrl(info: Info? , objData : RadioModel){

        guard let formats = info?.formats else {
            return
        }


        let _bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
        let _bestVideo = formats.filter {
            $0.isVideoOnly && (isTranscodingEnabled || !$0.isTranscodingNeeded) }.last
        let _best = formats.filter { !$0.isRemuxingNeeded && !$0.isTranscodingNeeded }.last
        print(_best ?? "no best?", _bestVideo ?? "no bestvideo?", _bestAudio ?? "no bestaudio?")

        if objData.id == nil{
            //PLAY VIDEO
            if _bestAudio?.urlRequest?.url != nil{
                playVideo(url: (_bestAudio?.urlRequest?.url)!)
            }
            else if  _best?.urlRequest?.url != nil{
                playVideo(url: (_best?.urlRequest?.url)!)
            }
            else if _bestVideo?.urlRequest?.url != nil{
                playVideo(url: (_bestVideo?.urlRequest?.url)!)
            }
            else{
                return
            }
        }
        else{
            var strURL : URL!
            if _bestAudio?.urlRequest?.url != nil{
                strURL = _bestAudio?.urlRequest?.url
            }
            else if  _best?.urlRequest?.url != nil{
                strURL = _best?.urlRequest?.url
            }
            else if _bestVideo?.urlRequest?.url != nil{
                strURL = _bestVideo?.urlRequest?.url
            }
            else{
                return
            }

//            strURL = _best?.urlRequest?.url

            //DOWNALOAD VIDEO
            if strURL != nil{

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

                //SAVE DATA
                if let objUser = UserDefaults.standard.user{
                    let getPoint : Int = Int(UserDefaults.standard.getCoine ?? "") ?? 0
                    if getPoint >= isMinimumCoine{
                        self.removeCoins()

                        CoreDBManager.sharedDatabase.saveDownalodURL(objSaveShowData: DownloadVideoParameater(download_percentage: "", download_URL: "", isDownload: "false", session_id: "", userID: objUser.id ?? "", video_artist_name: strArtist, video_id: "\(objData.id ?? 0)", video_img: "", video_name: objData.name ?? "", video_url: "\(strURL!)", youtubID: objData.youtubID )) { isSave in

                            //DOWNLOAD VIDEO
                            GlobalConstants.appDelegate?.DownloadVideos(videoURL: strURL, strVideoID: "\(objData.id ?? 0)")
                        }
                    }
                }
            }
            else{
                //REMOVE ID
                let MenuID = arrLoading.map{$0}
                if let index = MenuID.firstIndex(of: objData.id ?? 0) {
                    arrLoading.remove(at: index)
                }

                NotificationCenter.default.post(name: .removeLoading, object: nil, userInfo: nil)
            }
        }
    }
    
 
    func playVideo(url: URL) {
        strPlayLocalURL = ""
        playerItem = AVPlayerItem(url: url)
        var strName  = Application.appName
        //UPDATE ARRAY
        let MenuID = arrMusicPlayList.map{$0.id}
        if let index = MenuID.firstIndex(of: CurrentPlayTrackID){
            var objData = arrMusicPlayList[index]
            objData.videoPlayURL = "\(url)"
            strName = objData.name ?? Application.appName
            //SET NEW OBJECT
            arrMusicPlayList.remove(at: index)
            arrMusicPlayList.insert(objData, at: index)
        }
        
        playerVideo = nil
        playerVideo = AVPlayer(playerItem: playerItem)
        playerVideo?.play()
        
      
        setupAudioSession()
        setupNowPlaying(songName: strName)
        setupRemoteCommandCenter()

        
        //SET TIMER
        playerVideo?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
            if playerVideo?.currentItem?.status == .readyToPlay {
                NotificationCenter.default.post(name: .updateTiming, object: nil, userInfo: nil)
            }
        })
        
    }
    
    
    
    func playLocalVideo(strLocalURL: String, strSongName: String) {
        let destinationPath = (myDownloadPath as NSString).appendingPathComponent(strLocalURL)
        strPlayLocalURL = destinationPath
        
        playerItem = AVPlayerItem(url: URL(fileURLWithPath: destinationPath))
        playerVideo = nil
        playerVideo = AVPlayer(playerItem: playerItem)
        playerVideo?.play()
        
        setupAudioSession()
        setupNowPlaying(songName: strSongName)
        setupRemoteCommandCenter()

        //SET TIMER
        playerVideo?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
            if playerVideo?.currentItem?.status == .readyToPlay {
                NotificationCenter.default.post(name: .updateTiming, object: nil, userInfo: nil)
            }
        })
    }
    
    
    func setupAudioSession() {
//        do {
////            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//
//            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: .defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Error setting the AVAudioSession:", error.localizedDescription)
//        }
    }
    
    func setupNowPlaying(songName: String) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songName

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds / 2
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds / 2
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playerVideo?.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        if #available(iOS 13.0, *) {
            MPNowPlayingInfoCenter.default().playbackState = .playing
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            playerVideo?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            playerVideo?.pause()
            return .success
        }
        
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.addTarget {event in
            self.seekToSec(20)
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.addTarget {event in
            self.seekToSec(-10)
            return .success
        }
    }
    
    func seekToSec(_ seconds: Float64) {
        let timeScale = playerVideo?.currentItem?.asset.duration.timescale
        let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale!)
        playerVideo?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    @objc func currntPlayTiming() {
        // Start PLAYING
        NotificationCenter.default.post(name: .updateTiming, object: nil, userInfo: nil)

    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        // Your code here
        print("done")
        playerVideo = nil
        NotificationCenter.default.post(name: .autoPlayNextMusic, object: nil, userInfo: nil)
    }
    
    @objc func playAVPlayerItemFailedToPlayToEndTime(note: NSNotification) {
        // Your code here
        print("1")
    }
    
    @objc func playAVPlayerItemPlaybackStalled(note: NSNotification) {
        // Your code here
        print("2")
    }
    
    @objc func playAVPlayerItemNewAccessLogEntry(note: NSNotification) {
        // Start PLAYING
        NotificationCenter.default.post(name: .videoPlay, object: nil, userInfo: nil)
    }
    
    @objc func playAVPlayerItemNewErrorLogEntry(note: NSNotification) {
        // Your code here
        print("4")
    }
    
}






//MARK: - DOWNALOAD DELEGATE
extension AppDelegate : MZDownloadManagerDelegate{
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel]) {
    }
    
    func startDownloading(){
        if let objUser = UserDefaults.standard.user {
            
            let arrData = CoreDBManager.sharedDatabase.getAllDownloadData(userID: objUser.id ?? "")
            if arrData.count != 0{
                for obj in arrData{

                    if obj.download_URL == "" && obj.isDownload == "false" && obj.video_url != ""{

                        //DOWNALOAD VIDEO
                        self.DownloadVideos(videoURL: URL(string: obj.video_url ?? ""), strVideoID: obj.video_id ?? "")
                    }
                    else{
                        if obj.download_URL == "" && obj.isDownload == "true"{
                            //DELETE MUSIC
                            CoreDBManager.sharedDatabase.deleteDownloadVideo(userID: objUser.id ?? "", videoID: obj.video_id ?? "") { isDone in

                                if obj.download_URL != ""{
                                    let strDownloadURL : NSString = ((GlobalConstants.appDelegate?.myDownloadPath ?? "") as NSString).appendingPathComponent(obj.download_URL ?? "") as NSString
                                    try? FileManager.default.removeItem(atPath: "\(strDownloadURL)")
                                }
                                NotificationCenter.default.post(name: .removeLoading, object: nil, userInfo: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func DownloadVideos(videoURL : URL!, strVideoID : String) {
        //DOWNALOADING VIDEO
        DispatchQueue.main.async{
            if videoURL != nil && strVideoID != ""{
                
                self.urlSession.sessionDescription = strVideoID
                let downloadTask = self.urlSession.downloadTask(with: videoURL)
                downloadTask.resume()
                self.tasks.append(downloadTask)
            }
        }
    }
    
   
}

//URL SESSION
extension AppDelegate: URLSessionDownloadDelegate {
 

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if UserDefaults.standard.user == nil{
            downloadTask.cancel()
        }
        
        //CHECK DUBALUCATE SESSION
        if arrSession.count != 0{
            //CHECK
            let MenuID = arrSession.map{$0.videoID}
            if MenuID.firstIndex(of: "\(session)") != nil {
                downloadTask.cancel()
            }
            else{
                //ADD
                arrSession.append(SessionModel(session: "\(session)", videoID: session.sessionDescription ?? ""))
            }

        }
        else{
            //ADD
            arrSession.append(SessionModel(session: "\(session)", videoID: session.sessionDescription ?? ""))
        }
        
        //GET PROGRESS
        let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
        let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
        let progress = Float(receivedBytesCount / totalBytesCount)
        
        print("---------")
        print("\(downloadTask)")
        print("\(progress)")
        print(session.sessionDescription ?? "")
        print(countDownloading)
        
        //REMOVE ID
        //        if session.sessionDescription ?? "" != ""{
        //            let MenuID = arrLoading.map{$0}
        //            if let index = MenuID.firstIndex(of: Int(session.sessionDescription ?? "") ?? 0) {
        //                arrLoading.remove(at: index)
        //                NotificationCenter.default.post(name: .removeLoading, object: nil, userInfo: nil)
        //            }
        //        }
        
        
        DispatchQueue.main.async {
            if let objUser = UserDefaults.standard.user{
                let arrData = CoreDBManager.sharedDatabase.getDownloadVideosData(userID: objUser.id ?? "", videoID: session.sessionDescription ?? "")
                
                if arrData.count != 0{
                    let obj = arrData[0]
                    
                    if (Float(obj.download_percentage ?? "") ?? 0.0 <= progress || progress == 0.0) && progress != 1.0{
                        DispatchQueue.main.async {
                            CoreDBManager.sharedDatabase.updateDownalodURL(strUserID: obj.userID ?? "", videoID: session.sessionDescription ?? "", download_percentage: "\(progress)", sessionID: "\(downloadTask)", isisDownload: "false", FileName: "", videoURL: obj.video_url ?? "") { isSave in
                                
                                //CALL
                                NotificationCenter.default.post(name: .downLoadProgress, object: obj)

                            }
                        }
                    }
                 
                }
                else{
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .downLoadProgress, object: nil)
                    }
                    downloadTask.cancel()
                    
                    //CEHCK DOWNLAOD
                    self.startDownloading()
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    
        if let objUser = UserDefaults.standard.user{
            let arrData = CoreDBManager.sharedDatabase.getDownloadVideosData(userID: objUser.id ?? "", videoID: session.sessionDescription ?? "")
            if arrData.count != 0{
                let obj = arrData[0]

                let fileName = "\(randomString(length: 10)).mp4" as NSString
                let destinationPath = (myDownloadPath as NSString).appendingPathComponent(fileName as String)


                let fileManager : FileManager = FileManager.default

                //If all set just move downloaded file to the destination
                if fileManager.fileExists(atPath: myDownloadPath) {
                    let fileURL = URL(fileURLWithPath: destinationPath as String)
                    debugPrint("directory path = \(destinationPath)")

                    do {
                        try fileManager.moveItem(at: location, to: fileURL)

                        //SAVE DATA

                        DispatchQueue.main.async {
                            if obj.isDownload == "false"{
                                CoreDBManager.sharedDatabase.updateDownalodURL(strUserID: obj.userID ?? "", videoID: session.sessionDescription ?? "", download_percentage: "1.0", sessionID: "\(downloadTask)", isisDownload: "true", FileName: "\(fileName)", videoURL: obj.video_url ?? "") { isSave in

//                                    //CALL
//                                    self.downloadManager.presentNotificationForDownload("Ok", notifBody: "\(obj.video_name ?? "") downloaded successfully")

                                    NotificationCenter.default.post(name: .downLoadProgress, object: obj)
                                    NotificationCenter.default.post(name: .downLoadFinished, object: nil)

                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        //CEHCK DOWNLAOD
                                        self.startDownloading()
                                    }

                                }
                            }
                        }

                    } catch let error as NSError {
                        debugPrint("Error while moving downloaded file to destination path:\(error)")

                    }
                }
            }
        }
    }
    
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
 
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            DispatchQueue.global(qos: .background).async {
                backgroundCompletion()
            }
        }
        debugPrint("All tasks are finished")
    }
    
}
