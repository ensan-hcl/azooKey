//
//  Action.swift
//  Keyboard
//
//  Created by ensan on 2020/04/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardExpressionEvaluator
import CustardKit
import Foundation

extension CodableActionData {
    var actionType: ActionType {
        switch self {
        case let .input(value):
            return .input(value)
        case .replaceDefault:
            return .changeCharacterType
        case let .replaceLastCharacters(value):
            return .replaceLastCharacters(value)
        case let .delete(value):
            return .delete(value)
        case .smartDeleteDefault:
            return .smoothDelete
        case let .smartDelete(value):
            return .smartDelete(value)
        case .complete:
            return .enter
        case let .moveCursor(value):
            return .moveCursor(value)
        case let .smartMoveCursor(value):
            return .smartMoveCursor(value)
        case let .moveTab(value):
            return .moveTab(value.tab)
        case .enableResizingMode:
            return .enableResizingMode
        case .toggleCursorBar:
            return .setCursorBar(.toggle)
        case .toggleCapsLockState:
            return .setBoolState(VariableStates.BoolStates.isCapsLockedKey, .toggle)
        case .toggleTabBar:
            return .setTabBar(.toggle)
        case let .launchApplication(value):
            switch value.scheme {
            case .azooKey:
                return .openApp("azooKey://" + value.target)
            case .shortcuts:
                return .openApp("shortcuts://" + value.target)
            }
        case .dismissKeyboard:
            return .dismissKeyboard
        //        case let .setCursorBar(value):
        //            return .setCursorBar(value)
        //        case let .setCapsLockState(value):
        //            return .setBoolState(VariableStates.BoolStates.isCapsLockedKey, value)
        //        case let .setTabBar(value):
        //            return .setTabBar(value)
        //        case let .setBoolState(state, value):
        //            let tokenizer = CustardExpressionTokenizer()
        //            let compiler = CustardExpressionCompiler()
        //            let tokens = tokenizer.tokenize(expression: value)
        //            if let compiledExpression = try? compiler.compile(tokens: tokens) {
        //                return ._setBoolState(state, compiledExpression)
        //            }
        //            // TODO: implement empty action and enable actual do-nothing
        //            return .input("")
        //        case let .boolSwitch(expression, trueActions, falseActions):
        //            let tokenizer = CustardExpressionTokenizer()
        //            let compiler = CustardExpressionCompiler()
        //            let tokens = tokenizer.tokenize(expression: expression)
        //            if let compiledExpression = try? compiler.compile(tokens: tokens) {
        //                return .boolSwitch(compiledExpression, trueAction: trueActions.map {$0.actionType}, falseAction: falseActions.map {$0.actionType})
        //            }
        //            // TODO: implement empty action and enable actual do-nothing
        //            return .input("")
        }
    }
}

extension CodableLongpressActionData {
    var longpressActionType: LongpressActionType {
        .init(start: self.start.map {$0.actionType}, repeat: self.repeat.map {$0.actionType})
    }
}

extension ActionType {
    func feedback() {
        switch self {
        case .input:
            KeyboardFeedback.click()
        case .delete:
            KeyboardFeedback.delete()
        case .smoothDelete, .smartDelete, .smartMoveCursor:
            KeyboardFeedback.smoothDelete()
        case .moveTab, .enter, .changeCharacterType, .setCursorBar, .moveCursor, .enableResizingMode, .replaceLastCharacters, .setTabBar, .setBoolState/*, ._setBoolState*/:
            KeyboardFeedback.tabOrOtherKey()
        case .deselectAndUseAsInputting, .saveSelectedTextIfNeeded, .restoreSelectedTextIfNeeded, .openApp, .dismissKeyboard, .hideLearningMemory:
            return
        case let .boolSwitch(compiledExpression, trueAction, falseAction):
            if let condition = VariableStates.shared.boolStates.evaluateExpression(compiledExpression) {
                if condition {
                    trueAction.first?.feedback()
                } else {
                    falseAction.first?.feedback()
                }
            }
        #if DEBUG
        case .DEBUG_DATA_INPUT:
            return
        #endif
        }
    }
}
