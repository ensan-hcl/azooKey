//
//  InKeyboardTextEditor.swift
//  azooKey
//
//  Created by ensan on 2023/03/08.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct InKeyboardTextEditor: View {
    init(text: Binding<String>, configuration: Configuration) {
        self._text = text
        self.configuration = configuration
    }
    struct Configuration {
        var backgroundColor: Color?
        var font: UIFont?
    }

    private let configuration: Configuration
    @Binding private var text: String
    @State private var proxyWrapper = UITextDocumentProxyWrapper()
    @Environment(\.userActionManager) private var action

    var body: some View {
        TextViewWrapper(proxyWrapper: $proxyWrapper, text: $text, configuration: configuration)
            .onAppear {
                action.setTextDocumentProxy(.ikTextFieldProxy(proxyWrapper.proxy))
                action.setTextDocumentProxy(.preference(.ikTextField))
            }
            .onDisappear {
                action.setTextDocumentProxy(.ikTextFieldProxy(nil))
                action.setTextDocumentProxy(.preference(.main))
            }
            .onChange(of: proxyWrapper) { newValue in
                action.setTextDocumentProxy(.ikTextFieldProxy(newValue.proxy))
                action.setTextDocumentProxy(.preference(.ikTextField))
            }
    }
}

private struct UITextDocumentProxyWrapper: Equatable, Hashable {
    private var updateDate: Date = Date()
    var proxy: UITextDocumentProxy? {
        didSet {
            updateDate = Date()
        }
    }

    static func == (lhs: UITextDocumentProxyWrapper, rhs: UITextDocumentProxyWrapper) -> Bool {
        lhs.updateDate == rhs.updateDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(updateDate)
    }
}

private final class CustomTextDocumentProxy: NSObject, UITextDocumentProxy {
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

protocol IKTextEditor {
    var isInKeyboard: Bool { get }
}

final class IKTextView: UITextView, IKTextEditor {
    var isInKeyboard: Bool {
        true
    }
}

private struct TextViewWrapper: UIViewRepresentable {
    @Binding var proxyWrapper: UITextDocumentProxyWrapper
    @Binding var text: String
    @Environment(\.userActionManager) private var action
    var configuration: InKeyboardTextEditor.Configuration

    func makeUIView(context: UIViewRepresentableContext<Self>) -> IKTextView {
        let view = IKTextView(frame: .zero)

        view.delegate = context.coordinator
        // inputDelegateの調整
        view.inputDelegate = context.coordinator

        view.backgroundColor = configuration.backgroundColor.map(UIColor.init)
        view.font = configuration.font
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.sizeToFit()
        proxyWrapper.proxy = CustomTextDocumentProxy(input: view)
        return view
    }

    func updateUIView(_ view: IKTextView, context: UIViewRepresentableContext<Self>) {
        if view.text != text {
            Task {
                view.text = text
            }
        }
    }

    func makeCoordinator() -> Self.Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate, UITextInputDelegate {
        var parent: TextViewWrapper

        init(parent: TextViewWrapper) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ view: UITextView) {
            parent.text = view.text ?? ""
            parent.proxyWrapper.proxy = CustomTextDocumentProxy(input: view)
        }

        func textViewDidChange(_ view: UITextView) {
            parent.text = view.text ?? ""
        }

        func textViewDidChangeSelection(_ view: UITextView) {
            parent.text = view.text ?? ""
        }

        func textViewDidEndEditing(_ view: UITextView) {
            parent.text = view.text ?? ""
            parent.proxyWrapper.proxy = nil
        }

        func notifyWillChange(_ textInput: UITextInput) {
            let proxy = CustomTextDocumentProxy(input: textInput)
            self.parent.action.notifySomethingWillChange(
                left: proxy.documentContextBeforeInput ?? "",
                center: proxy.selectedText ?? "",
                right: proxy.documentContextAfterInput ?? ""
            )
        }

        func notifyDidChange(_ textInput: UITextInput) {
            let proxy = CustomTextDocumentProxy(input: textInput)
            self.parent.action.notifySomethingDidChange(
                a_left: proxy.documentContextBeforeInput ?? "",
                a_center: proxy.selectedText ?? "",
                a_right: proxy.documentContextAfterInput ?? ""
            )
            self.parent.action.setTextDocumentProxy(.preference(.ikTextField))
            VariableStates.shared.setUIReturnKeyType(type: .default)
        }

        // MARK: こちらで`textWillChange`などをハンドルすることで、`KeyboardViewController`では扱われなくなる
        func selectionWillChange(_ textInput: UITextInput?) {
            debug("TextViewWrapper.Coordinator.selectionWillChange")
            guard let textInput else {
                return
            }
            self.notifyWillChange(textInput)
        }

        func selectionDidChange(_ textInput: UITextInput?) {
            debug("TextViewWrapper.Coordinator.selectionDidChange")
            guard let textInput else {
                return
            }
            self.notifyDidChange(textInput)
        }

        func textWillChange(_ textInput: UITextInput?) {
            debug("TextViewWrapper.Coordinator.textWillChange")
            guard let textInput else {
                return
            }
            self.notifyWillChange(textInput)
        }

        func textDidChange(_ textInput: UITextInput?) {
            debug("TextViewWrapper.Coordinator.textDidChange")
            guard let textInput else {
                return
            }
            self.notifyDidChange(textInput)
        }
    }
}
