//
//  LAFilterTests.swift
//  LiverAtlas
//
//  Created by John on 11/20/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LAFilterTests: XCTestCase {
    let allCases = LAIndex.instance.allCases
    let filterer = LAFilterer(allCases: nil, modality: .ct, activeFilters: nil)
    
    func testFilterGroups() {
        let case6FilteredCases = FilteredCases(cases: [LAIndex.instance.case6], modality: .ct, filters: [])
        let filterGroups = filterer.filterGroups(fromFilteredCases: case6FilteredCases)
        
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filterType, .diagnosisCategory)
        XCTAssertEqual(diagnosisGroup.filters.count, 1)
        XCTAssertEqual(diagnosisGroup.filters.first!.filterString, "Infection")
    }

    func testAllFilterGroups() {
        let allCTFilteredCases = FilteredCases(cases: allCases, modality: .ct, filters: [])
        let filterGroups = filterer.filterGroups(fromFilteredCases: allCTFilteredCases)
        
        XCTAssertEqual(filterGroups.count, 3)
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filters.count, 16)
    }

    func testFilteredCases() {
        let allCTFilteredCases = FilteredCases(cases: allCases, modality: .ct, filters: [])
        let filterGroups = filterer.filterGroups(fromFilteredCases: allCTFilteredCases)
        let firstFilter = filterGroups.first!.filters.first!
        
        let filteredCases = LAFilterer.filteredCases(fromFilteredCases: allCTFilteredCases,
                                                   passingFilter: firstFilter)
        XCTAssertEqual(filteredCases.cases.count, 1)
    }

    func casesByDiagnosis() {
        let byDiagnosis = filterer.modalityFilteredCasesByDiagnoses
        
        XCTAssertEqual(byDiagnosis.count, 352)
    }
    

}
