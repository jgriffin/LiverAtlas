//
//  CaseResultImageCollectionViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    var laImage: LAImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        
        let views = ["imageView": imageView!]
        let visualFormats = ["H:|[imageView]|", "V:|[imageView]|"]
        let constraints = visualFormats.flatMap { (visualFormat) -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                           options: [], metrics: nil,
                                           views: views)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(laImage: LAImage) {
        self.laImage = laImage
        self.imageView.image = nil
        
        LACaseCrawler.instance.loadLAImageForURL(imageURL: laImage.imageURL) { [weak self] (image: UIImage?)  in
            assert(Thread.isMainThread)
            guard laImage.imageURL == self?.laImage.imageURL else {
                    return
            }

            self?.imageView.alpha = 0.0
            self?.imageView.image = image
            
            UIView.animate(withDuration: 0.25, animations: {
                self?.imageView.alpha = 1.0
            })
        }
    }
    
}
