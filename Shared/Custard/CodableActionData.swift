//
//  CodableActionData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

/// - Tab specifier
enum CodableTabData: Codable {
    /// - tabs prepared by default
    case system(SystemTab)
    /// - tabs made as custom tabs.
    case custom(String)

    /// - system tabs
    enum SystemTab: String, Codable {
        ///japanese input tab. the layout and input style depends on user's setting
        case user_japanese

        ///english input tab. the layout and input style depends on user's setting
        case user_english

        ///flick japanese input tab
        case flick_japanese

        ///flick enlgish input tab
        case flick_english

        ///flick number and symbols input tab
        case flick_numbersymbols

        ///qwerty japanese input tab
        case qwerty_japanese

        ///qwerty english input tab
        case qwerty_english

        ///qwerty number input tab
        case qwerty_number

        ///qwerty symbols input tab
        case qwerty_symbols

        ///the last tab
        case last_tab
    }
}

extension CodableTabData{
    enum CodingKeys: CodingKey{
        case system
        case custom
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .system(value):
            try container.encode(value, forKey: .system)
        case let .custom(value):
            try container.encode(value, forKey: .custom)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else{
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
        switch key {
        case .system:
            let value = try container.decode(
                SystemTab.self,
                forKey: .system
            )
            self = .system(value)
        case .custom:
            let value = try container.decode(
                String.self,
                forKey: .custom
            )
            self = .custom(value)
        }
    }
}

extension CodableTabData{
    var tab: Tab {
        switch self{
        case let .system(tab):
            switch tab{
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
            case .qwerty_number:
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
            if let custard = try? CustardManager.load().custard(identifier: identifier){
                return .existential(.custard(custard))
            }else{
                return .existential(.custard(.errorMessage))
            }
        }
    }
}

extension CodableTabData: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs){
        case let(.system(ltab), .system(rtab)):
            return ltab == rtab
        case let (.custom(ltab), .custom(rtab)):
            return ltab == rtab
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self{
        case let .system(tab):
            hasher.combine(tab)
            hasher.combine(CodingKeys.system)
        case let .custom(tab):
            hasher.combine(tab)
            hasher.combine(CodingKeys.custom)
        }
    }
}

/// - アクション
/// - actions done in key pressing
enum CodableActionData: Codable {
    /// - input action specified character
    case input(String)

    /// - input action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longInput(String)

    /// - exchange character "あ→ぁ", "は→ば", "a→A".
    /// - when longpress, delete sequencially.
    case exchangeCharacter

    /// - delete action specified count of characters
    case delete(Int)

    /// - delete action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longDelete(Int)

    /// - delete to beginning of the sentence
    case smoothDelete

    /// - complete current inputting words
    case complete

    /// - move cursor  specified count forward. when you specify negative number, the cursor moves backword.
    /// - when longpress, the cursor moves sequencially.
    case moveCursor(Int)

    /// - move cursor action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longMoveCursor(Int)

    /// - move to specified tab
    case moveTab(CodableTabData)

    /// - toggle show or not show the cursor move bar
    case toggleCursorMovingView

    /// - toggle capslock or not
    case toggleCapsLockState

    /// - toggle show or not show the tab bar
    case toggleTabBar

    /// - dismiss keyboard
    case dismissKeyboard

    /// - open specified url scheme.
    /// - warning: this action could be deleted in future iOS.
    /// - warning: some of url schemes doesn't work.
    case openApp(String)    //iOSのバージョンによって消える可能性がある
}

extension CodableActionData{
    enum CodingKeys: CodingKey{
        case input
        case long_input
        case exchange_character
        case delete
        case long_delete
        case smooth_delete
        case complete
        case move_cursor
        case long_move_cursor
        case move_tab
        case toggle_cursor_moving_view
        case toggle_tab_bar
        case toggle_caps_lock_state
        case open_app
        case dismiss_keyboard
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .input(value):
            try container.encode(value, forKey: .input)
        case let .longInput(value):
            try container.encode(value, forKey: .long_input)
        case .exchangeCharacter:
            try container.encode(true, forKey: .exchange_character)
        case let .delete(value):
            try container.encode(value, forKey: .delete)
        case let .longDelete(value):
            try container.encode(value, forKey: .long_delete)
        case .smoothDelete:
            try container.encode(true, forKey: .smooth_delete)
        case .complete:
            try container.encode(true, forKey: .complete)
        case let .moveCursor(value):
            try container.encode(value, forKey: .move_cursor)
        case let .longMoveCursor(value):
            try container.encode(value, forKey: .long_move_cursor)
        case let .moveTab(destination):
            try container.encode(destination, forKey: .move_tab)
        case .toggleCursorMovingView:
            try container.encode(true, forKey: .toggle_cursor_moving_view)
        case .toggleTabBar:
            try container.encode(true, forKey: .toggle_tab_bar)
        case .toggleCapsLockState:
            try container.encode(true, forKey: .toggle_caps_lock_state)
        case .dismissKeyboard:
            try container.encode(true, forKey: .dismiss_keyboard)
        case let .openApp(value):
            try container.encode(value, forKey: .open_app)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else{
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
        switch key {
        case .input:
            let value = try container.decode(
                String.self,
                forKey: .input
            )
            self = .input(value)
        case .long_input:
            let value = try container.decode(
                String.self,
                forKey: .long_input
            )
            self = .longInput(value)
        case .exchange_character:
            self = .exchangeCharacter
        case .delete:
            let value = try container.decode(
                Int.self,
                forKey: .delete
            )
            self = .delete(value)
        case .long_delete:
            let value = try container.decode(
                Int.self,
                forKey: .long_delete
            )
            self = .longDelete(value)
        case .smooth_delete:
            self = .smoothDelete
        case .complete:
            self = .complete
        case .move_cursor:
            let value = try container.decode(
                Int.self,
                forKey: .move_cursor
            )
            self = .moveCursor(value)
        case .long_move_cursor:
            let value = try container.decode(
                Int.self,
                forKey: .long_move_cursor
            )
            self = .longMoveCursor(value)
        case .move_tab:
            let destination = try container.decode(
                CodableTabData.self,
                forKey: .move_tab
            )
            self = .moveTab(destination)
        case .toggle_cursor_moving_view:
            self = .toggleCursorMovingView
        case .toggle_caps_lock_state:
            self = .toggleCapsLockState
        case .toggle_tab_bar:
            self = .toggleTabBar
        case .dismiss_keyboard:
            self = .dismissKeyboard
        case .open_app:
            let destination = try container.decode(
                String.self,
                forKey: .open_app
            )
            self = .openApp(destination)
        }
    }
}

extension CodableActionData: Hashable {
    static func == (lhs: CodableActionData, rhs: CodableActionData) -> Bool {
        switch (lhs, rhs){
        case let (.input(l), .input(r)):
            return l == r
        case let (.delete(l), .delete(r)):
            return l == r
        case (.smoothDelete, .smoothDelete):
            return true
        case let (.moveCursor(l),.moveCursor(r)):
            return l == r
        case (.toggleTabBar, .toggleTabBar):
            return true
        case (.toggleCursorMovingView,.toggleCursorMovingView):
            return true
        case (.complete, .complete):
            return true
        case (.exchangeCharacter, .exchangeCharacter):
            return true
        case (.toggleCapsLockState,.toggleCapsLockState):
            return true
        case let (.moveTab(l), .moveTab(r)):
            return l == r
        case let (.openApp(l), .openApp(r)):
            return l == r
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        let key: CodingKeys
        switch self {
        case let .input(value):
            hasher.combine(value)
            key = .input
        case let .longInput(value):
            hasher.combine(value)
            key = .long_input
        case .exchangeCharacter:
            key = .exchange_character
        case let .delete(value):
            hasher.combine(value)
            key = .delete
        case let .longDelete(value):
            hasher.combine(value)
            key = .long_delete
        case .smoothDelete:
            key = .smooth_delete
        case .complete:
            key = .complete
        case let .moveCursor(value):
            hasher.combine(value)
            key = .move_cursor
        case let .longMoveCursor(value):
            hasher.combine(value)
            key = .long_move_cursor
        case let .moveTab(destination):
            hasher.combine(destination)
            key = .move_tab
        case .toggleCursorMovingView:
            key = .toggle_cursor_moving_view
        case .toggleTabBar:
            key = .toggle_tab_bar
        case .toggleCapsLockState:
            key = .toggle_caps_lock_state
        case let .openApp(value):
            hasher.combine(value)
            key = .open_app
        case .dismissKeyboard:
            key = .dismiss_keyboard
        }
        hasher.combine(key)
    }
}
