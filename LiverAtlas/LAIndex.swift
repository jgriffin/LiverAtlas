//
//  LAIndex.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LAIndex {
    static var instance: LAIndex = LAIndex()
    
    // raw cases
    
    lazy var indexItems: [LAIndexItem] = { self.loadLAIndexItemsFromResourceFile() }()
    lazy var allCases: [LACase] = { self.loadLAAllCasesFromResourceFile() }()
    lazy var case6: LACase = { self.loadCase6() }()
    
    // internal
    
    
    // json loading
    
    let indexJsonFilename = "liveratlas_api_cases"
    let allCasesJsonFilename = "liveratlas_api_all_cases"
    
    func loadLAIndexItemsFromResourceFile() -> [LAIndexItem] {
        let jsonArray = jsonArrayForResource(filename: indexJsonFilename)!
        return LAJsonHelper.laIndex(fromJson: jsonArray)!
    }

    func loadLAAllCasesFromResourceFile() -> [LACase] {
        let jsonArray = jsonArrayForResource(filename: allCasesJsonFilename) as! [[String: AnyObject]]
        return jsonArray.map { LAJsonHelper.laCase(fromJson: $0)! }
    }
    
    let case6Filename = "liveratlas_api_case_6"
    func loadCase6() -> LACase {
        let jsonDictionary = jsonDictionaryForResource(filename: case6Filename)!
        return LAJsonHelper.laCase(fromJson: jsonDictionary)!
    }
    
    func fakeCase() -> LACase {
        let diagnosis = LADiagnosis(diagnosis: "diagnosis",
                                            categories: [],
                                            information: "information",
                                            pk: 1,
                                            modifiedData: Date(),
                                            synonyms: [])
        
        let fakeCase = LACase(title: "title",
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
