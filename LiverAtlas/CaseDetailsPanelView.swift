//
//  CaseDetailsPanelView.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

@IBDesignable
class CaseDetailsPanelView: UIView {
    @IBOutlet var diagnosisTextLabel: UILabel!
    @IBOutlet var specificDiagnosisLabel: UILabel!
    @IBOutlet var diagnosticKeywordsLabel: UILabel!
    @IBOutlet var clinicalPresentationHeading: UILabel!
    @IBOutlet var clinicalPresentationLabel: UILabel!
    @IBOutlet var notesHeading: UILabel!
    @IBOutlet var notesLabel: UILabel!

    var liverAtlasCase: LiverAtlasCase! {
        didSet {
            configureView(liverAtlasCase: liverAtlasCase)
        }
    }
    
    func configureView(liverAtlasCase: LiverAtlasCase) {
        diagnosisTextLabel?.text = liverAtlasCase.diagnosis.diagnosis
        specificDiagnosisLabel?.text = liverAtlasCase.specificDiagnosis
        diagnosticKeywordsLabel?.text = diagnosticCategoriesText(forDiagnosis: liverAtlasCase.diagnosis)
        clinicalPresentationHeading?.text = "Clinical Presentation:"
        clinicalPresentationLabel?.text = liverAtlasCase.clinicalPresentation
        notesHeading?.text = "Notes:"
        notesLabel?.text = liverAtlasCase.notes
    }

    func diagnosticCategoriesText(forDiagnosis diagnosis: LiverAtlasDiagnosis) -> String {
        let categoriesJoined = diagnosis.categories.map({ $0.title }).joined(separator: ", ")
        return "Diagnostic categories: \(categoriesJoined)"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        diagnosisTextLabel = UILabel()
        specificDiagnosisLabel = UILabel()
        diagnosticKeywordsLabel = UILabel()
        clinicalPresentationHeading = UILabel()
        clinicalPresentationLabel = UILabel()
        notesHeading = UILabel()
        notesLabel = UILabel()
        
        // add as subviews
        let labels: [UILabel] = [diagnosisTextLabel, specificDiagnosisLabel, diagnosticKeywordsLabel,
                     clinicalPresentationHeading, clinicalPresentationLabel, notesHeading, notesLabel]
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            addSubview(label)
        }
        
        styleTheLabels()
    }

    func styleTheLabels() {
        // set the fonts
        let textStyleForLabels: [UIFontTextStyle: [UILabel]] = [
            .headline: [
                diagnosisTextLabel
            ],
            .subheadline: [
                specificDiagnosisLabel,
                diagnosticKeywordsLabel,
                clinicalPresentationLabel,
                notesLabel
            ],
            .caption1: [
                clinicalPresentationHeading,
                notesHeading
            ]
        ]
        for (textStyle, labels) in textStyleForLabels {
            let font = UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: nil)
            labels.forEach { $0.font = font }
        }
    }

    func createConstraints() {
        let views: [String: UIView] = [
            "diagnosis": diagnosisTextLabel,
            "specific": specificDiagnosisLabel,
            "keywords": diagnosticKeywordsLabel,
            "clinicalHeading": clinicalPresentationHeading,
            "clinical": clinicalPresentationLabel,
            "notesHeading": notesHeading,
            "notes": notesLabel
        ]
        
        let constraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[diagnosis]-[specific]-[keywords]-[clinicalHeading][clinical]-[notesHeading][notes]-|",
                options: [.alignAllLeading, .alignAllTrailing],
                metrics: nil,
                views: views)
        self.addConstraints(constraints)
        
        let allViewsFullWidth = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[diagnosis]|",
            options: [],
            metrics: nil,
            views: views)
        self.addConstraints(allViewsFullWidth)
    }

    lazy var createConstraintsOnce: Void = { self.createConstraints() }()
    override func updateConstraints() {
        let _ = createConstraintsOnce
        
        super.updateConstraints()
    }

    override func prepareForInterfaceBuilder() {
        liverAtlasCase = LiverAtlasIndex.instance.case6
        
        setNeedsUpdateConstraints()
    }
    
}
