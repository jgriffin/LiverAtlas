//
//  FiltersViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

protocol FilterViewDelegate {
    func didChangeFilter(filteredCases: FilteredCases)
}


class FiltersViewController: UITableViewController {
    @IBOutlet var modalitySegmentedControl: UISegmentedControl!
    
    var delegate: FilterViewDelegate?
    
    fileprivate var filterer: LAFilterer!
    fileprivate var expandedFilterSections = Set<LAFilterType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50; //Set this to any value that works for you.
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50; //Set this to any value that works for you.
        self.tableView.register(FilterSectionHeaderView.self,
                                forHeaderFooterViewReuseIdentifier: CellID.sectionHeaderReuseID.rawValue)
        
        // clone LAFilterer.instance 
        // so filter changes are rememberd across the app
        filterer = LAFilterer(filterer: LAFilterer.instance)
        
        modalitySegmentedControl.selectedSegmentIndex = modalityToSegmentIndexMap[filterer.activeModality]!
        expandedFilterSections = [.diagnosisCategory]
        
        updateFiltersPrompt()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed || isMovingFromParentViewController {
            // write back changes to LAFilterer.instance (unless cancelled)
            LAFilterer.instance.activeModality = filterer.activeModality
            LAFilterer.instance.activeFilters = filterer.activeFilters
            
            let filteredCases = LAFilterer.filteredCases(
                fromFilteredCases: filterer.modalityFilteredCases,
                passingFilters: Array(filterer.activeFilters))
            
            delegate?.didChangeFilter(filteredCases: filteredCases)
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if let _ = presentingViewController {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            let _ = navigationController?.popViewController(animated: true)
        }
    }

    // MARK: Modality Filters
    
    let modalityToSegmentIndexMap: [LAModality: Int] = [.ct: 0, .mr: 1, .us: 2]
    
    @IBAction func modalityChanged(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else {
            fatalError()
        }
        
        let selectedModality: LAModality = modalityToSegmentIndexMap.first(where: { (modality, index) -> Bool in
            index == segmentedControl.selectedSegmentIndex
        })!.key
        
        filterer.activeModality = selectedModality
        tableView?.reloadData()
    }

    // features filter5s
    
    @IBAction func clearFiltersAction(_ sender: Any) {
        filterer.activeFilters.removeAll()
        tableView.reloadData()         // update item selections
        updateFiltersPrompt()
    }
    
    func updateActiveFilters(filter: LAFilter, shouldActivate: Bool) {
        if shouldActivate {
            filterer.activeFilters.insert(filter)
        } else {
            filterer.activeFilters.remove(filter)
        }
        
        updateFiltersPrompt()
    }
    
    func updateFiltersPrompt() {
        let filterCount = filterer.activeFilters.count
        
        let caseCount = filterer.filteredCases.cases.count
        navigationItem.title = "\(caseCount) cases filtered"

        navigationItem.prompt = filterCount == 0 ?
            "No filters selected" : "\(filterCount) filters selected"
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterGroup = filterer.modalityFilterGroups[indexPath.section]
        let filter = filterGroup.filters[indexPath.row]
        let isSelected = filterer.activeFilters.contains(filter)
        
        updateActiveFilters(filter: filter, shouldActivate: !isSelected)
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
}

extension FiltersViewController: ExpandableFilterSectionDelegate { // UITableViewDataSource

    func sectionExpansionToggle(isExpanded: Bool, forFilterType filterType: LAFilterType) {
        if isExpanded {
            expandedFilterSections.insert(filterType)
        } else {
            expandedFilterSections.remove(filterType)
        }
        let sectionIndex = { (filterType: LAFilterType) -> Int in
            switch filterType {
            case .diagnosisCategory: return 0
            case .structuralFeature: return 1
            case .imagingFeature: return 2
            }
        }(filterType)
        
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: sectionIndex),
                                 with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterer.modalityFilterGroups.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let filterGroup = filterer.modalityFilterGroups[section]
        
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CellID.sectionHeaderReuseID.rawValue) as! FilterSectionHeaderView
        
        let isExpanded = expandedFilterSections.contains(filterGroup.filterType)
        headerView.configure(filterType: filterGroup.filterType,
                             isExpanded: isExpanded,
                             delegate: self)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filterGroup = filterer.modalityFilterGroups[section]
        let filterCountForGroup = filterGroup.filters.count
        
        return expandedFilterSections.contains(filterGroup.filterType) ? filterCountForGroup : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterItem = filterer.modalityFilterGroups[indexPath.section].filters[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellID.filterItemReuseID.rawValue, for: indexPath)
        
        cell.textLabel?.text = filterItem.filterString
        cell.accessoryType = filterer.activeFilters.contains(filterItem) ? .checkmark : .none
        
        return cell
    }
    
}

