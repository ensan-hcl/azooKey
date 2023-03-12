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
    /// `convertTarget`に対応する文字列
    private(set) var composingText: ComposingText = .init()
    /// ライブ変換の有効化状態
    private(set) var isLiveConversionEnabled: Bool
    /// ライブ変換結果として表示されるべきテキスト
    private(set) var displayedLiveConversionText: String?
    /// marked textの有効化状態
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
            self.proxy?.unmarkText()
        }
        @KeyboardSetting(.liveConversion) var enabled
        self.isLiveConversionEnabled = enabled
        @KeyboardSetting(.markedTextSetting) var markedTextEnabled
        self.isMarkedTextEnabled = markedTextEnabled != .disabled

        self.composingText = .init()
        self.displayedLiveConversionText = nil
    }

    func enter() {
        if isMarkedTextEnabled {
            self.proxy?.unmarkText()
            self.insertText(self.displayedLiveConversionText ?? self.composingText.convertTarget)
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
        let text = self.displayedLiveConversionText ?? self.composingText.convertTarget
        let cursorPosition = self.displayedLiveConversionText.map(NSString.init(string:))?.length ?? NSString(string: String(self.composingText.convertTarget.prefix(self.composingText.convertTargetCursorPosition))).length
        self.proxy.setMarkedText(text, selectedRange: NSRange(location: cursorPosition, length: 0))
    }

    func insertText(_ text: String) {
        guard !text.isEmpty else {
            return
        }
        self.proxy.insertText(text)
        VariableStates.shared.textChangedCount += 1
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

    func moveCursor(count: Int, isComposing: Bool = true) {
        guard count != 0 else {
            return
        }
        let offset = self.getActualOffset(count: count)
        self.proxy.adjustTextPosition(byCharacterOffset: offset)
        VariableStates.shared.textChangedCount += 1
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
    func deleteBackward(count: Int) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteForward(count: abs(count))
            return
        }
        self.rawDeleteBackward(count: count)
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
            self.moveCursor(count: 1)
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
    func deleteForward(count: Int = 1) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteBackward(count: abs(count))
            return
        }
        self.rawDeleteForward(count: count)
    }

    /// ライブ変換結果の表示を止める
    func dismissLiveConversionText() {
        if isMarkedTextEnabled {
            self.displayedLiveConversionText = nil
            self.updateMarkedText()
        } else {
            let oldDisplayedText = self.displayedLiveConversionText ?? self.composingText.convertTarget
            let commonPrefix = oldDisplayedText.commonPrefix(with: self.composingText.convertTarget)
            let delete = oldDisplayedText.count - commonPrefix.count
            let input = self.composingText.convertTarget.suffix(self.composingText.convertTarget.count - commonPrefix.count)
            self.rawDeleteBackward(count: delete)
            self.proxy.insertText(String(input))
            self.displayedLiveConversionText = nil
        }
    }

    /// ライブ変換結果を更新する
    func updateLiveConversionText(liveConversionText: String) {
        if liveConversionText.isEmpty {
            self.dismissLiveConversionText()
            return
        }
        let oldDisplayedText = self.displayedLiveConversionText ?? self.composingText.convertTarget
        self.displayedLiveConversionText = liveConversionText
        if isMarkedTextEnabled {
            self.updateMarkedText()
        } else {
            let commonPrefix = oldDisplayedText.commonPrefix(with: liveConversionText)
            let delete = oldDisplayedText.count - commonPrefix.count
            let input = liveConversionText.suffix(liveConversionText.count - commonPrefix.count)
            self.rawDeleteBackward(count: delete)
            self.proxy.insertText(String(input))
        }
    }

    /// `composingText`を更新する
    func updateComposingText(composingText: ComposingText) {
        if isMarkedTextEnabled {
            self.composingText = composingText
            self.updateMarkedText()
        } else {
            let oldDisplayedText = self.displayedLiveConversionText ?? self.composingText.convertTarget
            let oldCursorPosition = self.displayedLiveConversionText?.count ?? self.composingText.convertTargetCursorPosition
            let newDisplayedText = self.displayedLiveConversionText ?? composingText.convertTarget
            let newCursorPosition = self.displayedLiveConversionText?.count ?? composingText.convertTargetCursorPosition
            self.composingText = composingText
            // アップデートのアルゴリズム
            // まず、カーソルをcomposingTextの右端に移動する
            // ついで差分を計算し、必要な分だけ削除して修正する
            // 最後にもう一度カーソルを動かす
            // 例外は無視できる
            let commonPrefix = oldDisplayedText.commonPrefix(with: newDisplayedText)
            let delete = oldDisplayedText.count - commonPrefix.count
            let input = newDisplayedText.suffix(newDisplayedText.count - commonPrefix.count)

            self.moveCursor(count: oldDisplayedText.count - oldCursorPosition)
            self.rawDeleteBackward(count: delete)
            self.proxy.insertText(String(input))
            self.moveCursor(count: newCursorPosition - newDisplayedText.count)
        }
    }

    func updateComposingText(composingText: ComposingText, userMovedCount: Int, composingTextOperation: ComposingText.ViewOperation) -> Bool {
        let delta = composingTextOperation.cursor - userMovedCount
        self.composingText = composingText
        if delta != 0 {
            let offset = self.getActualOffset(count: delta)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            return true
        }
        return false
    }

    func updateComposingText(composingText: ComposingText, completedPrefix: String, isSelected: inout Bool) {
        if isMarkedTextEnabled {
            self.insertText(completedPrefix)
            self.composingText = composingText
            self.updateMarkedText()
            isSelected = false
            self.displayedLiveConversionText = nil
        } else {
            // (例１): [あいし|てる] (「あい」を確定)
            // (削除): [|てる]
            // (挿入): 愛[|てる]
            // (挿入): 愛[し|てる]
            // (移動): 愛[し|てる]
            // (例２): [あい|してる] (「あい」を確定)
            // (削除): [|してる]
            // (挿入): 愛[|してる]
            // (挿入): 愛[|してる]
            // (移動): 愛[してる|]
            if !isSelected {
                let count = self.displayedLiveConversionText?.count ?? self.composingText.convertTargetCursorPosition
                try? self.deleteBackward(count: count)
                isSelected = false
            }
            self.insertText(completedPrefix)
            let delta = self.composingText.convertTarget.count - composingText.convertTarget.count
            let cursorPosition = self.composingText.convertTargetCursorPosition - delta
            self.insertText(String(self.composingText.convertTargetBeforeCursor.suffix(cursorPosition)))
            self.moveCursor(count: composingText.convertTargetCursorPosition - cursorPosition)
            self.composingText = composingText
            self.displayedLiveConversionText = nil
        }
    }

    // カーソルから前count文字をtextで置換する
    func replace(count: Int, with text: String) {
        self.rawDeleteBackward(count: count)
        self.proxy.insertText(text)
    }
}
