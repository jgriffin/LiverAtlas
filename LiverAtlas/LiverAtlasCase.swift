//
//  LiverIndexCase.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

struct LiverAtlasCase {
    let title: String
    let pk: Int
    let modifiedData: Date
    let clinicalPresentation: String
    let diagnosis: LiverAtlasDiagnosis
    let specificDiagnosis: String
    let notes: String
    let ctmodality: [LiverAtlasCTModality]
    let mrmodality: [LiverAtlasMRModality]
    let usmodality: [LiverAtlasUSModality]
    
    func imagingFeaturesForModality(modality: LiverAtlasModality) -> [LiverAtlasImagingFeature] {
        switch modality {
        case .ct:
            return ctmodality.flatMap { $0.imagingFeatures }
        case .mr:
            return mrmodality.flatMap { $0.imagingFeatures }
        case .us:
            return usmodality.flatMap { $0.imagingFeatures }
        }
    }
    
    func structuralFeaturesForModality(modality: LiverAtlasModality) -> [LiverAtlasStructuralFeature] {
        switch modality {
        case .ct:
            return ctmodality.flatMap { $0.structuralFeatures }
        case .mr:
            return mrmodality.flatMap { $0.structuralFeatures }
        case .us:
            return usmodality.flatMap { $0.structuralFeatures }
        }
    }

}

struct LiverAtlasDiagnosis {
    let diagnosis: String
    let categories: [LiverAtlasCategory]
    let information: String
    let pk: Int
    let modifiedData: Date
    let synonyms: [ LiverAtlasSynonym ]
}

struct LiverAtlasCategory {
    let id: Int
    let lft: Int
    let rgt: Int
    let treeID: Int
    let depth: Int
    let title: String
    let exclusiveChidren: Bool
    let modifiedDate: Date
}

struct LiverAtlasSynonym {
    let id: Int
    let name: String
    let modifiedDate: Date
    let diagnosis: Int
}

enum LiverAtlasModality {
    case ct, mr, us
}

struct LiverAtlasCTModality {
    let pk: Int
    let title: String
    let modifiedDate: Date
    let specificDiagnosis: String
    let imagingFindings: String
    let quizLevel: Int
    let isPublic: Bool
    let imagingFeatures: [LiverAtlasImagingFeature]
    let structuralFeatures: [LiverAtlasStructuralFeature]
    let images: [LiverAtlasImage]
}

struct LiverAtlasMRModality {
    let pk: Int
    let title: String
    let modifiedDate: Date
    let specificDiagnosis: String
    let imagingFindings: String
    let quizLevel: Int
    let isPublic: Bool
    let imagingFeatures: [LiverAtlasImagingFeature]
    let structuralFeatures: [LiverAtlasStructuralFeature]
    let images: [LiverAtlasImage]
}

struct LiverAtlasUSModality {
    let pk: Int
    let title: String
    let modifiedDate: Date
    let specificDiagnosis: String
    let imagingFindings: String
    let quizLevel: Int
    let isPublic: Bool
    let imagingFeatures: [LiverAtlasImagingFeature]
    let structuralFeatures: [LiverAtlasStructuralFeature]
    let images: [LiverAtlasImage]   
}

struct LiverAtlasImage {
    let id: Int
    let image: URL
    let imagePhase: String
    let imageCaption: String
    let order: Int
    let modifiedDate: Date
}

struct LiverAtlasImagingFeature {
    let id: Int
    let title: String
    let tree: String
}

struct LiverAtlasStructuralFeature {
    let id: Int
    let title: String
    let tree: String
}
