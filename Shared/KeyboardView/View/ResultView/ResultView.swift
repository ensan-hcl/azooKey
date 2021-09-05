//
//  ResultView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol ResultViewItemData {
    var text: String {get}
    var inputable: Bool {get}
}

private final class ResultModelVariableSection<Candidate: ResultViewItemData>: ObservableObject {
    @Published fileprivate var results: [ResultData<Candidate>] = []
    @Published fileprivate var scrollViewProxy: ScrollViewProxy?
}

struct ResultData<Candidate: ResultViewItemData>: Identifiable {
    var id: Int
    var candidate: Candidate
}

struct ResultView<Candidate: ResultViewItemData>: View {
    private let model: ResultModel<Candidate>
    @ObservedObject private var modelVariableSection: ResultModelVariableSection<Candidate>
    @ObservedObject private var sharedResultData: SharedResultData<Candidate>
    @ObservedObject private var variableStates = VariableStates.shared

    @Binding private var isResultViewExpanded: Bool
    @Environment(\.themeEnvironment) private var theme
    @KeyboardSetting(.displayTabBarButton) private var displayTabBarButton

    init(model: ResultModel<Candidate>, isResultViewExpanded: Binding<Bool>, sharedResultData: SharedResultData<Candidate>) {
        self.model = model
        self.modelVariableSection = model.variableSection
        self.sharedResultData = sharedResultData
        self._isResultViewExpanded = isResultViewExpanded
    }

    private var buttonHeight: CGFloat {
        Design.resultViewHeight()*0.6
    }

    private var tabBarButtonBackgroundColor: Color {
        ColorTools.hsv(theme.resultBackgroundColor.color) { h, s, v, a in
            return Color(hue: h, saturation: s, brightness: min(1, 0.7 * v + 0.3), opacity: min(1, 0.8 * a + 0.2 ))
        } ?? theme.normalKeyFillColor.color
    }

    private var tabBarButtonLabelColor: Color {
        theme.resultTextColor.color
    }

    var body: some View {
        Group {
            if variableStates.showMoveCursorBar {
                MoveCursorBar()
            } else if variableStates.showTabBar {
                let tabBarData = (try? CustardManager.load().tabbar(identifier: 0)) ?? .default
                TabBarView(data: tabBarData)
            } else {
                Group { [weak modelVariableSection] in
                    let results: [ResultData<Candidate>] = modelVariableSection?.results ?? []
                    if results.isEmpty  {
                        HStack {
                            Spacer()
                            Button {
                                variableStates.action.registerAction(.toggleTabBar)
                            } label: {
                                ZStack {
                                    if displayTabBarButton {
                                        Circle()
                                            .strokeAndFill(fillContent: tabBarButtonBackgroundColor, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
                                            .frame(width: Design.resultViewHeight()*0.8, height: Design.resultViewHeight()*0.8)
                                        AzooKeyIcon(fixedSize: Design.resultViewHeight()*0.6, color: .color(tabBarButtonLabelColor))
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                            .frame(height: buttonHeight)
                            .padding(.all, 5)
                            Spacer()
                        }
                        .background(Color.init(.sRGB, white: 1, opacity: 0.001))
                        .onLongPressGesture {
                            variableStates.action.registerAction(.toggleTabBar)
                        }
                    } else {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScrollViewReader {scrollViewProxy in
                                    LazyHStack(spacing: 10) {
                                        ForEach(results, id: \.id) {(data: ResultData<Candidate>) in
                                            if data.candidate.inputable {
                                                Button(data.candidate.text) {
                                                    Sound.click()
                                                    self.pressed(candidate: data.candidate)
                                                }
                                                .buttonStyle(ResultButtonStyle(height: buttonHeight))
                                                .contextMenu {
                                                    ResultContextMenuView(text: data.candidate.text)
                                                }
                                                .id(data.id)
                                            } else {
                                                Text(data.candidate.text)
                                                    .font(Design.fonts.resultViewFont(theme: theme))
                                                    .underline(true, color: .accentColor)
                                            }
                                        }
                                    }.onAppear {
                                        modelVariableSection?.scrollViewProxy = scrollViewProxy
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                            // 候補を展開するボタン
                            Button(action: {
                                self.expand()
                            }) {
                                Image(systemName: "chevron.down")
                                    .font(Design.fonts.iconImageFont(theme: theme))
                                    .frame(height: 18)
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

    private func pressed(candidate: Candidate) {
        variableStates.action.notifyComplete(candidate)
    }

    private func expand() {
        self.isResultViewExpanded = true
        self.sharedResultData.results = self.modelVariableSection.results
    }
}

struct ResultContextMenuView: View {
    private let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        Group {
            Button(action: {
                VariableStates.shared.magnifyingText = text
                VariableStates.shared.isTextMagnifying = true
            }) {
                Text("大きな文字で表示する")
                Image(systemName: "plus.magnifyingglass")
            }
        }
    }
}

struct ResultModel<Candidate: ResultViewItemData> {
    fileprivate var variableSection = ResultModelVariableSection<Candidate>()

    func setResults(_ results: [Candidate]) {
        self.variableSection.results = results.indices.map {ResultData(id: $0, candidate: results[$0])}
        self.scrollTop()
    }

    func scrollTop() {
        if let proxy = self.variableSection.scrollViewProxy {
            proxy.scrollTo(0, anchor: .trailing)
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
