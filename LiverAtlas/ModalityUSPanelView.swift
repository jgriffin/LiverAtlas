//
//  USModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class USModalityPanelView: ModalityPanelView {
    var usmodality: LAUSModality!
    
    func configure(usmodality: LAUSModality) {
        self.usmodality = usmodality
        
        titleLabel.text = usmodality.title
        specificDiagnosisLabel.text = usmodality.specificDiagnosis
        imagingFeaturesLabel.text = usmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = usmodality.structuralFeatures.map { $0.title }
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
        configure(usmodality: case6.usmodality.first!)
    }
}

extension USModalityPanelView: UICollectionViewDataSource {
    // images data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usmodality?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTileCollectionViewCell.identifier, for: indexPath) as! ImageTileCollectionViewCell
        cell.configure(laImage: usmodality.images[indexPath.item])
        
        return cell
    }
}

