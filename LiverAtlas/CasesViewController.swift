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
    
    fileprivate lazy var laSearchController: LASearchController = { self.createSearchController() }()
    fileprivate var hiddenRightBarButtonItems: [UIBarButtonItem]?

    fileprivate var filteredCases: FilteredCases! {
        didSet {
            _searchResultCases = nil
            tableView.reloadData()
        }
    }
    fileprivate var searchString: String = "" {
        didSet {
            _searchResultCases = nil
            tableView.reloadData()
        }
    }
    fileprivate var searchResultCases: [LACase] {
        guard filteredCases != nil else {
            fatalError("need to call CasesViewController.configure")
        }
        
        if _searchResultCases == nil {
            _searchResultCases = LASearcher().searchCases(
                fromFilteredCases: filteredCases,
                forSearchText: searchString)
            
            updateHeader(filteredCases: filteredCases,
                         searchText: searchString,
                         resultCount: _searchResultCases!.count)
        }
        return _searchResultCases!
    }
    private var _searchResultCases: [LACase]?
    
    func configure(filteredCases: FilteredCases) {
        self.filteredCases = filteredCases
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: CaseTableViewCell.nibName, bundle: MainStoryboard.bundle),
                           forCellReuseIdentifier: CellID.caseTableViewCellID.rawValue)
        
        if filteredCases == nil {
            filteredCases = LAFilterer.instance.filteredCases
        }
    }

    private func updateHeader(filteredCases: FilteredCases,
                              searchText: String,
                              resultCount: Int) {
        tableViewHeaderResultSummaryLabel.text = "There are \(resultCount ) cases matching the current search"
    }

    @IBAction func searchAction(_ sender: Any) {
        definesPresentationContext = true

        laSearchController.searchCases(filteredCasesToSearch: filteredCases, searchText: searchString)
    }
    
    @IBAction func filtersAction(_ sender: Any) {
        let filtersVC = MainStoryboard.instantiate(withStoryboardID: .filtersID) as! FiltersViewController
        filtersVC.delegate = self
        
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}

// MARK: UI Table View

extension CasesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let caseResultCell = tableView.dequeueReusableCell(
            withIdentifier: CellID.caseTableViewCellID.rawValue,
            for: indexPath) as! CaseTableViewCell
        
        let theCase = searchResultCases[indexPath.row]
        caseResultCell.configure(laCase: theCase, modalityFilter: filteredCases.modality)
        
        return caseResultCell
    }
}

extension CasesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let laCase = searchResultCases[indexPath.item]

        let caseDetailsVC = MainStoryboard.instantiate(withStoryboardID: .caseDetailsID) as! CaseDetailsViewController
        caseDetailsVC.configure(laCase: laCase)
        
        navigationController?.pushViewController(caseDetailsVC, animated: true)
    }
}

// MARK: Search Controller

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
        caseDetailsVC.configure(laCase: laCase)
        
        navigationController?.pushViewController(caseDetailsVC, animated: true)
    }
    
    func didEndSearch(withSearchString searchString: String) {
        self.searchString = searchString
    }
}

extension CasesViewController: FilterViewDelegate {
    func didChangeFilter(filteredCases: FilteredCases) {
        self.filteredCases = filteredCases
    }
}

