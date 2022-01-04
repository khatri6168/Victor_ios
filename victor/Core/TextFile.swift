//
//  TextFile.swift
//  User
//
//  Created by jigar on 11/01/21.
//

import Foundation
func languageChangeNotification(){
    
    str = Text()
    NotificationCenter.default.post(name: .languageUpdate, object: nil, userInfo: nil)
}

var str = Text()

//func phoneCode () -> String{
//    let arrCountryCodeList = CountryCode.shared.all()
//    let countryCode = Country_Code
//
//    //CHECK OBJECT IS ADD
//    let MenuID = arrCountryCodeList.map{$0.country_code.lowercased()}
//    if let index = MenuID.firstIndex(of: countryCode.lowercased()) {
//        return arrCountryCodeList[index].code
//    }
//    return "+966"
//}
//
//func curentCode () -> String{
//    let arrCountryCodeList = CountryCode.shared.all()
//    let countryCode = Country_Code
//
//    //CHECK OBJECT IS ADD
//    let MenuID = arrCountryCodeList.map{$0.country_code.lowercased()}
//    if let index = MenuID.firstIndex(of: countryCode.lowercased()) {
//        return arrCountryCodeList[index].country_code
//    }
//    return "IN"
//}
    

struct Text {
//    var countryCode = curentCode()
//    var phone_code = phoneCode()
    var appName  = "Victor".localized()
    
    //LOGIN SCREEN
    var loginTitle = "Sign in to your account".localized()
    var strEmail = "Email".localized()
    var strPassword = "Password".localized()
    var strConfirmPass = "Confirm Password".localized()

    var strForgotPassword = "Forgot your password?".localized()
    var strSignUp = "Don't Have An Account? Sign Up".localized()
    var strRemember = "Stay signed in for a month".localized()
    var strContinue = "Continue".localized()
    var FreeMusic = "© Free Music".localized()
    
    var errorEmail = "Please enter email".localized()
    var errorValidEmail = "Please enter valid email".localized()
    var errorPassword = "Please enter password".localized()
    var errorConfirmPassword = "Please enter confirm password".localized()
    var errorPasswordNotMatch = "The Password and Confirm Password do not match.".localized()
    var errorValidPassword = "The password must be at least 5 characters long".localized()
    var errorInvalidDetails = "These credentials do not match our records.".localized()

    
    //SIGNUP SCREEN
    var singupTitle = "Create a new account".localized()
    var strSignup = "Create Account".localized()
    var strLoginSignup = "Already Have An Account? Sing in.".localized()

    
    //TABBAR
    var genres = "Genres".localized()
    var home = "Home".localized()
    var top50 = "Top 50".localized()
    var populerTrack = "Popular Tracks".localized()
    var search = "Search".localized()
    var songs = "Songs".localized()
    var download = "Downloads".localized()
    var account = "Account".localized()
    var getMoreCoine = "Get More Coins".localized()
    var coins = "Coins :".localized()
    var whatchAds = "Watch a short ad".localized()

    //ARTISTS
    var strArtists = "Artists".localized()
    var strPlay = "Play".localized()
    var strMore = "More".localized()
    var strMore2 = "More..".localized()
    var strDiscography = "Discography".localized()
    var strSimilarArtists = "Similar Artists".localized()
    var strAbout = "About".localized()
    
    var strAlbums = "Albums".localized()
    var strPopularSongs = "Popular Songs".localized()
    
    var strShowMore = "Show More".localized()
    
    //MORE TAB
    var strProfile = "Profile"
    var strTrackRadio = "Go to Track Radio".localized()
    var strAddQueue = "Add to Queue".localized()
    var strRemoveQueue = "Remove from Queue".localized()
    var strAddPlaylist = "Add to Playlist >".localized()
    var strSaveMusic = "Save to Your Music".localized()
    var strRemoveMusic = "Remove from Your Music".localized()
    var strLyrics = "Show Lyrics".localized()
    var strCopyTrack = "Copy Track Link".localized()
    var strShare = "Share".localized()
    
    var strFollow = "Follow".localized()
    var strUnfollow = "Unfollow".localized()

    var noDataFountAboutUs = "Could not find biography for".localized()
    
    
    //YOUR MUSIC
    var strSongs = "Songs".localized()
    var strPlaylist = "Playlists".localized()
    var strAlbume = "Albume".localized()
    
    var strSongTitle = "Liked tracks".localized()
    var songSearchPlaceholder = "Search within tracks...".localized()
    var playlistSearchPlaceholder = "Search within playlist...".localized()
    var artistsSearchPlaceholder = "Search artists...".localized()
    var albumeSearchPlaceholder = "Search albume...".localized()

    var noSongData = "Nothing to display.".localized()
    var noSongDataDetails = "You have not added any songs to your library yet.".localized()
    
    var noArtistsDataDetails = "You have not added any artists to your library yet.".localized()

    var noAlbumeDataDetails = "You have not added any albume to your library yet.".localized()
    
    var noPlaylistDataDetails = "You have not added any playlist to your library yet.".localized()

    var SearchData = "Search Free Music".localized()
    var SearchDetails = "Find artists, albums, songs, playlists and more.".localized()

    var noSearchData = "No results for «".localized()
    var noSearchDetails = "Please check your spelling or try using different keywords.".localized()

    //ADD PLAYLIST
    var strPlaylistTitle = "New Playlist".localized()
    var strName = "Name".localized()
   
    var strCollaborative = "Collaborative".localized()
    var strCollaborativeDetails = "Invite other users to add tracks.".localized()

    var strPublic = "Public".localized()
    var strPublicDetails = "Everyone can see public playlists.".localized()

    var strCreat = "Create".localized()
    var strDescription = "Description".localized()

    var strUploadImg = "Upload Image".localized()
    
    //SEARCH
    var searchTitle = "Search..".localized()
    var topResults = "Top Results".localized()
    
    //ACCOUNT
    var strLogin = "Login".localized()
    var strRegister = "Register".localized()
    
    var strAccountSetting = "Account Settings".localized()
    var strNotificaiotn = "Notificaiotns".localized()
    var strDarkMode = "Dark Mode".localized()
    var strLightMode = "Light Mode".localized()
    var strLogOut = "LogOut".localized()
    
    var areYouSureYouWantToLogout = "Are you sure you want to Logout?".localized()
    var yes = "Yes".localized()
    var no = "No".localized()
    var streSelect = "Select".localized()
    var strCancel = "Cancel".localized()

    
    //DOWNLOAD
    var removeDownload = "Are you sure you want to remove this Music?".localized()
    var cancelDownload = "Are you sure you want to stop downloading this Music?".localized()
    var deleteDownload = "Are you sure you want to delete downloading this Music?".localized()

    
    //ACCOUNT SETTING
    var AccountSettingTitle = "View and update your account details, profile and more.".localized()
    var updateProfile = "Update Name or Profile Image".localized()
    var strFirstName = "First Name".localized()
    var strLastName = "Last Name".localized()
    var strProfileImg = "Profile image".localized()
    var strProfileImgTitle = "For best results, upload a high resolution image.".localized()
    var strUploadImage = "Upload Image".localized()
    var strSave = "Save Changes".localized()

    var updatePassword = "Update Password".localized()
    var strCurrentPassword = "Current Password".localized()
    var strNewPassword = "New Password".localized()
    var strUpdate = "Update".localized()
    
    var updatePreferences = "Update Account Preferences".localized()
    var strLanguage = "Language".localized()
    var strCountry = "Country".localized()
    var strTimezone = "Timezone".localized()
    
    var deleteAccounttitle = "Danger Zone".localized()
    var deleteAccount = "Delete Account".localized()

    var errorFirstName = "Please enter first name".localized()
    var errorLastName = "Please enter last name".localized()
    var errorName = "Please enter name".localized()

    var Gallery = "Gallery".localized()
    var Camera = "Camera".localized()
    var Close = "Close".localized()
    var Back = "Back".localized()
    
    var DeleteAccount = "Delete Account".localized()
    var DeleteAccountText = "Your account will be deleted immediately and permanently. Once deleted, accounts can not be restored.\n\nDo you want to delete the account?".localized()
    
    
    
    
    
    
    
    
    
    //NO DATA
    var strNoData = "Nothing to display".localized()
    var strNoDataDetails = "Seems like this channel does not have any content yet.".localized()
    
    var strNoDownloadData = "You have not downloaded any music yet.".localized()
    var strNoDownload = "Nothing to downloaded".localized()

    //NO DATA FOUND
    var strRetry = "Retry".localized()
    var somethingWentWrong = "Something went wrong!".localized()
    var noNetTitle = "No Internet".localized()
    var noNetTitle2 = "Please check your network connectivity\nand try again".localized()
    var invalidRequestParamater = "Invalid request parameter".localized()
    var notValidNumber = "Not valid mobile number".localized()
    var notValidOTP = "Not valid otp number".localized()
    var noValideMobileNumber = "This mobile number already exists".localized()
    var tokenValidation = "You have reached the maximum concurrent sessions allowed.".localized()
    var contentNotAvailable = "This content is not available in your country".localized()
   
}
