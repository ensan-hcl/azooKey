//
//  EmojiTabResultBar.swift
//  azooKey
//
//  Created by ensan on 2023/03/15.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct EmojiTabResultBar: View {
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    @ObservedObject private var model = VariableStates.shared.resultModelVariableSection
    @ObservedObject private var variableStates = VariableStates.shared
    @Namespace private var namespace
    private var buttonHeight: CGFloat {
        Design.keyboardBarHeight() * 0.9
    }
    private var searchBarHeight: CGFloat {
        Design.keyboardBarHeight() * 0.8
    }
    private var searchBarDesign: InKeyboardSearchBar.Configuration {
        .init(placeholder: "絵文字を検索", theme: theme)
    }
    @State private var searchQuery = ""
    @State private var showResults = false

    var body: some View {
        HStack {
            KeyboardBarButton {
                self.action.registerAction(.setTabBar(.on), variableStates: variableStates)
            }

            if !showResults {
                // 見た目だけ表示しておいて、実際はoverlayのボタンになっている
                InKeyboardSearchBar(text: $searchQuery, configuration: searchBarDesign)
                    .overlay {
                        Rectangle()
                            .fill(Color.background.opacity(0.001))
                            .onTapGesture {
                                self.action.registerActions([
                                    .moveTab(.user_dependent(.japanese)),
                                    .setUpsideComponent(.search([.emoji]))
                                ], variableStates: variableStates)
                            }
                    }
                    .padding(.trailing, 5)
                    .matchedGeometryEffect(id: "SearchBar", in: namespace)
            } else {
                KeyboardBarButton(label: .systemImage("magnifyingglass")) {
                    self.action.registerActions([
                        .moveTab(.user_dependent(.japanese)),
                        .setUpsideComponent(.search([.emoji]))
                    ], variableStates: variableStates)
                }
                .matchedGeometryEffect(id: "SearchBar", in: namespace)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(model.results, id: \.id) {(data: ResultData) in
                            if data.candidate.inputable {
                                Button(data.candidate.text) {
                                    KeyboardFeedback.click()
                                    self.pressed(candidate: data.candidate)
                                }
                                .buttonStyle(EmojiTabResultBarButtonStyle(height: buttonHeight))
                                .contextMenu {
                                    ResultContextMenuView(candidate: data.candidate)
                                }
                            } else {
                                Text(data.candidate.text)
                                    .font(Design.fonts.resultViewFont(theme: theme))
                                    .underline(true, color: .accentColor)
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }.onChange(of: model.results.isEmpty) { newValue in
            if showResults != !newValue {
                withAnimation(.easeIn(duration: 0.2)) {
                    showResults = !newValue
                }
            }
        }
    }

    private func pressed(candidate: any ResultViewItemData) {
        self.action.notifyComplete(candidate, variableStates: variableStates)
    }
}

struct EmojiTabResultBarButtonStyle: ButtonStyle {
    private let height: CGFloat
    @Environment(\.themeEnvironment) private var theme

    init(height: CGFloat) {
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.fonts.resultViewFont(theme: theme, fontSize: height * 0.9))
            .frame(height: height)
            .foregroundColor(theme.resultTextColor.color) // 文字色は常に不透明度1で描画する
            .background(
                configuration.isPressed ?
                    theme.pushedKeyFillColor.color.opacity(0.5) :
                    theme.resultBackgroundColor.color
            )
            .cornerRadius(5.0)
    }
}
