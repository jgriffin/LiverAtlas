//
//  LAJsonHelper.swift
//  LiverAtlas
//
//  Created by John on 11/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


struct LAJsonHelper {
    static func laIndex(fromJson json: Any) -> [LAIndexItem]? {
        guard let jsonArray = json as? [[String:AnyObject]] else {
            return nil
        }
        
        return jsonArray.flatMap { laIndexItem(fromJson: $0)! }
    }
    
    static func laIndexItem(fromJson json: [String: AnyObject]) -> LAIndexItem? {
        guard
            let title = json["title"] as? String,
            let pk = json["pk"] as? Int,
            let date = modifiedDateFromJson(jsonDictionary: json),
            let urlString = json["url"] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
    
        return LAIndexItem(title: title, pk: pk, modifiedDate: date, url: url)
    }

    static func laCase(fromJson json: [String: AnyObject]) -> LACase? {
        guard
            let title = json["title"] as? String,
            let pk = json["pk"] as? Int,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let clinicalPresentation = json["clinical_presentation"] as? String,
            let diagnosisJsonDictionary = json["diagnosis"] as? [String: AnyObject],
            let diagnosis = laDiagnosis(fromJson: diagnosisJsonDictionary),
            let specificDiagnosis = json["specific_diagnosis"] as? String,
            let notes = json["notes"] as? String,
            let ctModalitiesJson = json["ctmodality"] as? [[String: AnyObject]],
            let mrModalitiesJson = json["mrmodality"] as? [[String: AnyObject]],
            let usModalitiesJson = json["ctmodality"] as? [[String: AnyObject]] else {
                return nil
        }

        let ctModalities = ctModalitiesJson.flatMap { laCTModality(fromJson: $0) }
        let mrModalities = mrModalitiesJson.flatMap { laMRModality(fromJson: $0) }
        let usModalities = usModalitiesJson.flatMap { laUSModality(fromJson: $0) }
        
        return LACase(title: title,
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

    static func laDiagnosis(fromJson json: [String: AnyObject]) -> LADiagnosis? {
        guard
            let diagnosis = json["diagnosis"] as? String,
            let categoriesJsonArray = json["categories"] as? [[String:AnyObject]],
            let information = json["information"] as? String,
            let pk = json["pk"] as? Int,
            let modifiedDate = modifiedDateFromJson(jsonDictionary: json),
            let synonymsJsonArray = json["synonyms"] as? [[String: AnyObject]] else {
                return nil
        }
        
        let categories = categoriesJsonArray.map { laCategory(fromJson: $0)! }
        let synonyms = synonymsJsonArray.map { laSynonym(fromJson: $0)! }
        
        return LADiagnosis(diagnosis: diagnosis,
                                   categories: categories,
                                   information: information,
                                   pk: pk,
                                   modifiedData: modifiedDate,
                                   synonyms: synonyms)
    }

    static func laCategory(fromJson json: [String: AnyObject]) -> LACategory? {
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
        
        return LACategory(id: id,
                                  lft: lft,
                                  rgt: rgt,
                                  treeID: treeID,
                                  depth: depth,
                                  title: title,
                                  exclusiveChidren: exclusiveChidren,
                                  modifiedDate: modifiedDate)
    }

    static func laSynonym(fromJson json: [String: AnyObject]) -> LASynonym? {
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let modifiedDate = dateFromString(dateString: json["modified_date"] as? String),
            let diagnosis = json["diagnosis"] as? Int else {
                return nil
        }
        
        return LASynonym(id: id,
                                 name: name,
                                 modifiedDate: modifiedDate,
                                 diagnosis: diagnosis)
    }
    
    static func laCTModality(fromJson json: [String: AnyObject]) -> LACTModality? {
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
        
        let imagingFeatures = imagingFeaturesJsonArray.map { laImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { laStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { laImage(fromJson: $0)! }
        
        return LACTModality(pk: pk,
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

    static func laMRModality(fromJson json: [String: AnyObject]) -> LAMRModality? {
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
        
        let imagingFeatures = imagingFeaturesJsonArray.map { laImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { laStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { laImage(fromJson: $0)! }
        
        return LAMRModality(pk: pk,
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
    
    static func laUSModality(fromJson json: [String: AnyObject]) -> LAUSModality? {
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
        
        let imagingFeatures = imagingFeaturesJsonArray.map { laImagingFeature(fromJson: $0)! }
        let structuralFeatures = structuralFeaturesJsonArray.map { laStructuralFeature(fromJson: $0)! }
        let images = imagesJsonArray.map { laImage(fromJson: $0)! }
        
        return LAUSModality(pk: pk,
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

    static func laImagingFeature(fromJson json: [String: AnyObject]) -> LAImagingFeature! {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let tree = json["tree"] as? String else {
                return nil
        }

        return LAImagingFeature(id: id, title: title, tree: tree)
    }
    
    static func laStructuralFeature(fromJson json: [String: AnyObject]) -> LAStructuralFeature! {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let tree = json["tree"] as? String else {
                return nil
        }
        
        return LAStructuralFeature(id: id, title: title, tree: tree)
    }
    
    static func laImage(fromJson json: [String: AnyObject]) -> LAImage! {
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
        
        return LAImage(id: id,
                       imageURL: imageURL,
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
        return LAJsonHelper.dateFormatter.date(from: dateString!) ??
            LAJsonHelper.dateFormatterWithFractionalSeconds.date(from: dateString!)
    }
    
    static func modifiedDateFromJson(jsonDictionary: [String: AnyObject]) -> Date? {
        return dateFromString(dateString: jsonDictionary["modified_date"] as? String)
    }
    


}
