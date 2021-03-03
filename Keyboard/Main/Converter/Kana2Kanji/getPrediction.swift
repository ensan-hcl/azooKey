//
//  getPrediction.swift
//  Keyboard
//
//  Created by β α on 2020/12/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension Kana2Kanji{
    ///CandidateDataの状態から予測変換候補を取得する関数
    /// - parameters:
    ///   - prepart: CandidateDataで、予測変換候補に至る前の部分。例えば「これはき」の「き」の部分から予測をする場合「これは」の部分がprepart。
    ///   - lastRuby:
    ///     「これはき」の「き」の部分
    ///   - N_best: 取得する数
    /// - returns:
    ///    「これはき」から「これは今日」に対応する候補などを作って返す。
    /// - note:
    ///     この関数の役割は意味連接の考慮にある。
    func getPredicitonCandidates(prepart: CandidateData, lastRuby: String, lastRubyCount: Int, N_best: Int) -> [Candidate] {
        let datas: [DicDataElementProtocol]
        let lastData: DicDataElementProtocol?
        conversionBenchmark.start(process: .結果の処理_予測変換_日本語_雑多なデータ取得)
        do{
            var _str = ""
            let prestring: String = prepart.clauses.map{$0.clause.text}.joined()
            var count: Int = .zero
            while true{
                if prestring == _str{
                    break
                }
                _str += prepart.data[count].word
                count += 1
            }
            lastData = prepart.data.count > count ? prepart.data[count] : nil
            datas = Array(prepart.data.prefix(count))
        }

        let memory: [DicDataElementProtocol] = dicdataStore.getPrefixMemory(lastRuby)
        let osuserdict: [DicDataElementProtocol] = dicdataStore.getPrefixMatchOSUserDict(lastRuby)

        let lastCandidate: Candidate = prepart.isEmpty ? Candidate(text: "", value: .zero, correspondingCount: 0, lastMid: 500, data: []) : self.processClauseCandidate(prepart)
        let lastRcid: Int = lastCandidate.data.last?.rcid ?? 1316
        let nextLcid: Int = prepart.lastClause?.nextLcid ?? 1316
        let lastMid: Int = lastCandidate.lastMid
        let correspoindingCount: Int = lastCandidate.correspondingCount + lastRubyCount
        var ignoreCCValue: PValue = self.dicdataStore.getCCValue(lastRcid, nextLcid)

        if lastCandidate.data.count > 1, let lastNext = lastData{
            let lastPrev: DicDataElementProtocol = lastCandidate.data[lastCandidate.data.endIndex - 2]
            ignoreCCValue += PValue(self.ccBonusUnit*self.dicdataStore.getMatch(lastPrev, next: lastNext))
        }
        conversionBenchmark.end(process: .結果の処理_予測変換_日本語_雑多なデータ取得)

        conversionBenchmark.start(process: .結果の処理_予測変換_日本語_Dicdataの読み込み)
        let dicdata: DicDataStore.DicData
        switch VariableStates.shared.inputStyle{
        case .direct:
            dicdata = self.dicdataStore.getPredictionLOUDSDicData(head: lastRuby)
        case .roman:
            let ruby: Substring = lastRuby.prefix(while: {!String($0).onlyRomanAlphabet})
            let roman: Substring = lastRuby.suffix(lastRuby.count - ruby.count)
            if !roman.isEmpty{
                let ruby: Substring = lastRuby.prefix(while: {!String($0).onlyRomanAlphabet})
                let possibleNexts: [Substring] = DicDataStore.possibleNexts[String(roman), default: []].map{ruby + $0}
                let _dicdata: DicDataStore.DicData = self.dicdataStore.getPredictionLOUDSDicData(head: ruby)
                dicdata = _dicdata.filter{data in !possibleNexts.allSatisfy{!$0.hasPrefix(data.ruby)}}
            }else{
                dicdata = self.dicdataStore.getPredictionLOUDSDicData(head: ruby)
            }
        }
        conversionBenchmark.end(process: .結果の処理_予測変換_日本語_Dicdataの読み込み)
        conversionBenchmark.start(process: .結果の処理_予測変換_日本語_連接計算)
        var result: [Candidate] = []

        result.reserveCapacity(N_best &+ 1)
        (dicdata + memory + osuserdict).forEach{(data: DicDataElementProtocol) in
            let includeMMValueCalculation = DicDataStore.includeMMValueCalculation(data)
            let mmValue: PValue = includeMMValueCalculation ? self.dicdataStore.getMMValue(lastMid, data.mid):.zero
            let ccValue: PValue = self.dicdataStore.getCCValue(lastRcid, data.lcid)
            let penalty: PValue = -PValue(data.ruby.count &- lastRuby.count)    //文字数差をペナルティとする
            let wValue: PValue = data.value()
            let newValue: PValue = lastCandidate.value + mmValue + ccValue + wValue + penalty - ignoreCCValue
            //追加すべきindexを取得する
            let lastindex: Int = (result.lastIndex(where: {$0.value >= newValue}) ?? -1) + 1
            if lastindex >= N_best{
                return
            }
            var nodedata: [DicDataElementProtocol] = datas
            nodedata.append(data)
            let candidate: Candidate = Candidate(
                text: lastCandidate.text + data.word,
                value: newValue,
                correspondingCount: correspoindingCount,
                lastMid: includeMMValueCalculation ? data.mid:lastMid,
                data: nodedata
            )
            result.insert(candidate, at: lastindex)
            //カウントがオーバーしている場合は除去する
            if result.count == N_best &+ 1{
                result.removeLast()
            }
        }
        conversionBenchmark.end(process: .結果の処理_予測変換_日本語_連接計算)
        return result
    }
}
