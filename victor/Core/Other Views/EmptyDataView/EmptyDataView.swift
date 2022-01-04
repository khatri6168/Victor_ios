//
//  EmptyDataView.swift
//  Deonde
//
//  Created by Ankit Rupapara on 29/04/20.
//  Copyright © 2020 Ankit Rupapara. All rights reserved.
//

import UIKit

class EmptyDataView: UIView {

    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        
        backgroundColor = .clear
        
        Bundle.main.loadNibNamed("EmptyDataView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        contentView.backgroundColor = .clear
        
        contentView.widthAnchor.constraint(lessThanOrEqualToConstant: 280).isActive = true

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

//        subtitleLabel.configureLable(textColor: UIColor.secondary, fontName: GlobalConstants.APP_FONT_Regular, fontSize: 12.0, text: "")
//        subtitleLabel.numberOfLines = 0
//        subtitleLabel.textAlignment = .center
//
        imageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
    }
    
    private func configure(imageName: String = "", title: String = "", subtitle: String = "", tintColor : UIColor?){
        
        imageView.backgroundColor = .clear
        imageView.isHidden = imageName.count == 0
        imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = tintColor
        
        titleLabel.configureLable(textColor: tintColor, fontName: GlobalConstants.APP_FONT_Bold, fontSize: 14.0, text: "")
        titleLabel.isHidden = title.count == 0
        titleLabel.text = title
        
        subtitleLabel.configureLable(textColor: tintColor, fontName: GlobalConstants.APP_FONT_Light, fontSize: 14.0, text: "")
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.isHidden = subtitle.count == 0
        subtitleLabel.text = subtitle

                
        contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

extension EmptyDataView{
    func noDownload(){
        configure(imageName: "icon_downloadBG", title: str.strNoDownload, subtitle:str.strNoDownloadData, tintColor: setTextColour())
    }
    func noArtists(){
        configure(imageName: "icon_nodata", title: str.strNoData, subtitle:str.strNoDataDetails, tintColor: setTextColour())
    }

    func noSaveSongs(){
        configure(imageName: "icon_songs", title: str.noSongData, subtitle:str.noSongDataDetails, tintColor: setTextColour())
    }
    
    func noSavePlayList(){
        configure(imageName: "icon_playlist", title: str.noSongData, subtitle:str.noPlaylistDataDetails, tintColor: setTextColour())
    }
    
    func noSaveArtists(){
        configure(imageName: "icon_artists", title: str.noSongData, subtitle:str.noArtistsDataDetails, tintColor: setTextColour())
    }
    
    func noSaveAlbume(){
        configure(imageName: "icon_nodata", title: str.noSongData, subtitle:str.noAlbumeDataDetails, tintColor: setTextColour())
    }
    
    
    func noAboutUs(str : String){
        configure(imageName: "icon_NoDataAboutUs", title: "", subtitle:str, tintColor: setTextColour())
    }
    
    
    func noSearchData(strTitle : String, strDetails : String){
        configure(imageName: "icon_searchBG", title: strTitle, subtitle:strDetails, tintColor: setTextColour())
    }
    
    
}


