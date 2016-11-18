//
//  CaseResultsViewController.swift
//  LiverAtlas
//
//  Created by John on 11/17/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class CaseResultsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var liverAtlasCases: [LiverAtlasCase]? {
        didSet {
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        liverAtlasCases = LiverAtlasCaseIndex.instance.allCases
    }

}

extension CaseResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liverAtlasCases?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let caseResultCell = tableView.dequeueReusableCell(withIdentifier: "caseResultIdentifier",
                                                          for: indexPath)
        
        let theCase = liverAtlasCases![indexPath.row]
        
        caseResultCell.textLabel?.text = theCase.title
        caseResultCell.detailTextLabel?.text = theCase.specificDiagnosis
        
        return caseResultCell
    }
}


