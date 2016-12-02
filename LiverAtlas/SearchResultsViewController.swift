//
//  SearchResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController {
    private let searcher = LASearcher()
    
    fileprivate var filteredCasesToSearch: FilteredCases! {
        didSet {
            _searchResultCases = nil
        }
    }
    fileprivate var searchText: String = "" {
        didSet {
            _searchResultCases = nil
        }
    }
    var searchResultCases: [LACase] {
        if _searchResultCases == nil {
            _searchResultCases = searcher.searchCases(
                fromFilteredCases: filteredCasesToSearch,
                forSearchText: searchText)
        }
        return _searchResultCases!
    }
    private var _searchResultCases: [LACase]? {
        didSet {
            tableView.reloadData()
        }
    }

    func configure(filteredCasesToSearch: FilteredCases, searchText: String ) {
        self.filteredCasesToSearch = filteredCasesToSearch
        self.searchText = searchText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.register(UINib(nibName: CaseTableViewCell.nibName, bundle: MainStoryboard.bundle),
                           forCellReuseIdentifier: CellID.caseTableViewCellID.rawValue)
    }

    // TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.caseTableViewCellID.rawValue,
                                                 for: indexPath) as! CaseTableViewCell
        
        let laCase = searchResultCases[indexPath.item]
        cell.configure(laCase: laCase, modalityFilter: filteredCasesToSearch.modality)
        
        return cell
    }    
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        
        searchText = sb.text!
        
        // show even when empty
        self.view.isHidden = false
    }
}
