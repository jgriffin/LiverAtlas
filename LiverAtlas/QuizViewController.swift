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
    @IBOutlet weak var diagnosisPickerView: UIView!
    @IBOutlet weak var diagnosisPicker: UIPickerView!
    @IBOutlet weak var specificDiagnosisPickerView: UIView!
    @IBOutlet weak var specificDiagnosisPicker: UIPickerView!
    @IBOutlet weak var nextQuestionView: UIView!
    
    var laFilterer: LAFilterer!
    var diagnosesChoices: [String]!
    var specificDiagnosesChoices: [String]!
    
    fileprivate var laCase: LACase! {
        didSet {
            quizContentView.configure(laCase: laCase, modality: laFilterer.activeModality)
        }
    }
    fileprivate var quizStateMachine: QuizControllerStateMachine!

    override func viewDidLoad() {
        super.viewDidLoad()
        quizContentView.modalityPanelHostDelegate = self

        populateFilteredCasesAndDiagnoses()
        
        quizStateMachine = QuizControllerStateMachine(delegate: self)
        quizStateMachine.transition(toState: .pickANewCase)
    }
    
    override func prepareForInterfaceBuilder() {
        laCase = LAIndex.instance.case6
    }
    
    func populateFilteredCasesAndDiagnoses() {
        laFilterer = LAFilterer.instance
        
        let diagnosesAndSpecific = LAFilterer.diagnosesAndSpecificDiagnoses(
            fromFilteredCases: laFilterer.modalityFilteredCases)
        diagnosesChoices = diagnosesAndSpecific.diagnoses
        specificDiagnosesChoices = diagnosesAndSpecific.specificDiagnoses
    }
    
    func pickARandomCase() {
        laCase = laFilterer.filteredCases.cases.first
    }

    @IBAction func nextPatientAction(_ sender: Any) {
        assert(quizStateMachine.currentState == .wantANewCase)
        quizStateMachine.transition(toState: .pickANewCase)
    }
}

extension QuizViewController: QuizControllerStateMachineDelegate {
    func didTransition(fromState: QuizState, toState: QuizState) {
        switch toState {
        case .uninitialized:
            fatalError("should never get notified of .uninitialized")
        case .pickANewCase:
            // hide controls
            diagnosisPickerView.isHidden = true
            specificDiagnosisPickerView.isHidden = true
            nextQuestionView.isHidden = true
            
            pickARandomCase()
            quizStateMachine.transition(toState: .waitingForDiagnosis)
            break
        case .waitingForDiagnosis:
            diagnosisPickerView.isHidden = false
            diagnosisPickerView.isUserInteractionEnabled = true
            break
        case .wrongDiagnosis:
            // TODO:
            break
        case .correctDiagnosis:
            // TODO:
            quizStateMachine.transition(toState: .waitingForSpecificDiagnosis)
            break
        case .waitingForSpecificDiagnosis:
            diagnosisPickerView.isUserInteractionEnabled = false
            specificDiagnosisPickerView.isHidden = false
            specificDiagnosisPickerView.isUserInteractionEnabled = true
            break
        case .wrongSpecificDiagnosis:
            // TODO:
            break
        case .correctSpecificDiagnosis:
            specificDiagnosisPickerView.isUserInteractionEnabled = false
            quizStateMachine.transition(toState: .wantANewCase)
            break
        case .wantANewCase:
            nextQuestionView.isHidden = false
            break
        }
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
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case diagnosisPicker:
            let diagnosis = diagnosesChoices[row]
            let isCorrectDiagnosis = diagnosis == laCase.diagnosis.diagnosis
            let nextState: QuizState = isCorrectDiagnosis ? .correctDiagnosis : .wrongDiagnosis
            
            quizStateMachine.transition(toState: nextState)

        case specificDiagnosisPicker:
            let specificDiagnosis = specificDiagnosesChoices[row]
            let correctSpecificDiagnosos = SpecificDiagnosis(fromCase: laCase).specificDiagnosis
            let isCorrectSpecificDiagnosis = specificDiagnosis == correctSpecificDiagnosos
            let nextState: QuizState = isCorrectSpecificDiagnosis ? .correctSpecificDiagnosis : .wrongSpecificDiagnosis
            
            quizStateMachine.transition(toState: nextState)
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



