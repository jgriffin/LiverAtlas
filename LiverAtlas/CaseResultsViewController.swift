//
//  CaseResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultsViewController: UIViewController, UITableViewDelegate {
    let caseDetailSegueIdentifier =  "CaseResultToCaseDetailSegue"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderResultSummaryLabel: UILabel!
    
    var liverAtlasCases: [LiverAtlasCase]? {
        didSet {
            tableViewHeaderResultSummaryLabel.text = "There are \(liverAtlasCases?.count ?? 0) cases matching the current search"
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        liverAtlasCases = LiverAtlasCaseIndex.instance.allCases
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let liverAtlasCase = liverAtlasCases![tableView.indexPathForSelectedRow!.row]
        
        switch segue.identifier! {
        case caseDetailSegueIdentifier:
            let caseDetailVC = segue.destination as! LiverAtlasCaseDetailViewController
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

        let caseResultCell = tableView.dequeueReusableCell(withIdentifier: "caseResultIdentifier",
                                                          for: indexPath) as! CaseResultTableViewCell
        
        let theCase = liverAtlasCases![indexPath.row]
        caseResultCell.configure(liverAtlasCase: theCase)
        
        return caseResultCell
    }
}


