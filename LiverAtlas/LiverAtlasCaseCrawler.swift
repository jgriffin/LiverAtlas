//
//  LiverAtlasCaseCrawler.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation


class LiverAtlasCaseCrawler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    let liverAtlasIndexUrl = URL(string:"http://liveratlas.org/api/cases")!
    
    var liverAtlasIndex: [LiverAtlasIndexItem]! {
        didSet {
            liverAtlasIndexUpdated()
        }
    }
    
    var liverAtlasCases = [LiverAtlasCase]()

    // URL Session
    
    lazy var session: URLSession = self.createURLSession()
    lazy var fetcherGroup = DispatchGroup()

    func createURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 5
        
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Authorization": authorizationHeader()
        ]
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func authorizationHeader() -> String {
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
    
    // fetching methods

    func loadLiverAtlasIndex() {
        fetcherGroup.enter()
        
        let fetchIndexTask = session.dataTask(with: liverAtlasIndexUrl) { (data, response, error) in
            assert(!Thread.isMainThread)
            defer {
                self.fetcherGroup.leave()
            }
            
            guard error == nil && data != nil else {
                assert(false, "error downloading liver atlas index")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!)
                
                guard let jsonArray = json as? [[String: AnyObject]] else {
                    if let jsonDict = json as? [String: AnyObject],
                        let detail = jsonDict["detail"] as? String,
                        detail == "Authentication credentials were not provided." {
                        assert(false, "missing auth credentials")
                    } else {
                        assert(false, "json error")
                    }
                    return
                }
                
                let indexItems = LiverAtlasJsonHelper.liverAtlasIndex(fromJson: jsonArray)
                self.liverAtlasIndex = indexItems
                
            } catch {
                assert(false, "error parsing index json")
                return
            }
        }
        fetchIndexTask.resume()
    }
    
    func liverAtlasIndexUpdated() {
        
    }
    
    func loadCases(forIndexItems indexItems: [LiverAtlasIndexItem]) {
        
    }
    
    
    func jsonDictionaryForResource(filename: String) ->  [String: AnyObject]? {
        let casesFilePath = Bundle(for: type(of:self)).path(forResource: filename, ofType: ".json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: casesFilePath))
        
        return try! JSONSerialization.jsonObject(with: data, options: []) as?  [String: AnyObject]
    }

    
    let case6Filename = "liveratlas_api_case_6"
    func loadCaseForIndexItem(indexItem: LiverAtlasIndexItem, callback: @escaping (LiverAtlasCase?) -> Void) {
        // until auth is fixed, keep returning case 6 from the resource file
        let jsonDictionary = jsonDictionaryForResource(filename: case6Filename)!
        let atlasCase = LiverAtlasJsonHelper.liverAtlasCase(fromJson: jsonDictionary)
        DispatchQueue.main.async {
            callback(atlasCase)
        }
    }
}
