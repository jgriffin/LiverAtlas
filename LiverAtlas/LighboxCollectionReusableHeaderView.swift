//
//  LighboxCollectionReusableHeaderView.swift
//  LiverAtlas
//
//  Created by John on 12/7/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class LightboxHeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
    
    func configure(imagingFindings: String) {
        titleLabel.text = imagingFindings
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel = LightboxHeaderView.createTitleLabel(frame: self.bounds)
        addSubview(titleLabel)
        
        setNeedsUpdateConstraints()
        backgroundColor = UIColor.yellow
    }

    
    private func addConstraints() {
        let views: [String: UIView] = ["titleLabel": titleLabel]
        
        NSLayoutConstraint.activate(
            ["H:|-[titleLabel]-|", "V:|-[titleLabel]-|"].flatMap {
                (visualFormat) -> [NSLayoutConstraint] in
                return NSLayoutConstraint.constraints(
                    withVisualFormat: visualFormat,
                    options: [], metrics: nil, views: views)
        })
    }
    private lazy var addConstraintsOnce: Void = { [weak self] in self?.addConstraints() }()
    
    override func updateConstraints() {
        let _ = addConstraintsOnce
        super.updateConstraints()
    }

    static func createTitleLabel(frame: CGRect) -> UILabel {
        let titleLabel = UILabel(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        return titleLabel
    }

    static var measureLabel: UILabel = { return createTitleLabel(frame: CGRect.zero) }()
    
    static func size(withImagingFindings imagingFindings: String, collectionViewWidth: CGFloat) -> CGSize {
        measureLabel.text = imagingFindings
        let boundRect = CGRect(x: 0, y: 0,
                               width:collectionViewWidth,
                               height:CGFloat.greatestFiniteMagnitude)
        let textRect = measureLabel.textRect(forBounds: boundRect,
                                                 limitedToNumberOfLines: measureLabel.numberOfLines)
        return CGSize(width: collectionViewWidth, height: textRect.height)
    }
    
}
