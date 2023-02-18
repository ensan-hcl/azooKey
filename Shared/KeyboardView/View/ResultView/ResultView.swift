//
//  ResultView.swift
//  azooKey
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: Candidateを直接やりとりするのをやめて、(ID, text, inputtable, debugInfo)あたりを持った構造体として扱うようにする。
// TODO: こうすることでCandidateをジェネリックにしないで済むので、ResultModelVariableSectionをやめてVariableStatesに統合できる。
enum ResultViewItemDataType: Hashable {
    case candidate, information, predictionCandidate
}
protocol ResultViewItemData: Hashable, Identifiable<Int> {
    var text: String {get}
    var dataType: ResultViewItemDataType {get}
    #if DEBUG
    func getDebugInformation() -> String
    #endif
}

extension ResultViewItemData {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(dataType)
    }
}

extension ResultViewItemData {
    var id: Int {
        self.hashValue
    }
}

final class ResultModelVariableSection<Candidate: ResultViewItemData>: ObservableObject {
    @Published fileprivate var results: [Candidate] = []
    @Published fileprivate var scrollViewProxy: ScrollViewProxy?

    func setResults(_ results: [Candidate]) {
        self.results = results
        if let proxy = scrollViewProxy {
            proxy.scrollTo(0, anchor: .trailing)
        }
    }
}

struct ResultView<Candidate: ResultViewItemData>: View {
    @ObservedObject private var model: ResultModelVariableSection<Candidate>
    @ObservedObject private var variableStates = VariableStates.shared
    @Binding private var resultData: [Candidate]
    @Binding private var isResultViewExpanded: Bool

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    @KeyboardSetting(.displayTabBarButton) private var displayTabBarButton

    init(model: ResultModelVariableSection<Candidate>, isResultViewExpanded: Binding<Bool>, resultData: Binding<[Candidate]>) {
        self.model = model
        self._resultData = resultData
        self._isResultViewExpanded = isResultViewExpanded
    }

    private var buttonWidth: CGFloat {
        Design.resultViewHeight() * 0.5
    }
    private var buttonHeight: CGFloat {
        Design.resultViewHeight() * 0.6
    }

    private var tabBarButtonBackgroundColor: Color {
        ColorTools.hsv(theme.resultBackgroundColor.color) { h, s, v, a in
            Color(hue: h, saturation: s, brightness: min(1, 0.7 * v + 0.3), opacity: min(1, 0.8 * a + 0.2 ))
        } ?? theme.normalKeyFillColor.color
    }

    private var tabBarButtonLabelColor: Color {
        theme.resultTextColor.color
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
                Group { [unowned model] in
                    let results: [Candidate] = model.results
                    if results.isEmpty {
                        HStack {
                            Spacer()
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
                            .frame(height: buttonHeight)
                            .padding(.all, 5)
                            Spacer()
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
                                        ForEach(results, id: \.id) {(data: Candidate) in
                                            ResultItemView(data: data, buttonHeight: buttonHeight)
                                                .id(data.id)
                                        }
                                    }.onAppear {
                                        model.scrollViewProxy = scrollViewProxy
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                            // 候補を展開するボタン
                            Button(action: {
                                self.expand()
                            }) {
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
                .frame(height: Design.resultViewHeight())

            }
        }
    }

    private func expand() {
        self.isResultViewExpanded = true
        self.resultData = self.model.results
    }
}

struct ResultItemView<Candidate: ResultViewItemData>: View {
    init(data: Candidate, buttonHeight: CGFloat) {
        self.data = data
        self.buttonHeight = buttonHeight
    }

    private var data: Candidate
    private var buttonHeight: CGFloat
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    private func pressed(candidate: Candidate) {
        self.action.notifyComplete(candidate)
    }

    var body: some View {
        switch data.dataType {
        case .candidate:
            Button(data.text) {
                Sound.click()
                self.pressed(candidate: data)
            }
            .buttonStyle(ResultButtonStyle(height: buttonHeight))
            .contextMenu {
                ResultContextMenuView(candidate: data)
            }
        case .information:
            Text(data.text)
                .font(Design.fonts.resultViewFont(theme: theme))
                .underline(true, color: .accentColor)
        case .predictionCandidate:
            Button {
                Sound.click()
                self.pressed(candidate: data)
            } label: {
                Label(data.text, systemImage: "lightbulb")
            }
            .buttonStyle(ResultButtonStyle(height: buttonHeight))
            .contextMenu {
                ResultContextMenuView(candidate: data)
            }
        }
    }
}

struct ResultContextMenuView<Candidate: ResultViewItemData>: View {
    private let candidate: Candidate

    init(candidate: Candidate) {
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
            Button(action: {
                debug(self.candidate)
            }) {
                Text("デバッグ情報を詳細に表示する")
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
