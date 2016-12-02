//
//  LAFilterer.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

class LAFilterer {
    static var instance = LAFilterer(allCases: nil, modality: .ct)
    let allCases: [LACase]
    
    init(allCases: [LACase]?, modality: LAModality) {
        self.allCases = allCases ?? LAIndex.instance.allCases
        self.activeModality = modality
    }

    var activeModality: LAModality!  {
        didSet {
            _modalityFilteredCases = nil
            _modalityFilterGroups = nil
            _modalityByDiagnoses = nil
            _filteredCases = nil
        }
    }
    
    var activeFilters = Set<LAFilter>() {
        didSet {
            _filteredCases = nil
        }
    }

    // modality
    
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
    
    var filteredCases: FilteredCases {
        if _filteredCases == nil {
            _filteredCases = self.filteredCases(
                fromFilteredCases: modalityFilteredCases,
                passingFilters: Array(activeFilters))
        }
        
        return _filteredCases!
    }
    private var _filteredCases: FilteredCases?
}

extension LAFilterer { // helpers
    
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

    func filteredCases(fromFilteredCases filteredCases: FilteredCases,
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
    
    func casesWithDiagnosis(containing filterString: String,
                            fromCases theCases: [LACase]) -> [LACase] {
        return theCases.filter { theCase in
            theCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(filterString)
        }
    }
    
    func casesWithStructuralFeature(containing filterString: String,
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
    
    func casesWithImagingFeature(containing filterString: String,
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
    
    func casesByDiagnosis(fromFilteredCases filteredCases: FilteredCases) -> [LACaseByDiagnosis] {
        let casesBySpecificDiagnosisSorted = filteredCases.cases.map( { aCase -> LACaseByDiagnosis in
            return LACaseByDiagnosis.SpecificDiagnosis(diagnosis: aCase.diagnosis.diagnosis,
                                                       specificDiagnosis: aCase.specificDiagnosis,
                                                       laCase: aCase)
        }).sorted(by:compareBySpecificDiagnosis)
        
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
    
    func compareBySpecificDiagnosis(lhs: LACaseByDiagnosis, rhs:LACaseByDiagnosis) -> Bool {
        guard case let LACaseByDiagnosis.SpecificDiagnosis(lhsDiagnosis, lhsSpecific, _) = lhs,
            case let LACaseByDiagnosis.SpecificDiagnosis(rhsDiagnosis, rhsSpecific, _) = rhs else {
                fatalError()
        }
        
        return (lhsDiagnosis < rhsDiagnosis) || ((lhsDiagnosis == rhsDiagnosis) && lhsSpecific <= rhsSpecific)
    }
    
    func diagnosesAndSpecificDiagnoses(fromFilteredCases filteredCases: FilteredCases) -> (diagnoses: [String], specificDiagnoses: [String]) {
            var diagnosesBuilder = [String]()
            var specificDiagnosesBuilder = [String]()
            
            let byDiagnosis = self.casesByDiagnosis(fromFilteredCases: filteredCases)
            byDiagnosis.forEach { (caseByDiagnosis: LACaseByDiagnosis) in
                switch caseByDiagnosis {
                case .Diagnosis(let diagnosis):
                    diagnosesBuilder.append(diagnosis)
                case .SpecificDiagnosis(_, let specificDiagnosis, _):
                    specificDiagnosesBuilder.append(specificDiagnosis)
                }
            }
            
            return (diagnoses: diagnosesBuilder, specificDiagnoses: specificDiagnosesBuilder)
    }
}


