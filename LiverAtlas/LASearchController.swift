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
    func didEndSearch(withSearchString: String)
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
    
    func searchCases(filteredCasesToSearch: FilteredCases, searchText: String) {
        searchResultsController.configure(filteredCasesToSearch: filteredCasesToSearch,
                                          searchText: searchText)
        searchController.isActive = true
    }
}

extension LASearchController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        delegate?.didEndSearch(withSearchString: searchBar.text!)
        searchController.isActive = false
    }
}

extension LASearchController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let laCase = searchResultsController.searchResultCases[indexPath.item]
        
        delegate?.didSelect(laCase: laCase)
        searchController.isActive = false
    }

}

