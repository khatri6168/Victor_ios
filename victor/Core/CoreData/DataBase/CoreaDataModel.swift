//
//  CoreaDataModel.swift
//  SAMUH
//
//  Created by Jigar Khatri on 15/07/21.
//

import Foundation


struct DownloadVideoParameater: Codable {
    var download_percentage : String
    var download_URL : String
    var isDownload : String
    var session_id : String
    var userID: String
    var video_artist_name : String
    var video_id : String
    var video_img : String
    var video_name : String
    var video_url: String
    var youtubID: String
}
