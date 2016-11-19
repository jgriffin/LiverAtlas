//
//  CaseDetailsViewController.swift
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


class CaseDetailsViewController: UIViewController {
    static let storyboardIdentifier = "CaseDetailsViewController"

    @IBOutlet weak var caseDetailsPanelView: CaseDetailsPanelView!
    @IBOutlet weak var ctModalityPanelView: CTModalityPanelView!
    @IBOutlet weak var mrModalityPanelView: MRModalityPanelView!
    @IBOutlet weak var usModalityPanelView: USModalityPanelView!

    var liverAtlasCase: LiverAtlasCase? {
        didSet {
            self.configureView(liverAtlasCase: liverAtlasCase!)
        }
    }
    
    func configureView(liverAtlasCase: LiverAtlasCase) {
        guard caseDetailsPanelView != nil else {
            return
        }
        
        caseDetailsPanelView.liverAtlasCase = liverAtlasCase

        configureModalityPanels(liverAtlasCase: liverAtlasCase)
        
        // setup way to present new views
        ctModalityPanelView.parentNavigationController = self.navigationController
    }

    func configureModalityPanels(liverAtlasCase: LiverAtlasCase) {
        if let ctmodality = liverAtlasCase.ctmodality.first {
            ctModalityPanelView.configure(ctmodality: ctmodality)
        }
        if let mrmodality = liverAtlasCase.mrmodality.first {
            mrModalityPanelView.configure(mrmodality: mrmodality)
        }
        if let usmodality = liverAtlasCase.usmodality.first {
            usModalityPanelView.configure(usmodality: usmodality)
        }
        ctModalityPanelView.isHidden = liverAtlasCase.ctmodality.isEmpty
        mrModalityPanelView.isHidden = liverAtlasCase.mrmodality.isEmpty
        usModalityPanelView.isHidden = liverAtlasCase.usmodality.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = liverAtlasCase {
            configureView(liverAtlasCase: liverAtlasCase!)
        }
    }

}

