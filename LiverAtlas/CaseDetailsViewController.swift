//
//  CaseDetailsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseDetailsViewController: UIViewController {
    static let storyboardIdentifier = "CaseDetailsViewController"
    static let showImagingSequeIdentifier = "CaseDetailToImagingSegue"

    @IBOutlet weak var caseDetailsPanelView: CaseDetailsPanelView!
    @IBOutlet weak var ctModalityPanelView: CTModalityPanelView!
    @IBOutlet weak var mrModalityPanelView: MRModalityPanelView!
    @IBOutlet weak var usModalityPanelView: USModalityPanelView!

    lazy var searchController: LiverAtlasSearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?
    
    var liverAtlasCase: LiverAtlasCase? {
        didSet {
            self.configureView(liverAtlasCase: liverAtlasCase!)
        }
    }
    
    func configureView(liverAtlasCase: LiverAtlasCase) {
        guard caseDetailsPanelView != nil else {
            return
        }
        
        navigationItem.title = "Case \(liverAtlasCase.pk)"
        
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
        
        ctModalityPanelView.liverImagesCollectionView.delegate = self
        mrModalityPanelView.liverImagesCollectionView.delegate = self
        usModalityPanelView.liverImagesCollectionView.delegate = self
        ctModalityPanelView.liverImagesCollectionView.dataSource = self
        mrModalityPanelView.liverImagesCollectionView.dataSource = self
        usModalityPanelView.liverImagesCollectionView.dataSource = self

        if let _ = liverAtlasCase {
            configureView(liverAtlasCase: liverAtlasCase!)
        }
        
        definesPresentationContext = true
    }

    @IBAction func searchCases(_ sender: Any) {
        searchController.searchCases()
    }

}


extension CaseDetailsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case ctModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase?.ctmodality.count ?? 0
        case mrModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase?.mrmodality.count ?? 0
        case usModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase?.usmodality.count ?? 0
        default:
            fatalError("unrecognized collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageTileCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTileCollectionViewCell.identifier,
                                                             for: indexPath) as! ImageTileCollectionViewCell

        let liverAtlasImage = self.liverAtlasImage(forCollectionView: collectionView,
                                                   cellAtIndexPath: indexPath)
        imageTileCell.configure(liverAtlasImage: liverAtlasImage)
        
        return imageTileCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
    
    func liverAtlasImage(forCollectionView collectionView: UICollectionView,
                         cellAtIndexPath indexPath: IndexPath) -> LiverAtlasImage {
        switch collectionView {
        case ctModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase!.ctmodality.first!.images[indexPath.item]
        case mrModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase!.mrmodality.first!.images[indexPath.item]
        case usModalityPanelView.liverImagesCollectionView:
            return liverAtlasCase!.usmodality.first!.images[indexPath.item]
        default:
            fatalError("unrecognized collection view")
        }
    }
}

extension CaseDetailsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = liverAtlasImage(forCollectionView: collectionView,
                                    cellAtIndexPath: indexPath)
        performSegue(withIdentifier: CaseDetailsViewController.showImagingSequeIdentifier,
                     sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .some(CaseDetailsViewController.showImagingSequeIdentifier):
            if let image = sender as? LiverAtlasImage {
                (segue.destination as? ImagingViewController)?.loadWithImage(imageURL: image.image)
            }
            break
        default:
            NSLog("handled segue indetifier: \(segue.identifier)")
            break
        }
    }
}

extension CaseDetailsViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LiverAtlasSearchController {
        return LiverAtlasSearchController(delegate: self,
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

extension CaseDetailsViewController: LiverAtlasSearchControllerDelegate {
    
    func didSelect(liverAtlasCase: LiverAtlasCase) {
        
    }
    
    func didEndSearch(withCases filteredResults: [LiverAtlasCase]) {
        guard let navController = navigationController else {
            return
        }
        
        // CaseResultsViewController
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle(for: type(of:self)))
        let resultsViewController = storyboard
            .instantiateViewController(withIdentifier: CaseResultsViewController.storyboardIdentifier)
            as! CaseResultsViewController

        resultsViewController.liverAtlasCases = filteredResults
        
        let _ = navController.popToRootViewController(animated: false)
        navController.pushViewController(resultsViewController, animated: true)
    }
}

