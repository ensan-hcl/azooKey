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

struct Kana2Kanji<InputData: InputDataProtocol, LatticeNode: LatticeNodeProtocol>{
    let ccBonusUnit = 5
    var dicdataStore = DicDataStore()

    func processClauseCandidate(_ data: CandidateData) -> Candidate {
        let mmValue: (value: PValue, mid: Int) = data.clauses.reduce((value: .zero, mid: 500)){ result, data in
            return (
                value: result.value + self.dicdataStore.getMMValue(result.mid, data.clause.mid),
                mid: data.clause.mid
            )
        }
        let text = data.clauses.map{$0.clause.text}.joined()
        let value = data.clauses.last!.value + mmValue.value
        let visibleString = data.clauses.map{$0.clause.ruby}.joined()
        let rcid = data.clauses.last!.clause.rcid
        let lastMid = data.clauses.last!.clause.mid

        return Candidate(text: text, value: value, visibleString: visibleString, rcid: rcid, lastMid: lastMid, data: data.data)
    }
    
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
            let candidate: Candidate = Candidate(text: lastCandidate.text + data.word, value: newValue, visibleString: visibleString, rcid: data.rcid, lastMid: includeMMValueCalculation ? data.mid:lastMid, data: nodedata)
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

    func getZeroHintPredictionCandidates<T: Collection>(preparts: T, N_best: Int) -> [Candidate] where T.Element == Candidate{
        //let dicdata = self.dicdataStore.getZeroHintPredictionDicData()
        var result: [Candidate] = []
        /*
        result.reserveCapacity(N_best + 1)
        preparts.forEach{candidate in
            dicdata.forEach{data in
                let ccValue = self.dicdataStore.getCCValue(candidate.rcid, data.lcid)
                let isInposition = DicDataStore.isInposition(data)
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

                let candidate = Candidate(text: candidate.text + data.string, value: newValue, visibleString: candidate.visibleString, rcid: data.rcid, lastMid: isInposition ? data.mid:candidate.lastMid, data: nodedata)
                result.insert(candidate, at: lastindex)
                //カウントがオーバーしている場合は除去する
                if result.count == N_best &+ 1{
                    result.removeLast()
                }
            }
        }
         */

        preparts.forEach{candidate in
            if let last = candidate.data.last{
                let nexts = self.dicdataStore.getNextMemory(last)
                nexts.forEach{data, count in
                    if count <= 1{
                        return
                    }
                    let ccValue = self.dicdataStore.getCCValue(candidate.rcid, data.lcid)
                    let includeMMValueCalculation = DicDataStore.includeMMValueCalculation(data)
                    let mmValue = includeMMValueCalculation ? self.dicdataStore.getMMValue(candidate.lastMid, data.mid):.zero
                    let wValue = data.value()
                    let bonus = PValue(count * 1)
                    let newValue = candidate.value + mmValue + ccValue + wValue + bonus
                    var nodedata = candidate.data
                    nodedata.append(data)
                    let candidate = Candidate(text: candidate.text + data.word, value: newValue, visibleString: candidate.visibleString, rcid: data.rcid, lastMid: includeMMValueCalculation ? data.mid:candidate.lastMid, data: nodedata)
                    result.append(candidate)
                }
            }
        }
        return result
    }
}
