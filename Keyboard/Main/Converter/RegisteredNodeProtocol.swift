//
//  RegisteredNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

protocol RegisteredNodeProtocol {
    var data: DicdataElement {get}
    var prev: (any RegisteredNodeProtocol)? {get}
    var totalValue: PValue {get}
    var input: String {get}
    var convertTargetLength: Int {get}

    static func BOSNode() -> Self
    static func fromLastCandidate(_ candidate: Candidate) -> Self
}

struct RegisteredNode: RegisteredNodeProtocol {
    let data: DicdataElement
    let prev: (any RegisteredNodeProtocol)?
    let totalValue: PValue
    var convertTargetLength: Int
    // 入力に対応する文字列
    // ダイレクト入力中であれば「今日は」に対して「キョウハ」
    // ローマ字入力中であれば「今日は」に対してkyouhaになる
    var input: String

    init(data: DicdataElement, registered: RegisteredNode?, totalValue: PValue, convertTargetLength: Int, input: String) {
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.input = input
        self.convertTargetLength = convertTargetLength
    }

    static func BOSNode() -> RegisteredNode {
        RegisteredNode(data: DicdataElement.BOSData, registered: nil, totalValue: 0, convertTargetLength: 0, input: "")
    }

    static func fromLastCandidate(_ candidate: Candidate) -> RegisteredNode {
        RegisteredNode(
            data: DicdataElement(word: "", ruby: "", lcid: CIDData.BOS.cid , rcid: candidate.data.last?.rcid ?? CIDData.BOS.cid, mid: candidate.lastMid, value: 0),
            registered: nil,
            totalValue: 0,
            convertTargetLength: 0,
            input: ""
        )
    }
}


extension RegisteredNodeProtocol {
    func getCandidateData() -> CandidateData {
        guard let prev = self.prev else {
            let unit = ClauseDataUnit()
            unit.mid = self.data.mid
            unit.ruby = self.input
            unit.rubyCount = self.convertTargetLength
            return CandidateData(clauses: [(clause: unit, value: .zero)], data: [])
        }
        var lastcandidate = prev.getCandidateData()    // 自分に至るregisterdそれぞれのデータに処理

        if self.data.word.isEmpty {
            return lastcandidate
        }

        guard let lastClause = lastcandidate.lastClause else {
            return lastcandidate
        }

        if lastClause.text.isEmpty || !DicdataStore.isClause(prev.data.rcid, self.data.lcid) {
            // 文節ではないので、最後に追加する。
            lastClause.text.append(self.data.word)
            lastClause.ruby.append(self.input)
            lastClause.rubyCount += self.convertTargetLength
            // 最初だった場合を想定している
            if (lastClause.mid == 500 && self.data.mid != 500) || DicdataStore.includeMMValueCalculation(self.data) {
                lastClause.mid = self.data.mid
            }
            lastcandidate.clauses[lastcandidate.clauses.count-1].value = self.totalValue
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
        // 文節の区切りだった場合
        else {
            let unit = ClauseDataUnit()
            unit.text = self.data.word
            unit.ruby = self.input
            unit.rubyCount = self.convertTargetLength
            if DicdataStore.includeMMValueCalculation(self.data) {
                unit.mid = self.data.mid
            }
            // 前の文節の処理
            lastClause.nextLcid = self.data.lcid
            lastcandidate.clauses.append((clause: unit, value: self.totalValue))
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
    }
}
