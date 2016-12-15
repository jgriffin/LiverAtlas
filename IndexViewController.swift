//
//  IndexViewController.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersBarButtonItem: UIBarButtonItem!

    fileprivate var filteredCases: FilteredCases! {
        didSet {
            updateFiltersButton(modality: filteredCases.modality)
            _filteredCasesByDiagnoses = nil
            tableView.reloadData()
        }
    }
    
    fileprivate var filteredCasesByDiagnoses: [LACaseByDiagnosis] {
        if _filteredCasesByDiagnoses == nil {
            _filteredCasesByDiagnoses = LAFilterer.casesByDiagnosis(fromFilteredCases: filteredCases)
        }
        return _filteredCasesByDiagnoses!
    }
    var _filteredCasesByDiagnoses: [LACaseByDiagnosis]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        if filteredCases == nil {
            filteredCases = LAFilterer.instance.filteredCases
        }
    }
    
    @IBAction func filtersAction(_ sender: Any) {
        let filtersVC = MainStoryboard.instantiate(withStoryboardID: .filtersID) as! FiltersViewController
        filtersVC.delegate = self
        
        navigationController?.pushViewController(filtersVC, animated: true)
    }

    private func updateFiltersButton(modality: LAModality) {
        var buttonText: String
        switch modality {
        case .ct: buttonText = "CT"
        case .mr: buttonText = "MR"
        case .us: buttonText = "US"
        }
        
        filtersBarButtonItem.title = buttonText
    }
}

extension IndexViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCasesByDiagnoses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let byDiagnosis = filteredCasesByDiagnoses[indexPath.item]
        
        switch byDiagnosis {
        case let .Diagnosis(diagnosis):
            let diagnosisCell = tableView.dequeueReusableCell(
                withIdentifier: CellID.diagnosisCellID.rawValue,
                for: indexPath) as! IndexTableViewCell
            diagnosisCell.titleLabel.text = diagnosis
            return diagnosisCell
            
        case let .SpecificDiagnosis(_, specific, _):
            let diagnosisCell = tableView.dequeueReusableCell(
                withIdentifier: CellID.specificDiagnosisCellID.rawValue,
                for: indexPath) as! IndexTableViewCell
            diagnosisCell.titleLabel.text = specific
            return diagnosisCell
        }
    }
}

extension IndexViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let byDiagnosis = filteredCasesByDiagnoses[indexPath.item]
        
        switch byDiagnosis {
        case let .Diagnosis(diagnosis):
            let diagnosisFilter = LAFilter(filterType: .diagnosisCategory,
                                           filterString: diagnosis)
            let casesWithDiagnosis = LAFilterer.filteredCases(fromFilteredCases: filteredCases,
                                                              passingFilter: diagnosisFilter)
            
            let casesVC = MainStoryboard.instantiate(withStoryboardID: .casesID) as! CasesViewController
            casesVC.configure(filteredCases: casesWithDiagnosis)
            navigationController?.pushViewController(casesVC, animated: true)
            
        case let .SpecificDiagnosis(_, _, laCase):
            let detailsVC = MainStoryboard.instantiate(withStoryboardID: .caseDetailsID) as! CaseDetailsViewController
            detailsVC.configure(laCase: laCase, modality: filteredCases.modality)
            
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}

extension IndexViewController: FilterViewDelegate {
    func didChangeFilter(filteredCases: FilteredCases) {
        self.filteredCases = filteredCases
    }
}

class IndexTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
}
