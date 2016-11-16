//
//  LiverAtlasCaseCrawlerTests.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasCaseCrawlerTests: XCTestCase {

    class LiverAtlasCaseCrawlerHooked : LiverAtlasCaseCrawler {
        var onLiverAtlasIndexUpdated: (() -> ())!
        
        override func liverAtlasIndexUpdated() {
            if let onUpdate = onLiverAtlasIndexUpdated {
                onUpdate()
                return
            }
            
            super.liverAtlasIndexUpdated()
        }
    }
    
    func testFetchIndex() {
        let crawler = LiverAtlasCaseCrawlerHooked()
        let expectation = self.expectation(description: "Index Fetcher")
        crawler.onLiverAtlasIndexUpdated = {
            expectation.fulfill()
        }

        crawler.loadLiverAtlasIndex()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertNotNil(crawler.liverAtlasIndex)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
