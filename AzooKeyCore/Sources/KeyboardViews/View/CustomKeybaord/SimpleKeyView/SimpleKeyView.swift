//
//  SimpleKeyView.swift
//  azooKey
//
//  Created by ensan on 2021/02/19.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils

@MainActor
struct SimpleKeyView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    private let model: any SimpleKeyModelProtocol<Extension>
    @EnvironmentObject private var variableStates: VariableStates
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action
    enum SizeProvider {
        case tabDesign(TabDependentDesign)
        case direct(CGSize)
        var keyViewWidth: CGFloat {
            switch self {
            case .tabDesign(let tabDesign):
                tabDesign.keyViewWidth
            case .direct(let size):
                size.width
            }
        }
        @MainActor func keyViewHeight(screenWidth: CGFloat) -> CGFloat {
            switch self {
            case .tabDesign(let tabDesign):
                tabDesign.keyViewHeight(screenWidth: screenWidth)
            case .direct(let size):
                size.height
            }
        }
    }
    private let provider: SizeProvider


    private var keyViewWidth: CGFloat {
        provider.keyViewWidth
    }

    @MainActor private var keyViewHeight: CGFloat {
        provider.keyViewHeight(screenWidth: variableStates.screenWidth)
    }

    init(model: any SimpleKeyModelProtocol<Extension>, tabDesign: TabDependentDesign) {
        self.model = model
        self.provider = .tabDesign(tabDesign)
    }

    init(model: any SimpleKeyModelProtocol<Extension>, width: CGFloat, height: CGFloat) {
        self.model = model
        self.provider = .direct(.init(width: width, height: height))
    }

    @State private var isPressed = false
    @State private var pressStartDate = Date()

    private func label(width: CGFloat) -> some View {
        model.label(width: keyViewWidth, states: variableStates)
    }

    var body: some View {
        label(width: keyViewWidth)
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
                    if !(model is SimpleChangeKeyboardKeyModel<Extension> && SemiStaticStates.shared.needsInputModeSwitchKey) {
                        TouchDownAndTouchUpGestureView {
                            isPressed = true
                            pressStartDate = Date()
                            model.feedback(variableStates: variableStates)
                            action.reserveLongPressAction(self.model.longPressActions(variableStates: variableStates), variableStates: variableStates)
                        } touchMovedCallBack: { state  in
                            if state.distance > 15 {
                                isPressed = false
                                pressStartDate = Date()
                                action.registerLongPressActionEnd(self.model.longPressActions(variableStates: variableStates))
                            }
                        } touchUpCallBack: {state in
                            isPressed = false
                            action.registerLongPressActionEnd(self.model.longPressActions(variableStates: variableStates))
                            if Date().timeIntervalSince(pressStartDate) < 0.4 && state.distance < 30 {
                                action.registerActions(self.model.pressActions(variableStates: variableStates), variableStates: variableStates)
                                self.model.additionalOnPress(variableStates: variableStates)
                            }
                        }
                    }
                }
                .onDisappear {
                    action.registerLongPressActionEnd(self.model.longPressActions(variableStates: variableStates))
                }
            )
            .frame(width: keyViewWidth, height: keyViewHeight)
    }
}
