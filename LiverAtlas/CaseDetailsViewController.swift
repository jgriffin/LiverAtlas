//
//  CaseDetailsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseDetailsViewController: UIViewController {
    @IBOutlet weak var caseDetailsPanelView: CaseDetailsPanelView!
    @IBOutlet weak var ctModalityPanelView: CTModalityPanelView!
    @IBOutlet weak var mrModalityPanelView: MRModalityPanelView!
    @IBOutlet weak var usModalityPanelView: USModalityPanelView!

    fileprivate var laCase: LACase?
    
    func configure(laCase: LACase) {
        self.laCase = laCase
        
        guard caseDetailsPanelView != nil else {
            return
        }
        
        navigationItem.title = "Case \(laCase.pk)"
        
        caseDetailsPanelView.laCase = laCase

        configureModalityPanels(laCase: laCase)
    }

    private func configureModalityPanels(laCase: LACase) {
        if let ctmodality = laCase.ctmodality.first {
            ctModalityPanelView.configure(ctmodality: ctmodality)
        }
        if let mrmodality = laCase.mrmodality.first {
            mrModalityPanelView.configure(mrmodality: mrmodality)
        }
        if let usmodality = laCase.usmodality.first {
            usModalityPanelView.configure(usmodality: usmodality)
        }
        ctModalityPanelView.isHidden = laCase.ctmodality.isEmpty
        mrModalityPanelView.isHidden = laCase.mrmodality.isEmpty
        usModalityPanelView.isHidden = laCase.usmodality.isEmpty
        
        ctModalityPanelView.modalityPanelHostDelegate = self
        mrModalityPanelView.modalityPanelHostDelegate = self
        usModalityPanelView.modalityPanelHostDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = laCase {
            configure(laCase: laCase!)
        }
        
        definesPresentationContext = true
    }
}


extension CaseDetailsViewController: ModalityPanelHostDelegate {
 
    func modalityPanel(_ modalityPanel: ModalityPanelView,
                       didSelectImage laImage: LAImage?,
                       withIndex imageIndex: Int) {
        
        var selectedImage: LAImage
        
        switch modalityPanel {
        case ctModalityPanelView:
            selectedImage = laCase!.ctmodality.first!.images[imageIndex]
        case mrModalityPanelView:
            selectedImage = laCase!.mrmodality.first!.images[imageIndex]
        case usModalityPanelView:
            selectedImage = laCase!.usmodality.first!.images[imageIndex]
        default:
            fatalError()
        }
        
        let imagingController = MainStoryboard.instantiate(withStoryboardID: .imagingID) as! ImagingViewController
        imagingController.configure(laImage: selectedImage)
        
        navigationController?.pushViewController(imagingController, animated: true)
    }
}
