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
        
        liverImagesCollectionView.reloadData()
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

extension MRModalityPanelView:  UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let laImage = mrmodality.images[indexPath.item]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagingController = storyboard.instantiateViewController(withIdentifier: ImagingViewController.identifier) as! ImagingViewController
        imagingController.configure(laImage: laImage)
        
        parentNavigationController?.pushViewController(imagingController, animated: true)
    }
}

