//
//  TabManager.swift
//  azooKey
//
//  Created by ensan on 2021/02/20.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

extension TabData {
    var tab: Tab {
        switch self {
        case let .system(tab):
            switch tab {
            case .flick_japanese:
                return .existential(.flick_hira)
            case .flick_english:
                return .existential(.flick_abc)
            case .flick_numbersymbols:
                return .existential(.flick_numbersymbols)
            case .qwerty_japanese:
                return .existential(.qwerty_hira)
            case .qwerty_english:
                return .existential(.qwerty_abc)
            case .qwerty_numbers:
                return .existential(.qwerty_number)
            case .qwerty_symbols:
                return .existential(.qwerty_symbols)
            case .user_japanese:
                return .user_dependent(.japanese)
            case .user_english:
                return .user_dependent(.english)
            case .last_tab:
                return .last_tab
            case .__clipboard_history_tab:
                return .existential(.special(.clipboard_history_tab))
            }
        case let .custom(identifier):
            if let custard = try? CustardManager.load().custard(identifier: identifier) {
                return .existential(.custard(custard))
            } else {
                return .existential(.custard(.errorMessage))
            }
        }
    }
}

struct TabManager {
    var tab: ManagerTab {
        if let temporalTab {
            return temporalTab
        } else {
            return currentTab
        }
    }
    /// メインのタブ。
    private var currentTab: ManagerTab = Self.getDefaultTab().managerTab
    /// 一時的に表示を切り替えるタブ。lastTabに反映されない。
    private var temporalTab: ManagerTab?
    private var lastTab: ManagerTab?

    enum ManagerTab {
        case existential(Tab.ExistentialTab)
        case user_dependent(Tab.UserDependentTab)

        var existential: Tab.ExistentialTab {
            switch self {
            case let .existential(tab):
                return tab
            case let .user_dependent(tab):
                return tab.actualTab
            }
        }
    }

    func isCurrentTab(tab: Tab) -> Bool {
        switch tab {
        case let .existential(actualTab):
            return self.tab.existential == actualTab
        case let .user_dependent(type):
            return type.actualTab == self.tab.existential
        case .last_tab:
            return false
        }
    }

    mutating func initialize(variableStates: VariableStates) {
        switch lastTab {
        case .none:
            let targetTab: Tab = {
                @KeyboardSetting(.preferredLanguage) var preferredLanguage
                switch preferredLanguage.first {
                case .en_US:
                    return .user_dependent(.english)
                case .ja_JP:
                    return .user_dependent(.japanese)
                case .none, .el_GR:
                    return .user_dependent(.japanese)
                }
            }()
            self.moveTab(to: targetTab, variableStates: variableStates)
        case let .existential(tab):
            self.moveTab(to: tab, variableStates: variableStates)
        case let .user_dependent(tab):
            self.moveTab(to: .user_dependent(tab), variableStates: variableStates)
        }
    }

    mutating func closeKeyboard() {
        self.lastTab = self.currentTab
    }

    mutating private func moveTab(to destination: Tab.ExistentialTab, variableStates: VariableStates) {
        // VariableStateの状態を遷移先のタブに合わせて適切に変更する
        variableStates.setKeyboardLayout(destination.layout)
        variableStates.setInputStyle(destination.inputStyle)
        if let language = destination.language {
            variableStates.keyboardLanguage = language
        }

        // selfの状態を更新する
        self.temporalTab = nil
        self.lastTab = self.currentTab
        self.currentTab = .existential(destination)
    }

    private func updateVariableStates(_ variableStates: VariableStates, layout: KeyboardLayout, inputStyle: InputStyle, language: KeyboardLanguage?) {
        // VariableStateの状態を遷移先のタブに合わせて適切に変更する
        variableStates.setKeyboardLayout(layout)
        variableStates.setInputStyle(inputStyle)
        if let language {
            variableStates.keyboardLanguage = language
        }
    }

    private static func getDefaultTab() -> (existentialTab: Tab.ExistentialTab, managerTab: ManagerTab) {
        @KeyboardSetting(.preferredLanguage) var preferredLanguage: PreferredLanguage
        switch preferredLanguage.first {
        case .ja_JP:
            return (Tab.UserDependentTab.japanese.actualTab, .user_dependent(.japanese))
        case .en_US:
            return (Tab.UserDependentTab.english.actualTab, .user_dependent(.english))
        default:
            return (Tab.UserDependentTab.japanese.actualTab, .user_dependent(.japanese))
        }
    }

    mutating func setTemporalTab(_ destination: Tab, variableStates: VariableStates) {
        let actualTab: Tab.ExistentialTab
        switch destination {
        case let .existential(tab):
            self.updateVariableStates(variableStates, layout: tab.layout, inputStyle: tab.inputStyle, language: tab.language)
            self.temporalTab = .existential(tab)
        case let .user_dependent(tab):
            actualTab = tab.actualTab
            self.updateVariableStates(variableStates, layout: actualTab.layout, inputStyle: actualTab.inputStyle, language: actualTab.language)
            self.temporalTab = .user_dependent(tab)
        case .last_tab:
            if let lastTab {
                actualTab = lastTab.existential
                self.temporalTab = lastTab
            } else {
                (actualTab, self.temporalTab) = Self.getDefaultTab()
            }
            self.updateVariableStates(variableStates, layout: actualTab.layout, inputStyle: actualTab.inputStyle, language: actualTab.language)
        }
    }

    mutating func moveTab(to destination: Tab, variableStates: VariableStates) {
        switch destination {
        case let .existential(tab):
            self.updateVariableStates(variableStates, layout: tab.layout, inputStyle: tab.inputStyle, language: tab.language)
            self.lastTab = self.currentTab
            self.currentTab = .existential(tab)
        // Custard内の変数の初期化を実行
        //            if case let .custard(custard) = tab {
        //                for value in custard.logics.initial_values {
        //                    if case let .bool(bool) = value.value {
        //                        variableStates.boolStates.initializeState(value.name, with: bool)
        //                    }
        //                }
        //            }
        case let .user_dependent(tab):
            let actualTab = tab.actualTab
            self.updateVariableStates(variableStates, layout: actualTab.layout, inputStyle: actualTab.inputStyle, language: actualTab.language)
            self.lastTab = self.currentTab
            self.currentTab = .user_dependent(tab)

        case .last_tab:
            // 適切なタブを取得する
            let actualTab: Tab.ExistentialTab
            if let lastTab, lastTab.existential != self.currentTab.existential {
                actualTab = lastTab.existential
                self.currentTab = .existential(lastTab.existential)
            } else {
                (actualTab, self.currentTab) = Self.getDefaultTab()
            }
            self.updateVariableStates(variableStates, layout: actualTab.layout, inputStyle: actualTab.inputStyle, language: actualTab.language)
            self.lastTab = nil
        }
        self.temporalTab = nil
    }
}
