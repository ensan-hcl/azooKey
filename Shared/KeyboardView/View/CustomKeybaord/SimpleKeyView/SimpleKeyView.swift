//
//  SimpleKeyView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/19.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct SimpleKeyView: View {
    private let model: SimpleKeyModelProtocol
    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.themeEnvironment) private var theme

    private let tabDesign: TabDependentDesign

    init(model: SimpleKeyModelProtocol, tabDesign: TabDependentDesign) {
        self.model = model
        self.tabDesign = tabDesign
    }

    @State private var isPressed = false
    @State private var pressStartDate = Date()

    var body: some View {
        model.label(width: tabDesign.keyViewWidth, states: variableStates, theme: theme)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .strokeAndFill(
                        fillContent: isPressed ? model.backGroundColorWhenPressed(theme: theme) : model.unpressedKeyColorType.color(states: variableStates, theme: theme),
                        strokeContent: theme.borderColor.color,
                        lineWidth: theme.borderWidth
                    )
                    .frame(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight)
            )
            .frame(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight)
            .overlay(
                Group {
                    if !(model is SimpleChangeKeyboardKeyModel && SemiStaticStates.shared.needsInputModeSwitchKey) {
                        TouchDownAndTouchUpGestureView {
                            isPressed = true
                            pressStartDate = Date()
                            model.sound()
                            model.longPressReserve()
                        } touchMovedCallBack: {state in
                            if state.distance > 15 {
                                isPressed = false
                                pressStartDate = Date()
                                model.longPressEnd()
                            }
                        } touchUpCallBack: {state in
                            isPressed = false
                            model.longPressEnd()
                            if Date().timeIntervalSince(pressStartDate) < 0.4 && state.distance < 30 {
                                model.press()
                            }
                        }
                    }
                }
            )
            .frame(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight)
    }
}
