//
//  SaveAlbumsViewController.swift
//  victor
//
//  Created by Jigar Khatri on 18/11/21.
//

import UIKit
import Nuke

class SaveAlbumsViewController: UIViewController {
    //DECLARE VARIABLE
    @IBOutlet weak var objCollection: UICollectionView!

    @IBOutlet weak var viewBG: UIView!

    @IBOutlet weak var lblHeader: UILabel!

    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewLine: UIView!

    @IBOutlet var emptyDataView : EmptyDataView!{
        didSet{
            emptyDataView.isHidden = true
        }
    }
    
    var arrSaveAlbumeList : [TrackModel] = []
    var arrSearchSaveAlbumeList : [TrackModel] = []

    var isLoading : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //SET NODATA
        self.emptyDataView.noSaveAlbume()
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
        self.getSaveAlbumeListAPI()
    }
 
    
    func setTheView(){
        self.objCollection.reloadData()

        //SET SEARCH VIEW
        self.viewSearch.backgroundColor = .clear
        self.viewSearch.viewCorneRadius(radius: 5.0, isRound: false)
        self.viewSearch.viewBorderCorneRadius(borderColour: .gray)

        self.lblHeader.text = "\(str.strAlbums)"
        if self.arrSaveAlbumeList.count != 0{
            self.lblHeader.text = "\(self.arrSaveAlbumeList.count) \(str.strAlbums)"
        }
    }
    
    func setTheFont(){

        //SET FONT
        lblHeader.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Bold, fontSize: 20.0, text: "\(str.strAlbums)")
        
        txtSearch.configureText(bgColour: .clear, textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 14.0, text: "", placeholder: str.albumeSearchPlaceholder)
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
        self.arrSearchSaveAlbumeList = []
        self.arrSearchSaveAlbumeList = self.arrSaveAlbumeList.filter { Int((($0.name?.lowercased()) as NSString?)?.range(of: strSearch.lowercased()).location ?? 0) != NSNotFound}

        //RELOAD TABLE
        self.objCollection.reloadData()
        self.emptyDataView.isHidden = true
        self.viewLine.isHidden = false

        if txtSearch.text != ""{
            if arrSearchSaveAlbumeList.count == 0{
                self.emptyDataView.isHidden = false
                self.viewLine.isHidden = true
            }
        }
        
    }
}



extension SaveAlbumsViewController:  UITextFieldDelegate {
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




//MARK: - Collection View -
extension SaveAlbumsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading && UserDefaults.standard.user != nil{
            return 10
        }
        else{
            if txtSearch.text != ""{
                return arrSearchSaveAlbumeList.count
            }
            else{
                return arrSaveAlbumeList.count
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 60) / 2 , height: ((collectionView.frame.size.width - 60) / 2) + manageWidth(size: 70))
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresListCell", for: indexPath) as! GenresListCell
        cell.backgroundColor = UIColor.clear
        cell.imgVideo.viewCorneRadius(radius: 5.0, isRound: false)
        cell.con_ImgHeight.constant = (collectionView.frame.size.width - 60) / 2
        
        if isLoading{
            cell.imgVideo.image = nil
            cell.lblName.text = ""
            return cell
        }
        
        //GET DATA
        let objData : TrackModel!
        if txtSearch.text != ""{
            objData = self.arrSearchSaveAlbumeList[indexPath.row]
        }else{
            objData = self.arrSaveAlbumeList[indexPath.row]
        }
        cell.lblName.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 16.0, text: objData.name?.capitalizingFirstLetter() ?? "")
        
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
        
        cell.lblSubTitle.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: strArtist)
        
        
        //SET IMAGE
        cell.imgVideo.backgroundColor = UIColor.grayLight
        if let strImg = objData.image{
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
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumeListViewController") as? AlbumeListViewController{
            if txtSearch.text != ""{
                newViewController.strArtistsID = self.arrSearchSaveAlbumeList[indexPath.row].id ?? 0
            }
            else{
                newViewController.strArtistsID = self.arrSaveAlbumeList[indexPath.row].id ?? 0
            }
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}


 
