//
//  getPrediction.swift
//  Keyboard
//
//  Created by ensan on 2020/12/09.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

extension Kana2Kanji {
    /// CandidateDataの状態から予測変換候補を取得する関数
    /// - parameters:
    ///   - prepart: CandidateDataで、予測変換候補に至る前の部分。例えば「これはき」の「き」の部分から予測をする場合「これは」の部分がprepart。
    ///   - lastRuby:
    ///     「これはき」の「き」の部分
    ///   - N_best: 取得する数
    /// - returns:
    ///    「これはき」から「これは今日」に対応する候補などを作って返す。
    /// - note:
    ///     この関数の役割は意味連接の考慮にある。
    func getPredicitonCandidates(composingText: ComposingText, prepart: CandidateData, lastClause: ClauseDataUnit, N_best: Int, mainInputStyle: InputStyle) -> [Candidate] {
        debug("getPredicitonCandidates", composingText, lastClause.inputRange, lastClause.text)
        let lastRuby = ComposingText.getConvertTarget(for: composingText.input[lastClause.inputRange]).toKatakana()
        let lastRubyCount = lastClause.inputRange.count
        let datas: [DicdataElement]
        do {
            var _str = ""
            let prestring: String = prepart.clauses.reduce(into: "") {$0.append(contentsOf: $1.clause.text)}
            var count: Int = .zero
            while true {
                if prestring == _str {
                    break
                }
                _str += prepart.data[count].word
                count += 1
            }
            datas = Array(prepart.data.prefix(count))
        }

        let osuserdict: [DicdataElement] = dicdataStore.getPrefixMatchOSUserDict(lastRuby)

        let lastCandidate: Candidate = prepart.isEmpty ? Candidate(text: "", value: .zero, correspondingCount: 0, lastMid: MIDData.EOS.mid, data: []) : self.processClauseCandidate(prepart)
        let lastRcid: Int = lastCandidate.data.last?.rcid ?? CIDData.EOS.cid
        let nextLcid: Int = prepart.lastClause?.nextLcid ?? CIDData.EOS.cid
        let lastMid: Int = lastCandidate.lastMid
        let correspoindingCount: Int = lastCandidate.correspondingCount + lastRubyCount
        let ignoreCCValue: PValue = self.dicdataStore.getCCValue(lastRcid, nextLcid)

        let dicdata: [DicdataElement]
        switch mainInputStyle {
        case .direct:
            dicdata = self.dicdataStore.getPredictionLOUDSDicdata(key: lastRuby)
        case .roman2kana:
            let roman = lastRuby.suffix(while: {String($0).onlyRomanAlphabet})
            if !roman.isEmpty {
                let ruby: Substring = lastRuby.dropLast(roman.count)
                if ruby.isEmpty {
                    dicdata = []
                    break
                }
                let possibleNexts: [Substring] = DicdataStore.possibleNexts[String(roman), default: []].map {ruby + $0}
                debug("getPredicitonCandidates", lastRuby, ruby, roman, possibleNexts, prepart, lastRubyCount)
                dicdata = possibleNexts.flatMap { self.dicdataStore.getPredictionLOUDSDicdata(key: $0) }
            } else {
                debug("getPredicitonCandidates", lastRuby, roman)
                dicdata = self.dicdataStore.getPredictionLOUDSDicdata(key: lastRuby)
            }
        }

        var result: [Candidate] = []

        result.reserveCapacity(N_best &+ 1)
        for data in (dicdata + osuserdict) {
            let includeMMValueCalculation = DicdataStore.includeMMValueCalculation(data)
            let mmValue: PValue = includeMMValueCalculation ? self.dicdataStore.getMMValue(lastMid, data.mid):.zero
            let ccValue: PValue = self.dicdataStore.getCCValue(lastRcid, data.lcid)
            let penalty: PValue = -PValue(data.ruby.count &- lastRuby.count) * 3.0   // 文字数差をペナルティとする
            let wValue: PValue = data.value()
            let newValue: PValue = lastCandidate.value + mmValue + ccValue + wValue + penalty - ignoreCCValue
            // 追加すべきindexを取得する
            let lastindex: Int = (result.lastIndex(where: {$0.value >= newValue}) ?? -1) + 1
            if lastindex >= N_best {
                continue
            }
            var nodedata: [DicdataElement] = datas
            nodedata.append(data)
            let candidate: Candidate = Candidate(
                text: lastCandidate.text + data.word,
                value: newValue,
                correspondingCount: correspoindingCount,
                lastMid: includeMMValueCalculation ? data.mid:lastMid,
                data: nodedata
            )
            // カウントがオーバーしそうな場合は除去する
            if result.count >= N_best {
                result.removeLast()
            }
            // removeしてからinsertした方が速い (insertはO(N)なので)
            result.insert(candidate, at: lastindex)
        }

        return result
    }
}
