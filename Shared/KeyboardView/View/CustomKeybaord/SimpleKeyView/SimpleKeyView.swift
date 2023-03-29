//
//  SimpleKeyView.swift
//  azooKey
//
//  Created by ensan on 2021/02/19.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct SimpleKeyView: View {
    private let model: any SimpleKeyModelProtocol
    @EnvironmentObject private var variableStates: VariableStates
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    private let keyViewWidth: CGFloat
    private let keyViewHeight: CGFloat

    init(model: any SimpleKeyModelProtocol, tabDesign: TabDependentDesign) {
        self.model = model
        self.keyViewWidth = tabDesign.keyViewWidth
        self.keyViewHeight = tabDesign.keyViewHeight
    }

    init(model: any SimpleKeyModelProtocol, width: CGFloat, height: CGFloat) {
        self.model = model
        self.keyViewWidth = width
        self.keyViewHeight = height
    }

    @State private var isPressed = false
    @State private var pressStartDate = Date()

    var body: some View {
        model.label(width: keyViewWidth, states: variableStates, theme: theme)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .strokeAndFill(
                        fillContent: isPressed ? model.backGroundColorWhenPressed(theme: theme) : model.unpressedKeyColorType.color(states: variableStates, theme: theme),
                        strokeContent: theme.borderColor.color,
                        lineWidth: theme.borderWidth
                    )
                    .frame(width: keyViewWidth, height: keyViewHeight)
            )
            .frame(width: keyViewWidth, height: keyViewHeight)
            .overlay(
                Group {
                    if !(model is SimpleChangeKeyboardKeyModel && SemiStaticStates.shared.needsInputModeSwitchKey) {
                        TouchDownAndTouchUpGestureView {
                            isPressed = true
                            pressStartDate = Date()
                            model.feedback(variableStates: variableStates)
                            action.reserveLongPressAction(self.model.longPressActions, variableStates: variableStates)
                        } touchMovedCallBack: { state  in
                            if state.distance > 15 {
                                isPressed = false
                                pressStartDate = Date()
                                action.registerLongPressActionEnd(self.model.longPressActions)
                            }
                        } touchUpCallBack: {state in
                            isPressed = false
                            action.registerLongPressActionEnd(self.model.longPressActions)
                            if Date().timeIntervalSince(pressStartDate) < 0.4 && state.distance < 30 {
                                action.registerActions(self.model.pressActions(variableStates: variableStates), variableStates: variableStates)
                                self.model.additionalOnPress(variableStates: variableStates)
                            }
                        }
                    }
                }
                .onDisappear {
                    action.registerLongPressActionEnd(self.model.longPressActions)
                }
            )
            .frame(width: keyViewWidth, height: keyViewHeight)
    }
}
