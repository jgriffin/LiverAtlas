//
//  LiverAtlasFilter.swift
//  LiverAtlas
//
//  Created by John on 11/20/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


enum LiverAtlasFilterType {
    case diagnosisCategory, structuralFeature, imagingFeature
}

struct LiverAtlasFilter: Hashable {
    let filterType: LiverAtlasFilterType
    let filterString: String
    
    var hashValue: Int {
        return (31 &* filterType.hashValue) &+ filterString.hashValue
    }
}
func ==(lhs: LiverAtlasFilter, rhs: LiverAtlasFilter) -> Bool {
    return lhs.filterType == rhs.filterType && lhs.filterString == rhs.filterString
}


struct LiverAtlasFilterGroup {
    let filterType: LiverAtlasFilterType
    let filters: [LiverAtlasFilter]
}

