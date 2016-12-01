//
//  HomePageViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!

    var activeFilters = [LAFilter]()
    
    lazy var laSearchController: LASearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func searchCases(_ sender: Any) {
        let _ = laSearchController
        definesPresentationContext = true
        
        let allFilteredCases = FilteredCases(cases: LAIndex.instance.allCases,
                                             modality: .ct,
                                             filters: [])
        laSearchController.searchCases(filteredCasesToSearch: allFilteredCases)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .some(SegueID.homeToCaseDetailsSegueID.rawValue):
            let detailsVC = segue.destination as! CaseDetailsViewController
            detailsVC.laCase = LAIndex.instance.case6
        default:
            NSLog("unhandled segue with identifier: \(segue.identifier)" )
        }
    }
    
}

extension HomePageViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LASearchController {
        return LASearchController(delegate: self,
                                          searchControllerDelegate: self)
    }

    func presentSearchController(_ searchController: UISearchController) {
        if let _ = navigationItem.titleView {
            // already presented
            return
        }
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesBackButton = true

        hiddenRightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItems = nil
        
        searchController.searchBar.becomeFirstResponder()       
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItems = hiddenRightBarButtonItems
        hiddenRightBarButtonItems = nil
    }
}

extension HomePageViewController: LASearchControllerDelegate {
    
    func didSelect(laCase: LACase) {
        
    }
    
    func didEndSearch(withSearchResults: SearchResults) {
        guard let navController = navigationController else {
            return
        }
        
        // CasesViewController
        let caseResultsVC = MainStoryboard.instantiate(withStoryboardID: .casesID) as! CasesViewController
        
        caseResultsVC.searchResults = withSearchResults
        
        let _ = navController.popToRootViewController(animated: false)
        navController.pushViewController(caseResultsVC, animated: true)
    }
}
