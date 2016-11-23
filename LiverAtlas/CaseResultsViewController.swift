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
    static let homePageControllerIdentifier = "HomePageViewControllerStoryboardIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderResultSummaryLabel: UILabel!
    
    lazy var searchController: LASearchController = { self.createSearchController() }()
    var hiddenRightBarButtonItems: [UIBarButtonItem]?
    
    var laCases: [LACase]? {
        didSet {
            guard let _ = tableViewHeaderResultSummaryLabel else {
                return
            }

            tableViewHeaderResultSummaryLabel.text = "There are \(laCases?.count ?? 0) cases matching the current search"
            tableView?.reloadData()
        }
    }
    
    func configure(laCases: [LACase]) {
        self.laCases = laCases
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "CaseResultTableViewCell",
                                 bundle: Bundle(for: type(of:self))),
                           forCellReuseIdentifier: CaseResultTableViewCell.identifier)
        
        laCases = laCases ?? LAIndex.instance.allCases
    }
    

    @IBAction func searchAction(_ sender: Any) {
        definesPresentationContext = true
        
        let searchBar = searchController.searchController.searchBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        navigationItem.hidesBackButton = true
        
        hiddenRightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItem = nil

        searchController.searchCases()
    }
    
    @IBAction func homeAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle(for: type(of:self)))
        
        let homePageVC = storyboard.instantiateViewController(withIdentifier: CaseResultsViewController.homePageControllerIdentifier) as! HomePageViewController
        
        homePageVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        homePageVC.navigationItem.leftItemsSupplementBackButton = true
        
        let detailNavController = UINavigationController(rootViewController: homePageVC)
        
        showDetailViewController(detailNavController, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CaseResultsViewController.caseDetailSegueIdentifier:
            let indexPath = sender as! IndexPath
            let laCase = laCases![indexPath.item]
            let caseDetailVC = segue.destination as! CaseDetailsViewController
            
            caseDetailVC.laCase = laCase
            
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
        return laCases?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let caseResultCell = tableView.dequeueReusableCell(withIdentifier: CaseResultTableViewCell.identifier,
                                                          for: indexPath) as! CaseResultTableViewCell
        
        let theCase = laCases![indexPath.row]
        caseResultCell.configure(laCase: theCase)
        
        return caseResultCell
    }
}

extension CaseResultsViewController: UISearchControllerDelegate {
    
    func createSearchController() -> LASearchController {
        return LASearchController(delegate: self,
                                          searchControllerDelegate: self)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
//        searchController.searchBar.becomeFirstResponder()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItems = hiddenRightBarButtonItems
    }
}

extension CaseResultsViewController: LASearchControllerDelegate {
    
    func didSelect(laCase: LACase) {
        // TODO: push details vc
    }
    
    func didEndSearch(withCases filteredResults: [LACase]) {
        self.configure(laCases: filteredResults)
    }
}



