//
//  Download+CoreDataProperties.swift
//  
//
//  Created by Jigar Khatri on 03/12/21.
//
//

import Foundation
import CoreData


extension Download {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Download> {
        return NSFetchRequest<Download>(entityName: "Download")
    }

    @NSManaged public var download_percentage: String?
    @NSManaged public var download_URL: String?
    @NSManaged public var isDownload: String?
    @NSManaged public var video_url: String?
    @NSManaged public var video_img: String?
    @NSManaged public var video_name: String?
    @NSManaged public var video_artist_name: String?
    @NSManaged public var video_id: String?
    @NSManaged public var session_id: String?
    @NSManaged public var userID: String?c
    @NSManaged public var youtubID: String?c
    

}
