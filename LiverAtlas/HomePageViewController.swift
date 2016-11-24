//
//  HomePageViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    static let homeToDetailsSegueIdentifier = "HomeToCaseDetailsSegue"
    static let homeToIndexSegueIdentifier = "HomeToIndexSegue"
    
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!

    var activeFilters = [LAFilter]()
    
    lazy var laSearchController: LASearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

//        definesPresentationContext = true
    }

    @IBAction func searchCases(_ sender: Any) {
        let _ = laSearchController
        definesPresentationContext = true
        
        laSearchController.searchCases()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .some(HomePageViewController.homeToDetailsSegueIdentifier):
            let detailsVC = segue.destination as! CaseDetailsViewController
            detailsVC.laCase = LAIndex.instance.case6
        default:
            NSLog("unhandled segue with identifier: \(segue.identifier)" )
        }
    }
    
}

extension HomePageViewController: UISearchControllerDelegate, LASearchControllerDelegate {
    
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
    
    func didSelect(laCase: LACase) {
        
    }
    
    func didEndSearch(withCases filteredResults: [LACase]) {
        guard let navController = navigationController else {
            return
        }
        
        // CaseResultsViewController
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle(for: type(of:self)))
        let resultsViewController = storyboard
            .instantiateViewController(withIdentifier: CaseResultsViewController.storyboardIdentifier)
            as! CaseResultsViewController
        
        resultsViewController.laCases = filteredResults
        
        let _ = navController.popToRootViewController(animated: false)
        navController.pushViewController(resultsViewController, animated: true)
    }
}
