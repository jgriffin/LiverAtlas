//
//  LiverAtlasCasesTests.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasIndexItemTests: XCTestCase {
    let casesFilename = "liveratlas_api_cases"
    
    func jsonArrayForResource(filename: String) -> NSArray! {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as? NSArray
    }
        
    func testLoadCasesJson() {
        let jsonArray = jsonArrayForResource(filename: casesFilename)!
        XCTAssertEqual(jsonArray.count, 352)
    }

    func testLoadCaseIndexItemFromJson() {
        let firstJsonItem = jsonArrayForResource(filename: casesFilename)!.firstObject! as! [String: AnyObject]
        let caseIndexItem = LiverAtlasJsonHelper.liverAtlasIndexItem(fromJson: firstJsonItem)
        XCTAssertNotNil(caseIndexItem)
    }

    func testLoadAllCaseIndexItemsFromJson() {
        let jsonArray = jsonArrayForResource(filename: casesFilename)!
        XCTAssertEqual(jsonArray.count, 352)

        let cases = LiverAtlasJsonHelper.liverAtlasIndex(fromJson: jsonArray)
        XCTAssertEqual(cases?.count, 352)
    }

    func testLiverAtlasCaseIndex() {
        let index = LiverAtlasCaseIndex()
        
        XCTAssertEqual(index.indexItems.count, 352)
    }

    
    


    
}
