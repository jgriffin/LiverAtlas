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
    var usmodality: LiverAtlasUSModality!
    
    func configure(usmodality: LiverAtlasUSModality) {
        self.usmodality = usmodality
        
        titleLabel.text = usmodality.title
        specificDiagnosisLabel.text = usmodality.specificDiagnosis
        imagingFeaturesLabel.text = usmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = usmodality.structuralFeatures.map { $0.title }
            .joined(separator: ", ")
        
        liverImagesCollectionView.reloadData()
    }

    override func prepareForInterfaceBuilder() {
        let case6 = LiverAtlasIndex.instance.case6
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
        cell.configure(liverAtlasImage: usmodality.images[indexPath.item])
        
        return cell
    }
}

extension USModalityPanelView:  UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageURL = usmodality.images[indexPath.item].image

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagingController = storyboard.instantiateViewController(withIdentifier: ImagingViewController.identifier) as! ImagingViewController
        imagingController.loadWithImage(imageURL: imageURL)
        
        parentNavigationController?.pushViewController(imagingController, animated: true)
    }
}

