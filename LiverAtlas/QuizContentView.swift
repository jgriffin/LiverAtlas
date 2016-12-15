//
//  QuizContentView.swift
//  LiverAtlas
//
//  Created by John on 11/30/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class QuizContentView: UIView {
    @IBOutlet var clinicalPresentationHeader: UILabel!
    @IBOutlet var clinicalPresentationLabel: UILabel!
    @IBOutlet var modalityPanel: SingleModalityPanelView!
    
    var modalityPanelHostDelegate: ModalityPanelHostDelegate?
    
    var laCase: LACase!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        createSubviews()
    }
    
    // create
    
    func createSubviews() {
        clinicalPresentationHeader = UILabel()
        clinicalPresentationHeader.translatesAutoresizingMaskIntoConstraints = false
        clinicalPresentationHeader.numberOfLines = 0
        clinicalPresentationHeader.text = "Clinical Presentation:"
        clinicalPresentationHeader.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.addSubview(clinicalPresentationHeader)
        
        clinicalPresentationLabel = UILabel()
        clinicalPresentationLabel.translatesAutoresizingMaskIntoConstraints = false
        clinicalPresentationLabel.numberOfLines = 0
        clinicalPresentationLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.addSubview(clinicalPresentationLabel)
        
        modalityPanel = SingleModalityPanelView()
        modalityPanel.translatesAutoresizingMaskIntoConstraints = false
        modalityPanel.modalityPanelHostDelegate = self
        self.addSubview(modalityPanel)
        
        addSubviewConstraints()
    }
    
    func addSubviewConstraints() {
        let views: [String: UIView] = [
            "cpHeading": clinicalPresentationHeader,
            "cp": clinicalPresentationLabel,
            "modalityPanel": modalityPanel,
            ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[cpHeading][cp]-40-[modalityPanel]-|",
            options: [], metrics: nil, views: views)
        
        let fillToHorizontalMarginsVisualFormats = [
            "H:|-[cpHeading]-|", "H:|-[cp]-|", "H:|-[modalityPanel]-|"
        ]
        
        let horizonalConstraints = fillToHorizontalMarginsVisualFormats.flatMap {
            (visualFormat) -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraints(
                withVisualFormat: visualFormat,
                options: [], metrics: nil, views: views)
        }
        
        self.addConstraints(verticalConstraints)
        self.addConstraints(horizonalConstraints)
    }
    
    // configure
    
    func configure(laCase: LACase, modality: LAModality) {
        self.laCase = laCase
        
        clinicalPresentationLabel.text = laCase.clinicalPresentation
        modalityPanel.configure(laCase: laCase, modality: modality)
    }
    
    override func prepareForInterfaceBuilder() {
        configure(laCase: LAIndex.instance.case6, modality: .ct)
    }
}

extension QuizContentView: ModalityPanelHostDelegate {
    
    func modalityPanel(_ modalityPanel: ModalityPanelView,
                                didSelectImage laImage: LAImage?,
                                withIndex imageIndex: Int) {
        modalityPanelHostDelegate!.modalityPanel(modalityPanel,
                                                 didSelectImage: laImage,
                                                 withIndex: imageIndex)
    }
}
