//
//  TabManager.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/20.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import CustardKit

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
    private var currentTab: ManagerTab = .user_dependent(.japanese)
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

    mutating func initialize() {
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
            self.moveTab(to: targetTab)
        case let .existential(tab):
            self.moveTab(to: tab)
        case let .user_dependent(tab):
            self.moveTab(to: .user_dependent(tab))
        }
    }

    mutating func closeKeyboard() {
        self.lastTab = self.currentTab
    }

    mutating private func moveTab(to destination: Tab.ExistentialTab) {
        // VariableStateの状態を遷移先のタブに合わせて適切に変更する
        VariableStates.shared.setKeyboardLayout(destination.layout)
        VariableStates.shared.setInputStyle(destination.inputStyle)
        if let language = destination.language {
            VariableStates.shared.keyboardLanguage = language
        }

        // selfの状態を更新する
        self.temporalTab = nil
        self.lastTab = self.currentTab
        self.currentTab = .existential(destination)
    }

    mutating func setTemporalTab(_ destination: Tab) {
        // 適切なタブを取得する
        let actualTab: Tab.ExistentialTab
        switch destination {
        case let .existential(tab):
            actualTab = tab
        case let .user_dependent(tab):
            actualTab = tab.actualTab
        case .last_tab:
            guard let lastTab = self.lastTab else {
                return
            }
            actualTab = lastTab.existential
        }

        // VariableStateの状態を遷移先のタブに合わせて適切に変更する
        VariableStates.shared.setKeyboardLayout(actualTab.layout)
        VariableStates.shared.setInputStyle(actualTab.inputStyle)
        if let language = actualTab.language {
            VariableStates.shared.keyboardLanguage = language
        }

        // selfの状態を更新する
        switch destination {
        case let .existential(tab):
            self.temporalTab = .existential(tab)
        case let .user_dependent(tab):
            self.temporalTab = .user_dependent(tab)
        case .last_tab:
            if let lasttab = self.lastTab {
                self.temporalTab = lasttab
            }
        }
    }

    mutating func moveTab(to destination: Tab) {
        // 適切なタブを取得する
        let actualTab: Tab.ExistentialTab
        switch destination {
        case let .existential(tab):
            actualTab = tab
        case let .user_dependent(tab):
            actualTab = tab.actualTab
        case .last_tab:
            guard let lastTab = self.lastTab else {
                return
            }
            actualTab = lastTab.existential
        }

        // VariableStateの状態を遷移先のタブに合わせて適切に変更する
        VariableStates.shared.setKeyboardLayout(actualTab.layout)
        VariableStates.shared.setInputStyle(actualTab.inputStyle)
        if let language = actualTab.language {
            VariableStates.shared.keyboardLanguage = language
        }

        // selfの状態を更新する
        self.temporalTab = nil
        switch destination {
        case let .existential(tab):
            self.lastTab = self.currentTab
            self.currentTab = .existential(tab)
            // Custard内の変数の初期化を実行
            if case let .custard(custard) = tab {
                for value in custard.logics.initial_values {
                    if case let .bool(bool) = value.value {
                        VariableStates.shared.boolStates.initializeState(value.name, with: bool)
                    }
                }
            }
        case let .user_dependent(tab):
            self.lastTab = self.currentTab
            self.currentTab = .user_dependent(tab)
        case .last_tab:
            if let lasttab = self.lastTab {
                self.currentTab = lasttab
            }
            self.lastTab = nil
        }
    }
}
