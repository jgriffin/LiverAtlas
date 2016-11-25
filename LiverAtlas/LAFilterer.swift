//
//  LAFilterer.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

struct FilteredCases {
    let cases: [LACase]
    let modality: LAModality
    let filters: [LAFilter]
}


class LAFilterer {
    
    init(allCases: [LACase]?, modality: LAModality) {
        self.allCases = allCases ?? LAIndex.instance.allCases
        self.activeModality = modality
    }
    
    let allCases: [LACase]

    // modality
    
    var activeModality: LAModality!  {
        didSet {
            _modalityFilteredCases = nil
            _modalityFilterGroups = nil
            _modalityByDiagnoses = nil
        }
    }
    
    var modalityFilteredCases: FilteredCases {
        if _modalityFilteredCases == nil {
            _modalityFilteredCases = filteredCases(fromCases: allCases,
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
    
    var modalityFilteredCasesByDiagnoses: [LACaseByDiagnosis] {
        if _modalityByDiagnoses == nil {
            _modalityByDiagnoses = casesByDiagnosis(fromFilteredCases: modalityFilteredCases)
        }
        
        return _modalityByDiagnoses!
    }
    var _modalityByDiagnoses: [LACaseByDiagnosis]?
    
    // filters
    
    var activeFilters =  Set<LAFilter>()
    var activeSearchTerm: String?
    
    func filteredCases(fromCases theCases: [LACase],
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
    
    // extract the filter groups from cases
    
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
    
    // by diagnosis
    
    func casesByDiagnosis(fromFilteredCases filteredCases: FilteredCases) -> [LACaseByDiagnosis] {
        
        let casesBySpecificDiagnosis = allCases.map { aCase -> LACaseByDiagnosis in
            return LACaseByDiagnosis.SpecificDiagnosis(diagnosis: aCase.diagnosis.diagnosis,
                                                               specificDiagnosis: aCase.specificDiagnosis,
                                                               laCase: aCase)
        }
        
        let casesBySpecificDiagnosisSorted = casesBySpecificDiagnosis.sorted { (lhs, rhs) -> Bool in
            guard case let LACaseByDiagnosis.SpecificDiagnosis(lhsDiagnosis, lhsSpecific, _) = lhs,
                case let LACaseByDiagnosis.SpecificDiagnosis(rhsDiagnosis, rhsSpecific, _) = rhs else {
                    fatalError()
            }
            
            return (lhsDiagnosis < rhsDiagnosis) || ((lhsDiagnosis == rhsDiagnosis) && lhsSpecific <= rhsSpecific)
        }
        
        var byDiagnoses = [LACaseByDiagnosis]()
        
        for specific in casesBySpecificDiagnosisSorted {
            if specific.diagnosisName != byDiagnoses.last?.diagnosisName {
                // add a diagnosis header
                byDiagnoses.append(LACaseByDiagnosis.Diagnosis(diagnosis: specific.diagnosisName))
            }
            byDiagnoses.append(specific)
        }
        
        return byDiagnoses
    }
    

    
    // filter a list of cases
    
    func filteredCases(fromFilteredCases filteredCases: FilteredCases,
                       passingFilter filter: LAFilter) -> FilteredCases {
        var cases: [LACase]
        switch filter.filterType {
        case .diagnosisCategory:
            cases = casesFiltered(fromCases: filteredCases.cases, withDiagnosisContaining: filter.filterString)
        case .structuralFeature:
            cases = casesFiltered(fromCases: filteredCases.cases, withStructuralFeatureContaining: filter.filterString)
        case .imagingFeature:
            cases = casesFiltered(fromCases: filteredCases.cases, withImagingFeatureContaining: filter.filterString)
        }
        
        return FilteredCases(cases: cases, modality: filteredCases.modality, filters: filteredCases.filters + [filter])
    }
    
    func filteredCases(fromFilteredCases: FilteredCases,
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
    
    
    
    // filter helpers
    
    
    func casesFiltered(fromCases theCases: [LACase],
               withDiagnosisContaining filterString: String) -> [LACase] {
        return theCases.filter { theCase in
            theCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(filterString)
        }
    }
    
    func casesFiltered(fromCases theCases: [LACase],
               withStructuralFeatureContaining filterString: String) -> [LACase] {
        
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
    
    func casesFiltered(fromCases theCases: [LACase],
               withImagingFeatureContaining filterString: String) -> [LACase] {
        
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
