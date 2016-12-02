//
//  CaseTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseTableViewCell: UITableViewCell {
    static let nibName = "CaseTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var specificDiagnosisLabel: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var laCase: LACase!
    var laImages: [LAImage]!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        
        imagesCollectionView.register(CaseResultImageCollectionViewCell.self,
                                      forCellWithReuseIdentifier: CellID.resultTableViewImageCellID.rawValue)
    }
    
    func configure(laCase: LACase, modalityFilter: LAModality) {
        self.laCase = laCase
        self.laImages = laCase.imagesForModality(modality: modalityFilter)
        imagesCollectionView.reloadData()
        
        titleLabel?.text = laCase.title
        specificDiagnosisLabel?.text = laCase.specificDiagnosis
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
