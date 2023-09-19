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

    func update(candidate: Candidate, textChangedCount: Int, predictions: [KanaKanjiConverterModule.PredictionCandidate]) -> [PredictionCandidate] {
        self.lastState = State(candidate: candidate, textChangedCount: textChangedCount)
        return predictions.map{.init(candidate: $0, terminatePrediction: shouldTerminate($0))}
    }

    func shouldTerminate(_ candidate: KanaKanjiConverterModule.PredictionCandidate) -> Bool {
        if ["。", "、", ".", ","].contains(candidate.text) {
            return true
        }
        return false
    }

    func getLastCandidate() -> Candidate? {
        return lastState?.candidate
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
    init(candidate: KanaKanjiConverterModule.PredictionCandidate, terminatePrediction: Bool = false) {
        self.candidate = candidate
        self.terminatePrediction = terminatePrediction
    }
    var candidate: KanaKanjiConverterModule.PredictionCandidate

    var inputable: Bool {
        true
    }
            
    var text: String {
        candidate.text
    }

    var terminatePrediction: Bool
    
    #if DEBUG
    func getDebugInformation() -> String {
        text
    }
    #endif
}
