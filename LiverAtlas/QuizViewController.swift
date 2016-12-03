//
//  QuizViewController.swift
//  LiverAtlas
//
//  Created by John on 11/29/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    @IBOutlet weak var quizContentView: QuizContentView!
    @IBOutlet weak var diagnosisPicker: UIView!
    @IBOutlet weak var specificDiagnosisPicker: UIView!
    
    var laFilterer: LAFilterer!
    var diagnosesChoices: [String]!
    var specificDiagnosesChoices: [String]!
    
    var laCase: LACase! {
        didSet {
            quizContentView.configure(laCase: laCase)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        quizContentView.modalityPanelHostDelegate = self
        pickARandomCase()
        populateDiagnoses()
    }

    func pickARandomCase() {
        laCase = LAIndex.instance.case6
    }
    
    override func prepareForInterfaceBuilder() {
        laCase = LAIndex.instance.case6
    }
    
    func populateDiagnoses() {
        laFilterer = LAFilterer(allCases: nil, modality: .ct, activeFilters: nil)
        let diagnosesAndSpecific = LAFilterer.diagnosesAndSpecificDiagnoses(
            fromFilteredCases: laFilterer.modalityFilteredCases)

        diagnosesChoices = diagnosesAndSpecific.diagnoses
        specificDiagnosesChoices = diagnosesAndSpecific.specificDiagnoses
    }
}

extension QuizViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case diagnosisPicker:
            return diagnosesChoices.count
        case specificDiagnosisPicker:
            return specificDiagnosesChoices.count
        default:
            fatalError("unhandled picker type")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case diagnosisPicker:
            return diagnosesChoices[row]
        case specificDiagnosisPicker:
            return specificDiagnosesChoices[row]
        default:
            fatalError("unhandled picker type")
        }
    }
}

extension QuizViewController: ModalityPanelHostDelegate {
    func modalityPanel(_ modalityPanel: ModalityPanelView,
                       didSelectImage laImage: LAImage?,
                       withIndex imageIndex: Int) {
        let imagingController = MainStoryboard.instantiate(withStoryboardID: .imagingID) as! ImagingViewController
        imagingController.configure(laImage: laImage!)
        
        navigationController?.pushViewController(imagingController, animated: true)
    }
}


