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
        self.laImage = laImage
        // TODO: load and update image
    }
    
    private func commonInit() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named:"Portal_Venuos_1",
                            in: MainStoryboard.bundle,
                            compatibleWith: nil)
        imageView.image = image
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
}
