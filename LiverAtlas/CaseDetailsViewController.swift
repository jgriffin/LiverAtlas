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

    lazy var searchController: LASearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?
    
    var laCase: LACase? {
        didSet {
            self.configureView(laCase: laCase!)
        }
    }
    
    func configureView(laCase: LACase) {
        guard caseDetailsPanelView != nil else {
            return
        }
        
        navigationItem.title = "Case \(laCase.pk)"
        
        caseDetailsPanelView.laCase = laCase

        configureModalityPanels(laCase: laCase)
    }

    func configureModalityPanels(laCase: LACase) {
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
            configureView(laCase: laCase!)
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

extension CaseDetailsViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LASearchController {
        return LASearchController(delegate: self,
                                          searchControllerDelegate: self)
    }

    func presentSearchController(_ searchController: UISearchController) {
        if let _ = navigationItem.titleView {
            return
        }

        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesBackButton = true
        
        hiddenRightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItem = nil
        
        searchController.searchBar.becomeFirstResponder()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItems = hiddenRightBarButtonItems
    }
}

extension CaseDetailsViewController: LASearchControllerDelegate {
    
    func didSelect(laCase: LACase) {
        
    }
    
    func didEndSearch(withSearchResults: SearchResults) {
        guard let navController = navigationController else {
            return
        }
        
        // CasesViewController
        let resultsViewController = MainStoryboard.instantiate(withStoryboardID: .casesID) as! CasesViewController

        resultsViewController.searchResults = withSearchResults
        
        let _ = navController.popToRootViewController(animated: false)
        navController.pushViewController(resultsViewController, animated: true)
    }
}

