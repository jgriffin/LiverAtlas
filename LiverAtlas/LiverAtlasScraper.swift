//
//  LiverAtlasScraper.swift
//  LiverAtlas
//
//  Created by John on 11/5/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation
import Kanna

struct LiverAtlasIndexItem {
    let description: String
    let href: String
}

struct LiverAtlasCaseDetails {
    let caseURL: String
    let caseNumberHeading: String
    let headingText: String
    let headingHref: String
    let keywords: [String]
    let clinicalPresentation: String
    let images: [LiverAtlasImage]
    let imageFindings: String
}

struct LiverAtlasDiagnosisDetail {
    let clinicalPresentation: String
    let images: [LiverAtlasImage]
    let imagingFindings: String
}

struct LiverAtlasScrapeImage {
    let title: String
    let src: String
}


class LiverAtlasScraper {
  
    // MARK: - Scrapers
    
    static func indexItemsFrom(indexHtml: HTMLDocument) -> [LiverAtlasIndexItem] {
        let index_items = indexHtml.xpath("//li[@class='leaf']//a[@href]")
        return index_items.flatMap { (xmlElement) -> LiverAtlasIndexItem? in
            guard let href = xmlElement["href"],
                let description = xmlElement.content else {
                    return nil
            }
            return LiverAtlasIndexItem(description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                                       href: href)
        }
    }

    
    static func caseDetailsFrom(caseURL: URL, detailsHtml: HTMLDocument) -> LiverAtlasCaseDetails? {
        let theCase = detailsHtml.at_xpath("//div[@id='full_case_view']")!
        
        guard let heading_case_number = theCase.at_xpath("h1[@id='document_first_heading']/span")?.content?.trimmingCharacters(in: .whitespacesAndNewlines),
            let heading_text = theCase.at_xpath("h1[@id='document_first_heading']/a")?.content?.trimmingCharacters(in: .whitespacesAndNewlines),
            let heading_href = theCase.at_xpath("h1[@id='document_first_heading']/a")?["href"],
            let clinical_presentation = theCase.at_xpath("div[@id='case_diagnosis']/p")?.content else {
                print("dropping invalid case details for \(caseURL.absoluteString)")
                return nil
        }
        let keywords: [String] = theCase.xpath("*/ul[contains(@class,'keyword_list')]/li").flatMap { $0.content?.trimmingCharacters(in: .whitespacesAndNewlines) }
    
        let case_images = theCase.xpath(".//div[@class='image_gallery']//div[contains(@class, 'image_tile')]").flatMap { imageTile -> LiverAtlasImage? in
            guard let title = imageTile.at_xpath("./h4")?.content, let img_src = imageTile.at_xpath("./a/img")?["src"] else {
                print("dropping invalid image for \(caseURL.absoluteString)")
                return nil
            }
            return LiverAtlasImage(title: title, src: img_src)
        }
        
        guard let imaging_findings = theCase.at_xpath(".//div[@id='case_diagnosis']/div[@class='formatted_text']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("dropping missing image findings for \(caseURL.absoluteString)")
            return nil
        }
        
        return LiverAtlasCaseDetails(caseURL: caseURL.absoluteString,
                                     caseNumberHeading: heading_case_number,
                                     headingText: heading_text,
                                     headingHref: heading_href,
                                     keywords: keywords,
                                     clinicalPresentation: clinical_presentation,
                                     images: case_images,
                                     imageFindings: imaging_findings)
    }
    
    static func diagnosisDetailsFrom(detailsHtml: HTMLDocument) -> [LiverAtlasDiagnosisDetail] {
        let cases = detailsHtml.xpath("//div[@id='caselist_container']//div[@class='case_wrapper']")
        
        return cases.map { aCase in
            let case_presentation = aCase.at_xpath("div[contains(@class,'case_presentation')]")
            
            let clinical_presentation_heading = case_presentation?.at_xpath("h4")?.content
            let case_image_anchors = aCase.xpath("div[@class='case_imaging']/div[@class='case_images']//a[@class='fancybox_img']")
            let case_images = case_image_anchors.map { (anchorNode) in
                return LiverAtlasImage(title: anchorNode["title"]!, src: anchorNode["href"]!)
            }
            let imaging_findings = aCase.at_xpath("*//div[contains(@class,'case_findings')]/div[contains(@class,'expandable_container')]/p")?.content
            
            return LiverAtlasDiagnosisDetail(clinicalPresentation: clinical_presentation_heading!, images: case_images, imagingFindings: imaging_findings!)
        }
    }
}

class LiverAtlasScraperFetcher {
    let liverAtlasIndexURL = URL(string: "http://liveratlas.org/index/")!

    // LiverAtlasScraperFetcher fetches index then fetches details references from each item's reference
    //
    // The http calls are made asynchronously using a shared fetcherSession
    // Access to shared class resourses are synchronized on the main thread and
    // fetcherGroup enter/leaves calls are made so a caller can 
    // fetcherGroup.wait() or fetcherGroup.notify() to know when all operations have completed.
    
    lazy var fetcherSession: URLSession = {
        var configuration = URLSessionConfiguration.ephemeral
        // Keeping at 1 connection is a cheap way to getting the results in order
        configuration.httpMaximumConnectionsPerHost = 5
        return URLSession(configuration: configuration)
    }()
    
    lazy var fetcherGroup = DispatchGroup()
    
    var caseDetailResults = [LiverAtlasCaseDetails]()
    
    // MARK: fetcher methods
    
    func getIndexItemsReferencedFromIndex(completion: @escaping ([LiverAtlasIndexItem]) -> ()) {
        assert(Thread.isMainThread)
        fetcherGroup.enter()
        
        let downloadIndexTask = fetcherSession.dataTask(with: liverAtlasIndexURL) { (data, response, error) in
            assert(!Thread.isMainThread)
            defer {
                self.fetcherGroup.leave()
            }
            
            guard error == nil || data == nil else {
                assert(false, "error downloading liver atlas index")
                return
            }
            
            guard let indexHtml = Kanna.HTML(html: data!, encoding: .utf8) else {
                assert(false, "Kanna didn't load and parse url")
                return
            }
            
            let indexItems = LiverAtlasScraper.indexItemsFrom(indexHtml: indexHtml)
            
            self.fetcherGroup.enter()
            
            DispatchQueue.main.async {
                assert(Thread.isMainThread)
                defer {
                    self.fetcherGroup.leave()
                }

                completion(indexItems)
            }
            
        }
        downloadIndexTask.resume()
    }

    func getCaseDetailsFor(caseDetailURL: URL, completion: @escaping (LiverAtlasCaseDetails) -> ()) {
        assert(Thread.isMainThread)
        fetcherGroup.enter()

        let downloadIndexTask = fetcherSession.dataTask(with: caseDetailURL) { (data, response, error) in
            assert(!Thread.isMainThread)
            defer {
                self.fetcherGroup.leave()
            }
            
            guard error == nil || data == nil else {
                assert(false, "error downloading liver atlas index")
                return
            }
            
            guard let detailHtml = Kanna.HTML(html: data!, encoding: .utf8) else {
                assert(false, "Kanna didn't load and parse url")
                return
            }
            
            if let caseDetails = LiverAtlasScraper.caseDetailsFrom(caseURL: caseDetailURL, detailsHtml: detailHtml) {
                self.fetcherGroup.enter()
             
                DispatchQueue.main.async {
                    defer { 
                        self.fetcherGroup.leave()
                    }
                    
                    completion(caseDetails)
                }
            }
        }
        downloadIndexTask.resume()
    }
    
    // MARK: fetcher helpers
    
    func fetchCaseDetailsForIndexItems(indexItems: [LiverAtlasIndexItem]) {
        assert(Thread.isMainThread)
        self.fetcherGroup.enter()
        defer {
            self.fetcherGroup.leave()
        }
        
        // queue downloads for all the cases
        let caseIndexItems = indexItems.filter { (item) in item.href.contains("case") && !item.href.contains("?") }
        
        caseIndexItems.forEach { item in
            let caseURL = URL(string:item.href, relativeTo: liverAtlasIndexURL)!
            self.getCaseDetailsFor(caseDetailURL: caseURL) { caseDetails in
                self.appendCaseDetailResults(caseDetails: caseDetails)
            }
        }
    }
    
    func appendCaseDetailResults(caseDetails: LiverAtlasCaseDetails) {
        assert(Thread.isMainThread)
        
        self.caseDetailResults.append(caseDetails)
    }

}
