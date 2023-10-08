//
//  FlickNextCandidateKeyModel.swift
//  
//
//  Created by miwa on 2023/09/27.
//

import Foundation
import KeyboardThemes
import enum CustardKit.FlickDirection
import SwiftUI

struct FlickNextCandidateKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>: FlickKeyModelProtocol {
    let needSuggestView: Bool = false

    static var shared: Self { FlickNextCandidateKeyModel() }

    func pressActions(variableStates: VariableStates) -> [ActionType] {
        if variableStates.resultModel.results.isEmpty {
            [.input(" ")]
        } else {
            [.selectCandidate(.offset(1))]
        }
    }
    func longPressActions(variableStates: VariableStates) -> LongpressActionType {
        if variableStates.resultModel.results.isEmpty {
            .init(start: [.setCursorBar(.toggle)])
        } else {
            .init(start: [.input(" ")])
        }
    }
    func flickKeys(variableStates: VariableStates) -> [CustardKit.FlickDirection: FlickedKeyModel] {
        [
            .left: FlickedKeyModel(
                labelType: .text("←"),
                pressActions: [.moveCursor(-1)],
                longPressActions: .init(repeat: [.moveCursor(-1)])
            ),
            .top: FlickedKeyModel(
                labelType: .text("全角"),
                pressActions: [.input("　")]
            ),
            .bottom: FlickedKeyModel(
                labelType: .text("Tab"),
                pressActions: [.input("\u{0009}")]
            )
        ]
    }

    private init() {}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel<Extension> {
        if states.resultModel.results.isEmpty {
            KeyLabel(.text("空白"), width: width)
        } else {
            KeyLabel(.text("次候補"), width: width)
        }
    }

    func feedback(variableStates: VariableStates) {
        if variableStates.resultModel.results.isEmpty {
            KeyboardFeedback<Extension>.click()
        } else {
            KeyboardFeedback<Extension>.tabOrOtherKey()
        }
    }
    func backGroundColorWhenUnpressed<ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(states: VariableStates, theme: ThemeData<ThemeExtension>) -> Color {
        theme.specialKeyFillColor.color
    }
}
