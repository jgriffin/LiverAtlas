//
//  CTModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class MRModalityPanelView: ModalityPanelView {
    var mrmodality: LAMRModality!
    
    func configure(mrmodality: LAMRModality) {
        self.mrmodality = mrmodality
        
        titleLabel.text = mrmodality.title
        specificDiagnosisLabel.text = mrmodality.specificDiagnosis
        imagingFeaturesLabel.text = mrmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = mrmodality.structuralFeatures.map { $0.title }
            .joined(separator: ", ")
        
        liverImagesCollectionView.dataSource = self
        
        liverImagesCollectionView.reloadData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        liverImagesCollectionView.dataSource = self
        liverImagesCollectionView.delegate = self
    }

    override func prepareForInterfaceBuilder() {
        let case6 = LAIndex.instance.case6
        configure(mrmodality: case6.mrmodality.first!)
    }
}

extension MRModalityPanelView: UICollectionViewDataSource {
    // images data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mrmodality?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTileCollectionViewCell.identifier, for: indexPath) as! ImageTileCollectionViewCell
        cell.configure(laImage: mrmodality.images[indexPath.item])
        
        return cell
    }
}
