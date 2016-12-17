//
//  LAFilterer.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

class LAFilterer {
    static var instance = LAFilterer(allCases: nil, modality: .ct, activeFilters: nil)
    let allCases: [LACase]
    
    init(allCases: [LACase]?, modality: LAModality, activeFilters: Set<LAFilter>?) {
        self.allCases = allCases ?? LAIndex.instance.allCases
        self.activeModality = modality
        self.activeFilters = activeFilters ?? Set<LAFilter>()
    }
    
    convenience init(filterer: LAFilterer) {
        self.init(allCases: filterer.allCases,
                  modality: filterer.activeModality,
                  activeFilters: filterer.activeFilters)
    }

    var activeModality: LAModality!  {
        didSet {
            _modalityFilteredCases = nil
            _modalityFilterGroups = nil
            _modalityByDiagnoses = nil
            _filteredCases = nil
        }
    }
    
    var activeFilters: Set<LAFilter>! {
        didSet {
            _filteredCases = nil
        }
    }

    // modality
    
    var modalityFilteredCases: FilteredCases {
        if _modalityFilteredCases == nil {
            _modalityFilteredCases = LAFilterer.filteredCases(fromCases: allCases,
                                                              withModality: activeModality)
        }
        return _modalityFilteredCases!
    }
    var _modalityFilteredCases: FilteredCases?
    
    var modalityFilterGroups: [LAFilterGroup] {
        if _modalityFilterGroups == nil {
            _modalityFilterGroups = filterGroups(fromFilteredCases: modalityFilteredCases)
        }
        return _modalityFilterGroups!
    }
    var _modalityFilterGroups:[LAFilterGroup]?
    
    var modalityFilteredCasesByDiagnoses:[[SpecificDiagnosis]] {
        if _modalityByDiagnoses == nil {
            _modalityByDiagnoses = LAFilterer.casesByDiagnosis(fromFilteredCases: modalityFilteredCases)
        }
        
        return _modalityByDiagnoses!
    }
    var _modalityByDiagnoses: [[SpecificDiagnosis]]?
    
    // filters
    
    var filteredCases: FilteredCases {
        if _filteredCases == nil {
            _filteredCases = LAFilterer.filteredCases(fromFilteredCases: modalityFilteredCases,
                                                      passingFilters: Array(activeFilters))
        }
        
        return _filteredCases!
    }
    private var _filteredCases: FilteredCases?
}

extension LAFilterer { // helpers
    
    static func filteredCases(fromCases theCases: [LACase],
                     withModality modality: LAModality) -> FilteredCases {
        let filteredCases = theCases.filter { (aCase: LACase) -> Bool in
            switch modality {
            case .ct:
                return !aCase.ctmodality.isEmpty
            case .mr:
                return !aCase.mrmodality.isEmpty
            case .us:
                return !aCase.usmodality.isEmpty
            }
        }
        return FilteredCases(cases: filteredCases, modality: modality, filters: [])
    }
    
    static func filteredCases(fromFilteredCases: FilteredCases,
                       passingFilters filters: [LAFilter]) -> FilteredCases {
        var filteredCases = fromFilteredCases
        
        for filter in filters {
            filteredCases = self.filteredCases(fromFilteredCases: filteredCases,
                                               passingFilter: filter)
            if filteredCases.cases.isEmpty {
                // no results - we're done already
                return FilteredCases(cases: [],
                                     modality: fromFilteredCases.modality,
                                     filters: fromFilteredCases.filters + filters)
            }
        }
        
        return filteredCases
    }

    static func filteredCases(fromFilteredCases filteredCases: FilteredCases,
                       passingFilter filter: LAFilter) -> FilteredCases {
        var cases: [LACase]
        switch filter.filterType {
        case .diagnosisCategory:
            cases = casesWithDiagnosis(containing: filter.filterString,
                                       fromCases: filteredCases.cases)
        case .structuralFeature:
            cases = casesWithStructuralFeature(containing: filter.filterString,
                                               fromCases: filteredCases.cases)
        case .imagingFeature:
            cases = casesWithImagingFeature(containing: filter.filterString,
                                            fromCases: filteredCases.cases)
        }
        
        return FilteredCases(cases: cases, modality: filteredCases.modality, filters: filteredCases.filters + [filter])
    }

    // filter specific fields
    
    static func casesWithDiagnosis(containing filterString: String,
                            fromCases theCases: [LACase]) -> [LACase] {
        return theCases.filter { theCase in
            theCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(filterString)
        }
    }
    
    static func casesWithStructuralFeature(containing filterString: String,
                                    fromCases theCases: [LACase]) -> [LACase] {
        
        let structuralFeatureContainsFilterString = {
            (structuralFeature: LAStructuralFeature) -> Bool in
            return structuralFeature.title.localizedCaseInsensitiveContains(filterString)
        }
        
        let ctmodalityContainsFeature = {
            (ctmodality: LACTModality) -> Bool in
            return ctmodality.structuralFeatures.first(where: structuralFeatureContainsFilterString) != nil
        }
        
        return theCases.filter { theCase -> Bool in
            theCase.ctmodality.first(where: ctmodalityContainsFeature) != nil
        }
    }
    
    static func casesWithImagingFeature(containing filterString: String,
                                 fromCases theCases: [LACase]) -> [LACase] {
        
        let imagingFeatureContainsFilterString = {
            (imagingFeature: LAStructuralFeature) -> Bool in
            return imagingFeature.title.localizedCaseInsensitiveContains(filterString)
        }
        
        let ctmodalityContainsFeature = {
            (ctmodality: LACTModality) -> Bool in
            return ctmodality.structuralFeatures.first(where: imagingFeatureContainsFilterString) != nil
        }
        
        return theCases.filter { theCase -> Bool in
            theCase.ctmodality.first(where: ctmodalityContainsFeature) != nil
        }
    }
}

extension LAFilterer { // groups and diagnoses

    func filterGroups(fromFilteredCases filteredCases: FilteredCases) -> [LAFilterGroup] {
        let diagnosisFiltersGroup: LAFilterGroup = {
            let theDiagnoses = filteredCases.cases.flatMap { $0.diagnosis.categories.map({ $0.title}) }
            let uniqueDiagnoses = Set(theDiagnoses).sorted()
            let diagnosesFilters = uniqueDiagnoses.map {
                LAFilter(filterType: .diagnosisCategory, filterString: $0)
            }
            
            return LAFilterGroup(filterType: .diagnosisCategory,
                                 filters: diagnosesFilters)
        }()
        
        let structuralFiltersGroup: LAFilterGroup = {
            let theStructuralFeatureNames = filteredCases.cases.flatMap { (aCase: LACase) -> [String] in
                aCase.structuralFeaturesForModality(modality: filteredCases.modality).map { $0.title }
            }
            let uniqueStructuralFeatures = Set(theStructuralFeatureNames).sorted()
            let structuralFilters = uniqueStructuralFeatures.map { (featureName) -> LAFilter in
                LAFilter(filterType: .structuralFeature, filterString: featureName)
            }
            return LAFilterGroup(filterType: .structuralFeature,
                                 filters: structuralFilters)
        }()
        
        let imagingFiltersGroup: LAFilterGroup = {
            // imagine features group
            let theImagingFeatureNames = filteredCases.cases.flatMap { (aCase: LACase) -> [String] in
                aCase.imagingFeaturesForModality(modality: filteredCases.modality).map { $0.title }
            }
            let uniqueImagingFeatures = Set(theImagingFeatureNames).sorted()
            let imagingFilters = uniqueImagingFeatures.map { (featureName) -> LAFilter in
                LAFilter(filterType: .imagingFeature, filterString: featureName)
            }
            return LAFilterGroup(filterType: .imagingFeature, filters: imagingFilters)
        }()
        
        return [diagnosisFiltersGroup, structuralFiltersGroup, imagingFiltersGroup]
    }
    
    static func casesByDiagnosis(fromFilteredCases filteredCases: FilteredCases) -> [[SpecificDiagnosis]] {
        let casesBySpecificDiagnosisSorted = filteredCases.cases.map( { laCase -> SpecificDiagnosis in
            SpecificDiagnosis(fromCase: laCase)
        }).sorted(by:compareBySpecificDiagnosis)
        
        // collect into groups
        var byDiagnoses = [[SpecificDiagnosis]]()
        for specific in casesBySpecificDiagnosisSorted {
            if specific.diagnosis != byDiagnoses.last?.first?.diagnosis {
                // add a new section
                byDiagnoses.append([SpecificDiagnosis]())
            }
            byDiagnoses[byDiagnoses.count-1].append(specific)
        }
        
        return byDiagnoses
    }

    static func compareBySpecificDiagnosis(lhs: SpecificDiagnosis, rhs:SpecificDiagnosis) -> Bool {
        if lhs.diagnosis < rhs.diagnosis {
            return true
        }
        if lhs.diagnosis > rhs.diagnosis {
            return false
        }
        return lhs.specificDiagnosis <= rhs.specificDiagnosis
    }
    
    static func diagnosesAndSpecificDiagnoses(fromFilteredCases filteredCases: FilteredCases) -> (diagnoses: [String], specificDiagnoses: [String]) {
        let byDiagnosis = casesByDiagnosis(fromFilteredCases: filteredCases)

        let diagnoses = byDiagnosis.map { $0.first!.diagnosis }
        let specificDiagnoses = byDiagnosis.flatMap({ specificDiagnoses in
            specificDiagnoses.flatMap { $0.specificDiagnosis }
        })
        return (diagnoses, specificDiagnoses)
    }
}


