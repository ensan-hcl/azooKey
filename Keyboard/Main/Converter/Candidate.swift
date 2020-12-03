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

/// 変換候補のデータ
struct Candidate{
    ///入力となるテキスト
    let text: String
    ///評価値
    let value: PValue
    ///実際の入力テキスト
    let visibleString: String
    ///右側cid
    let rcid: Int
    ///最後のmid
    let lastMid: Int
    ///DicDataElement列
    let data: [DicDataElementProtocol]
    ///変換として選択した際に実行する`action`。
    /// - note: 括弧を入力した際にカーソルを移動するために追加した変数
    let actions: [ActionType]
    ///入力できるものか
    /// - note: 文字数表示のために追加したフラグ
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
    ///後から`action`を追加した形を生成する関数
    ///- parameters:
    ///  - actions: 実行する`action`
    func withActions(_ actions: [ActionType]) -> Candidate {
        return Candidate(text: text, value: value, visibleString: visibleString, rcid: rcid, lastMid: lastMid, data: data, actions: actions, inputable: inputable)
    }
}
