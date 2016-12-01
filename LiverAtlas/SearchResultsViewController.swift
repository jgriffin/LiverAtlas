//
//  SearchResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController {
    let searcher = LASearcher()
    
    var filteredCasesToSearch: FilteredCases! {
        didSet {
            searchResults = SearchResults(fromFilteredCases: filteredCasesToSearch,
                                          searchString: "",
                                          cases: filteredCasesToSearch.cases)
        }
    }
    
    var searchResults: SearchResults! {
        didSet {
            tableView.reloadData()
        }
    }
    
    func configure(filteredCasesToSearch: FilteredCases) {
        self.filteredCasesToSearch = filteredCasesToSearch
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.register(UINib(nibName:"CaseTableViewCell",
                                 bundle:Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseTableViewCell.identifier)
    }

    // TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.cases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CaseTableViewCell.identifier,
                                                 for: indexPath) as! CaseTableViewCell
        
        let laCase = searchResults.cases[indexPath.item]
        cell.configure(laCase: laCase, modalityFilter: searchResults.fromFilteredCases.modality)
        
        return cell
    }    
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        let searchText = sb.text!
        
        // show even when empty
        self.view.isHidden = false
        
        searchResults = searcher.searchCases(fromFilteredCases: filteredCasesToSearch,
                                             forSearchText: searchText)
    }
}
