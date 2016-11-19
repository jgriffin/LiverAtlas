//
//  ModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/18/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class ModalityPanelView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var specificDiagnosisHeading: UILabel!
    @IBOutlet var specificDiagnosisLabel: UILabel!
    @IBOutlet var liverImagesCollectionView: UICollectionView!
    @IBOutlet var imagingFeaturesHeading: UILabel!
    @IBOutlet var imagingFeaturesLabel: UILabel!
    @IBOutlet var structuralFeaturesHeading: UILabel!
    @IBOutlet var structuralFeaturesLabel: UILabel!
    
    var parentNavigationController: UINavigationController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        titleLabel = UILabel()
        specificDiagnosisHeading = UILabel()
        specificDiagnosisLabel = UILabel()

        imagingFeaturesHeading = UILabel()
        imagingFeaturesLabel = UILabel()
        structuralFeaturesHeading = UILabel()
        structuralFeaturesLabel = UILabel()
        
        let imagesLayout = UICollectionViewFlowLayout()
        imagesLayout.itemSize = CGSize(width: 100, height: 150)
        liverImagesCollectionView = IntrinsicSizeCollectionView(frame: self.bounds,
                                                                collectionViewLayout: imagesLayout )
        liverImagesCollectionView.backgroundColor = UIColor.white
        
        let views: [UIView] = [
            titleLabel,
            specificDiagnosisHeading, specificDiagnosisLabel,
            liverImagesCollectionView,
            imagingFeaturesHeading, imagingFeaturesLabel,
            structuralFeaturesHeading, structuralFeaturesLabel
        ]
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            (view as? UILabel)?.numberOfLines = 0
        }

        styleTheLabels()
        
        liverImagesCollectionView.register(UINib(nibName: "ImageTileCollectionViewCell",
                                                 bundle: Bundle(for: type(of:self))),
                                           forCellWithReuseIdentifier: ImageTileCollectionViewCell.identifier)
    }

    func styleTheLabels() {
        
        // set the fonts
        let textStyleForLabels: [UIFontTextStyle: [UILabel]] = [
            .headline: [
                titleLabel
            ],
            .subheadline: [
                specificDiagnosisLabel,
            ],
            .caption1: [
                specificDiagnosisHeading,
                imagingFeaturesHeading,
                structuralFeaturesHeading,
                ],
            .body: [
                imagingFeaturesLabel,
                structuralFeaturesLabel
            ]
        ]
        for (textStyle, labels) in textStyleForLabels {
            let font = UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: nil)
            
            labels.forEach { $0.font = font }
        }
    }
    
    func createConstraints() {
        let views: [String: UIView] = [
            "title": titleLabel,
            "specificHeading": specificDiagnosisHeading,
            "specific": specificDiagnosisLabel,
            "liverImages": liverImagesCollectionView,
            "imagingFeaturesHeading": imagingFeaturesHeading,
            "imagingFeatures": imagingFeaturesLabel,
            "structuralFeaturesHeading": structuralFeaturesHeading,
            "structuralFeatures": structuralFeaturesLabel,
        ]
        
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[title]-20-[specificHeading][specific]-20-[liverImages(150)]-20-[imagingFeaturesHeading][imagingFeatures]-20-[structuralFeaturesHeading][structuralFeatures]-20-|",
            options: [.alignAllLeading, .alignAllTrailing],
            metrics: nil,
            views: views)
        self.addConstraints(constraints)
        
        let allViewsFullWidth = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[title]|",
            options: [],
            metrics: nil,
            views: views)
        self.addConstraints(allViewsFullWidth)

    }
    
    lazy var addConstraintsOnce: Void = { self.createConstraints() }()
    override func updateConstraints() {
        let _ = addConstraintsOnce
        
        super.updateConstraints()
    }
    
    override func prepareForInterfaceBuilder() {
        setNeedsUpdateConstraints()
        super.prepareForInterfaceBuilder()
    }
}
