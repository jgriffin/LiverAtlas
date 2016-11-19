//
//  SearchResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController {
    let casesToSearch: [LiverAtlasCase]
    
    var filteredCases: [LiverAtlasCase] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let searcher = LiverAtlasSearcher()
    
    init(casesToSearch: [LiverAtlasCase]) {
        self.casesToSearch = casesToSearch
        self.filteredCases = casesToSearch

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.register(UINib(nibName:"CaseResultTableViewCell", bundle:Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseResultTableViewCell.identifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CaseResultTableViewCell.identifier,
                                                 for: indexPath) as! CaseResultTableViewCell
        
        let liverAtlasCase = filteredCases[indexPath.item]
        cell.configure(liverAtlasCase: liverAtlasCase)
        
        return cell
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        let searchText = sb.text!
        
        filteredCases = searcher.searchCases(casesToSearch: casesToSearch, forSearchText: searchText)
    }
}
