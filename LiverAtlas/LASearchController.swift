//
//  LASearchController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation
import UIKit



protocol LASearchControllerDelegate {
    func didEndSearch(withSearchResults: SearchResults)
    func didSelect(laCase: LACase)
}


class LASearchController: NSObject {
    var delegate: LASearchControllerDelegate?
    
    var searchController: UISearchController!
    var searchResultsController: SearchResultsViewController!
    
    init(delegate: LASearchControllerDelegate,
         searchControllerDelegate: UISearchControllerDelegate) {
        
        self.delegate = delegate
        super.init()

        createSearchAndResultsControllers(searchControllerDelegate: searchControllerDelegate)
    }
    
    func createSearchAndResultsControllers(searchControllerDelegate: UISearchControllerDelegate) {
        searchResultsController = SearchResultsViewController()
        searchResultsController.configure(filteredCasesToSearch: FilteredCases(cases: LAIndex.instance.allCases,
                                                                               modality: .ct,
                                                                               filters: []))
        searchResultsController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = searchControllerDelegate
        
        let searchBar = searchController.searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.sizeToFit()
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = true
        searchBar.delegate = self
    }
    
    func searchCases(filteredCasesToSearch: FilteredCases) {
        searchResultsController.configure(filteredCasesToSearch: filteredCasesToSearch)
        searchController.isActive = true
    }
}

extension LASearchController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard !searchBar.text!.isEmpty,
            let searchResults = searchResultsController?.searchResults,
            !searchResults.cases.isEmpty else {
                return
        }
        
        delegate?.didEndSearch(withSearchResults: searchResults)
        searchController.isActive = false
    }
}

extension LASearchController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let laCase = searchResultsController.searchResults.cases[indexPath.item]
        
        delegate?.didSelect(laCase: laCase)
        searchController.isActive = false
    }

}

