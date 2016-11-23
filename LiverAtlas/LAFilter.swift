//
//  LAFilter.swift
//  LiverAtlas
//
//  Created by John on 11/20/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


enum LAFilterType {
    case diagnosisCategory, structuralFeature, imagingFeature
}

struct LAFilter: Hashable {
    let filterType: LAFilterType
    let filterString: String
    
    var hashValue: Int {
        return (31 &* filterType.hashValue) &+ filterString.hashValue
    }
}
func ==(lhs: LAFilter, rhs: LAFilter) -> Bool {
    return lhs.filterType == rhs.filterType && lhs.filterString == rhs.filterString
}


struct LAFilterGroup {
    let filterType: LAFilterType
    let filters: [LAFilter]
}

