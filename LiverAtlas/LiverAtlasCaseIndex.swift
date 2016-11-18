//
//  LiverAtlasCaseIndex.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LiverAtlasCaseIndex {
    static var instance: LiverAtlasCaseIndex = LiverAtlasCaseIndex()
    
    lazy var indexItems: [LiverAtlasIndexItem] = { self.loadLiverAtlasIndexItemsFromResourceFile() }()
    lazy var allCases: [LiverAtlasCase] = { self.loadLiverAtlasAllCasesFromResourceFile() }()

    // internal
    
    let indexJsonFilename = "liveratlas_api_cases"
    let allCasesJsonFilename = "liveratlas_api_all_cases"
    
    func loadLiverAtlasIndexItemsFromResourceFile() -> [LiverAtlasIndexItem] {
        let jsonArray = jsonArrayForResource(filename: indexJsonFilename)!
        return LiverAtlasJsonHelper.liverAtlasIndex(fromJson: jsonArray)!
    }

    func loadLiverAtlasAllCasesFromResourceFile() -> [LiverAtlasCase] {
        let jsonArray = jsonArrayForResource(filename: allCasesJsonFilename) as! [[String: AnyObject]]
        return jsonArray.map { LiverAtlasJsonHelper.liverAtlasCase(fromJson: $0)! }
    }

    // helper
    
    func jsonArrayForResource(filename: String) -> NSArray! {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as? NSArray
    }

    
}
