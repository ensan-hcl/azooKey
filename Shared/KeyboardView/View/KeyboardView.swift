//
//  KeyboardView.swift
//  azooKey
//
//  Created by ensan on 2020/04/08.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
    typealias Value = ThemeData

    static var defaultValue: ThemeData = .default
}

extension EnvironmentValues {
    var themeEnvironment: ThemeData {
        get {
            self[ThemeEnvironmentKey.self]
        }
        set {
            self[ThemeEnvironmentKey.self] = newValue
        }
    }
}

struct MessageEnvironmentKey: EnvironmentKey {
    typealias Value = Bool

    static var defaultValue = true
}

extension EnvironmentValues {
    var showMessage: Bool {
        get {
            self[MessageEnvironmentKey.self]
        }
        set {
            self[MessageEnvironmentKey.self] = newValue
        }
    }
}

struct UserActionManagerEnvironmentKey: EnvironmentKey {
    typealias Value = UserActionManager

    static var defaultValue = UserActionManager()
}

extension EnvironmentValues {
    var userActionManager: UserActionManager {
        get {
            self[UserActionManagerEnvironmentKey.self]
        }
        set {
            self[UserActionManagerEnvironmentKey.self] = newValue
        }
    }
}

struct KeyboardView: View {
    @ObservedObject private var variableStates = VariableStates.shared

    @State private var messageManager: MessageManager = MessageManager()
    @State private var isResultViewExpanded = false

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.showMessage) private var showMessage

    private let defaultTab: Tab.ExistentialTab?

    init(defaultTab: Tab.ExistentialTab? = nil) {
        self.defaultTab = defaultTab
    }

    var body: some View {
        ZStack { [unowned variableStates] in
            theme.backgroundColor.color
                .frame(maxWidth: .infinity)
                .overlay(
                    Group {
                        if let image = theme.picture.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardScreenHeight)
                                .clipped()
                        }
                    }
                )
            VStack(spacing: 0) {
                if let upsideComponent = variableStates.upsideComponent {
                    Group {
                        switch upsideComponent {
                        default: EmptyView()
                        }
                    }
                    .frame(height: Design.upsideComponentHeight())
                }
                if isResultViewExpanded {
                    ExpandedResultView(isResultViewExpanded: $isResultViewExpanded)
                } else {
                    VStack(spacing: 0) {
                        ResultView(isResultViewExpanded: $isResultViewExpanded)
                            .padding(.vertical, 6)
                        if variableStates.refreshing {
                            keyboardView(tab: variableStates.tabManager.tab.existential)
                        } else {
                            keyboardView(tab: variableStates.tabManager.tab.existential)
                        }
                    }
                }
            }
            .resizingFrame(
                size: $variableStates.interfaceSize,
                position: $variableStates.interfacePosition,
                initialSize: CGSize(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth))
            )
            .padding(.bottom, 2)
            if variableStates.boolStates.isTextMagnifying {
                LargeTextView(text: variableStates.magnifyingText, isViewOpen: $variableStates.boolStates.isTextMagnifying)
            }
            if showMessage {
                ForEach(messageManager.necessaryMessages, id: \.id) {data in
                    if messageManager.requireShow(data.id) {
                        MessageView(data: data, manager: $messageManager)
                    }
                }
            }
        }
        .frame(height: Design.keyboardScreenHeight)
    }

    func keyboardView(tab: Tab.ExistentialTab) -> some View {
        let target: Tab.ExistentialTab
        if let defaultTab {
            target = defaultTab
        } else {
            target = tab
        }

        return Group {
            switch target {
            case .flick_hira:
                FlickKeyboardView(keyModels: FlickDataProvider().hiraKeyboard)
            case .flick_abc:
                FlickKeyboardView(keyModels: FlickDataProvider().abcKeyboard)
            case .flick_numbersymbols:
                FlickKeyboardView(keyModels: FlickDataProvider().numberKeyboard)
            case .qwerty_hira:
                QwertyKeyboardView(keyModels: QwertyDataProvider().hiraKeyboard)
            case .qwerty_abc:
                QwertyKeyboardView(keyModels: QwertyDataProvider().abcKeyboard)
            case .qwerty_number:
                QwertyKeyboardView(keyModels: QwertyDataProvider().numberKeyboard)
            case .qwerty_symbols:
                QwertyKeyboardView(keyModels: QwertyDataProvider().symbolsKeyboard)
            case let .custard(custard):
                CustomKeyboardView(custard: custard)
            case let .special(tab):
                switch tab {
                case .clipboard_history_tab:
                    // ClipboardHistoryTab()
                    EmojiTab()
                }
            }
        }
    }
}
