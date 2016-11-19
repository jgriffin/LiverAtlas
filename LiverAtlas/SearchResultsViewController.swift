//
//  SearchResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

protocol SearchResultsViewControllerDelegate {
    func didSelect(liverAtlasCase: LiverAtlasCase)
}


class SearchResultsViewController: UITableViewController {
    let searcher = LiverAtlasSearcher()
    var delegate: SearchResultsViewControllerDelegate?
    
    var casesToSearch: [LiverAtlasCase]! {
        didSet {
            filteredCases = casesToSearch
        }
    }
    var filteredCases: [LiverAtlasCase]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.register(UINib(nibName:"CaseResultTableViewCell",
                                 bundle:Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseResultTableViewCell.identifier)
    }

    // TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCases?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CaseResultTableViewCell.identifier,
                                                 for: indexPath) as! CaseResultTableViewCell
        
        let liverAtlasCase = filteredCases[indexPath.item]
        cell.configure(liverAtlasCase: liverAtlasCase)
        
        return cell
    }
    
    // TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liverAtlasCase = filteredCases[indexPath.item]
        delegate?.didSelect(liverAtlasCase: liverAtlasCase)
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        let searchText = sb.text!
        
        // show even when empty
        self.view.isHidden = false
        
        filteredCases = searcher.searchCases(casesToSearch: casesToSearch, forSearchText: searchText)
    }
}
