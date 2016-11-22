//
//  FilterTableViewController.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {
    let filterItemReuseIdentifier = "FilterItemCellIdentifier"
    let sectionHeaderReuseIdentifier = "SectionHeaderCellIdentifier"

    @IBOutlet var modalitySegmentedControl: UISegmentedControl!
    
    // selected modality and filters
    
    let filterer = LiverAtlasFilterer(allCases: nil,
                                      modality: LiverAtlasModality.ct)
    
    var expandedFilterSections = Set<LiverAtlasFilterType>()
    var selectedFeatures = Set<LiverAtlasFilter>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50; //Set this to any value that works for you.
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50; //Set this to any value that works for you.
        self.tableView.register(FilterSectionHeaderView.self,
                                forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        expandedFilterSections = [.diagnosisCategory]
        selectedFeatures = Set()
    }

    @IBAction func doneAction(_ sender: Any) {
        showDetailViewController(AppDelegate.instance.detailsNavigationController, sender: self)
    }

    // MARK: Modality Filters
    
    @IBAction func modalityChanged(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else {
            fatalError()
        }
        
        let selectedModality: LiverAtlasModality = {
            switch segmentedControl.selectedSegmentIndex {
            case 0: return .ct
            case 1: return .mr
            case 2: return .us
            default: fatalError()
            }
        }()
        
        filterer.activeModality = selectedModality
        tableView?.reloadData()
    }

    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterGroup = filterer.modalityFilterGroups[indexPath.section]
        let filter = filterGroup.filters[indexPath.row]
        let isSelected = selectedFeatures.contains(filter)
        
        if isSelected {
            selectedFeatures.remove(filter)
        } else {
            selectedFeatures.insert(filter)
        }

        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ApplyFilterToDetailsSegue" {
        }
    }
 
}

extension FilterTableViewController: ExpandableFilterSectionDelegate { // UITableViewDataSource

    func sectionExpansionToggle(isExpanded: Bool, forFilterType filterType: LiverAtlasFilterType) {
        if isExpanded {
            expandedFilterSections.insert(filterType)
        } else {
            expandedFilterSections.remove(filterType)
        }
        let sectionIndex = { (filterType: LiverAtlasFilterType) -> Int in
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
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as! FilterSectionHeaderView
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: filterItemReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = filterItem.filterString
        cell.accessoryType = selectedFeatures.contains(filterItem) ? .checkmark : .none
        
        return cell
    }
    
}

