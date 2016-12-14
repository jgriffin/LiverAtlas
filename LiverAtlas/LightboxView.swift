//
//  LightboxEmbededViewController.swift
//  LiverAtlas
//
//  Created by John on 12/4/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class LightboxView: UIView {
    @IBOutlet var headerView: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var laImages: LAModalityImages?

    func configure(laModalityImages modalityImages: LAModalityImages?) {
        self.laImages = modalityImages
        headerView?.text = modalityImages?.imagingFindings
        collectionView.reloadData()
        setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        
        headerView = UILabel(frame: frame)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.numberOfLines = 2
        headerView.font = UIFont.preferredFont(forTextStyle: .title1)
        headerView.text = laImages?.imagingFindings
        addSubview(headerView)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 150, height: 100)

        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layer.cornerRadius = 5
        collectionView.layer.borderWidth = 2
        collectionView.layer.borderColor = UIColor.darkGray.cgColor
        collectionView.backgroundColor = UIColor.cyan        
        addSubview(collectionView)

        registerReusableCollectionViews()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupConstraints()
        setNeedsLayout()
    }

    let LightboxImageCellViewID = "LightboxImageCellViewID"
    
    func registerReusableCollectionViews() {
        collectionView.register(LightboxImageCellView.self,
                                forCellWithReuseIdentifier: LightboxImageCellViewID)
    }

    private func setupConstraints() {
        let views: [String: UIView] = [
            "headerView" : headerView,
            "collectionView" : collectionView
        ]
        
        let constraints = [
            "H:|-[headerView]-|",
            "H:|-[collectionView]-|",
            "V:|-[headerView]-[collectionView]-|"].flatMap { formatString in
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: [], metrics: nil, views: views)
        }
        addConstraints(constraints)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let laCase = LAIndex.instance.case6
        configure(laModalityImages: laCase.ctmodality.first)
    }
}

extension LightboxView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return laImages == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return laImages?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let laImage = laImages!.images[indexPath.item]

        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: LightboxImageCellViewID,
                                                           for: indexPath) as! LightboxImageCellView
        imageCell.configure(laImage: laImage)
        return imageCell
    }
}




