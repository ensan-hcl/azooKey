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
                action.setInKeyboardProxy(proxyWrapper.proxy)
            }
            .onDisappear {
                action.setInKeyboardProxy(nil)
            }
            .onChange(of: proxyWrapper) { newValue in
                action.setInKeyboardProxy(newValue.proxy)
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
        // カーソル位置は`selectedTextRange`で取得できる。
        if let start = self.input.selectedTextRange?.start,
           let range = self.input.textRange(from: self.input.beginningOfDocument, to: start) {
            return self.input.text(in: range)
        }
        return nil
    }

    var documentContextAfterInput: String? {
        // カーソル位置は`selectedTextRange`で取得できる。
        if let end = self.input.selectedTextRange?.end,
           let range = self.input.textRange(from: end, to: self.input.endOfDocument) {
            return self.input.text(in: range)
        }
        return nil
    }

    var selectedText: String? {
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
        self.input.unmarkText()
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

private struct TextViewWrapper: UIViewRepresentable {
    @Binding var proxyWrapper: UITextDocumentProxyWrapper
    @Binding var text: String
    var configuration: InKeyboardTextEditor.Configuration

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let view = UITextView(frame: .zero)

        view.delegate = context.coordinator
        view.backgroundColor = configuration.backgroundColor.map(UIColor.init)
        view.font = configuration.font
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.sizeToFit()
        proxyWrapper.proxy = CustomTextDocumentProxy(input: view)
        return view
    }

    func updateUIView(_ view: UITextView, context: UIViewRepresentableContext<Self>) {
        if view.text != text {
            Task {
                view.text = text
            }
        }
    }

    func makeCoordinator() -> Self.Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
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
    }
}
