//
//  PredictionManager.swift
//  Keyboard
//
//  Created by miwa on 2023/09/18.
//  Copyright © 2023 miwa. All rights reserved.
//

import KanaKanjiConverterModule
import KeyboardViews

final class PredictionManager {
    private struct State {
        var candidate: Candidate
        var textChangedCount: Int
    }

    private var lastState: State?

    func update(candidate: Candidate, textChangedCount: Int) -> [PredictionCandidate] {
        self.lastState = State(candidate: candidate, textChangedCount: textChangedCount)
        return [
            // TODO: Provide implementation
        ]
    }

    func shouldResetPrediction(textChangedCount: Int) -> Bool {
        if let lastState, lastState.textChangedCount != textChangedCount {
            self.lastState = nil
            return true
        }
        return false
    }
}

struct PredictionCandidate: ResultViewItemData {
    var inputable: Bool {
        true
    }
            
    var text: String
    
    var terminatePrediction: Bool = false
    
    #if DEBUG
    func getDebugInformation() -> String {
        text
    }
    #endif
}