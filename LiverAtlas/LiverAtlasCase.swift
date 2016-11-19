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
