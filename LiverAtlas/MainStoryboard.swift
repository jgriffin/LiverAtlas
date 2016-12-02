//
//  MainStoryboard.swift
//  LiverAtlas
//
//  Created by John on 12/1/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit


struct MainStoryboard {
    static var instance = UIStoryboard(name: "Main",
                                       bundle: Bundle(for: MainStoryboard.self as! AnyClass ))

    static func instantiate(withStoryboardID id: StoryboardID) -> UIViewController {
        return MainStoryboard.instance.instantiateViewController(withIdentifier: id.rawValue)
    }
    
}

enum StoryboardID: String {
    case homePageID = "HomePageViewControllerStoryboardIdentifier"
    case casesID = "CasesViewControllerStoryboardIdentifier"
    case caseDetailsID = "CaseDetailsViewController"
    case imagingID = "ImagingViewController"
}

enum SegueID: String {
    case homeToCaseDetailsSegueID = "HomeToCaseDetailsSegue"
    case homeToIndexSegueID = "HomeToIndexSegue"
    case casesToCaseDetailSegueID =  "CaseResultToCaseDetailSegue"
    case showImagingSequeID = "CaseDetailToImagingSegue"
    
}

enum CellID: String {
    case diagnosisCellID = "DiagnosisTableCellIdentifier"
    case specificDiagnosisCellID = "SpecificDiagnosisTableCellIdentifier"
    case caseResultTableViewCellID = "caseResultTableViewCellID"
    case caseTableViewCellID = "CaseTableViewCellIdentifier"
    case resultTableViewImageCellID = "ResultTableViewImageCellIdentifier"
}

