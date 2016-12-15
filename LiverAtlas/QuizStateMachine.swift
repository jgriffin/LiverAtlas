//
//  QuizStateMachine.swift
//  LiverAtlas
//
//  Created by John on 12/15/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import Foundation

enum QuizState {
    case uninitialized
    case pickANewCase
    case waitingForDiagnosis, correctDiagnosis, wrongDiagnosis
    case waitingForSpecificDiagnosis, correctSpecificDiagnosis, wrongSpecificDiagnosis
    case wantANewCase
}

protocol QuizControllerStateMachineDelegate: class {
    func didTransition(fromState: QuizState, toState: QuizState)
}


class QuizControllerStateMachine {
    var delegate: QuizControllerStateMachineDelegate?
    var currentState: QuizState = .uninitialized

    init(delegate:QuizControllerStateMachineDelegate) {
        self.delegate = delegate
    }
    
    func transition(toState: QuizState) {
        assert(canTransition(fromState: currentState, toState: toState))
        
        let previous = currentState
        currentState = toState
        delegate?.didTransition(fromState: previous, toState: currentState)
    }
    
    func canTransition(fromState:QuizState, toState: QuizState) -> Bool {
        switch (fromState, toState) {
        case (.uninitialized, .pickANewCase): return true
        case (.pickANewCase, .waitingForDiagnosis): return true
            
        case (.waitingForDiagnosis, .correctDiagnosis): return true
        case (.waitingForDiagnosis, .wrongDiagnosis): return true
        case (.wrongDiagnosis, .wrongDiagnosis): return true
        case (.wrongDiagnosis, .correctDiagnosis): return true
        case (.correctDiagnosis, .waitingForSpecificDiagnosis): return true

        case (.waitingForSpecificDiagnosis, .correctSpecificDiagnosis): return true
        case (.waitingForSpecificDiagnosis, .wrongSpecificDiagnosis): return true
        case (.wrongSpecificDiagnosis, .wrongSpecificDiagnosis): return true
        case (.wrongSpecificDiagnosis, .correctSpecificDiagnosis): return true
        case (.correctSpecificDiagnosis, .wantANewCase): return true
            
        case (.wantANewCase, .pickANewCase): return true

        default: return false
        }
    }
}
