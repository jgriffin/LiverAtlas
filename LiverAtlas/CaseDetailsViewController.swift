//
//  CaseDetailsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseDetailsViewController: UIViewController {
    @IBOutlet weak var modalityPanelView: SingleModalityPanelView!
    @IBOutlet weak var caseDetailsPanelView: CaseDetailsPanelView!

    fileprivate var laCase: LACase?
    fileprivate var laModality: LAModality?
    
    func configure(laCase: LACase, modality: LAModality) {
        self.laCase = laCase
        self.laModality = modality
        
        guard caseDetailsPanelView != nil else {
            return
        }
        
        navigationItem.title = "Case \(laCase.pk)"
        
        caseDetailsPanelView.laCase = laCase

        configureModalityPanels(laCase: laCase, modality: modality)
    }

    private func configureModalityPanels(laCase: LACase, modality: LAModality) {
        modalityPanelView.configure(laCase: laCase, modality: laModality!)
        modalityPanelView.modalityPanelHostDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = laCase {
            configure(laCase: laCase!, modality: laModality!)
        }
        
        definesPresentationContext = true
    }
}


extension CaseDetailsViewController: ModalityPanelHostDelegate {
 
    func modalityPanel(_ modalityPanel: ModalityPanelView,
                       didSelectImage laImage: LAImage?,
                       withIndex imageIndex: Int) {

        let modalityImages = laCase!.modalityImages(forModality: laModality!)
        let selectedImage = modalityImages.images[imageIndex]
        
        let imagingController = MainStoryboard.instantiate(withStoryboardID: .imagingID) as! ImagingViewController
        imagingController.configure(laImage: selectedImage)
        
        navigationController?.pushViewController(imagingController, animated: true)
    }
}
