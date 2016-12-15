//
//  CaseTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseTableViewCell: UITableViewCell {
    static let nibName = "Case2TableViewCell"
    
    @IBOutlet weak var imagingView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var specificDiagnosisLabel: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var laCase: LACase!
    var laImages: [LAImage]!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imagesCollectionView?.dataSource = self
        imagesCollectionView?.delegate = self
        imagesCollectionView?.register(CaseResultImageCollectionViewCell.self,
                                      forCellWithReuseIdentifier: CellID.resultTableViewImageCellID.rawValue)
    }
    
    func configure(laCase: LACase, modalityFilter: LAModality) {
        self.laCase = laCase
        self.laImages = laCase.imagesForModality(modality: modalityFilter)
        
        imagesCollectionView?.reloadData()
        
        titleLabel?.text = laCase.title
        specificDiagnosisLabel?.text = laCase.specificDiagnosis

        imagingView?.image = nil

        if let firstImage = laImages.first {
            LACaseFetcher.instance.loadLAImageForURL(imageURL: firstImage.imageURL) {
                [weak self] (image: UIImage?, imageURL: URL, wasCached: Bool)  in
                assert(Thread.isMainThread)
                guard imageURL == firstImage.imageURL else {
                    return
                }
                
                self?.imagingView.alpha = 0.0
                self?.imagingView.image = image
                
                let duration = wasCached ? 0.0 : 0.25
                UIView.animate(withDuration: duration, animations: {
                    self?.imagingView.alpha = 1.0
                })
            }
        }

    }
}

extension CaseTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return laImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let laImage = laImages[indexPath.item]
        
        let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellID.resultTableViewImageCellID.rawValue,
            for: indexPath) as! CaseResultImageCollectionViewCell
        
        imageCell.configure(laImage: laImage)
        
        return imageCell
    }

}


extension CaseTableViewCell: UICollectionViewDelegate {
    
}
