//
//  ImageTileCollectionViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class ImageTileCollectionViewCell: UICollectionViewCell {
    static let nibName = "ImageTileCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    
    var laImage: LAImage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(laImage: LAImage) {
        imageView?.image = nil
        
        LACaseFetcher.instance.loadLAImageForURL(imageURL: laImage.imageURL) {
            [weak self] (image: UIImage?, imageURL: URL, wasCached: Bool)  in
            assert(Thread.isMainThread)

            self?.imageView?.image = image            
        }
        imageTitle?.text = laImage.imagePhase
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
