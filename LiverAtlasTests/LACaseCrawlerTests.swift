//
//  LACaseCrawlerTests.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LACaseCrawlerTests: XCTestCase {
    
    func testFetchIndex() {
        let crawler = LACaseCrawler()
        
        let expectation = self.expectation(description: "Index Fetcher")

        crawler.loadLAIndex { laIndex in
            XCTAssertNotNil(laIndex)
            XCTAssertEqual(laIndex?.count ?? 0, 352)

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 200, handler: nil)
    }

    func testFetchSomeCasesFromIndexItems() {
        let someIndexItems = Array(LAIndex().loadLAIndexItemsFromResourceFile().prefix(3))
        
        let crawler = LACaseCrawler()
        let expectation = self.expectation(description: "Case Crawler working")
        
        crawler.loadAllLACases(forIndexItems: someIndexItems) { (caseItems) in
            XCTAssertNotNil(caseItems)
            XCTAssertEqual(caseItems!.count, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func slow_testMeasureFetchAllCasesFromIndexItems() {
        self.measure { 
            let allIndexItems = LAIndex().loadLAIndexItemsFromResourceFile()
            XCTAssertEqual(allIndexItems.count, 352)

            let crawler = LACaseCrawler()
            let expectation = self.expectation(description: "Case Crawler working")
            
            crawler.loadAllLACases(forIndexItems: allIndexItems) { (caseItems) in
                XCTAssertNotNil(caseItems)
                XCTAssertEqual(caseItems!.count, 352)
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 100, handler: nil)
        }
    }
    
    func slow_testFetchAllCasesFromIndexItemsToJson() {
        let crawler = LACaseCrawler()
        let expectation = self.expectation(description: "Case Crawler working")
        
        let allIndexItems = LAIndex().loadLAIndexItemsFromResourceFile()
        crawler.loadAllLACasesJson(forIndexItems: allIndexItems) { (caseItemsJson) in
            if let _ = caseItemsJson,
                let jsonData = try? JSONSerialization.data(withJSONObject: caseItemsJson!, options: .prettyPrinted) {
                
                let url = URL(fileURLWithPath: "liveratlas_api_all_cases.json", relativeTo: URL(fileURLWithPath:NSTemporaryDirectory()))
                try! jsonData.write(to: url)
                NSLog("wrote all cases to: \(url.absoluteString)")
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 100, handler: nil)
    }
}
