//
//  ResultBar.swift
//  azooKey
//
//  Created by ensan on 2023/03/19.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

protocol ResultViewItemData {
    var text: String {get}
    var inputable: Bool {get}
    #if DEBUG
    func getDebugInformation() -> String
    #endif
}

final class ResultModelVariableSection: ObservableObject {
    @Published var results: [ResultData] = []
    @Published var searchResults: [ResultData] = []
    @Published var updateResult: Bool = false

    func setResults(_ results: [any ResultViewItemData]) {
        self.results = results.indices.map {ResultData(id: $0, candidate: results[$0])}
        self.updateResult.toggle()
    }
    func setSearchResults(_ results: [any ResultViewItemData]) {
        self.searchResults = results.indices.map {ResultData(id: $0, candidate: results[$0])}
    }
}

struct ResultData: Identifiable {
    var id: Int
    var candidate: any ResultViewItemData
}

struct ResultBar: View {
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    @ObservedObject private var model = VariableStates.shared.resultModelVariableSection
    @ObservedObject private var variableStates = VariableStates.shared
    @Binding private var isResultViewExpanded: Bool
    @KeyboardSetting(.displayTabBarButton) private var displayTabBarButton

    private var buttonWidth: CGFloat {
        Design.keyboardBarHeight() * 0.5
    }
    private var buttonHeight: CGFloat {
        Design.keyboardBarHeight() * 0.6
    }

    init(isResultViewExpanded: Binding<Bool>) {
        self._isResultViewExpanded = isResultViewExpanded
    }

    var body: some View {
        if model.results.isEmpty {
            CenterAlignedView {
                if displayTabBarButton {
                    KeyboardBarButton {
                        self.action.registerAction(.setTabBar(.toggle), variableStates: variableStates)
                    }
                }
            }
            .background(Color(.sRGB, white: 1, opacity: 0.001))
            .onLongPressGesture {
                self.action.registerAction(.setTabBar(.toggle), variableStates: variableStates)
            }
        } else {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader {scrollViewProxy in
                        LazyHStack(spacing: 10) {
                            ForEach(model.results, id: \.id) {(data: ResultData) in
                                if data.candidate.inputable {
                                    Button(data.candidate.text) {
                                        KeyboardFeedback.click()
                                        self.pressed(candidate: data.candidate)
                                    }
                                    .buttonStyle(ResultButtonStyle(height: buttonHeight))
                                    .contextMenu {
                                        ResultContextMenuView(candidate: data.candidate)
                                    }
                                    .id(data.id)
                                } else {
                                    Text(data.candidate.text)
                                        .font(Design.fonts.resultViewFont(theme: theme))
                                        .underline(true, color: .accentColor)
                                }
                            }
                        }.onChange(of: model.updateResult) { _ in
                            scrollViewProxy.scrollTo(0, anchor: .trailing)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                // 候補を展開するボタン
                Button(action: self.expand) {
                    ZStack {
                        Color(white: 1, opacity: 0.001)
                            .frame(width: buttonWidth)
                        Image(systemName: "chevron.down")
                            .font(Design.fonts.iconImageFont(theme: theme))
                            .frame(height: 18)
                    }
                }
                .buttonStyle(ResultButtonStyle(height: buttonHeight))
                .padding(.trailing, 10)
            }
        }
    }

    private func pressed(candidate: any ResultViewItemData) {
        self.action.notifyComplete(candidate, variableStates: variableStates)
    }

    private func expand() {
        self.isResultViewExpanded = true
    }
}

struct ResultContextMenuView: View {
    private let candidate: any ResultViewItemData

    init(candidate: any ResultViewItemData) {
        self.candidate = candidate
    }

    var body: some View {
        Group {
            Button(action: {
                VariableStates.shared.magnifyingText = candidate.text
                VariableStates.shared.boolStates.isTextMagnifying = true
            }) {
                Text("大きな文字で表示する")
                Image(systemName: "plus.magnifyingglass")
            }
            #if DEBUG
            Button(action: {
                debug(self.candidate.getDebugInformation())
            }) {
                Text("デバッグ情報を表示する")
                Image(systemName: "ladybug.fill")
            }
            #endif
        }
    }
}

struct ResultButtonStyle: ButtonStyle {
    private let height: CGFloat
    @Environment(\.themeEnvironment) private var theme

    init(height: CGFloat) {
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.fonts.resultViewFont(theme: theme))
            .frame(height: height)
            .padding(.all, 5)
            .foregroundColor(theme.resultTextColor.color) // 文字色は常に不透明度1で描画する
            .background(
                configuration.isPressed ?
                    theme.pushedKeyFillColor.color.opacity(0.5) :
                    theme.resultBackgroundColor.color
            )
            .cornerRadius(5.0)
    }
}
