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
    @IBOutlet var specificDiagnosisHeading: UILabel!
    @IBOutlet var specificDiagnosisLabel: UILabel!
    @IBOutlet var diagnosticKeywordsHeading: UILabel!
    @IBOutlet var diagnosticKeywordsLabel: UILabel!
    @IBOutlet var clinicalPresentationHeading: UILabel!
    @IBOutlet var clinicalPresentationLabel: UILabel!
    @IBOutlet var notesHeading: UILabel!
    @IBOutlet var notesLabel: UILabel!

    var laCase: LACase! {
        didSet {
            configureView(laCase: laCase)
        }
    }
    
    func configureView(laCase: LACase) {
        diagnosisTextLabel?.text = laCase.diagnosis.diagnosis
        specificDiagnosisHeading?.text = "Specific diagnosis:"
        specificDiagnosisLabel?.text = laCase.specificDiagnosis
        diagnosticKeywordsHeading?.text = "Diagnostic categories:"
        diagnosticKeywordsLabel?.text = diagnosticCategoriesText(forDiagnosis: laCase.diagnosis)
        clinicalPresentationHeading?.text = "Clinical Presentation:"
        clinicalPresentationLabel?.text = laCase.clinicalPresentation
        notesHeading?.text = "Notes:"
        notesLabel?.text = laCase.notes
    }

    func diagnosticCategoriesText(forDiagnosis diagnosis: LADiagnosis) -> String {
        return diagnosis.categories.map({ $0.title }).joined(separator: ", ")
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
        specificDiagnosisHeading = UILabel()
        specificDiagnosisLabel = UILabel()
        diagnosticKeywordsHeading = UILabel()
        diagnosticKeywordsLabel = UILabel()
        clinicalPresentationHeading = UILabel()
        clinicalPresentationLabel = UILabel()
        notesHeading = UILabel()
        notesLabel = UILabel()
        
        // add as subviews
        let labels: [UILabel] = [
            diagnosisTextLabel,
            specificDiagnosisHeading, specificDiagnosisLabel,
            diagnosticKeywordsHeading, diagnosticKeywordsLabel,
            clinicalPresentationHeading, clinicalPresentationLabel,
            notesHeading, notesLabel
        ]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.numberOfLines = 0
        }
        
        styleTheLabels()
    }

    func styleTheLabels() {
        
        // center the diagnosis
        diagnosisTextLabel.textAlignment = NSTextAlignment.center
        
        // set the fonts
        let textStyleForLabels: [UIFontTextStyle: [UILabel]] = [
            .headline: [
                diagnosisTextLabel
            ],
            .subheadline: [
                specificDiagnosisLabel,
            ],
            .body: [
                diagnosticKeywordsLabel,
                clinicalPresentationLabel,
                notesLabel
                ],
            .caption1: [
                specificDiagnosisHeading,
                diagnosticKeywordsHeading,
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
            "specificHeading": specificDiagnosisHeading,
            "specific": specificDiagnosisLabel,
            "keywordsHeading": diagnosticKeywordsHeading,
            "keywords": diagnosticKeywordsLabel,
            "clinicalHeading": clinicalPresentationHeading,
            "clinical": clinicalPresentationLabel,
            "notesHeading": notesHeading,
            "notes": notesLabel
        ]
        
        let constraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[diagnosis]-20-[specificHeading][specific]-20-[keywordsHeading][keywords]-20-[clinicalHeading][clinical]-20-[notesHeading][notes]-20-|",
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
        laCase = LAIndex.instance.case6
        
        setNeedsUpdateConstraints()
    }
    
}
