//
//  CaseResultTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultTableViewCell: UITableViewCell {
    static let identifier = "CaseResultTableViewCellIdentifier"
    static let resultTableViewImageCellIdentifier = "ResultTableViewImageCellIdentifier"
    
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
                                      forCellWithReuseIdentifier: CaseResultTableViewCell.resultTableViewImageCellIdentifier)
    }
    
    func configure(laCase: LACase) {
        self.laCase = laCase
        self.laImages = laCase.imagesForModality(modality: .ct)
        imagesCollectionView.reloadData()
        
        titleLabel?.text = laCase.title
        specificDiagnosisLabel?.text = laCase.specificDiagnosis
    }
}

extension CaseResultTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return laImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let laImage = laImages[indexPath.item]
        
        let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CaseResultTableViewCell.resultTableViewImageCellIdentifier,
            for: indexPath) as! CaseResultImageCollectionViewCell
        
        imageCell.configure(laImage: laImage)
        
        return imageCell
    }

}


extension CaseResultTableViewCell: UICollectionViewDelegate {
    
}
