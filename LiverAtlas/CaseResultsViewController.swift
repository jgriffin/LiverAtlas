//
//  CaseResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultsViewController: UIViewController, UITableViewDelegate {
    static let storyboardIdentifier = "CaseResultsViewControllerStoryboardIdentifier"
    static let caseDetailSegueIdentifier =  "CaseResultToCaseDetailSegue"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderResultSummaryLabel: UILabel!
    
    var liverAtlasCases: [LiverAtlasCase]? {
        didSet {
            guard let _ = tableViewHeaderResultSummaryLabel else {
                return
            }

            tableViewHeaderResultSummaryLabel.text = "There are \(liverAtlasCases?.count ?? 0) cases matching the current search"
            tableView?.reloadData()
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: CaseResultsViewController.caseDetailSegueIdentifier,
                     sender: indexPath)

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


