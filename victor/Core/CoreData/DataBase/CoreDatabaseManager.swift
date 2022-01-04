//
//  CoreDatabaseManager.swift
//  SAMUH
//
//  Created by Jigar Khatri on 13/07/21.
//

import Foundation
import CoreData

class CoreDBManager: NSObject {
    
    static let sharedDatabase = CoreDBManager()
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "VictorDataBase", withExtension: "mp4")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SamuhDataBase.sqlite")
//        UserDefaultManager.setStringToUserDefaults(value: url.path, key: LOCAL_DATABASE_PATH)
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "VictorDataBase")
        let url = self.applicationDocumentsDirectory.appendingPathComponent("VictorDataBase.sqlite")
        NSLog("Database Path: \(url)")
      //  UserDefaultManager.setStringToUserDefaults(value: url.path, key: LOCAL_DATABASE_PATH)
        
        /*add necessary support for migration*/
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions =  [description]
        /*add necessary support for migration*/
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {        return CoreDBManager.sharedDatabase.persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            DispatchQueue.main.async {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
        }
    }
    
    
    
    
    func getAllData(userID : String) -> [Download]{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!
//        let predicate1 = NSPredicate(format:"show_id == \(strID)")
//        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
   
        
        do{
            
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
            print(results)
            return try managedObjectContext.fetch(fetchRequest)

//            return try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
        }
        catch
        {
            return []
        }
    }
    
    
    
    func getAllDownloadData(userID : String) -> [Download]{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!
        
        let predicate0_1 = NSPredicate(format:"userID == %@",userID)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate0_1])
        
        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
        
        do{
            return try managedObjectContext.fetch(fetchRequest)

//            return try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
        }
        catch
        {
            return []
        }
    }
    
    func getDownloadVideosData(userID : String, videoID : String) -> [Download]{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!

        let predicate0_1 = NSPredicate(format:"userID == %@",userID)
        let predicate0_2 = NSPredicate(format:"video_id == %@",videoID)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate0_1, predicate0_2])
        
        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
        
        do{
            return try managedObjectContext.fetch(fetchRequest)

            
//            return try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
        }
        catch
        {
            return []
        }
    }
    
    
    //====UPDATE DATABASE=====
    func updateDownalodURL(strUserID : String, videoID : String, download_percentage : String ,sessionID : String , isisDownload : String, FileName : String, videoURL : String, complete:@escaping (_ isSave:Bool) -> ()){
        
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!

        let predicate0_1 = NSPredicate(format:"video_id == %@",videoID)
        let predicate0_2 = NSPredicate(format:"userID == %@",strUserID)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate0_1, predicate0_2])
        
        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
      
        
        do{
            var objCDDownloadShow:Download!
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
            if(results.count != 0)
            {
                let obj = results[0]
                objCDDownloadShow = results[0] as Download
                objCDDownloadShow.download_percentage = download_percentage
                objCDDownloadShow.download_URL = FileName
                objCDDownloadShow.isDownload = isisDownload
                objCDDownloadShow.session_id = sessionID
                objCDDownloadShow.userID = strUserID
                objCDDownloadShow.video_artist_name = obj.video_artist_name
                objCDDownloadShow.video_id = videoID
                objCDDownloadShow.video_img = obj.video_img
                objCDDownloadShow.video_name = obj.video_name
                if obj.video_url == ""{
                    objCDDownloadShow.video_url = videoURL
                }
                else{
                    objCDDownloadShow.video_url = obj.video_url
                }
                
                                
                self.saveContext()
                complete(true)
            }
            else{
                complete(false)
            }
        }
        catch
        {
            print("CHAT SYNCH FAILED")
        }
        
    }
    
    
    func deleteDownloadVideo(userID : String, videoID : String,complete:(_ isDone:Bool) -> ()){
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!

        let predicate0_1 = NSPredicate(format:"userID == %@",userID)
        let predicate0_2 = NSPredicate(format:"video_id == %@",videoID)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate0_1, predicate0_2])
        
        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
            if(results.count != 0)
            {
                for result in results {
                    objContext.delete(result)
                }
            }
            self.saveContext()
            complete(true)
        }
        catch
        {
            complete(false)
        }
    }
    
    
    func saveDownalodURL(objSaveShowData:DownloadVideoParameater,complete:@escaping (_ isSave:Bool) -> ()){
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<Download>(entityName: "Download")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Download", in: objContext)!
        let predicate0_1 = NSPredicate(format:"video_id == \(objSaveShowData.video_id)")
        let predicate0_2 = NSPredicate(format:"userID == %@",objSaveShowData.userID)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate0_1, predicate0_2])

        fetchRequest.predicate = predicate1
        fetchRequest.entity = disentity
        
        do{
            var objCDDownloadShow:Download!
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Download]
            if(results.count == 0)
            {
         
                objCDDownloadShow = (NSEntityDescription.insertNewObject(forEntityName:"Download",into:managedObjectContext) as? Download)!
                
                objCDDownloadShow.download_percentage = objSaveShowData.download_percentage
                objCDDownloadShow.download_URL = objSaveShowData.download_URL
                objCDDownloadShow.isDownload = objSaveShowData.isDownload
                objCDDownloadShow.session_id = ""
                objCDDownloadShow.userID = objSaveShowData.userID
                objCDDownloadShow.video_artist_name = objSaveShowData.video_artist_name
                objCDDownloadShow.video_id = objSaveShowData.video_id
                objCDDownloadShow.video_img = objSaveShowData.video_img
                objCDDownloadShow.video_name = objSaveShowData.video_name
                objCDDownloadShow.video_url = objSaveShowData.video_url

                self.saveContext()
                complete(true)
            }
        }
        catch
        {
            print("CHAT SYNCH FAILED")
        }
    }
}




