//
//  LightboxImageViewCell.swift
//  LiverAtlas
//
//  Created by John on 12/7/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class LightboxImageCellView: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    private var laImage: LAImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func configure(laImage: LAImage) {
        if self.laImage != nil {
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.alpha = 0.0
            })
        }
        
        LACaseFetcher.instance.loadLAImageForURL(imageURL: laImage.imageURL) {
            [weak self] (image: UIImage?, imageURL: URL, wasCached: Bool)  in
            assert(Thread.isMainThread)
            guard imageURL == laImage.imageURL else {
                return
            }
            
            self?.imageView.alpha = 0.0
            self?.imageView.image = image
            
            UIView.animate(withDuration: 0.25, animations: {
                self?.imageView.alpha = 1.0
            })
        }
    }
    
    private func commonInit() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let views = ["imageView": self.imageView!]
        let constraints = [
            "H:|-[imageView]-|",
            "V:|-[imageView]-|"
            ].flatMap { visualFormat in
                NSLayoutConstraint.constraints(
                    withVisualFormat: visualFormat,
                    options: [], metrics: nil, views: views)
        }
        self.addConstraints(constraints)
    }
    
    override func prepareForInterfaceBuilder() {
        if imageView?.image == nil {
            imageView.image = UIImage(named:"Portal_Venuos_1",
                                      in: MainStoryboard.bundle,
                                      compatibleWith: nil)
        }
    }
}
