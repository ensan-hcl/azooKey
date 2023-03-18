//
//  KeyboardBarView.swift
//  azooKey
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyboardBarView: View {
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
                    EmojiTabResultBar()
                default:
                    ResultBar(isResultViewExpanded: $isResultViewExpanded)
                }
            }
        }
        .frame(height: Design.resultViewHeight())
    }
}

struct KeyboardBarButton: View {
    enum LabelType {
        case azooKeyIcon
        case systemImage(String)
    }
    @Environment(\.themeEnvironment) private var theme
    private var action: () -> Void
    private let label: LabelType

    init(label: LabelType = .azooKeyIcon, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    private var buttonBackgroundColor: Color {
        Design.colors.prominentBackgroundColor(theme)
    }

    private var buttonLabelColor: Color {
        theme.resultTextColor.color
    }

    var body: some View {
        Button(action: self.action) {
            ZStack {
                Circle()
                    .strokeAndFill(fillContent: buttonBackgroundColor, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
                    .frame(width: Design.resultViewHeight() * 0.8, height: Design.resultViewHeight() * 0.8)
                switch label {
                case .azooKeyIcon:
                    AzooKeyIcon(fixedSize: Design.resultViewHeight() * 0.6, color: .color(buttonLabelColor))
                case let .systemImage(name):
                    Image(systemName: name)
                        .frame(width: Design.resultViewHeight() * 0.6, height: Design.resultViewHeight() * 0.6)
                        .foregroundColor(buttonLabelColor)
                }
            }
        }
        .frame(height: Design.resultViewHeight() * 0.6)
        .padding(.all, 5)
    }
}
