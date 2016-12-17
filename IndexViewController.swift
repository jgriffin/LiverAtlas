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
    
    fileprivate var filteredCasesByDiagnoses: [[SpecificDiagnosis]] {
        if _filteredCasesByDiagnoses == nil {
            _filteredCasesByDiagnoses = LAFilterer.casesByDiagnosis(fromFilteredCases: filteredCases)
        }
        return _filteredCasesByDiagnoses!
    }
    var _filteredCasesByDiagnoses: [[SpecificDiagnosis]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.register(IndexDiagnosisHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: CellID.diagnosisHeaderID.rawValue)

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
        return filteredCasesByDiagnoses.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CellID.diagnosisHeaderID.rawValue) as! IndexDiagnosisHeaderView

        let diagnosis = filteredCasesByDiagnoses[section].first!.diagnosis
        header.configure(title: diagnosis)
        
        return header
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCasesByDiagnoses[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let byDiagnosis = filteredCasesByDiagnoses[indexPath.section]
        
        let diagnosisCell = tableView.dequeueReusableCell(withIdentifier: CellID.specificDiagnosisCellID.rawValue,
                                                      for: indexPath) as! IndexTableViewCell
        diagnosisCell.titleLabel.text = byDiagnosis[indexPath.row].specificDiagnosis
        
        return diagnosisCell
    }
}

extension IndexViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let laCase = filteredCasesByDiagnoses[indexPath.section][indexPath.row].laCase
        
        let detailsVC = MainStoryboard.instantiate(withStoryboardID: .caseDetailsID) as! CaseDetailsViewController
        detailsVC.configure(laCase: laCase, modality: filteredCases.modality)
        
        navigationController?.pushViewController(detailsVC, animated: true)
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
