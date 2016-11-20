//
//  LiverAtlasSearchController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation
import UIKit

protocol LiverAtlasSearchControllerDelegate {
    
    func didEndSearch(withCases: [LiverAtlasCase])
    
    func didSelect(liverAtlasCase: LiverAtlasCase)

}



class LiverAtlasSearchController: NSObject {
    var delegate: LiverAtlasSearchControllerDelegate?
    
    var searchController: UISearchController!
    var searchResultsController: SearchResultsViewController!
    
    init(delegate: LiverAtlasSearchControllerDelegate,
         searchControllerDelegate: UISearchControllerDelegate) {
        
        self.delegate = delegate
        super.init()

        createSearchAndResultsControllers(searchControllerDelegate: searchControllerDelegate)
    }
    
    func createSearchAndResultsControllers(searchControllerDelegate: UISearchControllerDelegate) {
        searchResultsController = SearchResultsViewController()
        searchResultsController.casesToSearch = LiverAtlasIndex.instance.allCases
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
        searchBar.delegate = self
    }
    
    @IBAction func searchCases() {
        searchController.isActive = true
    }
}

extension LiverAtlasSearchController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard !searchBar.text!.isEmpty,
            let filteredResults = searchResultsController?.filteredCases,
            !filteredResults.isEmpty else {
                return
        }
        
        delegate?.didEndSearch(withCases: filteredResults)
        searchController.isActive = false
    }
}

extension LiverAtlasSearchController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liverAtlasCase = searchResultsController.filteredCases[indexPath.item]
        
        delegate?.didSelect(liverAtlasCase: liverAtlasCase)
        searchController.isActive = false
    }

}

