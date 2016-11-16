//
//  LiverAtlasScrapeTests.swift
//  LiverAtlas
//
//  Created by John on 11/5/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest
import Kanna

class LiverAtlasScrapeTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func urlSessionSynchronousGetKannaHtml(url: URL) -> HTMLDocument? {
        var responseData: Data?
        
        let expectation = self.expectation(description: "http get")

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let downloadTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            guard error == nil else {
                XCTAssert(false, "error downloading liver atlas index")
                return
            }
            expectation.fulfill()
            
            responseData = data
        })
        downloadTask.resume()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        guard let data = responseData,
            let doc = Kanna.HTML(html: data, encoding: .utf8) else {
                XCTAssert(false, "Kanna didn't load and parse url")
                return nil
        }
        return doc
    }
    
    func testLoadLiverAtlasIndex() {
        let url = URL(string: "http://liveratlas.org/index/")!
        let doc = urlSessionSynchronousGetKannaHtml(url: url)!

        let indexItems = LiverAtlasScraper.indexItemsFrom(indexHtml: doc)
        XCTAssertEqual(indexItems.count, 564)
    }
    
    func testLoadLiverCaseDetails() {
        let url = URL(string: "http://liveratlas.org/case/1")!
        let doc = urlSessionSynchronousGetKannaHtml(url: url)!
        
        let details = LiverAtlasScraper.caseDetailsFrom(caseURL: url, detailsHtml: doc)
        XCTAssertEqual(details?.caseNumberHeading, "Case 1:")
    }
    
    func testLoadLiverDiagnosisDetails() {
        let url = URL(string: "http://liveratlas.org/diagnosis/4")!
        let doc = urlSessionSynchronousGetKannaHtml(url: url)!
      
        let diagnosisDetails = LiverAtlasScraper.diagnosisDetailsFrom(detailsHtml: doc)
        XCTAssertEqual(diagnosisDetails.count, 1)
    }
    
    func testLoadAllDiagnosis() {
        let liverAtlastIndexURL = URL(string: "http://liveratlas.org/index/")!

        let indexHtml = urlSessionSynchronousGetKannaHtml(url: liverAtlastIndexURL)!
        let indexItems = LiverAtlasScraper.indexItemsFrom(indexHtml: indexHtml).filter { item in
                item.href.contains("case")
            }.prefix(3)
        
        let cases = indexItems.flatMap { (item) -> LiverAtlasCaseDetails? in
            let caseURL = URL(string:item.href, relativeTo: liverAtlastIndexURL)!
            let caseHtml = urlSessionSynchronousGetKannaHtml(url: caseURL)
            return LiverAtlasScraper.caseDetailsFrom(caseURL: caseURL, detailsHtml: caseHtml!)
        }
        XCTAssertEqual(cases.count, 3)
    }
    
    // MARK: - Fetcher tests

    func testFetcherGetIndexItemsReferencedFromIndex() {
        let expectation = self.expectation(description: "fetch liver atlas index")
        let fetcher = LiverAtlasScraperFetcher()
        fetcher.getIndexItemsReferencedFromIndex { (indexItems) in
            XCTAssertEqual(indexItems.count, 564)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFetcherGetCaseDetailsFor() {
        let url = URL(string: "http://liveratlas.org/case/1")!
        let expectation = self.expectation(description: "fetch liver atlas index")
        
        let fetcher = LiverAtlasScraperFetcher()
        fetcher.getCaseDetailsFor(caseDetailURL: url) { (caseDetail) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFetcherGetCaseDetailsForCase19() {
        let url = URL(string: "http://liveratlas.org/case/19")!
        let expectation = self.expectation(description: "fetch liver atlas index")
        
        let fetcher = LiverAtlasScraperFetcher()
        fetcher.getCaseDetailsFor(caseDetailURL: url) { (caseDetail) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFetcherGetCaseDetailsForCase160() {
        let url = URL(string: "http://liveratlas.org/case/160")!
        let expectation = self.expectation(description: "fetch liver atlas index")
        
        let fetcher = LiverAtlasScraperFetcher()
        fetcher.getCaseDetailsFor(caseDetailURL: url) { (caseDetail) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetcherCaseDetailsReferencedFromIndex() {
        self.measure() {
            let expectation = self.expectation(description: "fetch liver atlas index")
            let fetcher = LiverAtlasScraperFetcher()
            fetcher.getIndexItemsReferencedFromIndex(completion: fetcher.fetchCaseDetailsForIndexItems)
            
            fetcher.fetcherGroup.notify(queue: DispatchQueue.main) {
                XCTAssertEqual(fetcher.caseDetailResults.count, 238)
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 30, handler: nil)
        }
    }


    
}
