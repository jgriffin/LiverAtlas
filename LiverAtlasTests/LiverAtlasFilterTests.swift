//
//  LiverAtlasFilterTests.swift
//  LiverAtlas
//
//  Created by John on 11/20/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasFilterTests: XCTestCase {
    let allCases = LiverAtlasIndex.instance.allCases
    let case6 = LiverAtlasIndex.instance.case6
    let filterer = LiverAtlasFilterer(allCases: nil, modality: .ct)
    
    func testFilterGroups() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: [case6], withModality: .ct)
        
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filterType, .diagnosisCategory)
        XCTAssertEqual(diagnosisGroup.filters.count, 1)
        XCTAssertEqual(diagnosisGroup.filters.first!.filterString, "Abscess (pyogenic)")
    }

    func testAllFilterGroups() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: allCases, withModality: .ct)
        
        XCTAssertEqual(filterGroups.count, 1)
        let diagnosisGroup = filterGroups[0]
        XCTAssertEqual(diagnosisGroup.filters.count, 95)
    }

    func testFilteredCases() {
        let filterGroups = filterer.filterGroups(fromAllModalityCases: allCases, withModality: .ct)
        let firstFilter = filterGroups.first!.filters.first!
        
        let filteredCases = filterer.filteredCases(fromCases: allCases, passingFilter: firstFilter)
        XCTAssertEqual(filteredCases.count, 4)
    }

}
