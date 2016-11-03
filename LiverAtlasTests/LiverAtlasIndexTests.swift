//
//  LiverAtlasIndexTests.swift
//  LiverAtlas
//
//  Created by John on 11/3/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import XCTest

class LiverAtlasIndexTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIndexLoads() {
        XCTAssertFalse(LiverAtlasIndex().items.isEmpty)
   }
    
}
