//
//  KeyboardView.swift
//  azooKey
//
//  Created by ensan on 2020/04/08.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyboardView: View {
    @State private var messageManager: MessageManager = MessageManager()
    @State private var isResultViewExpanded = false

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.showMessage) private var showMessage
    @EnvironmentObject private var variableStates: VariableStates

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
                                .frame(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardScreenHeight(upsideComponent: variableStates.upsideComponent, orientation: variableStates.keyboardOrientation))
                                .clipped()
                        }
                    }
                )
            VStack(spacing: 0) {
                if let upsideComponent = variableStates.upsideComponent {
                    Group {
                        switch upsideComponent {
                        case let .search(target):
                            UpsideSearchView(target: target)
                        }
                    }
                    .frame(height: Design.upsideComponentHeight(upsideComponent, orientation: variableStates.keyboardOrientation))
                }
                if isResultViewExpanded {
                    ExpandedResultView(isResultViewExpanded: $isResultViewExpanded)
                } else {
                    VStack(spacing: 0) {
                        KeyboardBarView(isResultViewExpanded: $isResultViewExpanded)
                            .frame(height: Design.keyboardBarHeight(interfaceHeight: variableStates.interfaceSize.height, orientation: variableStates.keyboardOrientation))
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
                initialSize: CGSize(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth, orientation: variableStates.keyboardOrientation))
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
        .frame(height: Design.keyboardScreenHeight(upsideComponent: variableStates.upsideComponent, orientation: variableStates.keyboardOrientation))
    }

    func keyboardView(tab: Tab.ExistentialTab) -> some View {
        let target: Tab.ExistentialTab = defaultTab ?? tab
        return Group {
            switch target {
            case .flick_hira:
                FlickKeyboardView(keyModels: FlickDataProvider().hiraKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .flick_abc:
                FlickKeyboardView(keyModels: FlickDataProvider().abcKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .flick_numbersymbols:
                FlickKeyboardView(keyModels: FlickDataProvider().numberKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .qwerty_hira:
                QwertyKeyboardView(keyModels: QwertyDataProvider().hiraKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .qwerty_abc:
                QwertyKeyboardView(keyModels: QwertyDataProvider().abcKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .qwerty_number:
                QwertyKeyboardView(keyModels: QwertyDataProvider().numberKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case .qwerty_symbols:
                QwertyKeyboardView(keyModels: QwertyDataProvider().symbolsKeyboard, interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
            case let .custard(custard):
                CustomKeyboardView(custard: custard)
            case let .special(tab):
                switch tab {
                case .clipboard_history_tab:
                    ClipboardHistoryTab()
                case .emoji:
                    EmojiTab()
                }
            }
        }
    }
}
