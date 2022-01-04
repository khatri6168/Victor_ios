//
//  SongsViewController.swift
//  victor
//
//  Created by Jigar Khatri on 08/11/21.
//

import UIKit

class SongsViewController: UIViewController, SongsPageViewControllerDelegate {

    @IBOutlet weak var objHeaderCollection: UICollectionView!

    var arrMenuList : [[String : String]] = [["name" : str.strSongs ,"icon" : "icon_songs"], ["name" : str.strPlaylist ,"icon" : "icon_playlist"], ["name" : str.strArtists ,"icon" : "icon_artists"], ["name" : str.strAlbume ,"icon" : "icon_nodata"]]

    var selectIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.user == nil{
            //LOGINN SCREEN
            let storyBoard: UIStoryboard = UIStoryboard(name: GlobalConstants.LOGIN_MODEL, bundle: nil)
            if let navView = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                let vieweNavigationController = UINavigationController(rootViewController: navView)
                vieweNavigationController.modalPresentationStyle = .fullScreen
                navigationController?.present(vieweNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        tabBarPreviousIndexSelect = 3
                
        //SET VIEW
        self.view.backgroundColor = setColour()
        
        //SET NAVIGAITON AND TABBAR
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
     }
    
    
    
    //MARK: - Page view controller -
    var ProspectiveCustomersPageViewController: SongsPageViewController? {
        didSet {
            ProspectiveCustomersPageViewController?.tutorialDelegate = self
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ProspectiveCustomersViewController = segue.destination as? SongsPageViewController {
            self.ProspectiveCustomersPageViewController = ProspectiveCustomersViewController
        }
    }
    
    //MARK: - Pageview controller Delegate -
    func SongsPageViewController(_ SongsPageViewController: SongsPageViewController, didUpdatePageCount count: Int) {

    }
    
    func SongsPageViewController(_ SongsPageViewController: SongsPageViewController, didUpdatePageIndex index: Int) {
        selectIndex = index
        objHeaderCollection.reloadData()
        ProspectiveCustomersPageViewController?.scrollToViewController(index: index)
    }
}




//MARK: - Collection View -
extension SongsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrMenuList.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: CGFloat(GlobalConstants.windowWidth/4), height: collectionView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let lbl_Title : UILabel = cell.viewWithTag(100) as! UILabel
        let imgIcon : UIImageView = cell.viewWithTag(101) as! UIImageView
        
        //SET DATA
        let obj = arrMenuList[indexPath.row]
        
        //SET FONT
        lbl_Title.configureLable(textColor: UIColor.lightGray, fontName: GlobalConstants.APP_FONT_Light, fontSize: 12.0, text: "\(obj["name"] ?? "")")
        imgIcon.image = UIImage(named: "\(obj["icon"] ?? "")")
        imgColor(imgColor: imgIcon, colorHex: UIColor.lightGray)
        
        if selectIndex == indexPath.row{
            imgColor(imgColor: imgIcon, colorHex: setTextColour())
            lbl_Title.configureLable(textColor: setTextColour(), fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "\(obj["name"] ?? "")")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ProspectiveCustomersPageViewController?.scrollToPreviewsViewController(indexCall:indexPath.row)

        selectIndex = indexPath.row
        objHeaderCollection.reloadData()
    }
}
