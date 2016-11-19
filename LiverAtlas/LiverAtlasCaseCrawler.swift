//
//  LiverAtlasCaseCrawler.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit


class LiverAtlasCaseCrawler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    static var instance: LiverAtlasCaseCrawler = LiverAtlasCaseCrawler()
    lazy var session: URLSession = self.createURLSession()
    
    // LiverAtlas objects

    let liverAtlasIndexUrl = URL(string:"http://liveratlas.org/api/cases/")!
    
    func loadLiverAtlasIndex(completion: @escaping ([LiverAtlasIndexItem]?) -> Void) {
        loadLiverAtlasIndexJson { atlasIndexJson in
            guard let _ = atlasIndexJson,
                let atlasIndex = LiverAtlasJsonHelper.liverAtlasIndex(fromJson: atlasIndexJson!) else {
                    return completion(nil)
            }
            completion(atlasIndex)
        }
    }

    func loadLiverAtlasCase(indexItem: LiverAtlasIndexItem, callback: @escaping (LiverAtlasCase?) -> Void) {
        loadLiverAtlasCase(url: indexItem.url, callback: callback)
    }
    
    func loadLiverAtlasCase(url: URL, callback: @escaping (LiverAtlasCase?) -> Void) {
        
        loadLiverAtlasCaseJson(url: url) { dowloadedJsonDictionary in
            assert(Thread.isMainThread)
            guard
                let jsonDictionary = dowloadedJsonDictionary,
                let atlasCase = LiverAtlasJsonHelper.liverAtlasCase(fromJson: jsonDictionary) else {
                    callback(nil)
                    return
            }
            callback(atlasCase)
        }
    }

    func loadAllLiverAtlasCases(forIndexItems indexItems: [LiverAtlasIndexItem],
                                completion: @escaping ([LiverAtlasCase]?) -> Void) {
        
        loadAllLiverAtlasCasesJson(forIndexItems: indexItems) { (jsonCasesDictionaryArray: [[String: AnyObject]]?) in
            assert(Thread.isMainThread)
            guard let _ = jsonCasesDictionaryArray else {
                completion(nil)
                return
            }
            
            let liverAtlasCases = jsonCasesDictionaryArray!.map {
                LiverAtlasJsonHelper.liverAtlasCase(fromJson: $0)!
            }
            completion(liverAtlasCases)
        }
    }
    
    func loadLiverAtlasImageForURL(imageURL: URL, callback: @escaping (UIImage?) -> Void) {
        
        let downloadImageTask = session.dataTask(with: imageURL) { (data, reponse, error) in
            var imageResult: UIImage?
            defer {
                DispatchQueue.main.async {
                    callback(imageResult)
                }
            }
            
            guard let _ = data else {
                return
            }
            
            imageResult = UIImage(data: data!)
        }
        downloadImageTask.resume()
    }

    // Json objects
    
    func loadLiverAtlasIndexJson(completion: @escaping ([[String: AnyObject]]?) -> Void) {
        let fetchIndexTask = session.dataTask(with: liverAtlasIndexUrl) { (data, response, error) in
            assert(!Thread.isMainThread)
            
            var indexItemsResponse: [[String: AnyObject]]?
            defer {
                completion(indexItemsResponse)
            }
            
            guard error == nil && data != nil,
                let json = try? JSONSerialization.jsonObject(with: data!) else {
                    assert(false, "error downloading liver atlas index")
                    return
            }
            
            guard let jsonArray = json as? [[String: AnyObject]] else {
                if let jsonDict = json as? [String: AnyObject],
                    let detail = jsonDict["detail"] as? String,
                    detail == "Authentication credentials were not provided." {
                    NSLog("Authentication credentials were not provided.")
                } else {
                    assert(false, "json error")
                }
                return
            }
            
            indexItemsResponse = jsonArray
        }
        fetchIndexTask.resume()
    }
    
    func loadLiverAtlasCaseJson(url: URL, callback: @escaping ([String: AnyObject]?) -> Void) {
        
        let downloadImageTask = session.dataTask(with: url) { (data, reponse, error) in
            guard
                let _ = data,
                let json = try? JSONSerialization.jsonObject(with: data!),
                let jsonDictionary = json as? [String: AnyObject] else {
                    DispatchQueue.main.async {
                        callback(nil)
                    }
                    return
            }
            
            DispatchQueue.main.async {
                callback(jsonDictionary)
            }
        }
        downloadImageTask.resume()
    }

    func loadAllLiverAtlasCasesJson(forIndexItems indexItems: [LiverAtlasIndexItem],
                                    completion: @escaping ([[String: AnyObject]]?) -> Void) {
        
        // the fetcher groups allow us to know whether fetches are in progress
        let fetcherGroup = DispatchGroup()
        
        var liverAtlasCases = [[String: AnyObject]]()
        
        for indexItem in indexItems {
            fetcherGroup.enter()
            
            loadLiverAtlasCaseJson(url: indexItem.url, callback: { (liverAtlasCaseJson) in
                assert(Thread.isMainThread)
                guard let liverCase = liverAtlasCaseJson else {
                    NSLog("error downloading indexItem: \(indexItem.pk)")
                    fetcherGroup.leave()
                    return
                }
                
                liverAtlasCases.append(liverCase)
                fetcherGroup.leave()
            })
            
        }
        
        fetcherGroup.notify(queue: DispatchQueue.main, execute: {
            completion(liverAtlasCases)
        })
    }
    
    // helpers

    // create session methods
    
    func createURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 5
        
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Authorization": authorizationHeader
        ]
        
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
    
    var authorizationHeader: String {
        let (username, password) = ("john_griffin@hotmail.com", "liver")
        let authString = "\(username):\(password)"
        let authDataString = authString.data(using: .utf8)!.base64EncodedString()
        let authHeader = "Basic \(authDataString)"
        return authHeader
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }

}
