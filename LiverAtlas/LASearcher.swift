//
//  LASearcher.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

struct SearchResultCases {
    let fromFilteredCases: FilteredCases
    let searchString: String
    let cases: [LACase]
}

class LASearcher {

    func searchCases(fromFilteredCases: FilteredCases, forSearchText searchText: String) -> [LACase] {
        return searchCases(casesToSearch: fromFilteredCases.cases, forSearchText: searchText)
    }
    
    func searchCases(casesToSearch: [LACase], forSearchText searchText: String) -> [LACase] {
        if searchText.isEmpty {
            return casesToSearch
        }
        
        let casesWithScores = casesToSearch.map { ($0, searchScore(forLACase: $0, searchText: searchText)) }

        let results = casesWithScores.filter { (aCase, score) in return score != 0 }
        
        
        return results.map { (aCase, score) in aCase }
    }
    
    func searchScore(forLACase laCase: LACase, searchText: String) -> Int {
        var score = 0

        if laCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(searchText) {
            score += 10
        }
        if laCase.specificDiagnosis.localizedCaseInsensitiveContains(searchText) {
            score += 5
        }
        if laCase.clinicalPresentation.localizedCaseInsensitiveContains(searchText) {
            score += 3
        }
        if laCase.notes.localizedCaseInsensitiveContains(searchText) {
            score += 1
        }
        
        return score
    }
    
}
