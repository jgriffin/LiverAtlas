//
//  ModalityPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/18/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class ModalityPanelView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var specificDiagnosis: UILabel!
    @IBOutlet weak var liverImagesCollectionView: IntrinsicSizeCollectionView!
    @IBOutlet weak var imagingFeaturesLabel: UILabel!
    @IBOutlet weak var structuralFeaturesLabel: UILabel!
    
    var parentNavigationController: UINavigationController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    func loadNib() {
        Bundle(for: type(of:self)).loadNibNamed("ModalityPanelView", owner: self, options: nil)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        self.addSubview(self.view);
        
        liverImagesCollectionView.register(UINib(nibName:"ImageTileCollectionViewCell", bundle: Bundle(for: type(of:self))),
                                           forCellWithReuseIdentifier: ImageTileCollectionViewCell.identifier)
    }
}
