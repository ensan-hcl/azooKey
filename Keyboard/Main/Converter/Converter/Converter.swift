//
//  Converter.swift
//  Kana2KajiProject
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import UIKit

/// かな漢字変換の管理を受け持つクラス
final class KanaKanjiConverter {
    typealias InputData = ComposingText
    private var converter = Kana2Kanji<InputData>()
    private var checker = UITextChecker()

    // 前回の変換や確定の情報を取っておく部分。
    private var previousInputData: InputData?
    private var nodes: [[LatticeNode]] = []
    private var completedData: Candidate?
    private var lastData: DicdataElement?

    /// リセットする関数
    func clear() {
        self.previousInputData = nil
        self.nodes = []
        self.completedData = nil
        self.lastData = nil
    }

    /// 上流の関数から`dicdataStore`で行うべき操作を伝播する関数。
    /// - Parameters:
    ///   - data: 行うべき操作。
    func sendToDicdataStore(_ data: KeyboardActionDepartment.DicdataStoreNotification) {
        self.converter.dicdataStore.sendToDicdataStore(data)
    }
    /// 確定操作後、内部状態のキャッシュを変更する関数。
    /// - Parameters:
    ///   - candidate: 確定された候補。
    func setCompletedData(_ candidate: Candidate) {
        self.completedData = candidate
    }

    /// 確定操作後、学習メモリをアップデートする関数。
    /// - Parameters:
    ///   - candidate: 確定された候補。
    func updateLearningData(_ candidate: Candidate) {
        self.converter.dicdataStore.updateLearningData(candidate, with: self.lastData)
        self.lastData = candidate.data.last
    }

    /// 賢い変換候補を生成する関数。
    /// - Parameters:
    ///   - string: 入力されたString
    /// - Returns:
    ///   `賢い変換候補
    private func getWiseCandidate(_ inputData: InputData) -> [Candidate] {
        var result = [Candidate]()
        @KeyboardSetting(.westernJapaneseCalender) var westernJapaneseCalender
        if westernJapaneseCalender {
            result.append(contentsOf: self.toWareki(inputData))
            result.append(contentsOf: self.toSeirekiCandidates(inputData))
        }
        @KeyboardSetting(.typographyLetter) var typographyLetter
        if typographyLetter {
            result.append(contentsOf: self.typographicalCandidates(inputData))
        }
        @KeyboardSetting(.unicodeCandidate) var unicodeCandidate
        if unicodeCandidate {
            result.append(contentsOf: self.unicode(inputData))
        }
        result.append(contentsOf: self.toVersionCandidate(inputData))
        return result
    }

    /// 変換候補の重複を除去する関数。
    /// - Parameters:
    ///   - candidates: uniqueを実行する候補列。
    /// - Returns:
    ///   `candidates`から重複を削除したもの。
    private func getUniqueCandidate(_ candidates: [Candidate]) -> [Candidate] {
        var result = [Candidate]()
        for candidate in candidates where !candidate.text.isEmpty {
            if let index = result.firstIndex(where: {$0.text == candidate.text}) {
                if result[index].value < candidate.value {
                    result[index] = candidate
                }
            } else {
                result.append(candidate)
            }
        }
        return result
    }
    /// 外国語への予測変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のデータ。
    ///   - language: 言語コード。現在は`en-US`と`el(ギリシャ語)`のみ対応している。
    /// - Returns:
    ///   予測変換候補
    private func getForeignPredictionCandidate(inputData: InputData, language: String, penalty: PValue = -5) -> [Candidate] {
        switch language {
        case "en-US":
            var result: [Candidate] = []
            let ruby = String(inputData.characters)
            let range = NSRange(location: 0, length: ruby.utf16.count)
            if !ruby.onlyRomanAlphabet {
                return result
            }
            if let completions = checker.completions(forPartialWordRange: range, in: ruby, language: language) {
                if !completions.isEmpty {
                    let data = [DicdataElement(ruby: ruby, cid: CIDData.固有名詞.cid, mid: 501, value: penalty)]
                    let candidate: Candidate = Candidate(
                        text: ruby,
                        value: penalty,
                        correspondingCount: inputData.characters.count,
                        lastMid: 501,
                        data: data
                    )
                    result.append(candidate)
                }
                var value: PValue = -5 + penalty
                let delta: PValue = -10/PValue(completions.count)
                for word in completions {
                    let data = [DicdataElement(ruby: word, cid: CIDData.固有名詞.cid, mid: 501, value: value)]
                    let candidate: Candidate = Candidate(
                        text: word,
                        value: value,
                        correspondingCount: inputData.characters.count,
                        lastMid: 501,
                        data: data
                    )
                    result.append(candidate)
                    value += delta
                }
            }
            return result
        case "el":
            var result: [Candidate] = []
            let ruby = String(inputData.characters)
            let range = NSRange(location: 0, length: ruby.utf16.count)
            if let completions = checker.completions(forPartialWordRange: range, in: ruby, language: language) {
                if !completions.isEmpty {
                    let data = [DicdataElement(ruby: ruby, cid: CIDData.固有名詞.cid, mid: 501, value: penalty)]
                    let candidate: Candidate = Candidate(
                        text: ruby,
                        value: penalty,
                        correspondingCount: inputData.characters.count,
                        lastMid: 501,
                        data: data
                    )
                    result.append(candidate)
                }
                var value: PValue = -5 + penalty
                let delta: PValue = -10/PValue(completions.count)
                for word in completions {
                    let data = [DicdataElement(ruby: word, cid: CIDData.固有名詞.cid, mid: 501, value: value)]
                    let candidate: Candidate = Candidate(
                        text: word,
                        value: value,
                        correspondingCount: inputData.characters.count,
                        lastMid: 501,
                        data: data
                    )
                    result.append(candidate)
                    value += delta
                }
            }
            return result
        default:
            return []
        }
    }

    /// 予測変換候補を生成する関数
    /// - Parameters:
    ///   - sums: 変換対象のデータ。
    /// - Returns:
    ///   予測変換候補
    private func getPredictionCandidate(_ sums: [(CandidateData, Candidate)]) -> [Candidate] {
        // 予測変換は次の方針で行う。
        // prepart: 前半文節 lastPart: 最終文節とする。
        var candidates: [Candidate] = []
        var prepart: CandidateData = sums.max {$0.1.value < $1.1.value}!.0
        var lastpart: CandidateData.ClausesUnit?
        var count = 0
        while true {
            if count == 2 {
                break
            }
            if prepart.isEmpty {
                break
            }
            if let oldlastPart = lastpart {
                let lastUnit = prepart.clauses.popLast()!   // prepartをmutatingでlastを取る。
                let newUnit = lastUnit.clause               // 新しいlastpartとなる部分。
                newUnit.merge(with: oldlastPart.clause)     // マージする。
                let newValue = lastUnit.value + oldlastPart.value
                let newlastPart: CandidateData.ClausesUnit = (clause: newUnit, value: newValue)
                let predictions = converter.getPredicitonCandidates(prepart: prepart, lastRuby: newlastPart.clause.ruby, lastRubyCount: newlastPart.clause.rubyCount, N_best: 5)
                candidates += predictions
                lastpart = newlastPart
                if !predictions.isEmpty {
                    count += 1
                }
            } else {
                let lastRuby = prepart.lastClause!.ruby
                let lastRubyCount = prepart.lastClause!.rubyCount
                lastpart = prepart.clauses.popLast()
                let predictions = converter.getPredicitonCandidates(prepart: prepart, lastRuby: lastRuby, lastRubyCount: lastRubyCount, N_best: 5)
                candidates += predictions
                if !predictions.isEmpty {
                    count += 1
                }
            }
        }
        return candidates
    }

    /// トップレベルに追加する付加的な変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    /// - Returns:
    ///   付加的な変換候補
    private func getTopLevelAdditionalCandidate(_ inputData: InputData) -> [Candidate] {
        @KeyboardSetting(.englishCandidate) var englishCandidate
        var candidates: [Candidate] = []
        if englishCandidate {
            switch VariableStates.shared.inputStyle {
            case .direct: break
            case .roman2kana:
                candidates.append(contentsOf: self.getForeignPredictionCandidate(inputData: inputData, language: "en-US", penalty: -10))
            }
        }
        return candidates
    }
    /// 部分がカタカナである可能性を調べる
    /// 小さいほどよい。
    private func getKatakanaScore<S: StringProtocol>(_ katakana: __shared S) -> PValue {
        var score: PValue = 1
        // テキスト分析によってこれらのカタカナが入っている場合カタカナ語である可能性が高いと分かった。
        for c in katakana {
            if "プヴペィフ".contains(c) {
                score *= 0.5
            } else if "ュピポ".contains(c) {
                score *= 0.6
            } else if "パォグーム".contains(c) {
                score *= 0.7
            }
        }
        return score
    }

    /// 付加的な変換候補を生成する関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    /// - Returns:
    ///   付加的な変換候補
    private func getAdditionalCandidate(_ inputData: InputData) -> [Candidate] {
        var candidates: [Candidate] = []
        let string = inputData.katakanaString
        do {
            // カタカナ
            let value = -14 * getKatakanaScore(string)
            let data = DicdataElement(ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: value)
            let katakana = Candidate(
                text: string,
                value: value,
                correspondingCount: inputData.characters.count,
                lastMid: 501,
                data: [data]
            )
            candidates.append(katakana)
        }
        let hiraganaString = string.toHiragana()
        do {
            // ひらがな
            let data = DicdataElement(word: hiraganaString, ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: -14.5)

            let hiragana = Candidate(
                text: hiraganaString,
                value: -14.5,
                correspondingCount: inputData.characters.count,
                lastMid: 501,
                data: [data]
            )
            candidates.append(hiragana)
        }
        do {
            // 大文字
            let word = string.uppercased()
            let data = DicdataElement(word: word, ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: -15)
            let uppercasedLetter = Candidate(
                text: word,
                value: -14.6,
                correspondingCount: inputData.characters.count,
                lastMid: 501,
                data: [data]
            )
            candidates.append(uppercasedLetter)
        }
        @KeyboardSetting(.fullRomanCandidate) var fullRomanCandidate
        if fullRomanCandidate {
            // 全角英数字
            let word = string.applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? ""
            let data = DicdataElement(word: word, ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: -15)
            let fullWidthLetter = Candidate(
                text: word,
                value: -14.7,
                correspondingCount: inputData.characters.count,
                lastMid: 501,
                data: [data]
            )
            candidates.append(fullWidthLetter)
        }
        @KeyboardSetting(.halfKanaCandidate) var halfKanaCandidate
        if halfKanaCandidate {
            // 半角カタカナ
            let word = string.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? ""
            let data = DicdataElement(word: word, ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: -15)
            let halfWidthKatakana = Candidate(
                text: word,
                value: -15,
                correspondingCount: inputData.characters.count,
                lastMid: 501,
                data: [data]
            )
            candidates.append(halfWidthKatakana)
        }

        return candidates
    }

    /// ラティスを処理し変換候補の形にまとめる関数
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - result: convertToLatticeによって得られた結果。
    ///   - requirePrediction: 予測変換を必要とするか否か。
    ///   - requireEnglishPrediction: 英語の予測変換を必要とするか否か。
    /// - Returns:
    ///   重複のない変換候補。
    private func processResult(inputData: InputData, result: (result: LatticeNode, nodes: [[LatticeNode]]), requirePrediction: Bool, requireEnglishPrediction: Bool) -> (mainResults: [Candidate], firstClauseResults: [Candidate]) {
        self.previousInputData = inputData
        self.nodes = result.nodes
        let clauseResult = result.result.getCandidateData()
        if clauseResult.isEmpty {
            let candidates = self.getUniqueCandidate(self.getAdditionalCandidate(inputData))
            return (candidates, candidates)   // アーリーリターン
        }
        let clauseCandidates: [Candidate] = clauseResult.map {(candidateData: CandidateData) -> Candidate in
            let first = candidateData.clauses.first!
            var count = 0
            do {
                var str = ""
                while true {
                    str += candidateData.data[count].word
                    if str == first.clause.text {
                        break
                    }
                    count += 1
                }
            }
            return Candidate(
                text: first.clause.text,
                value: first.value,
                correspondingCount: first.clause.rubyCount,
                lastMid: first.clause.mid,
                data: Array(candidateData.data[0...count])
            )
        }
        let sums: [(CandidateData, Candidate)] = clauseResult.map {($0, converter.processClauseCandidate($0))}
        // 文章全体を変換した場合の候補上位五件を作る
        let whole_sentence_unique_candidates = self.getUniqueCandidate(sums.map {$0.1})
        let sentence_candidates = whole_sentence_unique_candidates.sorted {$0.value>$1.value}.prefix(5)
        // 予測変換
        let prediction_candidates: [Candidate] = requirePrediction ? Array(self.getUniqueCandidate(self.getPredictionCandidate(sums)).sorted {$0.value>$1.value}.prefix(4)) : []

        // 英単語の予測変換。appleのapiを使うため、処理が異なる。
        var foreign_candidates: [Candidate] = []

        if requireEnglishPrediction {
            foreign_candidates.append(contentsOf: self.getForeignPredictionCandidate(inputData: inputData, language: "en-US"))
        }
        if VariableStates.shared.keyboardLanguage == .el_GR {
            foreign_candidates.append(contentsOf: self.getForeignPredictionCandidate(inputData: inputData, language: "el"))
        }

        // ゼロヒント予測変換
        let best10 = getUniqueCandidate(sentence_candidates + prediction_candidates).sorted {$0.value > $1.value}.prefix(10)
        let zeroHintPrediction_candidates = converter.getZeroHintPredictionCandidates(preparts: best10, N_best: 3)
        let toplevel_additional_candidate = self.getTopLevelAdditionalCandidate(inputData)
        // 文全体を変換するパターン
        let full_candidate = getUniqueCandidate(best10 + foreign_candidates + (zeroHintPrediction_candidates + toplevel_additional_candidate)).sorted {$0.value>$1.value}.prefix(5)
        // 重複のない変換候補を作成するための集合
        var seenCandidate: Set<String> = full_candidate.mapSet {$0.text}
        // 文節のみ変換するパターン
        let clause_candidates = self.getUniqueCandidate(clauseCandidates.filter {!seenCandidate.contains($0.text)}).sorted {$0.value>$1.value}.prefix(5)
        seenCandidate.formUnion(clause_candidates.map {$0.text})
        // 賢く変換するパターン
        let wise_candidates: [Candidate] = self.getWiseCandidate(inputData)
        seenCandidate.formUnion(wise_candidates.map {$0.text})

        // 最初の辞書データ
        let dicCandidates: [Candidate] = result.nodes[0]
            // .filter {!($0.data is GeneratedDicdataElement)}
            .map {
                Candidate(
                    text: $0.data.word,
                    value: $0.data.value(),
                    correspondingCount: $0.rubyCount,
                    lastMid: $0.data.mid,
                    data: [$0.data]
                )
            }
        // 追加する部分
        let additionalCandidates: [Candidate] = self.getAdditionalCandidate(inputData)

        /*
         文字列の長さごとに並べ、かつその中で評価の高いものから順に並べる。
         */

        let word_candidates: [Candidate] = self.getUniqueCandidate(
            (dicCandidates+additionalCandidates)
                .filter {
                    !seenCandidate.contains($0.text)
                }
        )
        .sorted {
            let count0 = $0.correspondingCount
            let count1 = $1.correspondingCount
            return count0 == count1 ? $0.value>$1.value : count0 > count1
        }

        var result = Array(full_candidate)

        // 最低でも1つ、入力に完全一致する候補が入るようにする
        let checkRuby: (Candidate) -> Bool = {$0.data.reduce("") {$0 + $1.ruby} == inputData.katakanaString}
        if !result.contains(where: checkRuby) {
            if let candidate = sentence_candidates.first(where: checkRuby) {
                result.append(candidate)
            } else if let candidate = whole_sentence_unique_candidates.first(where: checkRuby) {
                result.append(candidate)
            }
        }

        result.append(contentsOf: clause_candidates)
        result.append(contentsOf: wise_candidates)
        result.append(contentsOf: word_candidates)

        result.mutatingForeach { item in
            item.withActions(self.getApporopriateActions(item))
            item.parseTemplate()
        }
        return (result, Array(clause_candidates))
    }

    /// 入力からラティスを構築する関数。状況に応じて呼ぶ関数を分ける。
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - N_best: 計算途中で保存する候補数。実際に得られる候補数とは異なる。
    /// - Returns:
    ///   結果のラティスノードと、計算済みノードの全体
    private func convertToLattice(_ inputData: InputData, N_best: Int) -> (result: LatticeNode, nodes: [[LatticeNode]])? {
        if inputData.characters.isEmpty {
            return nil
        }

        guard let previousInputData else {
            debug("convertToLattice: 新規計算用の関数を呼びますA")
            let result = converter.kana2lattice_all(inputData, N_best: N_best)
            self.previousInputData = inputData
            return result
        }

        // TODO: 完全に同一のデータの場合のケースを追加する

        // 文節確定の後の場合
        if let lastClause = self.completedData, let _ = inputData.isAfterDeletedPrefixCharacter(previous: previousInputData) {
            debug("convertToLattice: 文節確定用の関数を呼びます")
            let result = converter.kana2lattice_afterComplete(inputData, completedData: lastClause, N_best: N_best, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            self.completedData = nil
            return result
        }

        // 一文字消した場合
        if let deletedCount = inputData.isAfterDeletedCharacter(previous: previousInputData) {
            debug("convertToLattice: 最後尾削除用の関数を呼びます, 消した文字数は\(deletedCount)")
            let result = converter.kana2lattice_deletedLast(deletedCount: deletedCount, N_best: N_best, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        // 一文字変わった場合
        if let counts = inputData.isAfterReplacedCharacter(previous: previousInputData) {
            debug("convertToLattice: 最後尾文字置換用の関数を呼びますA")
            let result = converter.kana2lattice_changed(inputData, N_best: N_best, counts: counts, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        // 1文字増やした場合
        if let addedCount = inputData.isAfterAddedCharacter(previous: previousInputData) {
            debug("convertToLattice: 最後尾追加用の関数を呼びます")
            let result = converter.kana2lattice_added(inputData, N_best: N_best, addedCount: addedCount, previousResult: (inputData: previousInputData, nodes: nodes))
            self.previousInputData = inputData
            return result
        }

        // 一文字増やしていない場合
        if true {
            debug("convertToLattice: 新規計算用の関数を呼びますB")
            let result = converter.kana2lattice_all(inputData, N_best: N_best)
            self.previousInputData = inputData
            return result
        }
    }

    func getApporopriateActions(_ candidate: Candidate) -> [ActionType] {
        if ["[]", "()", "｛｝", "〈〉", "〔〕", "（）", "「」", "『』", "【】", "{}", "<>", "《》", "\"\"", "\'\'", "””"].contains(candidate.text) {
            return [.moveCursor(-1)]
        }
        if ["{{}}"].contains(candidate.text) {
            return [.moveCursor(-2)]
        }
        return []

    }

    /// 外部から呼ばれる変換候補を要求する関数。
    /// - Parameters:
    ///   - inputData: 変換対象のInputData。
    ///   - N_best: 計算途中で保存する候補数。実際に得られる候補数とは異なる。
    ///   - requirePrediction: 予測変換を必要とするか否か。-
    ///   - requireEnglishPrediction: 英語の予測変換を必要とするか否か。
    /// - Returns:
    ///   重複のない変換候補。
    func requestCandidates(_ inputData: InputData, N_best: Int, requirePrediction: Bool = true, requireEnglishPrediction: Bool = true) -> (mainResults: [Candidate], firstClauseResults: [Candidate]) {
        debug("入力は", inputData.characters)
        // stringが無の場合
        if inputData.characters.isEmpty {
            return (.init(), .init())
        }
        let start1 = Date()

        guard let result = self.convertToLattice(inputData, N_best: N_best) else {
            return (.init(), .init())
        }

        debug("ラティス構築", -start1.timeIntervalSinceNow)
        let start2 = Date()
        let candidates = self.processResult(inputData: inputData, result: result, requirePrediction: requirePrediction, requireEnglishPrediction: requireEnglishPrediction)
        debug("ラティス処理", -start2.timeIntervalSinceNow)
        debug("全体", -start1.timeIntervalSinceNow)

        return candidates
    }
}
