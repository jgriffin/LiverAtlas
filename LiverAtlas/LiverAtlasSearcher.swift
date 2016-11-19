//
//  LiverAtlasSearcher.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

class LiverAtlasSearcher {
    
    func searchCases(casesToSearch: [LiverAtlasCase], forSearchText searchText: String) -> [LiverAtlasCase] {
        if searchText.isEmpty {
            return casesToSearch
        }
        
        let casesWithScores = casesToSearch.map { ($0, searchScore(forLiverAtlasCase: $0, searchText: searchText)) }

        let results = casesWithScores.filter { (aCase, score) in return score != 0 }
        
        
        return results.map { (aCase, score) in aCase }
    }
    
    func searchScore(forLiverAtlasCase liverAtlasCase: LiverAtlasCase, searchText: String) -> Int {
        var score = 0

        if liverAtlasCase.diagnosis.diagnosis.localizedCaseInsensitiveContains(searchText) {
            score += 10
        }
        if liverAtlasCase.specificDiagnosis.localizedCaseInsensitiveContains(searchText) {
            score += 5
        }
        if liverAtlasCase.clinicalPresentation.localizedCaseInsensitiveContains(searchText) {
            score += 3
        }
        if liverAtlasCase.notes.localizedCaseInsensitiveContains(searchText) {
            score += 1
        }
        
        return score
    }
    
}
