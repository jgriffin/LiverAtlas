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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderResultSummaryLabel: UILabel!
    
    lazy var searchController: LiverAtlasSearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?
    
    var liverAtlasCases: [LiverAtlasCase]? {
        didSet {
            guard let _ = tableViewHeaderResultSummaryLabel else {
                return
            }

            tableViewHeaderResultSummaryLabel.text = "There are \(liverAtlasCases?.count ?? 0) cases matching the current search"
            tableView?.reloadData()
        }
    }
    
    func configure(liverAtlasCases: [LiverAtlasCase]) {
        self.liverAtlasCases = liverAtlasCases
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "CaseResultTableViewCell",
                                 bundle: Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseResultTableViewCell.identifier)
        
        liverAtlasCases = liverAtlasCases ?? LiverAtlasIndex.instance.allCases
    }
    

    @IBAction func searchAction(_ sender: Any) {
        searchController.searchCases()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CaseResultsViewController.caseDetailSegueIdentifier:
            let indexPath = sender as! IndexPath
            let liverAtlasCase = liverAtlasCases![indexPath.item]
            let caseDetailVC = segue.destination as! CaseDetailsViewController
            
            caseDetailVC.liverAtlasCase = liverAtlasCase
            
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
        return liverAtlasCases?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let caseResultCell = tableView.dequeueReusableCell(withIdentifier: CaseResultTableViewCell.identifier,
                                                          for: indexPath) as! CaseResultTableViewCell
        
        let theCase = liverAtlasCases![indexPath.row]
        caseResultCell.configure(liverAtlasCase: theCase)
        
        return caseResultCell
    }
}

extension CaseResultsViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LiverAtlasSearchController {
        return LiverAtlasSearchController(delegate: self,
                                          searchControllerDelegate: self)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        if let _ = navigationItem.titleView {
            return
        }
        
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesBackButton = true
        
        hiddenRightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItem = nil
        
        searchController.searchBar.becomeFirstResponder()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItems = hiddenRightBarButtonItems
    }
}

extension CaseResultsViewController: LiverAtlasSearchControllerDelegate {
    
    func didSelect(liverAtlasCase: LiverAtlasCase) {
        // TODO: push details vc
    }
    
    func didEndSearch(withCases filteredResults: [LiverAtlasCase]) {
        self.configure(liverAtlasCases: filteredResults)
    }
}



