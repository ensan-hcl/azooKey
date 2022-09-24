//
//  kana2kanji.swift
//  Kana2KajiProject
//
//  Created by β α on 2020/09/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import UIKit
typealias PValue = Float16

struct Kana2Kanji {
    typealias InputData = ComposingText
    let ccBonusUnit = 5
    var dicdataStore = DicdataStore()

    /// CandidateDataの状態からCandidateに変更する関数
    /// - parameters:
    ///   - data: CandidateData
    /// - returns:
    ///    Candidateとなった値を返す。
    /// - note:
    ///     この関数の役割は意味連接の考慮にある。
    func processClauseCandidate(_ data: CandidateData) -> Candidate {
        let mmValue: (value: PValue, mid: Int) = data.clauses.reduce((value: .zero, mid: 500)) { result, data in
            return (
                value: result.value + self.dicdataStore.getMMValue(result.mid, data.clause.mid),
                mid: data.clause.mid
            )
        }
        let text = data.clauses.map {$0.clause.text}.joined()
        let value = data.clauses.last!.value + mmValue.value
        let lastMid = data.clauses.last!.clause.mid
        let correspondingCount = data.clauses.map {$0.clause.convertTargetLength}.reduce(0, +)
        return Candidate(
            text: text,
            value: value,
            correspondingCount: correspondingCount,
            lastMid: lastMid,
            data: data.data
        )
    }

    /// 入力がない状態から、妥当な候補を探す
    /// - parameters:
    ///   - preparts: Candidate列。以前確定した候補など
    ///   - N_best: 取得する候補数
    /// - returns:
    ///   ゼロヒント予測変換の結果
    /// - note:
    ///   「食べちゃ-てる」「食べちゃ-いる」などの間抜けな候補を返すことが多いため、学習によるもの以外を無効化している。
    func getZeroHintPredictionCandidates(preparts: some Collection<Candidate>, N_best: Int) -> [Candidate] {
        // let dicdata = self.dicdataStore.getZeroHintPredictionDicdata()
        var result: [Candidate] = []
        /*
         result.reserveCapacity(N_best + 1)
         preparts.forEach{candidate in
         dicdata.forEach{data in
         let ccValue = self.dicdataStore.getCCValue(candidate.rcid, data.lcid)
         let isInposition = DicdataStore.isInposition(data)
         let mmValue = isInposition ? self.dicdataStore.getMMValue(candidate.lastMid, data.mid):0.0
         let wValue = data.value()
         let newValue = candidate.value + mmValue + ccValue + wValue
         //追加すべきindexを取得する
         let lastindex = (result.lastIndex(where: {$0.value >= newValue}) ?? -1) + 1
         if lastindex >= N_best{
         return
         }
         var nodedata = candidate.data
         nodedata.append(data)

         let candidate = Candidate(text: candidate.text + data.string, value: newValue, correspondingCount: candidate.correspondingCount, rcid: data.rcid, lastMid: isInposition ? data.mid:candidate.lastMid, data: nodedata)
         result.insert(candidate, at: lastindex)
         //カウントがオーバーしている場合は除去する
         if result.count == N_best &+ 1{
         result.removeLast()
         }
         }
         }
         */
        for candidate in preparts {
            if let last = candidate.data.last {
                let nexts = self.dicdataStore.getNextMemory(last)
                for (data, count) in nexts where count > 1 {
                    let ccValue = self.dicdataStore.getCCValue(last.rcid, data.lcid)
                    let includeMMValueCalculation = DicdataStore.includeMMValueCalculation(data)
                    let mmValue = includeMMValueCalculation ? self.dicdataStore.getMMValue(candidate.lastMid, data.mid):.zero
                    let wValue = data.value()
                    let bonus = PValue(count * 1)
                    let newValue = candidate.value + mmValue + ccValue + wValue + bonus
                    var nodedata = candidate.data
                    nodedata.append(data)
                    let candidate = Candidate(
                        text: candidate.text + data.word,
                        value: newValue,
                        correspondingCount: candidate.correspondingCount,
                        lastMid: includeMMValueCalculation ? data.mid:candidate.lastMid,
                        data: nodedata
                    )
                    result.append(candidate)
                }
            }
        }
        return result
    }
}
