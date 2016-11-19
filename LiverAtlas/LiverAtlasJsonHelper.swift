//
//  LiverAtlasJsonHelper.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


struct LiverAtlasJsonHelper {
    static func liverAtlasIndex(fromJson json: Any) -> [LiverAtlasIndexItem]? {
        guard let jsonArray = json as? [[String:AnyObject]] else {
            return nil
        }
        
        return jsonArray.flatMap { liverAtlasIndexItem(fromJson: $0)! }
    }
    
    static func liverAtlasIndexItem(fromJson json: [String: AnyObject]) -> LiverAtlasIndexItem? {
        guard
            let title = json["title"] as? String,
            let pk = json["pk"] as? Int,
            let date = modifiedDateFromJson(jsonDictionary: json),
            let urlString = json["url"] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
    
        return LiverAtlasIndexItem(title: title, pk: pk, modifiedDate: date, url: url)
    }

    static func liverAtlasCase(fromJson json: [String: AnyObject]) -> LiverAtlasCase? {
        guard
            let title = json["title"] as? String,
            let pk = json["pk"] as? Int,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let clinicalPresentation = json["clinical_presentation"] as? String,
            let diagnosisJsonDictionary = json["diagnosis"] as? [String: AnyObject],
            let diagnosis = liverAtlasDiagnosis(fromJson: diagnosisJsonDictionary),
            let specificDiagnosis = json["specific_diagnosis"] as? String,
            let notes = json["notes"] as? String,
            let ctModalitiesJson = json["ctmodality"] as? [[String: AnyObject]],
            let mrModalitiesJson = json["mrmodality"] as? [[String: AnyObject]],
            let usModalitiesJson = json["ctmodality"] as? [[String: AnyObject]] else {
                return nil
        }

        let ctModalities = ctModalitiesJson.flatMap { liverAtlasCTModality(fromJson: $0) }
        let mrModalities = mrModalitiesJson.flatMap { liverAtlasMRModality(fromJson: $0) }
        let usModalities = usModalitiesJson.flatMap { liverAtlasUSModality(fromJson: $0) }
        
        return LiverAtlasCase(title: title,
                              pk: pk,
                              modifiedData: modifiedDate,
                              clinicalPresentation: clinicalPresentation,
                              diagnosis: diagnosis,
                              specificDiagnosis: specificDiagnosis,
                              notes: notes,
                              ctmodality: ctModalities,
                              mrmodality: mrModalities,
                              usmodality: usModalities)
    }

    static func liverAtlasDiagnosis(fromJson json: [String: AnyObject]) -> LiverAtlasDiagnosis? {
        guard
            let diagnosis = json["diagnosis"] as? String,
            let categoriesJsonArray = json["categories"] as? [[String:AnyObject]],
            let information = json["information"] as? String,
            let pk = json["pk"] as? Int,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let synonymsJsonArray = json["synonyms"] as? [[String: AnyObject]] else {
                return nil
        }
        
        let categories = categoriesJsonArray.map { liverAtlasCategory(fromJson: $0)! }
        let synonyms = synonymsJsonArray.map { liverAtlasSynonym(fromJson: $0)! }
        
        return LiverAtlasDiagnosis(diagnosis: diagnosis,
                                   categories: categories,
                                   information: information,
                                   pk: pk,
                                   modifiedData: modifiedDate,
                                   synonyms: synonyms)
    }

    static func liverAtlasCategory(fromJson json: [String: AnyObject]) -> LiverAtlasCategory? {
        guard
            let id = json["id"] as? Int,
            let lft = json["lft"] as? Int,
            let rgt = json["lft"] as? Int,
            let treeID = json["lft"] as? Int,
            let depth = json["lft"] as? Int,
            let title = json["title"] as? String,
            let exclusiveChidren = json["exclusive_children"] as? Bool,
            let modifiedDate = dateFromString(dateString: json["modified_date"] as? String) else {
                return nil
        }
        
        return LiverAtlasCategory(id: id,
                                  lft: lft,
                                  rgt: rgt,
                                  treeID: treeID,
                                  depth: depth,
                                  title: title,
                                  exclusiveChidren: exclusiveChidren,
                                  modifiedDate: modifiedDate)
    }

    static func liverAtlasSynonym(fromJson json: [String: AnyObject]) -> LiverAtlasSynonym? {
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let modifiedDate = dateFromString(dateString: json["modified_date"] as? String),
            let diagnosis = json["diagnosis"] as? Int else {
                return nil
        }
        
        return LiverAtlasSynonym(id: id,
                                 name: name,
                                 modifiedDate: modifiedDate,
                                 diagnosis: diagnosis)
    }
    
    static func liverAtlasCTModality(fromJson json: [String: AnyObject]) -> LiverAtlasCTModality? {
        guard
            let pk = json["pk"] as? Int,
            let title = json["title"] as? String,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let specificDiagnosis = json["specific_diagnosis"] as? String,
            let imagingFindings = json["imaging_findings"] as? String,
            let quizLevel = json["quiz_level"] as? Int,
            let isPublic = json["public"] as? Bool,
            let imagingFeaturesJsonArray = json["imaging_features"] as? [[String: AnyObject]],
            let structuralFeaturesJsonArray = json["structural_features"] as? [[String: AnyObject]],
            let imagesJsonArray = json["images"] as? [[String: AnyObject]]  else {
                return nil
        }
        
        let imagingFeatures = imagingFeaturesJsonArray.map { liverAtlasImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { liverAtlasStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { liverAtlasImage(fromJson: $0)! }
        
        return LiverAtlasCTModality(pk: pk,
                                    title: title,
                                    modifiedDate: modifiedDate,
                                    specificDiagnosis: specificDiagnosis,
                                    imagingFindings: imagingFindings,
                                    quizLevel: quizLevel,
                                    isPublic: isPublic,
                                    imagingFeatures: imagingFeatures,
                                    structuralFeatures: structuralFeatures,
                                    images: images)
    }

    static func liverAtlasMRModality(fromJson json: [String: AnyObject]) -> LiverAtlasMRModality? {
        guard
            let pk = json["pk"] as? Int,
            let title = json["title"] as? String,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let specificDiagnosis = json["specific_diagnosis"] as? String,
            let imagingFindings = json["imaging_findings"] as? String,
            let quizLevel = json["quiz_level"] as? Int,
            let isPublic = json["public"] as? Bool,
            let imagingFeaturesJsonArray = json["imaging_features"] as? [[String: AnyObject]],
            let structuralFeaturesJsonArray = json["structural_features"] as? [[String: AnyObject]],
            let imagesJsonArray = json["images"] as? [[String: AnyObject]]  else {
                return nil
        }
        
        let imagingFeatures = imagingFeaturesJsonArray.map { liverAtlasImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { liverAtlasStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { liverAtlasImage(fromJson: $0)! }
        
        return LiverAtlasMRModality(pk: pk,
                                    title: title,
                                    modifiedDate: modifiedDate,
                                    specificDiagnosis: specificDiagnosis,
                                    imagingFindings: imagingFindings,
                                    quizLevel: quizLevel,
                                    isPublic: isPublic,
                                    imagingFeatures: imagingFeatures,
                                    structuralFeatures: structuralFeatures,
                                    images: images)
    }
    
    static func liverAtlasUSModality(fromJson json: [String: AnyObject]) -> LiverAtlasUSModality? {
        guard
            let pk = json["pk"] as? Int,
            let title = json["title"] as? String,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let specificDiagnosis = json["specific_diagnosis"] as? String,
            let imagingFindings = json["imaging_findings"] as? String,
            let quizLevel = json["quiz_level"] as? Int,
            let isPublic = json["public"] as? Bool,
            let imagingFeaturesJsonArray = json["imaging_features"] as? [[String: AnyObject]],
            let structuralFeaturesJsonArray = json["structural_features"] as? [[String: AnyObject]],
            let imagesJsonArray = json["images"] as? [[String: AnyObject]]  else {
                return nil
        }
        
        let imagingFeatures = imagingFeaturesJsonArray.map { liverAtlasImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { liverAtlasStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { liverAtlasImage(fromJson: $0)! }
        
        return LiverAtlasUSModality(pk: pk,
                                    title: title,
                                    modifiedDate: modifiedDate,
                                    specificDiagnosis: specificDiagnosis,
                                    imagingFindings: imagingFindings,
                                    quizLevel: quizLevel,
                                    isPublic: isPublic,
                                    imagingFeatures: imagingFeatures,
                                    structuralFeatures: structuralFeatures,
                                    images: images)
    }

    static func liverAtlasImagingFeature(fromJson json: [String: AnyObject]) -> LiverAtlasImagingFeature! {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let tree = json["tree"] as? String else {
                return nil
        }

        return LiverAtlasImagingFeature(id: id, title: title, tree: tree)
    }
    
    static func liverAtlasStructuralFeature(fromJson json: [String: AnyObject]) -> LiverAtlasStructuralFeature! {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let tree = json["tree"] as? String else {
                return nil
        }
        
        return LiverAtlasStructuralFeature(id: id, title: title, tree: tree)
    }
    
    static func liverAtlasImage(fromJson json: [String: AnyObject]) -> LiverAtlasImage! {
        guard
            let id = json["id"] as? Int,
            let imageURLString = json["image"] as? String,
            let imageURL = URL(string: imageURLString),
            let imagePhase = json["image_phase"] as? String,
            let imageCaption = json["image_caption"] as? String,
            let order = json["order"] as? Int,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json) else {
                return nil
        }
        
        return LiverAtlasImage(id: id,
                               image: imageURL,
                               imagePhase: imagePhase,
                               imageCaption: imageCaption,
                               order: order,
                               modifiedDate: modifiedDate)
    }

    //
    // helper methods
    //
    
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
    
    static func dateFromString(dateString: String?) -> Date? {
        guard let _ = dateString else {
            return nil
        }
        return LiverAtlasJsonHelper.dateFormatter.date(from: dateString!) ??
            LiverAtlasJsonHelper.dateFormatterWithFractionalSeconds.date(from: dateString!)
    }
    
    static func modifiedDateFromJson(jsonDictionary: [String: AnyObject]) -> Date? {
        return dateFromString(dateString: jsonDictionary["modified_date"] as? String)
    }
    


}
