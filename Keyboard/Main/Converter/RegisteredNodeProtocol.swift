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
    var inputRange: Range<Int> {get}
    var convertTargetLength: Int {get}
}

struct RegisteredNode: RegisteredNodeProtocol {
    let data: DicdataElement
    let prev: (any RegisteredNodeProtocol)?
    let totalValue: PValue
    // 入力に対応する文字列
    // ダイレクト入力中であれば「今日は」に対して「キョウハ」
    // ローマ字入力中であれば「今日は」に対してkyouhaになる
    let inputRange: Range<Int>
    var convertTargetLength: Int {
        inputRange.count
    }

    init(data: DicdataElement, registered: RegisteredNode?, totalValue: PValue, inputRange: Range<Int>) {
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.inputRange = inputRange
    }

    static func BOSNode() -> RegisteredNode {
        RegisteredNode(data: DicdataElement.BOSData, registered: nil, totalValue: 0, inputRange: 0 ..< 0)
    }

    static func fromLastCandidate(_ candidate: Candidate) -> RegisteredNode {
        RegisteredNode(
            data: DicdataElement(word: "", ruby: "", lcid: CIDData.BOS.cid , rcid: candidate.data.last?.rcid ?? CIDData.BOS.cid, mid: candidate.lastMid, value: 0),
            registered: nil,
            totalValue: 0,
            inputRange: 0 ..< 0
        )
    }
}


extension RegisteredNodeProtocol {
    func getCandidateData(for composingText: ComposingText) -> CandidateData {
        // TODO: ここが誤り (ルビになっていない)
        let inputString = composingText.input[self.inputRange].reduce(into: "") {$0.append($1.character)}
        guard let prev else {
            let unit = ClauseDataUnit()
            unit.mid = self.data.mid
            // TODO: ここが誤り (ルビになっていない)
            unit.convertTarget = inputString
            unit.convertTargetLength = self.convertTargetLength
            return CandidateData(clauses: [(clause: unit, value: .zero)], data: [])
        }
        var lastcandidate = prev.getCandidateData(for: composingText)    // 自分に至るregisterdそれぞれのデータに処理

        if self.data.word.isEmpty {
            return lastcandidate
        }

        guard let lastClause = lastcandidate.lastClause else {
            return lastcandidate
        }

        if lastClause.text.isEmpty || !DicdataStore.isClause(prev.data.rcid, self.data.lcid) {
            // 文節ではないので、最後に追加する。
            lastClause.text.append(self.data.word)
            // TODO: ここが誤り (ルビになっていない)
            lastClause.convertTarget.append(inputString)
            lastClause.convertTargetLength += self.convertTargetLength
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
            // TODO: ここが誤り (ルビになっていない)
            unit.convertTarget = inputString
            unit.convertTargetLength = self.convertTargetLength
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
