//
//  LAFilterer.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


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
    
    var modalityFilteredCases: [LACase] {
        if _modalityFilteredCases == nil {
            _modalityFilteredCases = filterCases(fromCases: allCases,
                                                 withModality: activeModality)
        }
        return _modalityFilteredCases!
    }
    var _modalityFilteredCases: [LACase]?
    
    var modalityFilterGroups: [LAFilterGroup] {
        if _modalityFilterGroups == nil {
            _modalityFilterGroups = filterGroups(fromAllModalityCases: modalityFilteredCases,
                                                 withModality: activeModality)
        }
        return _modalityFilterGroups!
    }
    var _modalityFilterGroups:[LAFilterGroup]?
    
    var modalityFilteredCasesByDiagnoses: [LACaseByDiagnosis] {
        if _modalityByDiagnoses == nil {
            _modalityByDiagnoses = casesByDiagnosis(fromCases: modalityFilteredCases)
        }
        
        return _modalityByDiagnoses!
    }
    var _modalityByDiagnoses: [LACaseByDiagnosis]?
    
    // filters
    
    var activeFilters =  Set<LAFilter>()
    var activeSearchTerm: String?
    
    func filterCases(fromCases theCases: [LACase],
                     withModality modality: LAModality) -> [LACase] {
        return theCases.filter { (aCase: LACase) -> Bool in
            switch modality {
            case .ct:
                return !aCase.ctmodality.isEmpty
            case .mr:
                return !aCase.mrmodality.isEmpty
            case .us:
                return !aCase.usmodality.isEmpty
            }
        }
    }
    
    // extract the filter groups from cases
    
    func filterGroups(fromAllModalityCases theCases: [LACase],
                      withModality modality: LAModality) -> [LAFilterGroup] {
        let diagnosisFiltersGroup: LAFilterGroup = {
            let theDiagnoses = theCases.flatMap { $0.diagnosis.categories.map({ $0.title}) }
            let uniqueDiagnoses = Set(theDiagnoses).sorted()
            let diagnosesFilters = uniqueDiagnoses.map {
                LAFilter(filterType: .diagnosisCategory, filterString: $0)
            }
            
            return LAFilterGroup(filterType: .diagnosisCategory,
                                         filters: diagnosesFilters)
        }()
        
        let structuralFiltersGroup: LAFilterGroup = {
            let theStructuralFeatureNames = theCases.flatMap { (aCase: LACase) -> [String] in
                aCase.structuralFeaturesForModality(modality: modality).map { $0.title }
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
            let theImagingFeatureNames = theCases.flatMap { (aCase: LACase) -> [String] in
                aCase.imagingFeaturesForModality(modality: modality).map { $0.title }
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
    
    func casesByDiagnosis(fromCases theCases: [LACase]) -> [LACaseByDiagnosis] {
        
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
    
    func filteredCases(fromCases theCases: [LACase],
                       passingFilter filter: LAFilter) -> [LACase] {
        switch filter.filterType {
        case .diagnosisCategory:
            return filteredCases(fromCases: theCases, withDiagnosisContaining: filter.filterString)
        case .structuralFeature:
            return filteredCases(fromCases: theCases, withStructuralFeatureContaining: filter.filterString)
        case .imagingFeature:
            return filteredCases(fromCases: theCases, withImagingFeatureContaining: filter.filterString)
        }
    }
    
    func filteredCases(fromCases theCases: [LACase],
                       passingFilters filters: [LAFilter]) -> [LACase] {
        var filteredCases: [LACase] = theCases
        
        for filter in filters {
            filteredCases = self.filteredCases(fromCases: filteredCases,
                                               passingFilter: filter)
            if filteredCases.isEmpty {
                // no results - we're done already
                return []
            }
        }
        
        return filteredCases
    }
    
    
    
    // filter helpers
    
    
    func filteredCases(fromCases theCases: [LACase],
                       withDiagnosisContaining filterString: String) -> [LACase] {
        return theCases.filter { theCase in
            theCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(filterString)
        }
    }
    
    func filteredCases(fromCases theCases: [LACase],
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
    
    func filteredCases(fromCases theCases: [LACase],
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
