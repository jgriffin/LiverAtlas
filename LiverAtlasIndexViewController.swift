//
//  LAIndexViewController.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class LAIndexViewController: UIViewController {
    let diagnosisCellIdentifier = "DiagnosisTableCellIdentifier"
    let specificDiagnosisCellIdentifier = "SpecificDiagnosisTableCellIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    
    var filterer: LAFilterer = LAFilterer(allCases: nil, modality: LAModality.ct)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension LAIndexViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterer.modalityFilteredCasesByDiagnoses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let byDiagnosis = filterer.modalityFilteredCasesByDiagnoses[indexPath.item]
        
        switch byDiagnosis {
        case let .Diagnosis(diagnosis):
            let diagnosisCell = tableView.dequeueReusableCell(withIdentifier: diagnosisCellIdentifier, for: indexPath)
            diagnosisCell.textLabel?.text = diagnosis
            return diagnosisCell
            
        case let .SpecificDiagnosis(_, specific, _):
            let diagnosisCell = tableView.dequeueReusableCell(withIdentifier: diagnosisCellIdentifier, for: indexPath)
            diagnosisCell.textLabel?.text = specific
            return diagnosisCell
        }
    }
    
}
//
//extension LAIndexViewController: UITableViewDelegate {
//    
//}
