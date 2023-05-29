//
//  IKTextDocumentProxy.swift
//  azooKey
//
//  Created by ensan on 2023/03/18.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUtils
import UIKit

final class IKTextDocumentProxy: NSObject, UITextDocumentProxy {
    private var input: any UITextInput

    var documentContextBeforeInput: String? {
        if self.input.markedTextRange != nil {
            return nil
        }
        // カーソル位置は`selectedTextRange`で取得できる。
        if let start = self.input.selectedTextRange?.start,
           let range = self.input.textRange(from: self.input.beginningOfDocument, to: start) {
            return self.input.text(in: range)
        }
        return nil
    }

    var documentContextAfterInput: String? {
        if self.input.markedTextRange != nil {
            return nil
        }
        // カーソル位置は`selectedTextRange`で取得できる。
        if let end = self.input.selectedTextRange?.end,
           let range = self.input.textRange(from: end, to: self.input.endOfDocument) {
            return self.input.text(in: range)
        }
        return nil
    }

    var selectedText: String? {
        if self.input.markedTextRange != nil {
            return nil
        }
        if let range = self.input.selectedTextRange {
            return self.input.text(in: range)
        }
        return nil
    }

    var documentInputMode: UITextInputMode? {
        self.input.textInputView?.textInputMode
    }

    var documentIdentifier: UUID = UUID()

    init(input: any UITextInput) {
        self.input = input
        super.init()
    }

    func adjustTextPosition(byCharacterOffset offset: Int) {
        if let range = self.input.selectedTextRange,
           let position = self.input.position(from: range.start, offset: offset) {
            input.selectedTextRange = self.input.textRange(from: position, to: position)
        }
    }

    func setMarkedText(_ markedText: String, selectedRange: NSRange) {
        debug("CustomTextDocumentProxy.setMarkedText", markedText)
        self.input.setMarkedText(markedText, selectedRange: selectedRange)
    }

    func unmarkText() {
        if self.input.markedTextRange != nil {
            self.input.unmarkText()
        }
    }

    var hasText: Bool {
        self.input.hasText
    }

    func insertText(_ text: String) {
        self.input.insertText(text)
    }

    func deleteBackward() {
        self.input.deleteBackward()
    }
}
