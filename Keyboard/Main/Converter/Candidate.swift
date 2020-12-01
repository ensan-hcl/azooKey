//
//  Candidate.swift
//  Keyboard
//
//  Created by β α on 2020/10/26.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

final class ClauseDataUnit{
    var mid: Int = 500
    var lcid: Int = .zero
    var rcid: Int = .zero
    var nextLcid = 1316

    var text: String = ""
    var ruby: String = ""
    init(){}

    init(data: DicDataElementProtocol){
        if DicDataStore.includeMMValueCalculation(data){
            self.mid = data.mid
        }
        self.lcid = data.lcid
        self.rcid = data.rcid
        self.nextLcid = data.lcid
        self.text = data.word
        self.ruby = data.ruby
    }

    func merge(with unit: ClauseDataUnit){
        self.text.append(unit.text)
        self.ruby.append(unit.ruby)
        self.rcid = unit.rcid
        self.nextLcid = unit.nextLcid

    }
}

struct CandidateData{
    typealias ClausesUnit = (clause: ClauseDataUnit, value: PValue)
    var clauses: [ClausesUnit]
    var data: [DicDataElementProtocol]

    init(clauses: [ClausesUnit], data: [DicDataElementProtocol]){
        self.clauses = clauses
        self.data = data
    }

    var lastClause: ClauseDataUnit? {
        return self.clauses.last?.clause
    }

    var isEmpty: Bool {
        return clauses.isEmpty
    }
}

struct Candidate{
    let text: String
    let value: PValue
    let visibleString: String
    let rcid: Int
    let lastMid: Int
    let data: [DicDataElementProtocol]
    let actions: [ActionType]
    let inputable: Bool

    init(text: String, value: PValue, visibleString: String, rcid: Int, lastMid: Int, data: [DicDataElementProtocol], actions: [ActionType] = [], inputable: Bool = true){
        self.text = text
        self.value = value
        self.visibleString = visibleString
        self.rcid = rcid
        self.lastMid = lastMid
        self.data = data
        self.actions = actions
        self.inputable = inputable
    }

    func withActions(_ actions: [ActionType]) -> Candidate {
        return Candidate(text: text, value: value, visibleString: visibleString, rcid: rcid, lastMid: lastMid, data: data, actions: actions, inputable: inputable)
    }
}
