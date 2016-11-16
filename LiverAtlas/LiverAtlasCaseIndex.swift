//
//  LiverAtlasCaseIndex.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LiverAtlasCaseIndex {
    lazy var indexItems: [LiverAtlasIndexItem] = { self.loadLiverAtlasIndexItemsFromResourceFile() }()

    let indexFilename = "liveratlas_api_cases"
    
    func loadLiverAtlasIndexItemsFromResourceFile() -> [LiverAtlasIndexItem] {
        let jsonArray = jsonArrayForResource(filename: indexFilename)!
        return LiverAtlasJsonHelper.liverAtlasIndex(fromJson: jsonArray)!
    }
    
    func jsonArrayForResource(filename: String) -> NSArray! {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as? NSArray
    }

    
}
