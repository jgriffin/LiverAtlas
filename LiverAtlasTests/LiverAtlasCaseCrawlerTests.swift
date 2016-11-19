//
//  LiverAtlasCaseCrawlerTests.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasCaseCrawlerTests: XCTestCase {
    
    func testFetchIndex() {
        let crawler = LiverAtlasCaseCrawler()
        
        let expectation = self.expectation(description: "Index Fetcher")

        crawler.loadLiverAtlasIndex { liverAtlasIndex in
            XCTAssertNotNil(liverAtlasIndex)
            XCTAssertEqual(liverAtlasIndex?.count ?? 0, 352)

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 200, handler: nil)
    }

    func testFetchSomeCasesFromIndexItems() {
        let someIndexItems = Array(LiverAtlasIndex().loadLiverAtlasIndexItemsFromResourceFile().prefix(3))
        
        let crawler = LiverAtlasCaseCrawler()
        let expectation = self.expectation(description: "Case Crawler working")
        
        crawler.loadAllLiverAtlasCases(forIndexItems: someIndexItems) { (caseItems) in
            XCTAssertNotNil(caseItems)
            XCTAssertEqual(caseItems!.count, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func slow_testMeasureFetchAllCasesFromIndexItems() {
        self.measure { 
            let allIndexItems = LiverAtlasIndex().loadLiverAtlasIndexItemsFromResourceFile()
            XCTAssertEqual(allIndexItems.count, 352)

            let crawler = LiverAtlasCaseCrawler()
            let expectation = self.expectation(description: "Case Crawler working")
            
            crawler.loadAllLiverAtlasCases(forIndexItems: allIndexItems) { (caseItems) in
                XCTAssertNotNil(caseItems)
                XCTAssertEqual(caseItems!.count, 352)
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 100, handler: nil)
        }
    }
    
    func slow_testFetchAllCasesFromIndexItemsToJson() {
        let crawler = LiverAtlasCaseCrawler()
        let expectation = self.expectation(description: "Case Crawler working")
        
        let allIndexItems = LiverAtlasIndex().loadLiverAtlasIndexItemsFromResourceFile()
        crawler.loadAllLiverAtlasCasesJson(forIndexItems: allIndexItems) { (caseItemsJson) in
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
