//
//  Converter.swift
//  Kana2KajiProject
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import UIKit

///かな漢字変換の管理を受け持つクラス
final class KanaKanjiConverter<InputData: InputDataProtocol, LatticeNode: LatticeNodeProtocol>{
    private var converter = Kana2Kanji<InputData, LatticeNode>()
    private var checker = UITextChecker()

    //前回の変換や確定の情報を取っておく部分。
    private var previousInputData: InputData? = nil
    private var nodes: [[LatticeNode]] = []
    private var completedData: Candidate? = nil
    private var lastData: DicDataElementProtocol? = nil

    ///リセットする関数
    func clear(){
        self.previousInputData = nil
        self.nodes = []
        self.completedData = nil
        self.lastData = nil
    }

    ///上流の関数から`dicdataStore`で行うべき操作を伝播する関数。
    /// - Parameters:
    ///   - data: 行うべき操作。
    func sendToDicDataStore(_ data: Store.DicDataStoreNotification){
        self.converter.dicdataStore.sendToDicDataStore(data)
    }
    ///確定操作後、内部状態のキャッシュを変更する関数。
    /// - Parameters:
    ///   - candidate: 確定された候補。
    func setCompletedData(_ candidate: Candidate){
        self.completedData = candidate
    }

    ///確定操作後、学習メモリをアップデートする関数。
    /// - Parameters:
    ///   - candidate: 確定された候補。
    func updateLearningData(_ candidate: Candidate){
        self.converter.dicdataStore.updateLearningData(candidate, with: self.lastData)
        self.lastData = candidate.data.last
    }

    ///賢い変換候補を生成する関数。
    /// - Parameters:
    ///   - string: 入力されたString
    /// - Returns:
    ///   `賢い変換候補
    private func getWiseCandidate(_ inputData: InputData) -> [Candidate] {
        var result = [Candidate]()
        if Store.shared.userSetting.westerJapaneseCalenderSetting{
            result.append(contentsOf: self.toWareki(inputData))
            result.append(contentsOf: self.toSeireki(inputData))
        }
        if Store.shared.userSetting.typographyLettersSetting{
            result.append(contentsOf: self.typographicalCandidates(inputData))
        }
        if Store.shared.userSetting.unicodeCandidateSetting{
            result.append(contentsOf: self.unicode(inputData))
        }
        return result
    }

    ///変換候補の重複を除去する関数。
    /// - Parameters:
    ///   - candidates: uniqueを実行する候補列。
    /// - Returns:
    ///   `candidates`から重複を削除したもの。
    private func getUniqueCandidate(_ candidates: [Candidate]) -> [Candidate] {
        var result = [Candidate]()
        candidates.forEach{(candidate: Candidate) in
            if candidate.text.isEmpty{
                return
            }
            if let index = result.firstIndex(where: {$0.text == candidate.text}){
                if result[index].value < candidate.value{
                    result[index] = candidate
                }
            }else{
                result.append(candidate)
            }
        }
        return result
    }
    ///外国語への予測変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のデータ。
    ///   - language: 言語コード。現在は`en-US`のみ対応している。
    /// - Returns:
    ///   予測変換候補
    private func getForeignPredictionCandidate(inputData: InputData, language: String, penalty: PValue = -5) -> [Candidate] {
        switch language{
        case "en-US":
            var result: [Candidate] = []
            let ruby = String(inputData.characters)
            let range = NSMakeRange(0, ruby.utf16.count)
            if !ruby.onlyRomanAlphabet{
                return result
            }
            if let completions = checker.completions(forPartialWordRange: range, in: ruby, language: language){
                if !completions.isEmpty{
                    let data = [LRE_SRE_DicDataElement(ruby: ruby, cid: 1288, mid: 501, value: penalty)]
                    let candidate: Candidate = Candidate(
                        text: ruby,
                        value: penalty,
                        correspondingCount: inputData.characters.count,
                        rcid: 1288,
                        lastMid: 501,
                        data: data
                    )
                    result.append(candidate)
                }
                var value: PValue = -5 + penalty
                let delta: PValue = -10/PValue(completions.count)
                completions.forEach{word in
                    let data = [LRE_SRE_DicDataElement(ruby: word, cid: 1288, mid: 501, value: value)]
                    let candidate: Candidate = Candidate(
                        text: word,
                        value: value,
                        correspondingCount: inputData.characters.count,
                        rcid: 1288,
                        lastMid: 501,
                        data: data)
                    result.append(candidate)
                    value += delta
                }
            }
            return result
        default:
            return []
        }
    }

    ///予測変換候補を生成する関数
    /// - Parameters:
    ///   - sums: 変換対象のデータ。
    /// - Returns:
    ///   予測変換候補
    private func getPredictionCandidate(_ sums: [(CandidateData, Candidate)]) -> [Candidate] {
        //予測変換は次の方針で行う。
        //prepart: 前半文節 lastPart: 最終文節とする。
        var candidates: [Candidate] = []
        var prepart: CandidateData = sums.max{$0.1.value < $1.1.value}!.0
        var lastpart: CandidateData.ClausesUnit? = nil
        var count = 0
        while true{
            if count == 2{
                break
            }
            if prepart.isEmpty{
                break
            }
            if let oldlastPart = lastpart{
                let lastUnit = prepart.clauses.popLast()!   //prepartをmutatingでlastを取る。
                let newUnit = lastUnit.clause               //新しいlastpartとなる部分。
                newUnit.merge(with: oldlastPart.clause)     //マージする。
                let newValue = lastUnit.value + oldlastPart.value
                let newlastPart: CandidateData.ClausesUnit = (clause: newUnit, value: newValue)
                let predictions = converter.getPredicitonCandidates(prepart: prepart, lastRuby: newlastPart.clause.ruby, lastRubyCount: newlastPart.clause.rubyCount, N_best: 5)
                candidates += predictions
                lastpart = newlastPart
                if !predictions.isEmpty{
                    count += 1
                }
            }else{
                let lastRuby = prepart.lastClause!.ruby
                let lastRubyCount = prepart.lastClause!.rubyCount
                lastpart = prepart.clauses.popLast()
                let predictions = converter.getPredicitonCandidates(prepart: prepart, lastRuby: lastRuby, lastRubyCount: lastRubyCount, N_best: 5)
                candidates += predictions
                if !predictions.isEmpty{
                    count += 1
                }
            }
        }
        return candidates
    }

    ///トップレベルに追加する付加的な変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    /// - Returns:
    ///   付加的な変換候補
    private func getTopLevelAdditionalCandidate(_ inputData: InputData) -> [Candidate] {
        var candidates: [Candidate] = []

        switch Store.shared.keyboardType{
        case .flick: break
        case .roman:
            candidates.append(contentsOf: self.getForeignPredictionCandidate(inputData: inputData, language: "en-US", penalty: -10))
        }
        return candidates
    }
    ///付加的な変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    /// - Returns:
    ///   付加的な変換候補
    private func getAdditionalCandidate(_ inputData: InputData) -> [Candidate] {
        var candidates: [Candidate] = []
        let string = inputData.katakanaString
        do{
            let data = LRE_SRE_DicDataElement(ruby: string, cid: 1288, mid: 501, value: -14)
            //カタカナ
            let katakana = Candidate(
                text: string,
                value: -14,
                correspondingCount: inputData.characters.count,
                rcid: 1288,
                lastMid: 501,
                data: [data]
            )
            candidates.append(katakana)
        }
        let hiraganaString = string.applyingTransform(.hiraganaToKatakana, reverse: true)!
        do{
            let data = LRE_DicDataElement(word: hiraganaString, ruby: string, cid: 1288, mid: 501, value: -14.5)

            let hiragana = Candidate(
                text: hiraganaString,
                value: -14.5,
                correspondingCount: inputData.characters.count,
                rcid: 1288,
                lastMid: 501,
                data: [data]
            )
            candidates.append(hiragana)
        }
        if Store.shared.userSetting.halfWidthKatakanaSetting{
            let string = string.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? ""
            let data = LRE_DicDataElement(word: string, ruby: string, cid: 1288, mid: 501, value: -15)
            let halfWidthKatakana = Candidate(
                text: string,
                value: -15,
                correspondingCount: inputData.characters.count,
                rcid: 1288,
                lastMid: 501,
                data: [data]
            )
            candidates.append(halfWidthKatakana)
        }

        return candidates
    }

    ///ラティスを処理し変換候補の形にまとめる関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - result: convertToLatticeによって得られた結果。
    ///   - requirePrediction: 予測変換を必要とするか否か。
    ///   - requireEnglishPrediction: 英語の予測変換を必要とするか否か。
    /// - Returns:
    ///   重複のない変換候補。
    private func processResult(inputData: InputData, result: (result: LatticeNode, nodes: [[LatticeNode]]), requirePrediction: Bool, requireEnglishPrediction: Bool) -> [Candidate] {
        self.previousInputData = inputData
        self.nodes = result.nodes
        let start1 = Date()
        let clauseResult = result.result.getCandidateData()
        if clauseResult.isEmpty{
            return self.getUniqueCandidate(self.getAdditionalCandidate(inputData))   //アーリーリターン
        }
        let clauseCandidates: [Candidate] = clauseResult.map{(candidateData: CandidateData) -> Candidate in
            let first = candidateData.clauses.first!
            var count = 0
            do{
                var str = ""
                while true{
                    str += candidateData.data[count].word
                    if str == first.clause.text{
                        break
                    }
                    count += 1
                }
            }
            return Candidate(
                text: first.clause.text,
                value:first.value,
                correspondingCount: first.clause.rubyCount,
                rcid: first.clause.rcid,
                lastMid: first.clause.mid,
                data: Array(candidateData.data[0...count])
            )
        }
        print("処理1:", -start1.timeIntervalSinceNow)
        let start2 = Date()
        let sums: [(CandidateData, Candidate)] = clauseResult.map{($0, converter.processClauseCandidate($0))}
        //文章全体を変換した場合の候補上位五件
        let sentence_candidates = self.getUniqueCandidate(sums.map{$0.1}).sorted{$0.value>$1.value}.prefix(5)
        print("処理2:", -start2.timeIntervalSinceNow)
        let start3 = Date()

        //予測変換
        let prediction_candidates: [Candidate] = requirePrediction ? self.getUniqueCandidate(self.getPredictionCandidate(sums)) : []
        print("処理3.1:", -start3.timeIntervalSinceNow)
        let start3_2 = Date()

        //英単語の予測変換。appleのapiを使うため、処理が異なる。
        let english_candidates: [Candidate] = requireEnglishPrediction ? self.getForeignPredictionCandidate(inputData: inputData, language: "en-US") : []
        print("処理3.2:", -start3_2.timeIntervalSinceNow)
        let start3_3 = Date()

        //ゼロヒント予測変換
        let best10 = getUniqueCandidate(sentence_candidates + prediction_candidates).sorted{$0.value > $1.value}.prefix(10)
        let zeroHintPrediction_candidates = converter.getZeroHintPredictionCandidates(preparts: best10, N_best: 3)
        print("処理3.3:", -start3_3.timeIntervalSinceNow)

        print("処理3全体:", -start3.timeIntervalSinceNow)
        let start4 = Date()


        let toplevel_additional_candidate = self.getTopLevelAdditionalCandidate(inputData)
        //文全体を変換するパターン
        let full_candidate = getUniqueCandidate(best10 + english_candidates + (zeroHintPrediction_candidates + toplevel_additional_candidate)).sorted{$0.value>$1.value}.prefix(5)
        //重複のない変換候補を作成するための集合
        var seenCandidate: Set<String> = Set(full_candidate.map{$0.text})
        print("処理4:", -start4.timeIntervalSinceNow)
        let start5 = Date()

        //文節のみ変換するパターン
        let clause_candidates = self.getUniqueCandidate(clauseCandidates.filter{!seenCandidate.contains($0.text)}).sorted{$0.value>$1.value}.prefix(5)
        seenCandidate.formUnion(clause_candidates.map{$0.text})
        //賢く変換するパターン
        let wise_candidates: [Candidate] = self.getWiseCandidate(inputData)
        seenCandidate.formUnion(wise_candidates.map{$0.text})

        //最初の辞書データ
        let dicCandidates: [Candidate] = result.nodes[0]
            .filter{!($0.data is GeneratedDicDataElement)}
            .map{
                Candidate(
                    text: $0.data.word,
                    value: $0.data.value(),
                    correspondingCount: $0.rubyCount,
                    rcid: $0.data.rcid,
                    lastMid: $0.data.mid,
                    data: [$0.data]
                )
        }
        print("処理5:", -start5.timeIntervalSinceNow)
        let start6 = Date()

        //追加する部分
        let additionalCandidates: [Candidate] = self.getAdditionalCandidate(inputData)

        /*
         文字列の長さごとに並べ、かつその中で評価の高いものから順に並べる。
         */
        let word_candidates: [Candidate] = self.getUniqueCandidate((dicCandidates+additionalCandidates).filter{!seenCandidate.contains($0.text)}).sorted{
            let count0 = $0.correspondingCount
            let count1 = $1.correspondingCount
            return count0 == count1 ? $0.value>$1.value : count0 > count1
        }

        var result = Array(full_candidate)
        result.append(contentsOf: clause_candidates)
        result.append(contentsOf: wise_candidates)
        result.append(contentsOf: word_candidates)
        print("処理6:", -start6.timeIntervalSinceNow)

        return result
    }

    ///入力からラティスを構築する関数。状況に応じて呼ぶ関数を分ける。
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - N_best: 計算途中で保存する候補数。実際に得られる候補数とは異なる。
    /// - Returns:
    ///   結果のラティスノードと、計算済みノードの全体
    private func convertToLattice(_ inputData: InputData, N_best: Int) -> (result: LatticeNode, nodes: [[LatticeNode]])? {
        if inputData.characters.isEmpty{
            return nil
        }

        guard let previousInputData = self.previousInputData else{
            print("新規計算用の関数を呼びますA")
            let result = converter.kana2lattice_all(inputData, N_best: N_best)
            self.previousInputData = inputData
            return result
        }

        //文節確定の後の場合
        if let lastClause = self.completedData, let _ = inputData.isAfterDeletedPrefixCharacter(previous: previousInputData){
            print("文節確定用の関数を呼びます")
            let result = converter.kana2lattice_afterComplete(inputData, completedData: lastClause, N_best: N_best, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            self.completedData = nil
            return result
        }

        //一文字消した場合
        if let deletedCount = inputData.isAfterDeletedCharacter(previous: previousInputData){
            print("最後尾削除用の関数を呼びます, 消した文字数は\(deletedCount)")
            let result = converter.kana2lattice_deletedLast(deletedCount: deletedCount, N_best: N_best, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        //一文字変わった場合
        if let counts = inputData.isAfterReplacedCharacter(previous: previousInputData){
            print("最後尾文字置換用の関数を呼びますA")
            let result = converter.kana2lattice_changed(inputData, N_best: N_best, counts: counts, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        //1文字増やした場合
        if let addedCount = inputData.isAfterAddedCharacter(previous: previousInputData){
            print("最後尾追加用の関数を呼びます")
            let result = converter.kana2lattice_added(inputData, N_best: N_best, addedCount: addedCount,  previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        //一文字増やしていない場合
        if true{
            print("新規計算用の関数を呼びますB")
            let result = converter.kana2lattice_all(inputData, N_best: N_best)
            self.previousInputData = inputData
            return result
        }
    }

    func getApporopriateActions(_ candidate: Candidate) -> [ActionType] {
        if ["[]","()","（）","「」","『』","【】","{}","<>","《》"].contains(candidate.text){
            return [.moveCursor(-1)]
        }
        return []

    }
    
    ///外部から呼ばれる変換候補を要求する関数。
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - N_best: 計算途中で保存する候補数。実際に得られる候補数とは異なる。
    ///   - requirePrediction: 予測変換を必要とするか否か。-
    ///   - requireEnglishPrediction: 英語の予測変換を必要とするか否か。
    /// - Returns:
    ///   重複のない変換候補。
    func requestCandidates(_ inputData: InputData, N_best: Int, requirePrediction: Bool = true, requireEnglishPrediction: Bool = true) -> [Candidate] {
        print("入力は", inputData.characters)
        //stringが無の場合
        if inputData.characters.isEmpty{
            return []
        }
        let start1 = Date()

        guard let result = self.convertToLattice(inputData, N_best: N_best) else{
            return []
        }

        print("ラティス構築", -start1.timeIntervalSinceNow)
        let start2 = Date()
        let candidates = self.processResult(inputData: inputData, result: result, requirePrediction: requirePrediction, requireEnglishPrediction: requireEnglishPrediction)
        print("ラティス処理", -start2.timeIntervalSinceNow)

        let results = candidates.map{
            $0.withActions(self.getApporopriateActions($0))
        }
        print("全体", -start1.timeIntervalSinceNow)

        return results
    }
}
