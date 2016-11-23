//
//  LASearcherTests.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LASearcherTests: XCTestCase {
    let allCases = LAIndex.instance.allCases
    let justCase6 = [LAIndex.instance.case6]
    let searcher = LASearcher()
    
    func testSearchingEmptyString_returnsAllCases() {
        let results = searcher.searchCases(casesToSearch: allCases, forSearchText: "")
        XCTAssertEqual(results.count, allCases.count)
    }
    
    func testSearchingDiagnosis() {
        let results = searcher.searchCases(casesToSearch: justCase6, forSearchText: "Abscess")
        XCTAssertEqual(results.count, 1)
    }

    func testSearchingDiagnosisCaseIndependent() {
        let results = searcher.searchCases(casesToSearch: justCase6, forSearchText: "abscess")
        XCTAssertEqual(results.count, 1)
    }
    
    func testSearchingSpecificDiagnosis() {
        let results = searcher.searchCases(casesToSearch: justCase6, forSearchText: "unilocular")
        XCTAssertEqual(results.count, 1)
    }

    func testSearchingClinialPresentation() {
        let results = searcher.searchCases(casesToSearch: justCase6, forSearchText: "gammopathy")
        XCTAssertEqual(results.count, 1)
    }
    
    func testSearchingNotes() {
        let results = searcher.searchCases(casesToSearch: justCase6, forSearchText: "1112-Liver")
        XCTAssertEqual(results.count, 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
