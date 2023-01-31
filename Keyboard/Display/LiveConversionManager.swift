//
//  LiveConversionManager.swift
//  Keyboard
//
//  Created by ensan on 2022/12/30.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation

// ライブ変換を管理するためのクラス
final class LiveConversionManager {
    init() {
        @KeyboardSetting(.liveConversion) var enabled
        self.enabled = enabled
    }
    var enabled = false

    private(set) var isFirstClauseCompletion: Bool = false
    // 現在ディスプレイに表示されている候補
    private(set) var lastUsedCandidate: Candidate?
    private var headClauseCandidateHistories: [[Candidate]] = []

    func clear() {
        self.lastUsedCandidate = nil
        @KeyboardSetting(.liveConversion) var enabled
        self.enabled = enabled
        self.headClauseCandidateHistories = []
    }

    func updateAfterFirstClauseCompletion() {
        // ここはどうにかしたい
        self.lastUsedCandidate = nil
        // フラグを戻す
        self.isFirstClauseCompletion = false
        // 最初を落とす
        headClauseCandidateHistories.removeFirst()
    }

    private func updateHistories(newCandidate: Candidate, firstClauseCandidates: [Candidate]) {
        var data = newCandidate.data[...]
        var count = 0
        while data.count > 0 {
            var clause = Candidate.makePrefixClauseCandidate(data: data)
            // ローマ字向けに補正処理を入れる
            if count == 0, let first = firstClauseCandidates.first(where: {$0.text == clause.text}) {
                clause.correspondingCount = first.correspondingCount
            }
            if self.headClauseCandidateHistories.count <= count {
                self.headClauseCandidateHistories.append([clause])
            } else {
                self.headClauseCandidateHistories[count].append(clause)
            }
            data = data.dropFirst(clause.data.count)
            count += 1
        }
    }

    /// かな漢字変換結果を受け取ってライブ変換状態の更新を行う関数
    func updateWithNewResults(_ candidates: [Candidate], firstClauseResults: [Candidate], convertTargetCursorPosition: Int, convertTarget: String) -> ComposingText.ViewOperation {
        // TODO: 最後の1単語のライブ変換を抑制したい
        // TODO: ローマ字入力中に最後の単語が優先される問題
        var candidate: Candidate
        if convertTargetCursorPosition > 1, let firstCandidate = candidates.first(where: {$0.data.map {$0.ruby}.joined().count == convertTarget.count}) {
            candidate = firstCandidate
        } else {
            candidate = .init(text: convertTarget, value: 0, correspondingCount: convertTarget.count, lastMid: MIDData.一般.mid, data: [.init(ruby: convertTarget.toKatakana(), cid: CIDData.一般名詞.cid, mid: MIDData.一般.mid, value: 0)])
        }
        self.adjustCandidate(candidate: &candidate)
        debug("Live Conversion:", candidate)

        // カーソルなどを調整する
        if convertTargetCursorPosition > 0 {
            let deleteCount = self.calculateNecessaryBackspaceCount(rubyCursorPosition: convertTargetCursorPosition)
            self.setLastUsedCandidate(candidate, firstClauseCandidates: firstClauseResults)
            return .init(delete: deleteCount, input: candidate.text)
        }
        return .init(delete: 0, input: "")
    }

    /// `lastUsedCandidate`を更新する関数
    func setLastUsedCandidate(_ candidate: Candidate?, firstClauseCandidates: [Candidate] = []) {
        if let candidate {
            // 削除や置換ではなく付加的な変更である場合に限って更新を実施したい。
            let diff: Int
            if let lastUsedCandidate {
                let lastLength = lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}
                let newLength = candidate.data.reduce(0) {$0 + $1.ruby.count}
                diff = newLength - lastLength
            } else {
                diff = 1
            }
            self.lastUsedCandidate = candidate
            // 追加である場合
            if diff > 0 {
                self.updateHistories(newCandidate: candidate, firstClauseCandidates: firstClauseCandidates)
            } else if diff < 0 {
                // 削除の場合には最後尾のログを1つ落とす。
                self.headClauseCandidateHistories.mutatingForeach {
                    _ = $0.popLast()
                }
            } else {
                // 置換の場合には更新を追加で入れる。
                self.headClauseCandidateHistories.mutatingForeach {
                    _ = $0.popLast()
                }
                self.updateHistories(newCandidate: candidate, firstClauseCandidates: firstClauseCandidates)
            }
        } else {
            self.lastUsedCandidate = nil
            self.headClauseCandidateHistories = []
        }
    }

    /// 条件に応じてCandidateを微調整するための関数
    func adjustCandidate(candidate: inout Candidate) {
        if let last = candidate.data.last, last.ruby.count < 2 {
            let ruby_hira = last.ruby.toHiragana()
            let newElement = DicdataElement(word: ruby_hira, ruby: last.ruby, lcid: last.lcid, rcid: last.rcid, mid: last.mid, value: last.adjustedData(0).value(), adjust: last.adjust)
            var newCandidate = Candidate(text: candidate.data.dropLast().map {$0.word}.joined() + ruby_hira, value: candidate.value, correspondingCount: candidate.correspondingCount, lastMid: candidate.lastMid, data: candidate.data.dropLast() + [newElement])
            newCandidate.parseTemplate()
            debug(candidate, newCandidate)
            candidate = newCandidate
        }
    }

    /// `insert`の前に削除すべき長さを返す関数。
    func calculateNecessaryBackspaceCount(rubyCursorPosition: Int) -> Int {
        if let lastUsedCandidate {
            // 直前のCandidateでinsertされた長さ
            // 通常、この文字数を消せば問題がない
            let lastCount = lastUsedCandidate.text.count
            // 直前に部分確定が行われた場合は話が異なる
            // この場合、「本来の文字数 == ルビカウントの和」と「今のカーソルポジション」の差分をとり、その文字数がinsertされたのだと判定していた
            // 「愛してる」において「愛し」を部分確定した場合を考える
            // 本来のルビカウントは5である
            // 一方、rubyCursorPositionとしては2が与えられる
            // 故に3文字に対応する部分が確定されているので、
            // 現在のカーソル位置から、直前のCandidateのルビとしての長さを引いている
            // カーソル位置は「ルビとしての長さ」なので、「田中」に対するrubyCursorPositionは「タナカ|」の3であることが期待できる。
            // 一方lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}はタナカの3文字なので3である。
            // 従ってこの例ではdelta=0と言える。
            debug("Live Conversion Delete Count Calc:", lastUsedCandidate, rubyCursorPosition)
            let delta = rubyCursorPosition - lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}
            return lastCount + delta
        } else {
            return rubyCursorPosition
        }
    }

    /// 最初の文節を確定して良い場合Candidateを返す関数
    /// - warning:
    ///   この関数を呼んで結果を得た場合、必ずそのCandidateで確定処理を行う必要がある。
    func candidateForCompleteFirstClause() -> Candidate? {
        @KeyboardSetting(.automaticCompletionStrength) var strength
        guard let history = headClauseCandidateHistories.first else {
            return nil
        }
        if history.count < strength.treshold {
            return nil
        }

        // 過去十分な回数変動がなければ、prefixを確定して良い
        debug("History", history)
        let texts = history.suffix(strength.treshold).mapSet { $0.text }
        if texts.count == 1 {
            self.isFirstClauseCompletion = true
            return history.last!
        } else {
            return nil
        }
    }
}
