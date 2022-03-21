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
    var ruby: String {get}
    var rubyCount: Int {get}

    static func BOSNode() -> Self
}

struct DirectRegisteredNode: RegisteredNodeProtocol {
    let data: DicdataElement
    let prev: (any RegisteredNodeProtocol)?
    let totalValue: PValue
    let rubyCount: Int
    var ruby: String {
        return self.data.ruby
    }

    init(data: DicdataElement, registered: (any RegisteredNodeProtocol)?, totalValue: PValue, rubyCount: Int) {
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.rubyCount = rubyCount
    }

    static func BOSNode() -> DirectRegisteredNode {
        DirectRegisteredNode(data: DicdataElement.BOSData, registered: nil, totalValue: 0, rubyCount: 0)
    }
}

struct RomanRegisteredNode: RegisteredNodeProtocol {
    let data: DicdataElement
    let prev: (any RegisteredNodeProtocol)?
    let totalValue: PValue
    let rubyCount: Int
    let ruby: String

    init(data: DicdataElement, registered: (any RegisteredNodeProtocol)?, totalValue: PValue, rubyCount: Int, romanString: String) {
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.ruby = romanString
        self.rubyCount = rubyCount
    }

    static func BOSNode() -> RomanRegisteredNode {
        RomanRegisteredNode(data: DicdataElement.BOSData, registered: nil, totalValue: 0, rubyCount: 0, romanString: "")
    }
}

extension RegisteredNodeProtocol {
    func getCandidateData() -> CandidateData {
        guard let prev = self.prev else {
            let unit = ClauseDataUnit()
            unit.mid = self.data.mid
            unit.ruby = self.ruby
            unit.rubyCount = self.rubyCount
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
            lastClause.ruby.append(self.ruby)
            lastClause.rubyCount += self.rubyCount
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
            unit.ruby = self.ruby
            unit.rubyCount = self.rubyCount
            if DicdataStore.includeMMValueCalculation(self.data) {
                unit.mid = self.data.mid
            }
            // 前の文節の処理
            lastClause.nextLcid = self.data.lcid
            switch VariableStates.shared.inputStyle {
            case .direct:
                break
            case .roman2kana:
                lastClause.ruby = lastClause.ruby.roman2katakana
            }
            lastcandidate.clauses.append((clause: unit, value: self.totalValue))
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
    }
}
