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
    @IBOutlet var modalityStackView: UIStackView!
    @IBOutlet var ctModalityPanel: CTModalityPanelView!
    @IBOutlet var mrModalityPanel: MRModalityPanelView!
    @IBOutlet var usModalityPanel: USModalityPanelView!
    
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
        addSubviewConstraints()
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
        
        ctModalityPanel = CTModalityPanelView()
        ctModalityPanel.translatesAutoresizingMaskIntoConstraints = false
        ctModalityPanel.modalityPanelHostDelegate = self
        self.addSubview(ctModalityPanel)
        
        mrModalityPanel = MRModalityPanelView()
        mrModalityPanel.translatesAutoresizingMaskIntoConstraints = false
        mrModalityPanel.modalityPanelHostDelegate = self
        self.addSubview(mrModalityPanel)
        
        usModalityPanel = USModalityPanelView()
        usModalityPanel.translatesAutoresizingMaskIntoConstraints = false
        usModalityPanel.modalityPanelHostDelegate = self
        self.addSubview(usModalityPanel)
        
        modalityStackView = UIStackView(arrangedSubviews: [ctModalityPanel, mrModalityPanel, usModalityPanel])
        modalityStackView.translatesAutoresizingMaskIntoConstraints = false
        modalityStackView.axis = .vertical
        modalityStackView.alignment = .fill
        self.addSubview(modalityStackView)
    }
    
    func addSubviewConstraints() {
        let views: [String: UIView] = [
            "cpHeading": clinicalPresentationHeader,
            "cp": clinicalPresentationLabel,
            "modalityStackPanel": modalityStackView,
            ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[cpHeading][cp]-40-[modalityStackPanel]-|",
            options: [], metrics: nil, views: views)
        
        let fillToHorizontalMarginsVisualFormats = [
            "H:|-[cpHeading]-|", "H:|-[cp]-|", "H:|-[modalityStackPanel]-|"
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
    
    func configureView(laCase: LACase) {
        self.laCase = laCase
        
        clinicalPresentationLabel.text = laCase.clinicalPresentation
        configureModalityPanels(laCase: laCase)
    }
    
    func configureModalityPanels(laCase: LACase) {
        if let ctmodality = laCase.ctmodality.first {
            ctModalityPanel.configure(ctmodality: ctmodality)
        }
        if let mrmodality = laCase.mrmodality.first {
            mrModalityPanel.configure(mrmodality: mrmodality)
        }
        if let usmodality = laCase.usmodality.first {
            usModalityPanel.configure(usmodality: usmodality)
        }
        ctModalityPanel.isHidden = laCase.ctmodality.isEmpty
        mrModalityPanel.isHidden = laCase.mrmodality.isEmpty
        usModalityPanel.isHidden = laCase.usmodality.isEmpty
    }
    
    override func prepareForInterfaceBuilder() {
        configureView(laCase: LAIndex.instance.case6)
    }
}

extension QuizContentView: ModalityPanelHostDelegate {
    
    func modalityPanel(_ modalityPanel: ModalityPanelView,
                                didSelectImage laImage: LAImage?,
                                withIndex imageIndex: Int) {
        var selectedImage = laImage
        if selectedImage == nil {
            switch modalityPanel {
            case ctModalityPanel:
                selectedImage = laCase.ctmodality.first!.images[imageIndex]
            case usModalityPanel:
                selectedImage = laCase.usmodality.first!.images[imageIndex]
            case mrModalityPanel:
                selectedImage = laCase.mrmodality.first!.images[imageIndex]
            default:
                fatalError()
            }
        }
        
        modalityPanelHostDelegate!.modalityPanel(modalityPanel,
                                                 didSelectImage: selectedImage,
                                                 withIndex: imageIndex)
    }
}
