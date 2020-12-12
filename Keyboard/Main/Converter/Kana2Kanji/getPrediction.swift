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
    func getPredicitonCandidates(prepart: CandidateData, lastRuby: String, N_best: Int) -> [Candidate] {
        let datas: [DicDataElementProtocol]
        let lastData: DicDataElementProtocol?
        let start_3_1_1 = Date()
        do{
            var _str = ""
            let prestring = prepart.clauses.map{$0.clause.text}.joined()
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
        print("処理3.1.1", -start_3_1_1.timeIntervalSinceNow)
        let start_3_1_2 = Date()

        let memory: [DicDataElementProtocol] = dicdataStore.getPrefixMemory(lastRuby)
        print("処理3.1.2", -start_3_1_2.timeIntervalSinceNow)
        let start_3_1_3 = Date()

        let dicdata: DicDataStore.DicData
        switch Store.shared.keyboardType{
        case .flick:
            dicdata = self.dicdataStore.getPredictionLOUDSDicData(head: lastRuby)
        case .roman:
            let ruby = lastRuby.prefix(while: {!String($0).onlyRomanAlphabet})
            let roman = lastRuby.suffix(lastRuby.count - ruby.count)
            if !roman.isEmpty{
                let ruby = lastRuby.prefix(while: {!String($0).onlyRomanAlphabet})
                let possibleNexts = DicDataStore.possibleNexts[String(roman), default: []].map{ruby + $0}
                let _dicdata = self.dicdataStore.getPredictionLOUDSDicData(head: ruby)
                dicdata = _dicdata.filter{data in !possibleNexts.allSatisfy{!$0.hasPrefix(data.ruby)}}
            }else{
                dicdata = self.dicdataStore.getPredictionLOUDSDicData(head: ruby)
            }
        }

        print("処理3.1.3", -start_3_1_3.timeIntervalSinceNow) //ここが激遅い
        let start_3_1_4 = Date()

        let lastCandidate = prepart.isEmpty ? Candidate(text: "", value: .zero, visibleString: "", rcid: .zero, lastMid: 500, data: []) : self.processClauseCandidate(prepart)
        let nextLcid = prepart.lastClause?.nextLcid ?? 1316
        let lastMid = lastCandidate.lastMid
        let lastRcid = lastCandidate.rcid
        let visibleString = lastCandidate.visibleString + lastRuby
        var ignoreCCValue = self.dicdataStore.getCCValue(lastRcid, nextLcid)

        if lastCandidate.data.count > 1, let lastNext = lastData{
            let lastPrev = lastCandidate.data[lastCandidate.data.endIndex - 2]
            ignoreCCValue += PValue(self.ccBonusUnit*self.dicdataStore.getMatch(lastPrev, next: lastNext))
        }

        print("処理3.1.4", -start_3_1_4.timeIntervalSinceNow)
        let start_3_1_5 = Date()

        var result: [Candidate] = []

        result.reserveCapacity(N_best &+ 1)
        (dicdata+memory).forEach{(data: DicDataElementProtocol) in
            let includeMMValueCalculation = DicDataStore.includeMMValueCalculation(data)
            let mmValue = includeMMValueCalculation ? self.dicdataStore.getMMValue(lastMid, data.mid):.zero
            let ccValue = self.dicdataStore.getCCValue(lastRcid, data.lcid)
            let penalty = -PValue(data.ruby.count &- lastRuby.count)    //文字数差をペナルティとする
            let wValue = data.value()
            let newValue: PValue = lastCandidate.value + mmValue + ccValue + wValue + penalty - ignoreCCValue
            //追加すべきindexを取得する
            let lastindex = (result.lastIndex(where: {$0.value >= newValue}) ?? -1) + 1
            if lastindex >= N_best{
                return
            }
            var nodedata = datas
            nodedata.append(data)
            let candidate: Candidate = Candidate(
                text: lastCandidate.text + data.word,
                value: newValue,
                visibleString: visibleString,
                rcid: data.rcid,
                lastMid: includeMMValueCalculation ? data.mid:lastMid,
                data: nodedata
            )
            result.insert(candidate, at: lastindex)
            //カウントがオーバーしている場合は除去する
            if result.count == N_best &+ 1{
                result.removeLast()
            }
        }
        print("処理3.1.5", -start_3_1_5.timeIntervalSinceNow)
        print("処理3.1全体", -start_3_1_1.timeIntervalSinceNow)

        return result
    }
}
