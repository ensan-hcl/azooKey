//
//  DisplayedTextManager.swift
//  Keyboard
//
//  Created by ensan on 2022/12/30.
//  Copyright © 2022 ensan. All rights reserved.
//

import UIKit

/// UI側の入力中のテキストの更新を受け持つクラス
final class DisplayedTextManager {
    init() {
        @KeyboardSetting(.liveConversion) var enabled
        self.isLiveConversionEnabled = enabled

        @KeyboardSetting(.markedTextSetting) var markedTextEnabled
        self.isMarkedTextEnabled = markedTextEnabled != .disabled
    }
    // Viewに表示されているテキスト全体
    // ライブ変換が有効になっている場合、convertedTextが「きょうは」のときに「今日は」が入る
    // 無効になっている場合はconvertedTextと一致する
    private(set) var displayedText: String = ""
    // その中でのカーソルポジション
    private(set) var displayedTextCursorPosition = 0
    // ライブ変換の有効化状態
    private(set) var isLiveConversionEnabled: Bool
    // marked textの有効化状態
    private(set) var isMarkedTextEnabled: Bool
    private var proxy: UITextDocumentProxy! {
        if let inKeyboardProxy {
            return inKeyboardProxy
        }
        return displayedTextProxy
    }
    /// キーボード外のテキストを扱う`UITextDocumentProxy`
    private var displayedTextProxy: UITextDocumentProxy!
    /// キーボード内テキストフィールドの`UITextDocumentProxy`
    private var inKeyboardProxy: UITextDocumentProxy?

    func setTextDocumentProxy(_ proxy: UITextDocumentProxy!) {
        self.displayedTextProxy = proxy
    }

    func setInKeyboardProxy(_ proxy: UITextDocumentProxy?) {
        self.inKeyboardProxy = proxy
    }

    var documentContextAfterInput: String? {
        self.proxy.documentContextAfterInput
    }

    var selectedText: String? {
        self.proxy.selectedText
    }

    var documentContextBeforeInput: String? {
        self.proxy.documentContextBeforeInput
    }

    func clear() {
        debug("DisplayedTextManager.clear")
        // unmarkText()だけではSafariの検索Viewなどで破綻する。
        if isMarkedTextEnabled {
            self.insertText("", shouldSimplyInsert: true)
            self.proxy?.unmarkText()
        }
        @KeyboardSetting(.liveConversion) var enabled
        self.isLiveConversionEnabled = enabled
        @KeyboardSetting(.markedTextSetting) var markedTextEnabled
        self.isMarkedTextEnabled = markedTextEnabled != .disabled

        self.displayedText = ""
        self.displayedTextCursorPosition = 0
    }

    func enter() {
        if isMarkedTextEnabled {
            self.insertText(self.displayedText, shouldSimplyInsert: true)
            self.proxy?.unmarkText()
        } else {
            // do nothing
        }
        self.clear()
    }

    private func getActualOffset(count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count > 0 {
            if let after = self.proxy.documentContextAfterInput {
                // 改行があって右端の場合ここに来る。
                if after.isEmpty {
                    return 1
                }
                let suf = after.prefix(count)
                debug("あとの文字は、", suf, -suf.utf16.count)
                return suf.utf16.count
            } else {
                return 1
            }
        } else {
            if let before = self.proxy.documentContextBeforeInput {
                let pre = before.suffix(-count)
                debug("前の文字は、", pre, -pre.utf16.count)

                return -pre.utf16.count

            } else {
                return -1
            }
        }
    }

    /// MarkedTextを更新する関数
    /// この関数自体はisMarkedTextEnabledのチェックを行わない。
    func updateMarkedText() {
        self.proxy.setMarkedText(
            self.displayedText,
            selectedRange: NSRange(location: self.displayedText.prefix(self.displayedTextCursorPosition).utf16.count, length: 0)
        )
    }

    func insertText(_ text: String, shouldSimplyInsert: Bool = false) {
        guard !text.isEmpty else {
            return
        }
        defer {
            VariableStates.shared.textChangedCount += 1
        }
        if shouldSimplyInsert {
            self.proxy.insertText(text)
            return
        }

        self.displayedText.insert(
            contentsOf: text,
            at: self.displayedText.indexFromStart(displayedTextCursorPosition)
        )
        self.displayedTextCursorPosition += text.count

        if isMarkedTextEnabled {
            self.updateMarkedText()
        } else {
            self.proxy.insertText(text)
        }
    }

    // 与えられたカウントをそのまま使う
    // 正しい文字数移動できない可能性がある
    // DisplayedTextの位置は更新しない
    func unsafeMoveCursor(unsafeCount: Int) {
        guard unsafeCount != 0 else {
            return
        }
        self.proxy.adjustTextPosition(byCharacterOffset: unsafeCount)
        VariableStates.shared.textChangedCount += 1
    }

    enum OperationError: Error {
        case liveConversion
        case deleteTooMuch
    }

    // すでにカーソルが動かされた場合に処理を行う
    // 戻り値はカーソルを補正したか否か
    func setMovedCursor(movedCount: Int, composingTextOperation: ComposingText.ViewOperation) -> Bool {
        VariableStates.shared.textChangedCount += 1
        let delta = composingTextOperation.cursor - movedCount
        self.displayedTextCursorPosition += composingTextOperation.cursor
        if delta != 0 {
            let offset = self.getActualOffset(count: delta)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            return true
        }
        return false
    }

    func moveCursor(count: Int, isComposing: Bool = true) throws {
        guard count != 0 else {
            return
        }
        VariableStates.shared.textChangedCount += 1
        // ライブ変換中はカーソル移動の場合変換を停止したいので、動かすだけ動かしてエラーを投げる。
        if isComposing && isLiveConversionEnabled {
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            throw OperationError.liveConversion
        }
        // 更新
        if isComposing {
            self.displayedTextCursorPosition += count
        }
        // 反映
        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
        }
    }

    // ただ与えられた回数の削除を実行する関数
    func rawDeleteBackward(count: Int = 1) {
        guard count != 0 else {
            return
        }
        for _ in 0 ..< count {
            self.proxy.deleteBackward()
        }
        VariableStates.shared.textChangedCount += 1
    }

    // isComposingの場合、countはadjust済みであることを期待する
    // されていなかった場合は例外を投げる
    func deleteBackward(count: Int, isComposing: Bool = true) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteForward(count: abs(count), isComposing: isComposing)
            return
        }
        if !isComposing {
            self.rawDeleteBackward(count: count)
            return
        }

        let adjustedCount = min(self.displayedTextCursorPosition, count)
        let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition - adjustedCount)
        let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
        self.displayedText.removeSubrange(leftIndex ..< rightIndex)
        self.displayedTextCursorPosition -= adjustedCount

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteBackward(count: adjustedCount)
        }

        let delta = count - adjustedCount
        if delta > 0 {
            if isMarkedTextEnabled {
                if displayedText.isEmpty {
                    self.rawDeleteBackward(count: delta)
                    throw OperationError.deleteTooMuch
                }
            } else {
                self.rawDeleteBackward(count: delta)
                throw OperationError.deleteTooMuch
            }
        }
    }

    // ただ与えられた回数の削除を入力方向に実行する関数
    // カーソルが動かせない場合を検知するために工夫を入れている
    // TODO: iOS16以降のテキストフィールドの仕様変更で動かなくなっている。直す必要があるが、どうしようもない気がしている。
    func rawDeleteForward(count: Int) {
        guard count != 0 else {
            return
        }
        for _ in 0 ..< count {
            let before_b = self.proxy.documentContextBeforeInput
            let before_a = self.proxy.documentContextAfterInput
            // 例外は無視できる
            try? self.moveCursor(count: 1, isComposing: false)
            if before_a != self.proxy.documentContextAfterInput || before_b != self.proxy.documentContextBeforeInput {
                self.proxy.deleteBackward()
            } else {
                return
            }
        }
        VariableStates.shared.textChangedCount += 1
    }

    // isComposingの場合、countはadjust済みであることを期待する
    // されていなかった場合は例外を投げる
    func deleteForward(count: Int = 1, isComposing: Bool = true) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteBackward(count: abs(count), isComposing: isComposing)
            return
        }
        if !isComposing {
            self.rawDeleteForward(count: count)
            return
        }

        let adjustedCount = min(self.displayedText.count - self.displayedTextCursorPosition, count)
        let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
        let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition + adjustedCount)
        self.displayedText.removeSubrange(leftIndex ..< rightIndex)

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteForward(count: adjustedCount)
        }
        let delta = count - adjustedCount
        if delta > 0 {
            if isMarkedTextEnabled {
                if displayedText.isEmpty {
                    self.rawDeleteForward(count: delta)
                    throw OperationError.deleteTooMuch
                }
            } else {
                self.rawDeleteForward(count: delta)
                throw OperationError.deleteTooMuch
            }
        }
    }

    // カーソルから前count文字をtextで置換する
    func replace(count: Int, with text: String, isComposing: Bool = true) {
        if isComposing {
            let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition - count)
            let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
            self.displayedText.removeSubrange(leftIndex ..< rightIndex)
            self.displayedText.insert(contentsOf: text, at: leftIndex)
            self.displayedTextCursorPosition -= count
            self.displayedTextCursorPosition += text.count
        }

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteBackward(count: count)
            self.proxy.insertText(text)
        }
    }
}
