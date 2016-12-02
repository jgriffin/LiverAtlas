//
//  CasesViewController.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CasesViewController: UIViewController {
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
        
        tableView.register(UINib(nibName: "CaseTableViewCell",
                                 bundle: Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CellID.caseTableViewCellID.rawValue)

        if searchResults == nil {
            let filteredCases = FilteredCases(cases: LAIndex.instance.allCases, modality: .ct, filters: [])
            configure(filteredCases: filteredCases)
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        definesPresentationContext = true

        laSearchController.searchCases(filteredCasesToSearch: searchResults.fromFilteredCases)
    }
    
    @IBAction func filtersAction(_ sender: Any) {
        let filtersViewControllerStoryboardID = "filtersViewControllerStoryboardID"

        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle(for: type(of:self)))
        
        let filtersVC = storyboard.instantiateViewController(withIdentifier: filtersViewControllerStoryboardID) as! FiltersViewController
        navigationController?.pushViewController(filtersVC, animated: true)
    }
    
    
    @IBAction func homeAction(_ sender: Any) {
        let homePageVC = MainStoryboard.instantiate(withStoryboardID: .homePageID) as! HomePageViewController
        
        homePageVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        homePageVC.navigationItem.leftItemsSupplementBackButton = true
        
        let detailNavController = UINavigationController(rootViewController: homePageVC)
        
        showDetailViewController(detailNavController, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch SegueID(rawValue:segue.identifier!) {
        case .some(.casesToCaseDetailSegueID):
            let indexPath = sender as! IndexPath
            let laCase = searchResults.cases[indexPath.item]
            let caseDetailVC = segue.destination as! CaseDetailsViewController
            
            caseDetailVC.laCase = laCase
                        
        default:
            NSLog("unrecognized segue")
        }
    }

}

extension CasesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueID.casesToCaseDetailSegueID.rawValue,
                     sender: indexPath)
    }
    
}

extension CasesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.cases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let caseResultCell = tableView.dequeueReusableCell(
            withIdentifier: CellID.caseTableViewCellID.rawValue,
            for: indexPath) as! CaseTableViewCell
        
        let theCase = searchResults.cases[indexPath.row]
        caseResultCell.configure(laCase: theCase, modalityFilter: searchResults.fromFilteredCases.modality)
        
        return caseResultCell
    }
}

extension CasesViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LASearchController {
        return LASearchController(delegate: self,
                                          searchControllerDelegate: self)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        guard navigationItem.titleView == nil else {
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

extension CasesViewController: LASearchControllerDelegate {
    
    func didSelect(laCase: LACase) {
        let caseDetailsVC = MainStoryboard.instantiate(withStoryboardID: .caseDetailsID) as! CaseDetailsViewController
        caseDetailsVC.laCase = laCase
        
        navigationController?.pushViewController(caseDetailsVC, animated: true)
    }
    
    func didEndSearch(withSearchResults: SearchResults) {
        self.searchResults = withSearchResults
    }
}

extension CasesViewController: FilterViewDelegate {
    func didChangeFilter(filteredCases: FilteredCases) {
        searchResults = SearchResults(fromFilteredCases: filteredCases,
                                      searchString: "",
                                      cases: filteredCases.cases)
    }
}

