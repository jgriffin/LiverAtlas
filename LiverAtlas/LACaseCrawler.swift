//
//  LACaseCrawler.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit


class LACaseCrawler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    static var instance: LACaseCrawler = LACaseCrawler()
    lazy var session: URLSession = self.createURLSession()
    
    // LiverAtlas objects

    let laIndexUrl = URL(string:"http://liveratlas.org/api/cases/")!
    
    func loadLAIndex(completion: @escaping ([LAIndexItem]?) -> Void) {
        loadLAIndexJson { atlasIndexJson in
            guard let _ = atlasIndexJson,
                let atlasIndex = LAJsonHelper.laIndex(fromJson: atlasIndexJson!) else {
                    return completion(nil)
            }
            completion(atlasIndex)
        }
    }

    func loadLACase(indexItem: LAIndexItem, callback: @escaping (LACase?) -> Void) {
        loadLACase(url: indexItem.url, callback: callback)
    }
    
    func loadLACase(url: URL, callback: @escaping (LACase?) -> Void) {
        
        loadLACaseJson(url: url) { dowloadedJsonDictionary in
            assert(Thread.isMainThread)
            guard
                let jsonDictionary = dowloadedJsonDictionary,
                let atlasCase = LAJsonHelper.laCase(fromJson: jsonDictionary) else {
                    callback(nil)
                    return
            }
            callback(atlasCase)
        }
    }

    func loadAllLACases(forIndexItems indexItems: [LAIndexItem],
                                completion: @escaping ([LACase]?) -> Void) {
        
        loadAllLACasesJson(forIndexItems: indexItems) { (jsonCasesDictionaryArray: [[String: AnyObject]]?) in
            assert(Thread.isMainThread)
            guard let _ = jsonCasesDictionaryArray else {
                completion(nil)
                return
            }
            
            let laCases = jsonCasesDictionaryArray!.map {
                LAJsonHelper.laCase(fromJson: $0)!
            }
            completion(laCases)
        }
    }
    
    func loadLAImageForURL(imageURL: URL, callback: @escaping (UIImage?) -> Void) {
        
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
    
    func loadLAIndexJson(completion: @escaping ([[String: AnyObject]]?) -> Void) {
        let fetchIndexTask = session.dataTask(with: laIndexUrl) { (data, response, error) in
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
    
    func loadLACaseJson(url: URL, callback: @escaping ([String: AnyObject]?) -> Void) {
        
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

    func loadAllLACasesJson(forIndexItems indexItems: [LAIndexItem],
                                    completion: @escaping ([[String: AnyObject]]?) -> Void) {
        
        // the fetcher groups allow us to know whether fetches are in progress
        let fetcherGroup = DispatchGroup()
        
        var laCases = [[String: AnyObject]]()
        
        for indexItem in indexItems {
            fetcherGroup.enter()
            
            loadLACaseJson(url: indexItem.url, callback: { (laCaseJson) in
                assert(Thread.isMainThread)
                guard let liverCase = laCaseJson else {
                    NSLog("error downloading indexItem: \(indexItem.pk)")
                    fetcherGroup.leave()
                    return
                }
                
                laCases.append(liverCase)
                fetcherGroup.leave()
            })
            
        }
        
        fetcherGroup.notify(queue: DispatchQueue.main, execute: {
            completion(laCases)
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
