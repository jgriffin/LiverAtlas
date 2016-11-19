//
//  LiverAtlasIndex.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LiverAtlasIndex {
    static var instance: LiverAtlasIndex = LiverAtlasIndex()
    
    lazy var indexItems: [LiverAtlasIndexItem] = { self.loadLiverAtlasIndexItemsFromResourceFile() }()
    lazy var allCases: [LiverAtlasCase] = { self.loadLiverAtlasAllCasesFromResourceFile() }()

    lazy var case6: LiverAtlasCase = { self.loadCase6() }()
    
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
    
    let case6Filename = "liveratlas_api_case_6"
    func loadCase6() -> LiverAtlasCase {
        let jsonDictionary = jsonDictionaryForResource(filename: case6Filename)!
        return LiverAtlasJsonHelper.liverAtlasCase(fromJson: jsonDictionary)!
    }
    
    func fakeCase() -> LiverAtlasCase {
        let diagnosis = LiverAtlasDiagnosis(diagnosis: "diagnosis",
                                            categories: [],
                                            information: "information",
                                            pk: 1,
                                            modifiedData: Date(),
                                            synonyms: [])
        
        let fakeCase = LiverAtlasCase(title: "title",
                                      pk: 1,
                                      modifiedData: Date(),
                                      clinicalPresentation: "clinical presentation",
                                      diagnosis: diagnosis,
                                      specificDiagnosis: "specific diagnosis",
                                      notes: "notes",
                                      ctmodality: [],
                                      mrmodality: [],
                                      usmodality: [])
        return fakeCase
    }


    // helpers
    
    func jsonArrayForResource(filename: String) -> NSArray! {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as? NSArray
    }

    func jsonDictionaryForResource(filename: String) ->  [String: AnyObject]? {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as?  [String: AnyObject]
    }
    

    
}
