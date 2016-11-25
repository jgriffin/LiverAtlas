//
//  CaseResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultsViewController: UIViewController {
    static let storyboardIdentifier = "CaseResultsViewControllerStoryboardIdentifier"
    static let caseDetailSegueIdentifier =  "CaseResultToCaseDetailSegue"
    static let homePageControllerIdentifier = "HomePageViewControllerStoryboardIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderResultSummaryLabel: UILabel!
    
    lazy var laSearchController: LASearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?
    
    var searchResults: SearchResults! {
        didSet {
            guard let _ = tableViewHeaderResultSummaryLabel else {
                return
            }

            tableViewHeaderResultSummaryLabel.text = "There are \(searchResults.cases.count ) cases matching the current search"
            tableView?.reloadData()
        }
    }
    
    
    func configure(filteredCases: FilteredCases) {
        self.searchResults = SearchResults(fromFilteredCases: filteredCases,
                                           searchString: "",
                                           cases: filteredCases.cases)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "CaseResultTableViewCell",
                                 bundle: Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseResultTableViewCell.identifier)

        if searchResults == nil {
            let filteredCases = FilteredCases(cases: LAIndex.instance.allCases, modality: .ct, filters: [])
            configure(filteredCases: filteredCases)
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        definesPresentationContext = true

        laSearchController.searchCases()
    }
    
    @IBAction func homeAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle(for: type(of:self)))
        
        let homePageVC = storyboard.instantiateViewController(withIdentifier: CaseResultsViewController.homePageControllerIdentifier) as! HomePageViewController
        
        homePageVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        homePageVC.navigationItem.leftItemsSupplementBackButton = true
        
        let detailNavController = UINavigationController(rootViewController: homePageVC)
        
        showDetailViewController(detailNavController, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CaseResultsViewController.caseDetailSegueIdentifier:
            let indexPath = sender as! IndexPath
            let laCase = searchResults.cases[indexPath.item]
            let caseDetailVC = segue.destination as! CaseDetailsViewController
            
            caseDetailVC.laCase = laCase
            
        default:
            NSLog("unrecognized segue")
        }
    }

}

extension CaseResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: CaseResultsViewController.caseDetailSegueIdentifier,
                     sender: indexPath)
        
    }
    
}

extension CaseResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.cases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let caseResultCell = tableView.dequeueReusableCell(withIdentifier: CaseResultTableViewCell.identifier,
                                                          for: indexPath) as! CaseResultTableViewCell
        
        let theCase = searchResults.cases[indexPath.row]
        caseResultCell.configure(laCase: theCase, modalityFilter: searchResults.fromFilteredCases.modality)
        
        return caseResultCell
    }
}

extension CaseResultsViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LASearchController {
        return LASearchController(delegate: self,
                                          searchControllerDelegate: self)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        guard let _ = navigationItem.titleView  else {
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

extension CaseResultsViewController: LASearchControllerDelegate {
    
    func didSelect(laCase: LACase) {
        // TODO: push details vc
    }
    
    func didEndSearch(withSearchResults: SearchResults) {
        self.searchResults = withSearchResults
    }
}



