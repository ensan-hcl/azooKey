//
//  Candidate.swift
//  Keyboard
//
//  Created by β α on 2020/10/26.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

// 一文節を担う
final class ClauseDataUnit {
    var mid: Int = MIDData.EOS.mid
    // 次の文節のlcid
    var nextLcid = CIDData.EOS.cid
    var text: String = ""
    var inputRange: Range<Int> = 0 ..< 0

    func merge(with unit: ClauseDataUnit) {
        self.text.append(unit.text)
        self.inputRange = self.inputRange.startIndex ..< unit.inputRange.endIndex
        self.nextLcid = unit.nextLcid
    }
}

#if DEBUG
extension ClauseDataUnit: CustomDebugStringConvertible {
    var debugDescription: String {
        return "ClauseDataUnit(mid: \(mid), nextLcid: \(nextLcid), text: \(text), inputRange: \(inputRange))"
    }
}
#endif

struct CandidateData {
    typealias ClausesUnit = (clause: ClauseDataUnit, value: PValue)
    var clauses: [ClausesUnit]
    var data: [DicdataElement]

    init(clauses: [ClausesUnit], data: [DicdataElement]) {
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

/// 変換候補のデータ
struct Candidate: ResultViewItemData {
    /// 入力となるテキスト
    var text: String
    /// 評価値
    let value: PValue
    /// composingText.inputにおいて対応する文字数。
    var correspondingCount: Int
    /// 最後のmid(予測変換に利用)
    let lastMid: Int
    /// DicdataElement列
    let data: [DicdataElement]
    /// 変換として選択した際に実行する`action`。
    /// - note: 括弧を入力した際にカーソルを移動するために追加した変数
    var actions: [ActionType]
    /// 入力できるものか
    /// - note: 文字数表示のために追加したフラグ
    let inputable: Bool

    init(text: String, value: PValue, correspondingCount: Int, lastMid: Int, data: [DicdataElement], actions: [ActionType] = [], inputable: Bool = true) {
        self.text = text
        self.value = value
        self.correspondingCount = correspondingCount
        self.lastMid = lastMid
        self.data = data
        self.actions = actions
        self.inputable = inputable
    }
    /// 後から`action`を追加した形を生成する関数
    /// - parameters:
    ///  - actions: 実行する`action`
    @inlinable mutating func withActions(_ actions: [ActionType]) {
        self.actions = actions
    }

    private static let dateExpression = "<date format=\".*?\" type=\".*?\" language=\".*?\" delta=\".*?\" deltaunit=\".*?\">"
    private static let randomExpression = "<random type=\".*?\" value=\".*?\">"

    static func parseTemplate(_ text: String) -> String {
        var newText = text
        while let range = newText.range(of: Self.dateExpression, options: .regularExpression) {
            let templateString = String(newText[range])
            let template = DateTemplateLiteral.import(from: templateString)
            let value = template.previewString()
            newText.replaceSubrange(range, with: value)
        }
        while let range = newText.range(of: Self.randomExpression, options: .regularExpression) {
            let templateString = String(newText[range])
            let template = RandomTemplateLiteral.import(from: templateString)
            let value = template.previewString()
            newText.replaceSubrange(range, with: value)
        }
        return newText.unescaped()
    }

    @inlinable mutating func parseTemplate() {
        // ここでCandidate.textとdata.map(\.word).join("")の整合性が壊れることに注意
        // ただし、dataの方を加工するのは望ましい挙動ではない。
        self.text = Self.parseTemplate(text)
    }

    func getDebugInformation() -> String {
        return self.data.debugDescription
    }

    /// 入力を文としたとき、prefixになる文節に対応するCandidateを作る
    static func makePrefixClauseCandidate(data: some Collection<DicdataElement>) -> Candidate {
        var text = ""
        var correspondingCount = 0
        var lastRcid = CIDData.BOS.cid
        var lastMid = 501
        var candidateData: [DicdataElement] = []
        for item in data {
            // 文節だったら
            if DicdataStore.isClause(lastRcid, item.lcid) {
                break
            }
            text.append(item.word)
            correspondingCount += item.ruby.count
            lastRcid = item.rcid
            // 最初だった場合を想定している
            if item.mid != 500 && DicdataStore.includeMMValueCalculation(item) {
                lastMid = item.mid
            }
            candidateData.append(item)
        }
        return Candidate(
            text: text,
            value: -5,
            correspondingCount: correspondingCount,
            lastMid: lastMid,
            data: candidateData
        )
    }

}
