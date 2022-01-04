//
//  AddPlayList.swift
//  SAMUH
//
//  Created by Jigar Khatri on 23/06/21.
//

import UIKit
import Photos

protocol AddPlayListPROTOCOL {
    func addPlayerSuccess()
}

class AddPlayList: UIView, UITableViewDelegate ,UITableViewDataSource{
    var delegate : AddPlayListPROTOCOL? = nil
    var imgProfile : UIImage!
    let picker = UIImagePickerController()

    //VIEW
    @IBOutlet weak var tblView: UITableView!

    @IBOutlet weak var subView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet weak var con_ViewHieght: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!

    @IBOutlet weak var btnCreate: UIButton!

    // method to load reasons xib.
    func loadPopUpView(selectValue : String) {
        // ContactUS name of the XIB.
        Bundle.main.loadNibNamed("AddPlayList", owner:self, options:nil)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        self.subView.layer.cornerRadius = 10.0
        self.mainView.frame = self.bounds
        self.addSubview(self.mainView)
        self.mainView.layoutIfNeeded()
        

        //SET CONSTANT
        con_ViewHieght.constant =  manageWidth(size: checkDeviceiPad() ? 800 : 600)

        //SET ANIMATION
        self.subView.transform = CGAffineTransform(scaleX: 0.2, y:0.2)
        UIView.animate(withDuration:1.0, delay: 0.0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: [], animations:
            {
                self.subView.transform = CGAffineTransform(scaleX: 1.0, y:1.0)
        }, completion:nil)
        
       

        //SET TABLE 
        self.tblView.register(UINib(nibName: "AddPlayListCell", bundle: nil), forCellReuseIdentifier: "AddPlayListCell")
        self.tblView.dataSource = self
        self.tblView.delegate = self
        self.tblView.reloadData()
        

        //SET FONT
        setTheView()
    }
    
    func removeViewWithAnimation() {
        self.subView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.1, animations: {
            self.subView.transform = CGAffineTransform(scaleX: 1.01, y:1.01)
        } ,completion:{ (finished) in
            if(finished) {
                self.alpha = 1.0
                UIView.animate(withDuration:0.5, animations: {
                    self.alpha = 0
                    self.subView.transform = CGAffineTransform(scaleX: 0.2, y:0.2)
                }, completion: { (finished) in
                    if(finished) {
                        self.removeFromSuperview()
                    }
                })
            }
        })
    }
    
    //SET THE VIEW
    func setTheView() {
        //SET FONT
        lblTitle.configureLable(textColor: UIColor.secondary, fontName: GlobalConstants.APP_FONT_Medium, fontSize: 16.0, text: str.strPlaylistTitle)
        

        btnCreate.configureLable(bgColour: UIColor.standard, textColor: .primary, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: str.strCreat)
        btnCreate.btnCorneRadius(radius: 5, isRound: false)

        
        //SET VIEW
        self.subView.backgroundColor = UIColor.primary
        self.subView.viewCorneRadius(radius: 10.0, isRound: false)
    }
    
    //......................... OTHER FUNCION .........................//
    @IBAction func btnCloseClicked(_ sender: Any) {
        removeViewWithAnimation()
    }
    
    @IBAction func btnCeratPlaylistClicked(_ sender: UIButton) {
        self.endEditing(true)
        
        let index = IndexPath(row: 0, section: 0)
        let cell: AddPlayListCell = self.tblView.cellForRow(at: index) as! AddPlayListCell
        
        //CHECK VALIDATION
        let strName: String = cell.txtName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
      
        if strName == ""{
            showAlertMessage(strMessage: str.errorName)
        }
        else{
            print(cell.objSwitchCollaborative.isOn)
            addNewPlayListAPI(NewPlaylistParameater: NewPlaylistParameater(name: strName, description: cell.txtDescription.text, image: "", strPublic: cell.objSwitchCollaborative.isOn, collaborative: cell.objSwitchPublic.isOn))
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPlayListCell", for: indexPath) as! AddPlayListCell
        cell.selectionStyle = .none
        
        //SET IMAGE
        cell.imgUploadImage.viewCorneRadius(radius: 5.0, isRound: false)
        if imgProfile != nil{
            cell.imgUploadImage.image = imgProfile
        }
        
        //SET BUTTON ACTION
        cell.btnUploadImage.addTarget(self, action: #selector(self.btnUploadImageClicked(_:)), for: .touchUpInside)

       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    @objc func btnUploadImageClicked(_ sender:Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: str.Gallery, style: UIAlertAction.Style.default, handler: { (action) in
            self.showPickerController(self.picker, withSourceType: .photoLibrary)
            
        }))
        alert.addAction(UIAlertAction(title: str.Camera, style: UIAlertAction.Style.default, handler: { (action) in
            self.showPickerController(self.picker, withSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: str.Close, style: UIAlertAction.Style.cancel, handler: nil))
        GlobalConstants.appDelegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}








//MARK: - IMAGE PICKER
extension AddPlayList : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    private func showPickerController(_ pickerController: UIImagePickerController,
                                      withSourceType sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image", "public.movie"]
        let show: (UIImagePickerController) -> Void = {(pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                
                GlobalConstants.appDelegate?.window?.rootViewController?.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let accessDenied: (_ withSourceType: UIImagePickerController.SourceType) -> Void = { (sourceType) in
            let typeName = sourceType == .camera ? "Camera" : "Photos"
            let title = "\(typeName) Access Disabled"
            let message = "You can allow access to \(typeName) in Settings"
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]
                    , completionHandler: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                GlobalConstants.appDelegate?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        //Check Access
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
                
            @unknown default:
                print("")
            }
        } else {
            //Photo Library Access
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            case .limited:
                break
            @unknown default:
                print("")
            }
        }     }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgProfile = pickedImage
            tblView.reloadData()
            
            //UPDATE USRE PROFILE
            UploadProfilePicAPI()
        }
        
        GlobalConstants.appDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        GlobalConstants.appDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}



extension AddPlayList :WebServiceHelperDelegate{

   
    func UploadProfilePicAPI(){
        ImpactGenerator()
        
        //Declaration URL
        let strURL = "\(Url.uploadImage.absoluteString!)"

        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "updateProfilePic"
        webHelper.methodType = "post"
        webHelper.strURL = strURL
        webHelper.dictType = [:]
        webHelper.dictHeader = NSDictionary()
        webHelper.delegateWeb = self
        webHelper.showLogForCallingAPI = true
        webHelper.serviceWithAlert = true
        webHelper.indicatorShowOrHide = true
        webHelper.imageUpload = imgProfile
        webHelper.imageUploadName = "file"
        webHelper.startDownloadWithImage()
    }
    
    
    struct NewPlaylistParameater: Codable {
        var name: String
        var description: String
        var image: String
        var strPublic: Bool
        var collaborative: Bool
    }

    
    func addNewPlayListAPI(NewPlaylistParameater : NewPlaylistParameater){
        ImpactGenerator()
        indicatorShow()
        guard var parameater = try? NewPlaylistParameater.asDictionary() else {
            showAlertMessage(strMessage: str.invalidRequestParamater)
            return
        }

        if let keyData = parameater["strPublic"]{
            parameater.removeValue(forKey: "strPublic")
            parameater["public"] = keyData
        }
        
        //Declaration URL
        let strURL = "\(Url.addNewPlayList.absoluteString!)"
        
        //Create object for webservicehelper and start to call method
        let webHelper = WebServiceHelper()
        webHelper.strMethodName = "addNewPlayList"
        webHelper.methodType = "get"
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
        delegate?.addPlayerSuccess()
        removeViewWithAnimation()
    }
    
    func appArrayDataDidSuccess(_ arrData: NSArray, selectIndexSection: Int, selectIndexRow: Int, request strRequest: String) {
    }

    func appDataDidFail(_ error: Error, request strRequest: String) {
        indicatorHide()
        showAlertMessage(strMessage: str.somethingWentWrong)
    }
}
