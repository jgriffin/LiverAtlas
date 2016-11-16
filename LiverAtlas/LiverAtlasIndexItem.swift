//
//  LiverIndexCaseIndexItem.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


struct LiverAtlasIndexItem {
    let title: String
    let pk: Int
    let modifiedDate: Date
    let url: URL
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    static var dateFormatterWithFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        return formatter
    }()    
}
