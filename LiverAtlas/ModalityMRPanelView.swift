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
    var mrmodality: LiverAtlasMRModality!
    
    func configure(mrmodality: LiverAtlasMRModality) {
        self.mrmodality = mrmodality
        
        title.text = mrmodality.title
        specificDiagnosis.text = mrmodality.specificDiagnosis
        imagingFeaturesLabel.text = mrmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = mrmodality.structuralFeatures.map { $0.title }
            .joined(separator: ", ")
        
        liverImagesCollectionView.reloadData()
    }
    
    override func prepareForInterfaceBuilder() {
        let case6 = LiverAtlasIndex.instance.case6
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
        cell.configure(liverAtlasImage: mrmodality.images[indexPath.item])
        
        return cell
    }
}

extension MRModalityPanelView:  UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageURL = mrmodality.images[indexPath.item].image

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagingController = storyboard.instantiateViewController(withIdentifier: ImagingViewController.identifier) as! ImagingViewController
        imagingController.loadWithImage(imageURL: imageURL)
        
        parentNavigationController?.pushViewController(imagingController, animated: true)
    }
}

