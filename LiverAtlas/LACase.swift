//
//  LiverIndexCase.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

struct LACase {
    let title: String
    let pk: Int
    let modifiedData: Date
    let clinicalPresentation: String
    let diagnosis: LADiagnosis
    let specificDiagnosis: String
    let notes: String
    let ctmodality: [LACTModality]
    let mrmodality: [LAMRModality]
    let usmodality: [LAUSModality]
}

extension LACase {

    func modalityImages(forModality modality: LAModality) -> LAModalityImages {
        switch modality {
        case .ct:
            return ctmodality.first!
        case .mr:
            return mrmodality.first!
        case .us:
            return usmodality.first!
        }
    }
    
    
    func imagesForModality(modality: LAModality) -> [LAImage] {
        return modalityImages(forModality: modality).images
    }
    
    func imagingFeaturesForModality(modality: LAModality) -> [LAImagingFeature] {
        switch modality {
        case .ct:
            return ctmodality.flatMap { $0.imagingFeatures }
        case .mr:
            return mrmodality.flatMap { $0.imagingFeatures }
        case .us:
            return usmodality.flatMap { $0.imagingFeatures }
        }
    }
    
    func structuralFeaturesForModality(modality: LAModality) -> [LAStructuralFeature] {
        return modalityImages(forModality: modality).structuralFeatures
    }

}

struct LADiagnosis {
    let diagnosis: String
    let categories: [LACategory]
    let information: String
    let pk: Int
    let modifiedData: Date
    let synonyms: [ LASynonym ]
}

struct LACategory {
    let id: Int
    let lft: Int
    let rgt: Int
    let treeID: Int
    let depth: Int
    let title: String
    let exclusiveChidren: Bool
    let modifiedDate: Date
}

struct LASynonym {
    let id: Int
    let name: String
    let modifiedDate: Date
    let diagnosis: Int
}

enum LAModality {
    case ct, mr, us
}

struct LAModalityImages {
    let pk: Int
    let title: String
    let modifiedDate: Date
    let specificDiagnosis: String
    let imagingFindings: String
    let quizLevel: Int
    let isPublic: Bool
    let imagingFeatures: [LAImagingFeature]
    let structuralFeatures: [LAStructuralFeature]
    let images: [LAImage]
}

import UIKit
extension LAModalityImages {

    var attributedImagingFindings: NSAttributedString? {
        guard let htmlData = imagingFindings.data(using: String.Encoding.unicode),
            let attrString = try? NSAttributedString(data: htmlData,
                                                     options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                     documentAttributes: nil) else {
            return nil
        }
        return attrString
    }
}



typealias LACTModality = LAModalityImages
typealias LAMRModality = LAModalityImages
typealias LAUSModality = LAModalityImages

struct LAImage {
    let id: Int
    let imageURL: URL
    let imagePhase: String
    let imageCaption: String
    let order: Int
    let modifiedDate: Date
}

struct LAImagingFeature {
    let id: Int
    let title: String
    let tree: String
}

struct LAStructuralFeature {
    let id: Int
    let title: String
    let tree: String
}
