//
//  ChatGPTInteractionTab.swift
//  azooKey
//
//  Created by ensan on 2023/03/10.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import OpenAISwift
import SwiftUI

struct ChatGPTInteractionTab: View {
    struct Message: Codable {
        var role: ChatRole
        var content: String
        var orderType: ChatBasedOrder = .none

        var text: String {
            let newContent: String
            switch self.orderType {
            case .none:
                newContent = content
            case .writeMore:
                newContent = "「\(content)」の続きを書いてください"
            case .summary:
                newContent = "「\(content)」を要約してください"
            case .makeBetter:
                newContent = "「\(content)」の印象をよくしてください"
            case .checkErrors:
                newContent = "「\(content)」を校閲してください"
            case .englishTranslation:
                newContent = "「\(content)」を英語翻訳してください"
            }
            return newContent
        }

        func toChatMessage() -> ChatMessage {
            .init(role: role, content: text)
        }
    }

    enum ChatBasedOrder: UInt8, Codable {
        case none
        case writeMore
        case makeBetter
        case checkErrors
        case summary
        case englishTranslation
    }

    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.userActionManager) private var action
    @State private var lastIndex = 0
    @State private var userPrompt = ""
    @State private var lastInsertedText: String?
    @State private var messages: [Message] = [.init(role: .assistant, content: "知りたいことや、やりたいことを教えてください！")]
    @FocusState private var textEditorFocused
    private let openAI = OpenAISwift(authToken: "")

    private var textEditorConfig: InKeyboardTextEditor.Configuration {
        .init(backgroundColor: .background)
    }
    var tabDependentDesign: TabDependentDesign {
        TabDependentDesign(width: 7, height: 4, layout: .flick, orientation: VariableStates.shared.keyboardOrientation)
    }

    private func backgroundColor(role: ChatRole) -> Color {
        switch role {
        case .system:
            return .gray
        case .user:
            return .green
        case .assistant:
            return .background
        }
    }

    private func chatPrompt(_ type: ChatBasedOrder, userContent: String) {
        if !userContent.isEmpty {
            self.appendMessage(.init(role: .user, content: userContent, orderType: type))
            self.userPrompt = ""

            Task {
                do {
                    let systemContent: String
                    switch type {
                    case .makeBetter: systemContent = "Rewrite the given text in a way that makes a good impression on native speakers of the language, and then return the rewriten text. If you explain points, use user language. Keep tone of the given text."
                    case .summary: systemContent = "Shorten the given text with small loss of information in given language. No translation is required."
                    case .checkErrors: systemContent = "Check grammatical or stylistic errors, inconsistencies, and other non-fluent points, and return text which explains the errors in user language. If the given text is perfect, just praise it in user language."
                    case .writeMore: systemContent = "Write the content which continues from user's input in given language."
                    case .englishTranslation: systemContent = "Translate Japanese to English."
                    case .none: systemContent = "You are native Japanese speaker and you should answer in Japanese. Be positive and friendly!"
                    }
                    let messages: [ChatMessage] = [
                        .init(role: .system, content: systemContent),
                        .init(role: .user, content: userContent)
                    ]
                    debug("ChatGPTInteractionTab send input", userContent, type)
                    let result = try await openAI.sendChat(with: messages, model: .chat(.chatgpt))
                    if let response = result.choices.first?.message {
                        self.appendMessage(.init(role: .assistant, content: response.content))
                    }
                } catch {
                    self.requestError(error)
                }
            }
        }
    }

    private var promptSuggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if userPrompt.isEmpty {
                    Button("ペースト") {
                        action.registerAction(.paste)
                    }
                }
                if let lastInsertedText {
                    Button("取り消し") {
                        action.setTextDocumentProxy(.preference(.main))
                        action.registerAction(.delete(lastInsertedText.count))
                        self.lastInsertedText = nil
                        action.setTextDocumentProxy(.preference(.ikTextField))
                    }
                    .onChange(of: variableStates.textChangedCount) { _ in
                        self.lastInsertedText = nil
                    }
                } else if messages.count > 1, let last = messages.last, last.role == .assistant {
                    Button("回答を入力") {
                        self.input(last.content)
                    }
                }
                if !userPrompt.isEmpty {
                    Button("好印象にする") {
                        chatPrompt(.makeBetter, userContent: userPrompt)
                    }
                    Button("英語翻訳") {
                        chatPrompt(.englishTranslation, userContent: userPrompt)
                    }
                    Button("校閲") {
                        chatPrompt(.checkErrors, userContent: userPrompt)
                    }
                    Button("要約") {
                        chatPrompt(.summary, userContent: userPrompt)
                    }
                }
                Button("閉じる") {
                    action.registerAction(.setUpsideComponent(nil))
                }
            }
        }
        .frame(height: tabDependentDesign.keyViewHeight * 0.5)
        .buttonStyle(.bordered)
    }

    private struct ResponseWaitingView: View {
        private let startDate = Date()
        private let circleCount = 5
        private let interval = 0.2
        private let circleSize = 11.0

        var body: some View {
            TimelineView(.periodic(from: startDate, by: interval)) { context in
                let selection = Int((context.date.timeIntervalSince(startDate)) / interval) % (circleCount)
                HStack(spacing: 5) {
                    ForEach(0..<circleCount, id: \.self) { index in
                        Circle()
                            .fill(Color.systemGray5)
                            .frame(width: circleSize, height: circleSize)
                            .scaleEffect(index == selection ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: interval), value: selection)
                    }
                }
            }
        }
    }

    private var responseWaitingView: some View {
        ResponseWaitingView()
            .padding(8)
            .background(self.backgroundColor(role: .assistant))
            .cornerRadius(12)
            .foregroundColor(Color.primary)
            .padding(.horizontal, 10)
    }

    @ViewBuilder
    private func messageView(_ message: Message) -> some View {
        Text(message.text)
            .padding(8)
            .background(self.backgroundColor(role: message.role))
            .cornerRadius(12)
            .foregroundColor(Color.primary)
            .padding(.horizontal, 10)
            .contextMenu {
                Button {
                    self.input(message.text)
                } label: {
                    Label("この文章を入力する", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                Button {
                    UIPasteboard.general.string = message.text
                } label: {
                    Label("この文章をコピーする", systemImage: "doc.on.doc.fill")
                }
            }
    }

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    Group {
                        ForEach(messages.indices, id: \.self) { i in
                            VStack {
                                switch messages[i].role {
                                case .user:
                                    HStack {
                                        Spacer()
                                        messageView(messages[i])
                                    }
                                case .system:
                                    HStack {
                                        Spacer()
                                        messageView(messages[i])
                                        Spacer()
                                    }
                                case .assistant:
                                    HStack {
                                        messageView(messages[i])
                                        Spacer()
                                    }
                                }
                                // 末尾に追加する
                                if i == messages.endIndex - 1 && messages[i].role == .user {
                                    HStack {
                                        responseWaitingView
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: lastIndex) { newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .bottom)
                        }
                    }
                }
            }
            VStack {
                promptSuggestions
                HStack {
                    InKeyboardTextEditor(text: $userPrompt, configuration: textEditorConfig)
                        .frame(width: tabDependentDesign.keyViewWidth(widthCount: 6), height: tabDependentDesign.keyViewHeight)
                        .cornerRadius(12)
                        .focused($textEditorFocused)
                    Button {
                        guard !userPrompt.isEmpty else {
                            return
                        }
                        self.appendMessage(Message(role: .user, content: userPrompt, orderType: .none))
                        self.userPrompt = ""
                        Task {
                            do {
                                let messages: [ChatMessage] = [.init(role: .system, content: "You are native Japanese speaker and you should answer in Japanese. Be positive and friendly!")] + Array(self.messages.dropFirst().suffix(10).map {$0.toChatMessage()})
                                debug("ChatGPTInteractionTab send messages", messages)
                                let response = try await openAI.sendChat(with: messages, model: .chat(.chatgpt))
                                let result = response.choices
                                if let response = result.first?.message {
                                    self.appendMessage(Message(role: response.role, content: response.content))
                                }
                            } catch {
                                self.requestError(error)
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(Font.system(size: tabDependentDesign.keyViewHeight * 0.5))
                            .frame(width: tabDependentDesign.keyViewWidth, height: tabDependentDesign.keyViewHeight)
                    }
                }
            }
        }
        .onAppear {
            self.textEditorFocused = true
        }
    }

    private func appendMessage(_ message: Message) {
        self.messages.append(message)
        self.lastIndex = self.messages.endIndex - 1
    }

    private func input(_ text: String) {
        self.action.registerAction(.insertMainDisplay(text))
        self.lastInsertedText = text
    }

    private func requestError(_ error: Error, line: Int = #line) {
        #if DEBUG
        debug("ChatGPTInteractionTab error at \(line)", error)
        self.appendMessage(Message(role: .system, content: "エラーが発生しました。\(error.localizedDescription)"))
        #else
        self.appendMessage(Message(role: .system, content: "エラーが発生しました。"))
        #endif
    }
}
