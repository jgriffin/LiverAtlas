//
//  HomePageViewController.swift
//  LiverAtlas
//
//  Created by John on 11/19/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .some(SegueID.homeToCaseDetailsSegueID.rawValue):
            let detailsVC = segue.destination as! CaseDetailsViewController
            detailsVC.configure(laCase: LAIndex.instance.case6)
        default:
            NSLog("unhandled segue with identifier: \(segue.identifier)" )
        }
    }    
}
