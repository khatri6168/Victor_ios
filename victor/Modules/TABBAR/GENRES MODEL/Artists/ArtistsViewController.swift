//
//  ArtistsViewController.swift
//  victor
//
//  Created by Jigar Khatri on 10/11/21.
//

import UIKit
import Nuke

class ArtistsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //SET VIEW VALUES
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    
    //LOAD MORE
    var strRadioID : Int = 0

    var filterName : String = ""
    var _loadingView: UIActivityIndicatorView!
    var bool_Load: Bool = false
    var objRefresh : UIRefreshControl?
    var isLoading : Bool = true

    var arrArtistsList : [GenresModel] = []
    var pageCount : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //SET REFRSH CONTROL
        self.objRefresh = UIRefreshControl()
        self.objRefresh?.tintColor = setTextColour()
        self.objRefresh?.addTarget(self, action: #selector(self.refreshList), for: .valueChanged)
        self.tblView.addSubview(self.objRefresh!)
        
        self.refreshList()
        
        //SET NODATA
        self.emptyDataView.noArtists()
        self.emptyDataView.isHidden = true

    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        showToast(sender: self.view, message: "sfs")
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tblView.reloadData()
        }
        
        //SET VIEW
        self.view.backgroundColor = setColour()
      
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        
        //SET NAVIGATION BAR
        setNavigationBarTowButtonFor(controller: self, title: str.strArtists, isTransperent: true, hideShadowImage: false, leftIcon: "icon_back", rightIcon: "icon_radio") { SelectTag in
            self.navigationController?.popViewController(animated: true)
        } rightActionHandler: {SelectTag in
            if SelectTag == 1{
                //SEARCH
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.SEARCH_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            else if SelectTag == 2{
                //MOVE RADIO SCREEN
                let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "RadioListViewController") as? RadioListViewController{
                    newViewController.strRadioID = self.strRadioID
                    newViewController.isRadioTrack = ""
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
        }
        
        //SET FFONT
        self.setupTableView()
     }
    
    @objc func refreshList() {
        //GET DETAILS
        self.pageCount = 1
        self.arrArtistsList = []
        self.ArtistsAPI(GenresParameater: GenresParameater(filter: filterName, page: "\(pageCount)"))
    }
}


//.......................... UITABLE VIEW ..........................//


//MARK: -- UITABEL DELEGATE --

extension ArtistsViewController : UITableViewDelegate, UITableViewDataSource{
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
                if bool_Load == false && arrArtistsList.count != 0 {

                    //Refresh code
                    self.bool_Load = true

                    //START LOADING
                    startAnimatingView()
                    
                    //GET DETAILS
                    self.ArtistsAPI(GenresParameater: GenresParameater(filter: filterName, page: "\(pageCount)"))
                }
            }
        }
    }
    
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
            cell.con_CollectionViewHeight.constant = ((tableView.frame.size.width - 60) / 2) * CGFloat((arrArtistsList.count + 1) / 2)
        }

        
        //RELOAD COLLECTION VIEW
        cell.objCollection.reloadData()
                    
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}




//MARK: - Collection View -
extension ArtistsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading{
            return 10
        }
        return arrArtistsList.count
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
        
        let obj = self.arrArtistsList[indexPath.row]
        cell.lblName.configureLable(textColor: UIColor.primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 16.0, text: obj.name?.capitalizingFirstLetter() ?? "")
        
        //SET IMAGE
        cell.imgVideo.backgroundColor = UIColor.grayLight
        if let strImg = obj.image_small{
            let imgURL =  ("\(strImg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? ""
            if let url = URL(string: imgURL.replacingOccurrences(of: " ", with: "%20")){
                Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)), into: cell.imgVideo)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MOVE ARTISTS SCREEN
        let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.HOME_MODEL, bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeViewController") as? AlbumeViewController{
            newViewController.strArtistsID = self.arrArtistsList[indexPath.row].id ?? 0
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}


 
