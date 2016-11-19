//
//  USModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class USModalityPanelView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var specificDiagnosis: UILabel!
    @IBOutlet weak var liverImagesCollectionView: IntrinsicSizeCollectionView!
    @IBOutlet weak var imagingFeaturesLabel: UILabel!
    @IBOutlet weak var structuralFeaturesLabel: UILabel!

    var parentNavigationController: UINavigationController!
    var usmodality: LiverAtlasUSModality!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    func configure(usmodality: LiverAtlasUSModality) {
        self.usmodality = usmodality
        
        title.text = usmodality.title
        specificDiagnosis.text = usmodality.specificDiagnosis
        imagingFeaturesLabel.text = usmodality.imagingFeatures.map { $0.title }
            .joined(separator: ", ")
        structuralFeaturesLabel.text = usmodality.structuralFeatures.map { $0.title }
            .joined(separator: ", ")
        
        liverImagesCollectionView.reloadData()
    }
    
    
    func loadNib() {
        Bundle(for: type(of:self)).loadNibNamed("CTModalityPanelView", owner: self, options: nil)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true

        self.addSubview(self.view);

        liverImagesCollectionView.register(UINib(nibName:"ImageTileCollectionViewCell", bundle: Bundle(for: type(of:self))),
                                           forCellWithReuseIdentifier: ImageTileCollectionViewCell.identifier)
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

