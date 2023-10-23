//
//  UpsideSearchView.swift
//  Keyboard
//
//  Created by ensan on 2023/03/17.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI
import enum KanaKanjiConverterModule.ConverterBehaviorSemantics

@MainActor
struct UpsideSearchView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @Environment(\.userActionManager) private var action
    @Environment(Extension.Theme.self) private var theme
    @EnvironmentObject private var variableStates: VariableStates
    @State private var searchQuery = ""
    private let target: [ConverterBehaviorSemantics.ReplacementTarget]
    private var buttonHeight: CGFloat {
        Design.keyboardBarHeight(interfaceHeight: variableStates.interfaceSize.height, orientation: variableStates.keyboardOrientation) * 0.9
    }
    private var searchBarHeight: CGFloat {
        Design.keyboardBarHeight(interfaceHeight: variableStates.interfaceSize.height, orientation: variableStates.keyboardOrientation) * 0.8
    }

    init(target: [ConverterBehaviorSemantics.ReplacementTarget]) {
        self.target = target
    }

    private var searchBarDesign: InKeyboardSearchBar<Extension>.Configuration {
        .init(placeholder: "絵文字を検索", clearButtonMode: .always, theme: theme)
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(variableStates.resultModel.searchResults, id: \.id) {(data: ResultData) in
                        if data.candidate.inputable {
                            Button(data.candidate.text) {
                                KeyboardFeedback<Extension>.click()
                                self.pressed(candidate: data.candidate)
                            }
                            .buttonStyle(EmojiTabResultBarButtonStyle<Extension>(height: buttonHeight))
                            .contextMenu {
                                ResultContextMenuView(candidate: data.candidate, displayResetLearningButton: false)
                            }
                        } else {
                            Text(data.candidate.text)
                                .font(Design.fonts.resultViewFont(theme: theme, userSizePrefrerence: Extension.SettingProvider.resultViewFontSize))
                                .underline(true, color: .accentColor)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            HStack {
                InKeyboardSearchBar<Extension>(text: $searchQuery, configuration: searchBarDesign, initiallyFocused: true)
                    .frame(height: searchBarHeight)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                    .onChange(of: searchQuery) { _ in
                        self.action.registerAction(.setSearchQuery(searchQuery, target), variableStates: variableStates)
                    }
                KeyboardBarButton<Extension>(label: .systemImage("face.smiling")) {
                    self.action.setTextDocumentProxy(.preference(.main))
                    self.action.registerActions([.setUpsideComponent(nil), .moveTab(.system(.emoji_tab))], variableStates: variableStates)
                }
                KeyboardBarButton<Extension>(label: .systemImage("arrowtriangle.down.fill")) {
                    self.action.setTextDocumentProxy(.preference(.main))
                    self.action.registerAction(.setUpsideComponent(nil), variableStates: variableStates)
                }
            }
        }
        .onAppear {
            self.action.setTextDocumentProxy(.preference(.ikTextField))
        }
        .onDisappear {
            self.variableStates.resultModel.setSearchResults([])
        }
    }
    private func pressed(candidate: any ResultViewItemData) {
        self.action.registerAction(.insertMainDisplay(candidate.text), variableStates: variableStates)
    }
}
