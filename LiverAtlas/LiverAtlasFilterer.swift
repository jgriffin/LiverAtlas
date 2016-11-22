//
//  LiverAtlasFilterer.swift
//  LiverAtlas
//
//  Created by John on 11/22/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LiverAtlasFilterer {
    
    init(allCases: [LiverAtlasCase]?, modality: LiverAtlasModality) {
        self.allCases = allCases ?? LiverAtlasIndex.instance.allCases
        self.activeModality = modality
    }
    
    let allCases: [LiverAtlasCase]

    // modality
    
    var activeModality: LiverAtlasModality!  {
        didSet {
            _modalityFilteredCases = nil
            _modalityFilterGroups = nil
        }
    }
    
    var modalityFilteredCases: [LiverAtlasCase] {
        if _modalityFilteredCases == nil {
            _modalityFilteredCases = filterCases(fromCases: allCases,
                                                 withModality: activeModality)
        }
        return _modalityFilteredCases!
    }
    var _modalityFilteredCases: [LiverAtlasCase]?
    
    var modalityFilterGroups: [LiverAtlasFilterGroup] {
        if _modalityFilterGroups == nil {
            _modalityFilterGroups = filterGroups(fromAllModalityCases: modalityFilteredCases,
                                                 withModality: activeModality)
        }
        return _modalityFilterGroups!
    }
    var _modalityFilterGroups:[LiverAtlasFilterGroup]?
    
    // filters
    
    
    var activeFilters =  Set<LiverAtlasFilter>()
    var activeSearchTerm: String?
    

    
    func filterCases(fromCases theCases: [LiverAtlasCase],
                     withModality modality: LiverAtlasModality) -> [LiverAtlasCase] {
        return theCases.filter { (aCase: LiverAtlasCase) -> Bool in
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
    
    func filterGroups(fromAllModalityCases theCases: [LiverAtlasCase],
                      withModality modality: LiverAtlasModality) -> [LiverAtlasFilterGroup] {
        let diagnosisFiltersGroup: LiverAtlasFilterGroup = {
            let theDiagnoses = theCases.flatMap { $0.diagnosis.categories.map({ $0.title}) }
            let uniqueDiagnoses = Set(theDiagnoses).sorted()
            let diagnosesFilters = uniqueDiagnoses.map {
                LiverAtlasFilter(filterType: .diagnosisCategory, filterString: $0)
            }
            
            return LiverAtlasFilterGroup(filterType: .diagnosisCategory,
                                         filters: diagnosesFilters)
        }()
        
        let structuralFiltersGroup: LiverAtlasFilterGroup = {
            let theStructuralFeatureNames = theCases.flatMap { (aCase: LiverAtlasCase) -> [String] in
                aCase.structuralFeaturesForModality(modality: modality).map { $0.title }
            }
            let uniqueStructuralFeatures = Set(theStructuralFeatureNames).sorted()
            let structuralFilters = uniqueStructuralFeatures.map { (featureName) -> LiverAtlasFilter in
                LiverAtlasFilter(filterType: .structuralFeature, filterString: featureName)
            }
            return LiverAtlasFilterGroup(filterType: .structuralFeature,
                                         filters: structuralFilters)
        }()
        
        let imagingFiltersGroup: LiverAtlasFilterGroup = {
            // imagine features group
            let theImagingFeatureNames = theCases.flatMap { (aCase: LiverAtlasCase) -> [String] in
                aCase.imagingFeaturesForModality(modality: modality).map { $0.title }
            }
            let uniqueImagingFeatures = Set(theImagingFeatureNames).sorted()
            let imagingFilters = uniqueImagingFeatures.map { (featureName) -> LiverAtlasFilter in
                LiverAtlasFilter(filterType: .imagingFeature, filterString: featureName)
            }
            return LiverAtlasFilterGroup(filterType: .imagingFeature, filters: imagingFilters)
        }()
        
        return [diagnosisFiltersGroup, structuralFiltersGroup, imagingFiltersGroup]
    }
    
    // filter a list of cases
    
    func filteredCases(fromCases theCases: [LiverAtlasCase],
                       passingFilter filter: LiverAtlasFilter) -> [LiverAtlasCase] {
        switch filter.filterType {
        case .diagnosisCategory:
            return filteredCases(fromCases: theCases, withDiagnosisContaining: filter.filterString)
        case .structuralFeature:
            return filteredCases(fromCases: theCases, withStructuralFeatureContaining: filter.filterString)
        case .imagingFeature:
            return filteredCases(fromCases: theCases, withImagingFeatureContaining: filter.filterString)
        }
    }
    
    func filteredCases(fromCases theCases: [LiverAtlasCase],
                       passingFilters filters: [LiverAtlasFilter]) -> [LiverAtlasCase] {
        var filteredCases: [LiverAtlasCase] = theCases
        
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
    
    
    func filteredCases(fromCases theCases: [LiverAtlasCase],
                       withDiagnosisContaining filterString: String) -> [LiverAtlasCase] {
        return theCases.filter { theCase in
            theCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(filterString)
        }
    }
    
    func filteredCases(fromCases theCases: [LiverAtlasCase],
                       withStructuralFeatureContaining filterString: String) -> [LiverAtlasCase] {
        
        let structuralFeatureContainsFilterString = {
            (structuralFeature: LiverAtlasStructuralFeature) -> Bool in
            return structuralFeature.title.localizedCaseInsensitiveContains(filterString)
        }
        
        let ctmodalityContainsFeature = {
            (ctmodality: LiverAtlasCTModality) -> Bool in
            return ctmodality.structuralFeatures.first(where: structuralFeatureContainsFilterString) != nil
        }
        
        return theCases.filter { theCase -> Bool in
            theCase.ctmodality.first(where: ctmodalityContainsFeature) != nil
        }
    }
    
    func filteredCases(fromCases theCases: [LiverAtlasCase],
                       withImagingFeatureContaining filterString: String) -> [LiverAtlasCase] {
        
        let imagingFeatureContainsFilterString = {
            (imagingFeature: LiverAtlasStructuralFeature) -> Bool in
            return imagingFeature.title.localizedCaseInsensitiveContains(filterString)
        }
        
        let ctmodalityContainsFeature = {
            (ctmodality: LiverAtlasCTModality) -> Bool in
            return ctmodality.structuralFeatures.first(where: imagingFeatureContainsFilterString) != nil
        }
        
        return theCases.filter { theCase -> Bool in
            theCase.ctmodality.first(where: ctmodalityContainsFeature) != nil
        }
    }
}
