//
//  RegisteredNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
protocol RegisteredNodeProtocol {
    var data: LatticeNodeDataProtocol {get}
    var registered: RegisteredNodeProtocol? {get}
    var totalValue: PValue {get}
    var ruby: String {get}
}

struct FlickRegisteredNode: RegisteredNodeProtocol {
    let data: LatticeNodeDataProtocol
    let registered: RegisteredNodeProtocol?
    let totalValue: PValue
    var ruby: String {
        return self.data.ruby
    }

    init(data: LatticeNodeDataProtocol, registered: RegisteredNodeProtocol?, totalValue: PValue) {
        self.data = data
        self.registered = registered
        self.totalValue = totalValue
    }

}

struct RomanRegisteredNode: RegisteredNodeProtocol {
    let data: LatticeNodeDataProtocol
    let registered: RegisteredNodeProtocol?
    let totalValue: PValue
    let ruby: String

    init(data: LatticeNodeDataProtocol, registered: RegisteredNodeProtocol?, totalValue: PValue, romanString: String) {
        self.data = data
        self.registered = registered
        self.totalValue = totalValue
        self.ruby = romanString
    }
}

extension RegisteredNodeProtocol {
    func getCandidateData() -> CandidateData {
        guard let registered = self.registered else {
            let unit = ClauseDataUnit()
            unit.rcid = self.data.rcid
            unit.mid = self.data.mid
            unit.ruby = self.ruby
            return [(clause: unit, value: 0.0)]
        }
        let lastcandidate = registered.getCandidateData()    // 自分に至るregisterdそれぞれのデータに処理

        if self.data.string.isEmpty {
            return lastcandidate
        }
        if lastcandidate.last!.clause.text.isEmpty || !DicDataStore.isClause(registered.data.rcid, self.data.lcid) {
            var candidate = lastcandidate
            let lastindex = candidate.count-1
            // 文節ではないので、最後に追加する。
            let clause = candidate[lastindex].clause    // ClauseDataUnitは参照型であることに留意
            clause.text.append(self.data.string)
            clause.ruby.append(self.ruby)
            clause.rcid = self.data.rcid
            if (clause.mid == 500 && self.data.mid != 500) || DicDataStore.isInposition(self.data) {
                clause.mid = self.data.mid
            }
            candidate[lastindex].value = self.totalValue

            return candidate
        }
        // 文節の区切りだった場合
        else {
            let unit = ClauseDataUnit()
            unit.text = self.data.string
            unit.ruby = self.ruby
            unit.lcid = self.data.lcid
            unit.rcid = self.data.rcid

            if DicDataStore.isInposition(self.data) {
                unit.mid = self.data.mid
            }
            let candidate = lastcandidate
            let clause = candidate[candidate.count-1].clause
            clause.nextLcid = self.data.lcid
            switch Store.shared.keyboardType {
            case .flick:
                break
            case .roman:
                clause.ruby = clause.ruby.roman2katakana
            }
            return candidate + [(clause: unit, value: self.totalValue)]
        }
    }
}
