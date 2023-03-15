//
//  ResultView.swift
//  azooKey
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
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
    @Published var updateResult: Bool = false

    func setResults(_ results: [any ResultViewItemData]) {
        self.results = results.indices.map {ResultData(id: $0, candidate: results[$0])}
        self.updateResult.toggle()
    }
}

struct ResultData: Identifiable {
    var id: Int
    var candidate: any ResultViewItemData
}

struct ResultView: View {
    @ObservedObject private var variableStates = VariableStates.shared
    @Binding private var isResultViewExpanded: Bool
    @Environment(\.themeEnvironment) private var theme

    init(isResultViewExpanded: Binding<Bool>) {
        self._isResultViewExpanded = isResultViewExpanded
    }

    var body: some View {
        Group { [unowned variableStates] in
            switch variableStates.barState {
            case .cursor:
                MoveCursorBar()
            case .tab:
                let tabBarData = (try? CustardManager.load().tabbar(identifier: 0)) ?? .default
                TabBarView(data: tabBarData)
            case .none:
                switch variableStates.tabManager.tab {
                case let .existential(.special(tab)) where tab == .clipboard_history_tab:
                    ResultBar(isResultViewExpanded: $isResultViewExpanded)
                default:
                    ResultBar(isResultViewExpanded: $isResultViewExpanded)
                }
            }
        }
        .frame(height: Design.resultViewHeight())
    }
}

struct TabBarButton: View {
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    @KeyboardSetting(.displayTabBarButton) private var displayTabBarButton

    private var tabBarButtonBackgroundColor: Color {
        ColorTools.hsv(theme.resultBackgroundColor.color) { h, s, v, a in
            Color(hue: h, saturation: s, brightness: min(1, 0.7 * v + 0.3), opacity: min(1, 0.8 * a + 0.2 ))
        } ?? theme.normalKeyFillColor.color
    }

    private var tabBarButtonLabelColor: Color {
        theme.resultTextColor.color
    }

    var body: some View {
        Button {
            self.action.registerAction(.setTabBar(.toggle))
        } label: {
            ZStack {
                if displayTabBarButton {
                    Circle()
                        .strokeAndFill(fillContent: tabBarButtonBackgroundColor, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
                        .frame(width: Design.resultViewHeight() * 0.8, height: Design.resultViewHeight() * 0.8)
                    AzooKeyIcon(fixedSize: Design.resultViewHeight() * 0.6, color: .color(tabBarButtonLabelColor))
                } else {
                    EmptyView()
                }
            }
        }
        .frame(height: Design.resultViewHeight() * 0.6)
        .padding(.all, 5)
    }
}

struct ResultBar: View {
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    @ObservedObject private var model = VariableStates.shared.resultModelVariableSection
    @Binding private var isResultViewExpanded: Bool

    private var buttonWidth: CGFloat {
        Design.resultViewHeight() * 0.5
    }
    private var buttonHeight: CGFloat {
        Design.resultViewHeight() * 0.6
    }

    init(isResultViewExpanded: Binding<Bool>) {
        self._isResultViewExpanded = isResultViewExpanded
    }

    var body: some View {
        if model.results.isEmpty {
            CenterAlignedView {
                TabBarButton()
            }
            .background(Color(.sRGB, white: 1, opacity: 0.001))
            .onLongPressGesture {
                self.action.registerAction(.setTabBar(.toggle))
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
        self.action.notifyComplete(candidate)
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
