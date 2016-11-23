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
    let case6 = LAIndex.instance.case6
    let filterer = LAFilterer(allCases: nil, modality: .ct)
    
    func testFilterGroups() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: [case6], withModality: .ct)
        
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filterType, .diagnosisCategory)
        XCTAssertEqual(diagnosisGroup.filters.count, 1)
        XCTAssertEqual(diagnosisGroup.filters.first!.filterString, "Infection")
    }

    func testAllFilterGroups() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: allCases, withModality: .ct)
        
        XCTAssertEqual(filterGroups.count, 3)
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filters.count, 16)
    }

    func testFilteredCases() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: allCases, withModality: .ct)
        let firstFilter = filterGroups.first!.filters.first!
        
        let filteredCases = filterer.filteredCases(fromCases: allCases, passingFilter: firstFilter)
        XCTAssertEqual(filteredCases.count, 1)
    }

    func casesByDiagnosis() {
        let byDiagnosis = filterer.modalityFilteredCasesByDiagnoses
        
        XCTAssertEqual(byDiagnosis.count, 352)
    }
    

}
