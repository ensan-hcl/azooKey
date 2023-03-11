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
    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.userActionManager) private var action
    @State private var userPrompt = ""
    @State private var messages: [ChatMessage] = [.init(role: .assistant, content: "知りたいことや、やりたいことを教えてください！")]
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
    @ViewBuilder
    private func messageView(_ message: ChatMessage) -> some View {
        Text(message.content)
            .padding(8)
            .background(self.backgroundColor(role: message.role))
            .cornerRadius(12)
            .foregroundColor(Color.primary)
            .padding(.horizontal, 10)
            .contextMenu {
                Button {
                    action.registerAction(.insertMainDisplay(message.content))
                } label: {
                    Label("この文章を入力する", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
            }
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    action.registerAction(.setUpsideComponent(nil))
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ScrollView {
                ForEach(messages.indices, id: \.self) { i in
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
                }
            }
            HStack {
                InKeyboardTextEditor(text: $userPrompt, configuration: textEditorConfig)
                    .frame(width: tabDependentDesign.keyViewWidth(widthCount: 6), height: tabDependentDesign.keyViewHeight)
                    .cornerRadius(12)
                    .focused($textEditorFocused)
                Button {
                    guard !userPrompt.isEmpty else {
                        return
                    }
                    self.messages.append(ChatMessage(role: .user, content: userPrompt))
                    self.userPrompt = ""
                    Task {
                        do {
                            let messages: [ChatMessage] = [.init(role: .system, content: "You are native Japanese speaker and you should answer in Japanese. Be positive and friendly!")] + Array(self.messages.dropFirst().suffix(10))
                            debug("ChatGPTInteractionTab send messages", messages)
                            let response = try await openAI.sendChat(with: messages, model: .chat(.chatgpt))
                            let result = response.choices
                            if let responseMessage = result.first?.message {
                                self.messages.append(responseMessage)
                            }
                        } catch {
                            #if DEBUG
                            debug("ChatGPTInteractionTab error", error)
                            self.messages.append(ChatMessage(role: .system, content: "エラーが発生しました。\(error.localizedDescription)"))
                            #else
                            self.messages.append(ChatMessage(role: .system, content: "エラーが発生しました。"))
                            #endif
                        }
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(Font.system(size: tabDependentDesign.keyViewHeight * 0.5))
                        .frame(width: tabDependentDesign.keyViewWidth, height: tabDependentDesign.keyViewHeight)
                }
            }
        }
        .onAppear {
            self.textEditorFocused = true
        }
    }
}
