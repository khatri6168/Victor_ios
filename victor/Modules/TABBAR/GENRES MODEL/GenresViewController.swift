//
//  GenresViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit
import Nuke
import GoogleMobileAds

class GenresViewController: UIViewController {

    //SET VIEW VALUES
    @IBOutlet weak var tblView: UITableView!

    //LOAD MORE
    var _loadingView: UIActivityIndicatorView!
    var bool_Load: Bool = false
    var objRefresh : UIRefreshControl?
    var isLoading : Bool = false

    var arrGenresList : [GenresStaticModel] = []
    var pageCount : Int = 1
    
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrGenresList = [GenresStaticModel(id: 46, name: "j-pop", image: "j-pop", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 45, name: "grindcore", image: "grindcore", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 44, name: "guitar", image: "guitar", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 43, name: "idm", image: "idm", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 42, name: "grunge", image: "grunge", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 41, name: "french", image: "french", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 40, name: "emo", image: "emo", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 39, name: "country", image: "country", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 38, name: "indie pop", image: "indie-pop", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 37, name: "electro", image: "electro", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 36, name: "trip hop", image: "trip-hop", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 35, name: "reggae", image: "reggae", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 34, name: "techno", image: "techno", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 33, name: "piano", image: "piano", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 32, name: "trance", image: "trance", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 31, name: "House", image: "house", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 30, name: "funk", image: "funk", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 29, name: "german", image: "german", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 28, name: "metalcore", image: "metalcore", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 27, name: "acoustic", image: "acoustic", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 26, name: "blues", image: "blues", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 25, name: "punk rock", image: "punk-rock", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 24, name: "industrial", image: "industrial", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 23, name: "Classical", image: "classical", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 22, name: "soul", image: "soul", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 21, name: "british", image: "british", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 20, name: "hardcore", image: "hardcore", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 19, name: "heavy metal", image: "heavy-metal", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 18, name: "death metal", image: "death-metal", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 17, name: "dance", image: "dance", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 16, name: "singer-songwriter", image: "singer-songwriter", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 15, name: "black metal", image: "black-metal", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 14, name: "hard-rock", image: "hard-rock", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 13, name: "hip hop", image: "hip-hop", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 12, name: "punk", image: "punk", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 11, name: "folk", image: "folk", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 10, name: "ambient", image: "ambient", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 9, name: "jazz", image: "jazz", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 8, name: "metal", image: "metal", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 7, name: "indie", image: "indie", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 6, name: "alternative", image: "alternative", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 5, name: "electronic", image: "electronic", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 4, name: "rock", image: "rock", image_small: "", model_type: "genre", plays: ""),
                         GenresStaticModel(id: 2, name: "pop", image: "pop", image_small: "", model_type: "genre", plays: ""),
                         
                         
        ]

        // Do any additional setup after loading the view.
        
        //SET REFRSH CONTROL
        self.objRefresh = UIRefreshControl()
        self.objRefresh?.tintColor = setTextColour()
        self.objRefresh?.addTarget(self, action: #selector(self.refreshList), for: .valueChanged)
        self.tblView.addSubview(self.objRefresh!)
        
        self.refreshList()
        
        
  
        
        //OPNE ADS
  
//        if isAppOpneAds == false{
//            //MOVE ARTISTS SCREEN
//            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
//            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "OpenAdsViewController") as? OpenAdsViewController{
//                self.present(newViewController, animated: false, completion: nil)
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarPreviousIndexSelect = 0
        
         DispatchQueue.main.asyncAfter(deadline: .now() ) {
             //START DOWNALDING
             GlobalConstants.appDelegate?.startDownloading()
             
             guard let controller  = self.tabBarController as? TabbarViewController else {
                 return
             }
             controller.setTheTabBarView()
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                 controller.setTheTabBarView()
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                     controller.setTheTabBarView()
                 }
             }
             controller.selectMusicBar()
         }
//        showToast(sender: self.view, message: "sfs")
        
        //SET VIEW
        self.view.backgroundColor = setColour()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tblView.reloadData()
        }
        

        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
        //SET NAVIGATION BAR
        setNavigationBarTitleFor(controller: self, title: str.genres, isTransperent: true, hideShadowImage: false, leftIcon: "", rightIcon: "icon_search") { SelectTag in
        } rightActionHandler: {SelectTag in
            //SEARCH
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.SEARCH_MODEL, bundle: nil)
            if let newViewController = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
        
        //SET FFONT
        self.setupTableView()
        self.tblView.reloadData()
    }
 
    
    
   
    @objc func refreshList() {
        //GET DETAILS
        self.pageCount = 1
//        self.arrGenresList = []
//        self.GenresAPI(GenresParameater: GenresParameater(filter: "", page: "\(pageCount)"))
    }
    
}


//.......................... UITABLE VIEW ..........................//

//MARK: -- UITABEL CELL --
class GenresCell : UITableViewCell{
    @IBOutlet weak var objCollection: UICollectionView!
    @IBOutlet weak var con_CollectionViewHeight: NSLayoutConstraint!
}


//MARK: -- UITABEL DELEGATE --

extension GenresViewController : UITableViewDelegate, UITableViewDataSource{
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
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == tblView{
//            if tblView.contentSize.height <= tblView.contentOffset.y + tblView.frame.size.height && tblView.contentOffset.y >= 0 {
//                if bool_Load == false && arrGenresList.count != 0 {
//
//                    //Refresh code
//                    self.bool_Load = true
//
//                    //START LOADING
//                    startAnimatingView()
//
//                    //GET DETAILS
////                    self.GenresAPI(GenresParameater: GenresParameater(filter: "", page: "\(pageCount)"))
//                }
//            }
//        }
//    }
    
    //HEADER SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell") as! GenresCell
        cell.backgroundColor = UIColor.clear
        
        //SET HEADER COLLECTION VIEW
        if isLoading{
            cell.con_CollectionViewHeight.constant = ((tableView.frame.size.width - 60) / 2) * 10
        }
        else{
            cell.objCollection.tag = indexPath.row
            cell.con_CollectionViewHeight.constant = ((tableView.frame.size.width - 60) / 2) * 22        }

        
        //RELOAD COLLECTION VIEW
        cell.objCollection.reloadData()
                    
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


class GenresListCell: UICollectionViewCell {
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var con_ImgHeight: NSLayoutConstraint!

}

//MARK: - Collection View -
extension GenresViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading{
            return 10
        }
        return arrGenresList.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 60) / 2 , height: (collectionView.frame.size.width - 60) / 2)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresListCell", for: indexPath) as! GenresListCell
        cell.backgroundColor = UIColor.clear
        cell.imgVideo.viewCorneRadius(radius: 5.0, isRound: false)

        if isLoading{
            cell.imgVideo.image = nil
            cell.lblName.text = ""
            return cell
        }
        

        let obj = self.arrGenresList[indexPath.row]
        cell.lblName.configureLable(textColor: UIColor.primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 16.0, text: obj.name?.capitalizingFirstLetter() ?? "")
        
        //SET IMAGE
        cell.imgVideo.backgroundColor = UIColor.grayLight
        cell.imgVideo.image = UIImage(named: obj.image ?? "")

        
//        if let strImg = obj.image{
//            let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
//            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
//                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
//            }
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //MOVE ARTISTS SCREEN
        let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "ArtistsViewController") as? ArtistsViewController{
            newViewController.strRadioID = self.arrGenresList[indexPath.row].id ?? 0
            newViewController.filterName = self.arrGenresList[indexPath.row].name ?? ""
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}


 
//extension GenresViewController {
//
//
//    func extractInfo(url: URL) {
//        guard let youtubeDL = youtubeDL else {
//            loadPythonModule()
//            return
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let (_, info) = try youtubeDL.extractInfo(url: url)
//                DispatchQueue.main.async {
////                    print(info?.formats)
//                    self.checkOutVideoUrl(info: info)
//                }
//            }
//            catch {
//            }
//        }
//    }
//
//
//
//    func checkOutVideoUrl(info: Info?){
//        guard let formats = info?.formats else {
//            return
//        }
//
//
//        let _bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
//        let _bestVideo = formats.filter {
//            $0.isVideoOnly && (isTranscodingEnabled || !$0.isTranscodingNeeded) }.last
//        let _best = formats.filter { !$0.isRemuxingNeeded && !$0.isTranscodingNeeded }.last
//        print(_best ?? "no best?", _bestVideo ?? "no bestvideo?", _bestAudio ?? "no bestaudio?")
//
//        print(_bestVideo?.urlRequest?.url)
//        print(_bestAudio?.urlRequest?.url)
//        play(url: (_best?.urlRequest?.url)!)
//
////        guard let best = _best, let bestVideo = _bestVideo, let bestAudio = _bestAudio,
////              let bestHeight = best.height, let bestVideoHeight = bestVideo.height
//////              , bestVideoHeight > bestHeight
////        else
////        {
////            print(_bestVideo?.urlRequest?.url)
////            print(_bestAudio?.urlRequest?.url)
////            return
////        }
//    }
//    func loadPythonModule() {
//        guard FileManager.default.fileExists(atPath: YoutubeDL.pythonModuleURL.path) else {
//            downloadPythonModule()
//            return
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                self.youtubeDL = try YoutubeDL()
//                DispatchQueue.main.async {
//
//                    self.url.map { self.extractInfo(url: $0) }
//                }
//            }
//            catch {
//                print(#function, error)
//
//            }
//        }
//    }
//
//    func downloadPythonModule() {
//        YoutubeDL.downloadPythonModule { error in
//            DispatchQueue.main.async {
//                guard error == nil else {
//                    return
//                }
//
//                self.loadPythonModule()
//            }
//        }
//    }
//
//
////    private func playBackgoundVideo(strUrl : URL) {
////        player = AVPlayer(url: strUrl)
//////        let playerLayer = AVPlayerLayer(player: player)
//////        playerLayer.frame = self.view.bounds
//////        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//////        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil) { (_) in
//////            self.player?.seek(to: CMTime.zero)
//////            self.player?.play()
//////        }
//////        self.view.layer.addSublayer(playerLayer)
//////        player?.volume = 0
////        player?.play()
////    }
//
//    func play(url: URL) {
//        let item = AVPlayerItem(url: url)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
//
//        playerVideo = AVPlayer(playerItem: item)
//        playerVideo?.play()
//
//                let playerLayer = AVPlayerLayer(player: playerVideo)
//                playerLayer.frame = self.view.bounds
//                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
////                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil) { (_) in
////                    self.player?.seek(to: CMTime.zero)
////                    self.player?.play()
////                }
//                self.view.layer.addSublayer(playerLayer)
//
//    }
//
//    @objc func playerDidFinishPlaying(note: NSNotification) {
//        // Your code here
//        print("done")
//    }
//}


// MARK: AppOpenAdManagerDelegate
extension GenresViewController : AppOpenAdManagerDelegate{
    func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager) {
        isAppOpneAds = true
    }
}
