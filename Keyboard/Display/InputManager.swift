//
//  InputManager.swift
//  Keyboard
//
//  Created by ensan on 2022/12/30.
//  Copyright © 2022 ensan. All rights reserved.
//

import OrderedCollections
import UIKit

final class InputManager {
    // 入力中の文字列を管理する構造体
    private(set) var composingText = ComposingText()
    // 表示される文字列を管理するクラス
    private(set) var displayedTextManager = DisplayedTextManager()
    // TODO: displayedTextManagerとliveConversionManagerを何らかの形で統合したい
    // ライブ変換を管理するクラス
    var liveConversionManager = LiveConversionManager()

    // セレクトされているか否か、現在入力中の文字全体がセレクトされているかどうかである。
    // TODO: isSelectedはdisplayedTextManagerが持っているべき
    var isSelected = false

    /// システム側でproxyを操作した結果、`textDidChange`などがよばれてしまう場合に、その呼び出しをスキップするため、フラグを事前に立てる
    private var previousSystemOperation: SystemOperationType?
    enum SystemOperationType {
        case moveCursor
        case setMarkedText
    }

    // 再変換機能の提供のために用いる辞書
    private var rubyLog: OrderedDictionary<String, String> = [:]

    // 変換結果の通知用関数
    private var updateResult: (([Candidate]) -> Void)?

    private var liveConversionEnabled: Bool {
        liveConversionManager.enabled && !self.isSelected
    }

    private func updateLog(candidate: Candidate) {
        for data in candidate.data {
            // 「感謝する: カンシャスル」→を「感謝: カンシャ」に置き換える
            var word = data.word.toHiragana()
            var ruby = data.ruby.toHiragana()

            // wordのlastがrubyのlastである時、この文字は仮名なので
            while !word.isEmpty && word.last == ruby.last {
                word.removeLast()
                ruby.removeLast()
            }
            while !word.isEmpty && word.first == ruby.first {
                word.removeFirst()
                ruby.removeFirst()
            }
            if word.isEmpty {
                continue
            }
            // 一度消してから入れる(reorder)
            rubyLog.removeValue(forKey: word)
            rubyLog[word] = ruby
        }
        while rubyLog.count > 100 {  // 最大100個までログを取る
            rubyLog.removeFirst()
        }
        debug("rubyLog", rubyLog)
    }

    /// ルビ(ひらがな)を返す
    private func getRubyIfPossible(text: String) -> String? {
        // TODO: もう少しやりようがありそう、例えばログを見てひたすら置換し、最後にkanaだったらヨシ、とか？
        // ユーザがテキストを選択した場合、というやや強い条件が入っているので、パフォーマンスをあまり気にしなくても大丈夫
        // 長い文章を再変換しない、みたいな仮定も入れられる
        if let ruby = rubyLog[text] {
            return ruby.toHiragana()
        }
        // 長い文章は諦めてもらう
        if text.count > 20 {
            return nil
        }
        // {hiragana}*{known word}のパターンを救う
        do {
            for (word, ruby) in rubyLog {
                if text.hasSuffix(word) {
                    if text.dropLast(word.count).isKana {
                        return (text.dropLast(word.count) + ruby).toHiragana()
                    }
                }
            }
        }
        // {known word}{hiragana}*のパターンを救う
        do {
            for (word, ruby) in rubyLog {
                if text.hasPrefix(word) {
                    if text.dropFirst(word.count).isKana {
                        return (ruby + text.dropFirst(word.count)).toHiragana()
                    }
                }
            }
        }
        return nil
    }

    /// かな漢字変換を受け持つ変換器。
    private var kanaKanjiConverter = KanaKanjiConverter()

    func sendToDicdataStore(_ data: DicdataStore.Notification) {
        self.kanaKanjiConverter.sendToDicdataStore(data)
    }

    func setTextDocumentProxy(_ proxy: AnyTextDocumentProxy) {
        self.displayedTextManager.setTextDocumentProxy(proxy)
    }

    func setUpdateResult(_ updateResult: @escaping ([Candidate]) -> Void) {
        self.updateResult = updateResult
    }

    func getPreviousSystemOperation() -> SystemOperationType? {
        if let previousSystemOperation {
            self.previousSystemOperation = nil
            return previousSystemOperation
        }
        return nil
    }

    /// 変換を選択した場合に呼ばれる
    func complete(candidate: Candidate) {
        self.updateLog(candidate: candidate)
        self.composingText.prefixComplete(correspondingCount: candidate.correspondingCount)
        if self.displayedTextManager.shouldSkipMarkedTextChange {
            self.previousSystemOperation = .setMarkedText
        }
        self.displayedTextManager.updateComposingText(composingText: self.composingText, completedPrefix: candidate.text, isSelected: self.isSelected)
        self.kanaKanjiConverter.updateLearningData(candidate)
        guard !self.composingText.isEmpty else {
            // ここで入力を停止する
            self.stopComposition()
            return
        }
        self.isSelected = false
        self.kanaKanjiConverter.setCompletedData(candidate)

        if liveConversionEnabled {
            self.liveConversionManager.updateAfterFirstClauseCompletion()
        }
        self.setResult()
    }

    /// 入力を停止する。DisplayedTextには特に何もしない。
    func stopComposition() {
        self.composingText.stopComposition()
        self.displayedTextManager.stopComposition()
        self.liveConversionManager.stopComposition()
        self.kanaKanjiConverter.stopComposition()

        self.isSelected = false
        VariableStates.shared.setEnterKeyState(.return)

        if let updateResult {
            updateResult([])
        }
    }

    func closeKeyboard() {
        debug("closeKeyboard: キーボードが閉じます")
        self.sendToDicdataStore(.closeKeyboard)
        _ = self.enter()
    }

    /// 「現在入力中として表示されている文字列で確定する」というセマンティクスを持った操作である。
    /// - parameters:
    ///  - shouldModifyDisplayedText: DisplayedTextを操作して良いか否か。`textDidChange`などの場合は操作してはいけない。
    func enter(shouldModifyDisplayedText: Bool = true) -> [ActionType] {
        var candidate: Candidate
        // ライブ変換中に確定する場合、現在表示されているテキストそのものが候補となる。
        if liveConversionEnabled, let _candidate = liveConversionManager.lastUsedCandidate {
            candidate = _candidate
        } else {
            candidate = Candidate(
                text: self.composingText.convertTarget,
                value: -18,
                correspondingCount: self.composingText.input.count,
                lastMid: MIDData.一般.mid,
                data: [
                    DicdataElement(
                        word: self.composingText.convertTarget,
                        ruby: self.composingText.convertTarget.toKatakana(),
                        cid: CIDData.固有名詞.cid,
                        mid: MIDData.一般.mid,
                        value: -18
                    )
                ]
            )
        }
        let actions = self.kanaKanjiConverter.getApporopriateActions(candidate)
        candidate.withActions(actions)
        candidate.parseTemplate()
        self.updateLog(candidate: candidate)
        if shouldModifyDisplayedText {
            self.composingText.prefixComplete(correspondingCount: candidate.correspondingCount)
            if self.displayedTextManager.shouldSkipMarkedTextChange {
                self.previousSystemOperation = .setMarkedText
            }
            self.displayedTextManager.updateComposingText(composingText: self.composingText, completedPrefix: candidate.text, isSelected: self.isSelected)
        }
        self.stopComposition()
        return actions
    }

    func insertMainDisplayText(_ text: String) {
        self.displayedTextManager.insertMainDisplayText(text)
    }

    // MARK: キーボード経由でユーザがinputを行った場合に呼び出す
    func input(text: String, requireSetResult: Bool = true, simpleInsert: Bool = false) {
        if simpleInsert {
            // 必要に応じて確定する
            _ = self.enter()
            self.displayedTextManager.insertText(text)
            return
        }
        if self.isSelected {
            // 選択部分を削除する
            self.displayedTextManager.deleteBackward(count: 1)
            // 変換をリセットする
            self.stopComposition()
            // 入力する
            self.composingText.insertAtCursorPosition(text, inputStyle: VariableStates.shared.inputStyle)
            // 変換を要求する
            self.setResult()

            VariableStates.shared.setEnterKeyState(.complete)
            return
        }

        if text == "\n"{
            _ = self.enter()
            self.displayedTextManager.insertText(text)
            return
        }
        // スペースだった場合
        if text == " " || text == "　" || text == "\t" || text == "\0"{
            _ = self.enter()
            self.displayedTextManager.insertText(text)
            return
        }

        if VariableStates.shared.keyboardLanguage == .none {
            _ = self.enter()
            self.displayedTextManager.insertText(text)
            return
        }

        self.composingText.insertAtCursorPosition(text, inputStyle: VariableStates.shared.inputStyle)
        debug("Input Manager input:", composingText)
        if requireSetResult {
            // 変換を実施する
            self.setResult()
            // キーの種類を変更
            VariableStates.shared.setEnterKeyState(.complete)
        }
    }

    /// テキストの進行方向に削除する
    /// `ab|c → ab|`のイメージ
    func deleteForward(count: Int, requireSetResult: Bool = true) {
        if count < 0 {
            return
        }

        guard !self.composingText.isEmpty else {
            self.displayedTextManager.deleteForward(count: count)
            return
        }

        self.composingText.deleteForwardFromCursorPosition(count: count)
        debug("Input Manager deleteForward: ", composingText)

        if requireSetResult {
            // 変換を実施する
            self.setResult()
            if self.composingText.isEmpty {
                VariableStates.shared.setEnterKeyState(.return)
            }
        }
    }

    /// テキストの進行方向と逆に削除する
    /// `ab|c → a|c`のイメージ
    /// - Parameters:
    ///   - convertTargetCount: `convertTarget`の文字数。`displayedText`の文字数ではない。
    ///   - requireSetResult: `setResult()`の呼び出しを要求するか。
    func deleteBackward(convertTargetCount: Int, requireSetResult: Bool = true) {
        if convertTargetCount == 0 {
            return
        }
        // 選択状態ではオール削除になる
        if self.isSelected {
            // 選択部分を削除する
            self.displayedTextManager.deleteBackward(count: 1)
            // 変換をリセットする
            self.stopComposition()
            return
        }
        // 条件
        if convertTargetCount < 0 {
            self.deleteForward(count: abs(convertTargetCount), requireSetResult: requireSetResult)
            return
        }
        guard !self.composingText.isEmpty else {
            self.displayedTextManager.deleteBackward(count: convertTargetCount)
            return
        }

        self.composingText.deleteBackwardFromCursorPosition(count: convertTargetCount)
        debug("Input Manager deleteBackword: ", composingText)

        if requireSetResult {
            // 変換を実施する
            self.setResult()
            if self.composingText.isEmpty {
                VariableStates.shared.setEnterKeyState(.return)
            }
        }
    }

    /// 特定の文字まで削除する
    func smoothDelete(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            // 選択部分を完全に削除する
            self.displayedTextManager.deleteBackward(count: 1)
            // Compositionをリセットする
            self.stopComposition()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            // TODO: Check implementation of `requireSetResult`
            // カーソルより前を全部消す
            self.composingText.deleteBackwardFromCursorPosition(count: self.composingText.convertTargetCursorPosition)
            // 文字がもうなかった場合、ここで全て削除して終了
            if self.composingText.isEmpty {
                // 全て削除する
                if self.displayedTextManager.shouldSkipMarkedTextChange {
                    self.previousSystemOperation = .setMarkedText
                }
                self.displayedTextManager.updateComposingText(composingText: self.composingText, newLiveConversionText: nil)
                self.stopComposition()
                return
            }
            // カーソルを先頭に移動する
            self.moveCursor(count: self.composingText.convertTarget.count)
            if requireSetResult {
                setResult()
            }
            return
        }

        var deletedCount = 0
        while let last = self.displayedTextManager.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                self.displayedTextManager.deleteBackward(count: 1)
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            self.displayedTextManager.deleteBackward(count: 1)
        }
    }

    /// テキストの進行方向に、特定の文字まで削除する
    /// 入力中はカーソルから右側を全部消す
    func smoothDeleteForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            // 完全に削除する
            self.displayedTextManager.deleteBackward(count: 1)
            // Compositionをリセットする
            self.stopComposition()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            // TODO: Check implementation of `requireSetResult`
            // count文字消せるのは自明なので、返り値は無視できる
            self.composingText.deleteForwardFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            // 文字がもうなかった場合
            if self.composingText.isEmpty {
                // 全て削除する
                if self.displayedTextManager.shouldSkipMarkedTextChange {
                    self.previousSystemOperation = .setMarkedText
                }
                self.displayedTextManager.updateComposingText(composingText: self.composingText, newLiveConversionText: nil)
                self.stopComposition()
            }
            return
        }

        var deletedCount = 0
        while let first = self.displayedTextManager.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                self.displayedTextManager.deleteForward(count: 1)
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            self.displayedTextManager.deleteForward(count: 1)
        }
    }

    /// テキストの進行方向と逆に、特定の文字までカーソルを動かす
    func smartMoveCursorBackward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態では左にカーソルを移動
        if isSelected {
            // 左にカーソルを動かす
            self.displayedTextManager.moveCursor(count: -1)
            self.stopComposition()
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            if self.liveConversionEnabled {
                _ = self.enter()
                return
            }
            _ = self.composingText.moveCursorFromCursorPosition(count: -self.composingText.convertTargetCursorPosition)
            if requireSetResult {
                self.setResult()
            }
            return
        }

        var movedCount = 0
        while let last = displayedTextManager.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                self.displayedTextManager.moveCursor(count: -1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            self.displayedTextManager.moveCursor(count: -1)
        }
    }

    /// テキストの進行方向に、特定の文字までカーソルを動かす
    func smartMoveCursorForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態では最も右にカーソルを移動
        if isSelected {
            self.displayedTextManager.moveCursor(count: 1)
            self.stopComposition()
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            if self.liveConversionEnabled {
                _ = self.enter()
                return
            }
            _ = self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            if requireSetResult {
                setResult()
            }
            return
        }

        var movedCount = 0
        while let first = displayedTextManager.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                self.displayedTextManager.moveCursor(count: 1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            self.displayedTextManager.moveCursor(count: 1)
        }
    }

    /// iOS16以上の仕様変更に対応するため追加されたAPI
    func adjustLeftString(_ left: String) -> String {
        if #available(iOS 16, *) {
            var newLeft = left.components(separatedBy: "\n").last ?? ""
            if left.contains("\n") && newLeft.isEmpty {
                newLeft = "\n"
            }
            return newLeft
        }
        return left
    }

    func updateSurroundingText() {
        debug("updateSurroundingText Triggered")
        let left = adjustLeftString(self.displayedTextManager.documentContextBeforeInput ?? "")
        let center = self.displayedTextManager.selectedText ?? ""
        let right = self.displayedTextManager.documentContextAfterInput ?? ""

        VariableStates.shared.moveCursorBarState.updateLine(leftText: left + center, rightText: right)
    }

    /// 選択状態にあるテキストを再度入力し、編集可能な状態にする
    func edit() {
        if isSelected {
            let selectedText = composingText.convertTarget
            self.displayedTextManager.deleteBackward(count: 1)
            self.isSelected = false
            self.composingText.stopComposition()
            self.input(text: selectedText)
            VariableStates.shared.setEnterKeyState(.complete)
        }
    }

    /// 文字のreplaceを実施する
    /// `changeCharacter`を`CustardKit`で扱うためのAPI。
    /// キーボード経由でのみ実行される。
    func replaceLastCharacters(table: [String: String], requireSetResult: Bool = true) {
        debug(table, composingText, isSelected)
        if isSelected {
            return
        }
        let counts: (max: Int, min: Int) = table.keys.reduce(into: (max: 0, min: .max)) {
            $0.max = max($0.max, $1.count)
            $0.min = min($0.min, $1.count)
        }
        // 入力状態の場合、入力中のテキストの範囲でreplaceを実施する。
        if !composingText.isEmpty {
            let leftside = composingText.convertTargetBeforeCursor
            var found = false
            for count in (counts.min...counts.max).reversed() where count <= composingText.convertTargetCursorPosition {
                if let replace = table[String(leftside.suffix(count))] {
                    // deleteとinputを効率的に行うため、setResultを要求しない (変換を行わない)
                    self.deleteBackward(convertTargetCount: leftside.suffix(count).count, requireSetResult: false)
                    // ここで変換が行われる。内部的には差分管理システムによって「置換」の場合のキャッシュ変換が呼ばれる。
                    self.input(text: replace, requireSetResult: requireSetResult)
                    found = true
                    break
                }
            }
            if !found && requireSetResult {
                self.setResult()
            }
            return
        }
        // 言語の指定がない場合は、入力中のテキストの範囲でreplaceを実施する。
        if VariableStates.shared.keyboardLanguage == .none {
            let leftside = displayedTextManager.documentContextBeforeInput ?? ""
            for count in (counts.min...counts.max).reversed() where count <= leftside.count {
                if let replace = table[String(leftside.suffix(count))] {
                    self.displayedTextManager.deleteBackward(count: count)
                    self.displayedTextManager.insertText(replace)
                    break
                }
            }
        }
    }

    /// カーソル左側の1文字を変更する関数
    /// ひらがなの場合は小書き・濁点・半濁点化し、英字・ギリシャ文字・キリル文字の場合は大文字・小文字化する
    func changeCharacter(requireSetResult: Bool = true) {
        if self.isSelected {
            return
        }
        guard let char = self.composingText.convertTargetBeforeCursor.last else {
            return
        }
        let changed = CharacterUtils.requestChange(char)
        // 同じ文字の場合は無視する
        if Character(changed) == char {
            return
        }
        // deleteとinputを効率的に行うため、setResultを要求しない (変換を行わない)
        self.deleteBackward(convertTargetCount: 1, requireSetResult: false)
        // inputの内部でsetResultが発生する
        self.input(text: changed, requireSetResult: requireSetResult)
    }

    /// キーボード経由でのカーソル移動
    func moveCursor(count: Int, requireSetResult: Bool = true) {
        if self.isSelected {
            // ただ横に動かす(選択解除)
            self.displayedTextManager.moveCursor(count: 1)
            // 解除する
            self.stopComposition()
            return
        }
        if count == 0 {
            return
        }
        // カーソルを移動した直後、挙動が不安定であるため、スキップを登録する
        self.previousSystemOperation = .moveCursor
        // 入力中の文字が空の場合は普通に動かす
        if composingText.isEmpty {
            self.displayedTextManager.moveCursor(count: count)
            return
        }
        if self.liveConversionEnabled {
            _ = self.enter()
            return
        }

        debug("Input Manager moveCursor:", composingText, count)

        _ = self.composingText.moveCursorFromCursorPosition(count: count)
        if count != 0 && requireSetResult {
            setResult()
        }
    }

    /// ユーザがキーボードを経由せずにカーソルを何かした場合の後処理を行う関数。
    ///  - note: この関数をユーティリティとして用いてはいけない。
    func userMovedCursor(count: Int) {
        debug("userによるカーソル移動を検知、今の位置は\(composingText.convertTargetCursorPosition)、動かしたオフセットは\(count)")
        VariableStates.shared.textChangedCount += 1
        if composingText.isEmpty {
            // 入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }
        let operation = composingText.moveCursorFromCursorPosition(count: count)
        self.previousSystemOperation = self.displayedTextManager.updateComposingText(composingText: self.composingText, userMovedCount: count, composingTextOperation: operation) ? .moveCursor : nil
        setResult()
    }

    /// ユーザがキーボードを経由せずカットした場合の処理
    func userCutText(text: String) {
        self.stopComposition()
        VariableStates.shared.textChangedCount += 1
    }

    // ユーザが文章を選択した場合、その部分を入力中であるとみなす(再変換)
    func userSelectedText(text: String) {
        if text.isEmpty {
            return
        }
        defer {
            VariableStates.shared.textChangedCount += 1
        }
        // 長すぎるのはダメ
        if text.count > 100 {
            return
        }
        if text.hasPrefix("http") {
            return
        }
        // 改行文字はだめ
        if text.contains("\n") || text.contains("\r") {
            return
        }
        // 空白文字もだめ
        if text.contains(" ") || text.contains("\t") {
            return
        }
        // 過去のログを見て、再変換に利用する
        self.composingText.stopComposition()
        if let ruby = self.getRubyIfPossible(text: text) {
            debug("Evaluated ruby:", ruby)
            // rubyはひらがなである
            self.composingText.insertAtCursorPosition(ruby, inputStyle: .direct)
        } else {
            self.composingText.insertAtCursorPosition(text, inputStyle: .direct)
        }

        self.isSelected = true
        self.setResult()
        VariableStates.shared.setEnterKeyState(.edit)
    }

    /// 選択を解除した場合、Compositionをリセットする
    func userDeselectedText() {
        self.stopComposition()
    }

    /// 変換リクエストを送信し、結果をDisplayed Textにも反映する関数
    func setResult() {
        let requireJapanesePrediction: Bool
        let requireEnglishPrediction: Bool
        switch VariableStates.shared.inputStyle {
        case .direct:
            requireJapanesePrediction = true
            requireEnglishPrediction = true
        case .roman2kana:
            requireJapanesePrediction = VariableStates.shared.keyboardLanguage == .ja_JP
            requireEnglishPrediction = VariableStates.shared.keyboardLanguage == .en_US
        }
        @KeyboardSetting(.typographyLetter) var typographyLetterCandidate
        @KeyboardSetting(.unicodeCandidate) var unicodeCandidate
        @KeyboardSetting(.englishCandidate) var englishCandidateInRoman2KanaInput
        @KeyboardSetting(.fullRomanCandidate) var fullWidthRomanCandidate
        @KeyboardSetting(.halfKanaCandidate) var halfWidthKanaCandidate
        @KeyboardSetting(.learningType) var learningType

        let options = ConvertRequestOptions(
            N_best: 10,
            requireJapanesePrediction: requireJapanesePrediction,
            requireEnglishPrediction: requireEnglishPrediction,
            // VariableStatesを注入
            keyboardLanguage: VariableStates.shared.keyboardLanguage,
            mainInputStyle: VariableStates.shared.inputStyle,
            // KeyboardSettingsを注入
            typographyLetterCandidate: typographyLetterCandidate,
            unicodeCandidate: unicodeCandidate,
            englishCandidateInRoman2KanaInput: englishCandidateInRoman2KanaInput,
            fullWidthRomanCandidate: fullWidthRomanCandidate,
            halfWidthKanaCandidate: halfWidthKanaCandidate,
            learningType: learningType,
            maxMemoryCount: 65536
        )

        let inputData = composingText.prefixToCursorPosition()
        debug("setResult value to be input", inputData, options)

        let results: [Candidate]
        let firstClauseResults: [Candidate]
        (results, firstClauseResults) = self.kanaKanjiConverter.requestCandidates(inputData, options: options)

        // 表示を更新する
        if !self.isSelected {
            if self.displayedTextManager.shouldSkipMarkedTextChange {
                self.previousSystemOperation = .setMarkedText
            }
            if liveConversionEnabled {
                let liveConversionText = self.liveConversionManager.updateWithNewResults(results, firstClauseResults: firstClauseResults, convertTargetCursorPosition: inputData.convertTargetCursorPosition, convertTarget: inputData.convertTarget)
                self.displayedTextManager.updateComposingText(composingText: self.composingText, newLiveConversionText: liveConversionText)
            } else {
                self.displayedTextManager.updateComposingText(composingText: self.composingText, newLiveConversionText: nil)
            }
        }

        debug("results to be registered:", results)
        if let updateResult {
            updateResult(results)
            // 自動確定の実施
            if liveConversionEnabled, let firstClause = self.liveConversionManager.candidateForCompleteFirstClause() {
                debug("Complete first clause", firstClause)
                self.complete(candidate: firstClause)
            }
        }
    }
}
