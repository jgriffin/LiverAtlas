//
//  MainStoryboard.swift
//  LiverAtlas
//
//  Created by John on 12/1/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit


class MainStoryboard {
    static var instance = UIStoryboard(name: "Main",
                                       bundle: MainStoryboard.bundle)

    static var bundle: Bundle {
        return Bundle(for: MainStoryboard.self)
    }
    
    static func instantiate(withStoryboardID id: StoryboardID) -> UIViewController {
        return MainStoryboard.instance.instantiateViewController(withIdentifier: id.rawValue)
    }
}

enum StoryboardID: String {
    case homePageID = "HomePageViewControllerStoryboardIdentifier"
    case casesID = "CasesViewControllerStoryboardIdentifier"
    case caseDetailsID = "CaseDetailsViewController"
    case imagingID = "ImagingViewController"
    case filtersID = "filtersViewControllerStoryboardID"

}

enum SegueID: String {
    case homeToCaseDetailsSegueID = "HomeToCaseDetailsSegue"
    case homeToIndexSegueID = "HomeToIndexSegue"
    case casesToCaseDetailSegueID =  "CaseResultToCaseDetailSegue"
    case showImagingSequeID = "CaseDetailToImagingSegue"
    case filterViewToCaseResultsSegue = "FilterViewToCaseResultsSegue"
    case casesViewControllerIdentifier = "CasesViewControllerStoryboardIdentifier"
    
}

enum CellID: String {
    case diagnosisHeaderID = "DiagnosisTableHeaderIdentifier"
    case diagnosisCellID = "DiagnosisTableCellIdentifier"
    case specificDiagnosisCellID = "SpecificDiagnosisTableCellIdentifier"
    case caseResultTableViewCellID = "caseResultTableViewCellID"
    case caseTableViewCellID = "CaseTableViewCellIdentifier"
    case resultTableViewImageCellID = "ResultTableViewImageCellIdentifier"
    case imageTileCollectionViewCellID = "ImageTileCollectionViewCell"

    case filterItemReuseID = "FilterItemCellIdentifier"
    case sectionHeaderReuseID = "SectionHeaderCellIdentifier"
}

