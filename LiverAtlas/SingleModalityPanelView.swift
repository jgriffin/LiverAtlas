//
//  CTModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class SingleModalityPanelView: ModalityPanelView {
    var ctmodality: LAModalityImages!
    
    func configure(laCase: LACase, modality: LAModality) {
        self.ctmodality = laCase.modalityImages(forModality: modality)
        
        titleLabel.text = ctmodality.title
        specificDiagnosisLabel.text = ctmodality.specificDiagnosis
        imagingFeaturesLabel.text = ctmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = ctmodality.structuralFeatures.map { $0.title }
            .joined(separator: ", ")
        
        
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
   }

    
    override func prepareForInterfaceBuilder() {
        let case6 = LAIndex.instance.case6
        configure(laCase: case6, modality: .ct)
        
        super.prepareForInterfaceBuilder()
    }
}

extension SingleModalityPanelView: UICollectionViewDataSource {
    // images data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ctmodality?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellID.imageTileCollectionViewCellID.rawValue,
            for: indexPath) as! ImageTileCollectionViewCell
        cell.configure(laImage: ctmodality.images[indexPath.item])
        
        return cell
    }
}

