//
//  RegisteredNode.swift
//  Keyboard
//
//  Created by ensan on 2020/09/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

/// `struct`の`RegisteredNode`を再帰的に所持できるようにするため、Existential Typeで抽象化する。
/// - Note: `indirect enum`との比較はまだやっていない。
protocol RegisteredNodeProtocol {
    var data: DicdataElement {get}
    var prev: (any RegisteredNodeProtocol)? {get}
    var totalValue: PValue {get}
    var inputRange: Range<Int> {get}
}

struct RegisteredNode: RegisteredNodeProtocol {
    /// このノードが保持する辞書データ
    let data: DicdataElement
    /// 1つ前のノードのデータ
    let prev: (any RegisteredNodeProtocol)?
    /// 始点からこのノードまでのコスト
    let totalValue: PValue
    /// `composingText`の`input`で対応する範囲
    let inputRange: Range<Int>

    init(data: DicdataElement, registered: RegisteredNode?, totalValue: PValue, inputRange: Range<Int>) {
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.inputRange = inputRange
    }

    /// 始点ノードを生成する関数
    /// - Returns: 始点ノードのデータ
    static func BOSNode() -> RegisteredNode {
        RegisteredNode(data: DicdataElement.BOSData, registered: nil, totalValue: 0, inputRange: 0 ..< 0)
    }

    /// 入力中、確定した部分を考慮した始点ノードを生成する関数
    /// - Returns: 始点ノードのデータ
    static func fromLastCandidate(_ candidate: Candidate) -> RegisteredNode {
        RegisteredNode(
            data: DicdataElement(word: "", ruby: "", lcid: CIDData.BOS.cid, rcid: candidate.data.last?.rcid ?? CIDData.BOS.cid, mid: candidate.lastMid, value: 0),
            registered: nil,
            totalValue: 0,
            inputRange: 0 ..< 0
        )
    }
}

extension RegisteredNodeProtocol {
    /// 再帰的にノードを遡り、`CandidateData`を構築する関数
    /// - Returns: 文節単位の区切り情報を持った変換候補データ
    func getCandidateData() -> CandidateData {
        guard let prev else {
            let unit = ClauseDataUnit()
            unit.mid = self.data.mid
            unit.inputRange = self.inputRange
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
            lastClause.inputRange = lastClause.inputRange.startIndex ..< self.inputRange.endIndex
            // 最初だった場合を想定している
            if (lastClause.mid == 500 && self.data.mid != 500) || DicdataStore.includeMMValueCalculation(self.data) {
                lastClause.mid = self.data.mid
            }
            lastcandidate.clauses[lastcandidate.clauses.count - 1].value = self.totalValue
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
        // 文節の区切りだった場合
        else {
            let unit = ClauseDataUnit()
            unit.text = self.data.word
            unit.inputRange = self.inputRange
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
