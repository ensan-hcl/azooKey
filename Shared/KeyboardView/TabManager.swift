//
//  TabManager.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/20.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum Tab{
    case flick_hira
    case flick_abc
    case flick_numbersymbols
    case qwerty_hira
    case qwerty_abc
    case qwerty_number
    case qwerty_symbols
    case user_dependent(UserDependentTab)
    case custard(Custard)

    enum UserDependentTab{
        case japanese
        case english

        var actualTab: Tab {
            //ユーザの設定に合わせて遷移先のタブ(非user_dependent)を返す
            switch self{
            case .english:
                switch SettingData.shared.keyboardLayout(for: .englishKeyboardLayout){
                case .flick:
                    return .flick_abc
                case .qwerty:
                    return .qwerty_abc
                }
            case .japanese:
                switch SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout){
                case .flick:
                    return .flick_hira
                case .qwerty:
                    return .qwerty_hira
                }
            }
        }

    }

    ///deprecated
    var isAbcTab: Bool {
        #warning("このプロパティは使用しないことを推奨します。")
        switch self{
        case .flick_abc, .qwerty_abc:
            return true
        default:
            return false
        }
    }

    var inputStyle: InputStyle {
        switch self{
        case .qwerty_hira:
            return .roman
        case let .user_dependent(tab):
            let actualTab = tab.actualTab
            return actualTab.inputStyle
        case let .custard(custard):
            switch custard.input_style{
            case .direct:
                return .direct
            case .roman2kana:
                return .roman
            }
        default:
            return .direct
        }
    }

    var layout: KeyboardLayout {
        switch self{
        case .flick_hira, .flick_abc, .flick_numbersymbols:
            return .flick
        case .qwerty_hira, .qwerty_abc, .qwerty_number, .qwerty_symbols:
            return .qwerty
        case let .user_dependent(tab):
            let actualTab = tab.actualTab
            return actualTab.layout
        case let .custard(custard):
            switch custard.interface.key_style{
            case .flick:
                return .flick
            case .qwerty:
                return .qwerty
            }
        }
    }

    var language: KeyboardLanguage? {
        switch self{
        case .flick_abc, .qwerty_abc:
            return .english
        case .flick_hira, .qwerty_hira:
            return .japanese
        case let .user_dependent(tab):
            let actualTab = tab.actualTab
            return actualTab.language
        case let .custard(custard):
            switch custard.language{
            case .japanese:
                return .japanese
            case .english:
                return .english
            case .undefined:
                return nil
            }
        default:
            return nil
        }
    }
}

extension Tab: Equatable {
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        switch (lhs, rhs){
        case (.flick_abc, .flick_abc), (.flick_hira, .flick_hira), (.flick_numbersymbols, .flick_numbersymbols), (.qwerty_abc, .qwerty_abc), (.qwerty_hira, .qwerty_hira), (.qwerty_number, .qwerty_number), (.qwerty_symbols, .qwerty_symbols):
            return true
        case let (.user_dependent(ltab), .user_dependent(rtab)):
            return ltab == rtab
        case let (.user_dependent(ltab), _):
            return ltab.actualTab == rhs
        case let (_, .user_dependent(rtab)):
            return lhs == rtab.actualTab
        case let (.custard(lcustard), .custard(rcustard)):
            return lcustard.identifier == rcustard.identifier
        default:
            return false
        }
    }


}

struct TabManager{
    var currentTab: Tab = .user_dependent(.japanese)
    var lastTab: Tab? = nil

    mutating func initialize(){
        if let lastTab = self.lastTab{
            self.moveTab(to: lastTab)
        }
    }

    mutating func moveTab(to destination: Tab){
        //VariableStateの状態を遷移先のタブに合わせて適切に変更する
        VariableStates.shared.keyboardLayout = destination.layout
        VariableStates.shared.setInputStyle(destination.inputStyle)
        if let language = destination.language{
            VariableStates.shared.keyboardLanguage = language
        }

        //selfの状態を更新する
        self.lastTab = self.currentTab
        if case let .user_dependent(tab) = destination{
            self.currentTab = tab.actualTab
        }else{
            self.currentTab = destination
        }
    }
}
