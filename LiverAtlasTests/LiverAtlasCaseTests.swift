
//  LiverAtlasCaseTests.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasCaseTests: XCTestCase {
    let case6Filename = "liveratlas_api_case_6"
    
    func jsonDictionaryForResource(filename: String) ->  [String: AnyObject]? {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as?  [String: AnyObject]
    }
    
    func testLoadCases6Json() {
        let jsonDictionary = jsonDictionaryForResource(filename: case6Filename)!
        XCTAssertEqual(jsonDictionary.count, 10)
    }
    
    func testLoadCase6IndexItemFromJson() {
        let jsonDictionary = jsonDictionaryForResource(filename: case6Filename)!
        let atlasCase = LiverAtlasJsonHelper.liverAtlasCase(fromJson: jsonDictionary)
        
        XCTAssertNotNil(atlasCase)
    }
    
}

