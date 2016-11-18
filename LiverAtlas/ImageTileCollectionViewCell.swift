//
//  ImageTileCollectionViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class ImageTileCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImageTileCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    
    var liverAtlasImage: LiverAtlasImage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(liverAtlasImage: LiverAtlasImage) {
        imageView?.image = nil
        
        LiverAtlasCaseCrawler.instance.loadLiverAtlasImageForURL(imageURL: liverAtlasImage.image) { [weak self] (image: UIImage?)  in
            assert(Thread.isMainThread)

            self?.imageView?.image = image            
        }
        imageTitle?.text = liverAtlasImage.imagePhase
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
