//
//  IntrinsicSizeCollectionView.swift
//  LiverAtlas
//
//  Created by John on 11/6/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class IntrinsicSizeCollectionView: UICollectionView {

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
