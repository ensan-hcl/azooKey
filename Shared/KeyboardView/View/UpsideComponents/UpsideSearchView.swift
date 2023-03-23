//
//  UpsideSearchView.swift
//  Keyboard
//
//  Created by ensan on 2023/03/17.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct UpsideSearchView: View {
    @Environment(\.userActionManager) private var action
    @Environment(\.themeEnvironment) private var theme

    @ObservedObject private var variableStates = VariableStates.shared
    @ObservedObject private var model = VariableStates.shared.resultModelVariableSection
    @State private var searchQuery = ""
    @FocusState private var searchBarFocus
    private let target: [ConverterBehaviorSemantics.ReplacementTarget]
    private var buttonHeight: CGFloat {
        Design.keyboardBarHeight() * 0.9
    }
    private var searchBarHeight: CGFloat {
        Design.keyboardBarHeight() * 0.8
    }

    init(target: [ConverterBehaviorSemantics.ReplacementTarget]) {
        self.target = target
    }

    private var searchBarDesign: InKeyboardSearchBar.Configuration {
        .init(placeholder: "絵文字を検索", clearButtonMode: .always, theme: theme)
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(model.searchResults, id: \.id) {(data: ResultData) in
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
            HStack {
                InKeyboardSearchBar(text: $searchQuery, configuration: searchBarDesign)
                    .focused($searchBarFocus)
                    .frame(height: searchBarHeight)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                    .onChange(of: searchQuery) { _ in
                        self.action.registerAction(.setSearchQuery(searchQuery, target), variableStates: variableStates)
                    }
                KeyboardBarButton(label: .systemImage("face.smiling")) {
                    self.action.setTextDocumentProxy(.preference(.main))
                    self.action.registerActions([.setUpsideComponent(nil), .moveTab(.existential(.special(.emoji)))], variableStates: variableStates)
                }
                KeyboardBarButton(label: .systemImage("arrowtriangle.down.fill")) {
                    self.action.registerAction(.setUpsideComponent(nil), variableStates: variableStates)
                    self.action.setTextDocumentProxy(.preference(.main))
                }
            }
        }
        .onAppear {
            self.searchBarFocus = true
            self.action.setTextDocumentProxy(.preference(.ikTextField))
        }
        .onDisappear {
            self.model.searchResults = []
            self.searchBarFocus = false
        }
    }
    private func pressed(candidate: any ResultViewItemData) {
        self.action.registerAction(.insertMainDisplay(candidate.text), variableStates: variableStates)
    }
}
