//
//  FilterSectionHeaderTableViewCell.swift
//  LiverAtlas
//
//  Created by John on 11/21/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

protocol ExpandableFilterSectionDelegate {
    func sectionExpansionToggle(isExpanded: Bool, forFilterType filterType:LiverAtlasFilterType)
}

class FilterSectionHeaderView: UITableViewHeaderFooterView {

    var filterType: LiverAtlasFilterType!
    var delegate: ExpandableFilterSectionDelegate!
    var isExpanded: Bool!
    
    func configure(filterType: LiverAtlasFilterType,
                   isExpanded: Bool,
                   delegate: ExpandableFilterSectionDelegate) {
        self.filterType = filterType
        self.delegate = delegate
        self.isExpanded = isExpanded
        
        let headerText = [
            .diagnosisCategory: "Diagnosis Categories",
            .structuralFeature: "Structural Features",
            .imagingFeature: "Imaging Features"
            ][filterType]
        
        textLabel?.text = headerText
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func commonInit() {
        let expandCollapseTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpandCollapse))
        self.addGestureRecognizer(expandCollapseTapGesture)
    }
    
    @IBAction func toggleExpandCollapse(_ sender: AnyObject) {
        let shouldExpand = !isExpanded
        delegate?.sectionExpansionToggle(isExpanded: shouldExpand, forFilterType: filterType)
        
        isExpanded = shouldExpand
    }
}
