//
//  LiverAtlasCaseDetailViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

//struct LiverAtlasCase {
//    let title: String
//    let pk: Int
//    let modifiedData: Date
//    let clinicalPresentation: String
//    let diagnosis: LiverAtlasDiagnosis
//    let specificDiagnosis: String
//    let notes: String
//    let ctmodality: [LiverAtlasCTModality]
//    let mrmodality: [LiverAtlasMRModality]
//    let usmodality: [LiverAtlasUSModality]
//}


class LiverAtlasCaseDetailViewController: UIViewController {

    @IBOutlet weak var caseHeadingNumberLabel: UILabel!
    @IBOutlet weak var caseHeadingTextLabel: UILabel!
    
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var clinicalPresentationLabel: UILabel!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var specificDiagnosisLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!

    var liverAtlasIndexItem: LiverAtlasIndexItem! {
        didSet {
            fetchCaseDetails(indexItem: liverAtlasIndexItem)
            self.configureView()
        }
    }
    
    var liverAtlasCase: LiverAtlasCase? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        guard caseHeadingTextLabel != nil else {
            return
        }
        
        // Update the user interface for the detail item.
        caseHeadingNumberLabel.text = "Case \(liverAtlasIndexItem.pk): "
        caseHeadingTextLabel.text = liverAtlasIndexItem.title
        
        if let caseItem = liverAtlasCase {
            clinicalPresentationLabel.text = caseItem.clinicalPresentation
            diagnosisLabel.text = caseItem.diagnosis.diagnosis
            specificDiagnosisLabel.text = caseItem.specificDiagnosis
            notesLabel.text = caseItem.notes
            
            detailsStackView.isHidden = false
        } else {
            detailsStackView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }

    func fetchCaseDetails(indexItem: LiverAtlasIndexItem) {
        LiverAtlasCaseCrawler().loadCaseForIndexItem(indexItem: liverAtlasIndexItem, callback: { (liverAtlasCase:LiverAtlasCase?) in
            assert(Thread.isMainThread)
            
            if let _ = liverAtlasCase {
                self.liverAtlasCase = liverAtlasCase
            }
        })
    }
    

}

