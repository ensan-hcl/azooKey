//
//  KeyboardPreview.swift
//  MainApp
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import AzooKeyUtils
import Foundation
import KeyboardViews
import SwiftUI

private struct CandidateMock: ResultViewItemData {
    let inputable: Bool = true
    var text: String
    #if DEBUG
    func getDebugInformation() -> String {
        "CandidateMock: \(text)"
    }
    #endif
}
private struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

@MainActor
struct KeyboardPreview: View {
    private let theme: AzooKeyTheme
    @State private var height: CGFloat = 100
    private let defaultTab: Tab.ExistentialTab?
    @StateObject private var variableStates = VariableStates(
        orientation: MainAppDesign.keyboardOrientation,
        clipboardHistoryManagerConfig: ClipboardHistoryManagerConfig(),
        tabManagerConfig: TabManagerConfig(),
        userDefaults: UserDefaults.standard
    )

    init(theme: AzooKeyTheme? = nil, defaultTab: Tab.ExistentialTab? = nil) {
        self.theme = theme ?? AzooKeySpecificTheme.default(layout: defaultTab?.layout ?? .flick)
        self.defaultTab = defaultTab
    }

    var body: some View {
        GeometryReader { proxy in
            let keyboardWidth = proxy.size.width
            let keyboardHeight = Design.keyboardScreenHeight(upsideComponent: nil, orientation: MainAppDesign.keyboardOrientation, screenWidth: proxy.size.width)
            KeyboardView<AzooKeyKeyboardViewExtension>(defaultTab: defaultTab)
                .environmentObject(variableStates)
                .themeEnvironment(theme)
                .environment(\.showMessage, false)
                .frame(width: keyboardWidth, height: keyboardHeight)
                .onAppear {
                    variableStates.resultModel.setResults([
                        CandidateMock(text: "azooKey"),
                        CandidateMock(text: "あずーきー"),
                        CandidateMock(text: "アズーキー")
                    ])
                    variableStates.screenWidth = keyboardWidth
                    variableStates.setInterfaceSize(orientation: MainAppDesign.keyboardOrientation, screenWidth: keyboardWidth)
                }
                .onChange(of: keyboardWidth) { newValue in
                    variableStates.screenWidth = newValue
                    variableStates.setInterfaceSize(orientation: MainAppDesign.keyboardOrientation, screenWidth: newValue)
                }
                .preference(key: HeightKey.self, value: keyboardHeight)
        }
        .onPreferenceChange(HeightKey.self) {
            self.height = $0
        }
        .frame(height: self.height)
    }
}

/// GeometryReaderが不要な場合にのみ利用を推奨
@MainActor
struct RawKeyboardPreview: View {
    private let theme: AzooKeyTheme
    private let defaultTab: Tab.ExistentialTab?
    @StateObject private var variableStates = VariableStates(
        orientation: MainAppDesign.keyboardOrientation,
        clipboardHistoryManagerConfig: ClipboardHistoryManagerConfig(),
        tabManagerConfig: TabManagerConfig(),
        userDefaults: UserDefaults.standard
    )

    init(theme: AzooKeyTheme? = nil, defaultTab: Tab.ExistentialTab? = nil) {
        self.theme = theme ?? AzooKeySpecificTheme.default(layout: defaultTab?.layout ?? .flick)
        self.defaultTab = defaultTab
    }

    var body: some View {
        let keyboardWidth = UIScreen.main.bounds.width
        let keyboardHeight = Design.keyboardScreenHeight(upsideComponent: nil, orientation: MainAppDesign.keyboardOrientation, screenWidth: UIScreen.main.bounds.width)
        KeyboardView<AzooKeyKeyboardViewExtension>(defaultTab: defaultTab)
            .environmentObject(variableStates)
            .themeEnvironment(theme)
            .environment(\.showMessage, false)
            .frame(width: keyboardWidth, height: keyboardHeight)
            .onAppear {
                variableStates.resultModel.setResults([
                    CandidateMock(text: "azooKey"),
                    CandidateMock(text: "あずーきー"),
                    CandidateMock(text: "アズーキー")
                ])
                variableStates.screenWidth = keyboardWidth
                variableStates.setInterfaceSize(orientation: MainAppDesign.keyboardOrientation, screenWidth: keyboardWidth)
            }
    }
}
