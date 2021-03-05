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
                    debugDescription: "Unabled to decode CodableTabData."
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

struct SmartDeleteItem: Codable, Hashable {
    let targets: [String]
    let direction: Direction

    enum Direction: String, Codable {
        case forward
        case backward
    }
}

struct SmartMoveCursorItem: Codable, Hashable {
    let targets: [String]
    let direction: Direction

    enum Direction: String, Codable {
        case forward
        case backward
    }
}

/// - アクション
/// - actions done in key pressing
enum CodableActionData: Codable {
    /// - input action specified character
    /// - warning: when use this in longpress, it works as one time action
    case input(String)

    /// - input action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longInput(String)

    /// - exchange character "あ→ぁ", "は→ば", "a→A"
    case replaceDefault

    /// - replace string at the trailing of cursor following to specified table
    case replaceLastCharacters([String: String])

    /// - delete action specified count of characters
    /// - warning: when use this in longpress, it works as one time action
    case delete(Int)

    /// - delete action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longDelete(Int)

    /// - delete to beginning of the sentence
    case smartDeleteDefault

    /// - delete to the ` direction` until `target` appears in the direction of travel..
    /// - if `target` is `[".", ","]`, `direction` is `.backward`, and current text is `I love this. But |she likes`, after the action, the text become `I love this.|she likes`.
    case smartDelete(SmartDeleteItem)

    /// - complete current inputting words
    case complete

    /// - move cursor  specified count forward. when you specify negative number, the cursor moves backword
    /// - warning: when use this in longpress, it works as one time action
    case moveCursor(Int)

    /// - move cursor action used in longpress
    /// - warning: when use this in not longpress, it works as one time action
    case longMoveCursor(Int)

    /// - move cursor to the ` direction` until `target` appears in the direction of travel..
    /// - if `target` is `[".", ","]`, `direction` is `.backward`, and current text is `I love this. But |she likes`, after the action, the text become `I love this.| But she likes`.
    case smartMoveCursor(SmartMoveCursorItem)

    /// - move to specified tab
    case moveTab(CodableTabData)

    /// - toggle show or not show the cursor move bar
    case toggleCursorBar

    /// - toggle capslock or not
    case toggleCapslockState

    /// - toggle show or not show the tab bar
    case toggleTabBar

    /// - dismiss keyboard
    case dismissKeyboard

    /// - open specified url scheme.
    /// - warning: this action could be deleted in future iOS.
    /// - warning: some of url schemes doesn't work.
    case openURL(String)    //iOSのバージョンによって消える可能性がある
}

extension CodableActionData{
    enum CodingKeys: CodingKey{
        case input
        case long_input
        case replace_default
        case replace_last_characters
        case delete
        case long_delete
        case smart_delete
        case smart_delete_default
        case complete
        case move_cursor
        case long_move_cursor
        case smart_move_cursor
        case move_tab
        case toggle_cursor_bar
        case toggle_tab_bar
        case toggle_capslock_state
        case open_url
        case dismiss_keyboard
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .input(value):
            try container.encode(value, forKey: .input)
        case let .longInput(value):
            try container.encode(value, forKey: .long_input)

        case .replaceDefault:
            try container.encode(true, forKey: .replace_default)
        case let .replaceLastCharacters(value):
            try container.encode(value, forKey: .replace_last_characters)

        case let .delete(value):
            try container.encode(value, forKey: .delete)
        case let .longDelete(value):
            try container.encode(value, forKey: .long_delete)
        case .smartDeleteDefault:
            try container.encode(true, forKey: .smart_delete_default)
        case let .smartDelete(value):
            try container.encode(value, forKey: .smart_delete)

        case .complete:
            try container.encode(true, forKey: .complete)

        case let .moveCursor(value):
            try container.encode(value, forKey: .move_cursor)
        case let .longMoveCursor(value):
            try container.encode(value, forKey: .long_move_cursor)
        case let .smartMoveCursor(value):
            try container.encode(value, forKey: .smart_move_cursor)

        case let .moveTab(destination):
            try container.encode(destination, forKey: .move_tab)

        case .toggleCursorBar:
            try container.encode(true, forKey: .toggle_cursor_bar)
        case .toggleTabBar:
            try container.encode(true, forKey: .toggle_tab_bar)
        case .toggleCapslockState:
            try container.encode(true, forKey: .toggle_capslock_state)

        case .dismissKeyboard:
            try container.encode(true, forKey: .dismiss_keyboard)
        case let .openURL(value):
            try container.encode(value, forKey: .open_url)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else{
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode CodableActionData: keys are \(container.allKeys)."
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
        case .replace_default:
            self = .replaceDefault
        case .replace_last_characters:
            let value = try container.decode(
                [String: String].self,
                forKey: .replace_last_characters
            )
            self = .replaceLastCharacters(value)
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
        case .smart_delete_default:
            self = .smartDeleteDefault
        case .smart_delete:
            let value = try container.decode(
                SmartDeleteItem.self,
                forKey: .smart_delete
            )
            self = .smartDelete(value)
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
        case .smart_move_cursor:
            let value = try container.decode(
                SmartMoveCursorItem.self,
                forKey: .smart_move_cursor
            )
            self = .smartMoveCursor(value)
        case .move_tab:
            let destination = try container.decode(
                CodableTabData.self,
                forKey: .move_tab
            )
            self = .moveTab(destination)
        case .toggle_cursor_bar:
            self = .toggleCursorBar
        case .toggle_capslock_state:
            self = .toggleCapslockState
        case .toggle_tab_bar:
            self = .toggleTabBar
        case .dismiss_keyboard:
            self = .dismissKeyboard
        case .open_url:
            let destination = try container.decode(
                String.self,
                forKey: .open_url
            )
            self = .openURL(destination)
        }
    }
}

extension CodableActionData: Hashable {
    static func == (lhs: CodableActionData, rhs: CodableActionData) -> Bool {
        switch (lhs, rhs){
        case let (.input(l), .input(r)):
            return l == r
        case let (.longInput(l), .longInput(r)):
            return l == r

        case (.replaceDefault, .replaceDefault):
            return true
        case let (.replaceLastCharacters(l), .replaceLastCharacters(r)):
            return l == r

        case let (.delete(l), .delete(r)):
            return l == r
        case let (.longDelete(l), .longDelete(r)):
            return l == r
        case (.smartDeleteDefault, .smartDeleteDefault):
            return true
        case let (.smartDelete(l), .smartDelete(r)):
            return l == r

        case (.complete, .complete):
            return true

        case let (.moveCursor(l),.moveCursor(r)):
            return l == r
        case let (.longMoveCursor(l), .longMoveCursor(r)):
            return l == r
        case let (.smartMoveCursor(l), .smartMoveCursor(r)):
            return l == r

        case let (.moveTab(l), .moveTab(r)):
            return l == r

        case (.toggleTabBar, .toggleTabBar):
            return true
        case (.toggleCursorBar,.toggleCursorBar):
            return true
        case (.toggleCapslockState,.toggleCapslockState):
            return true
        case let (.openURL(l), .openURL(r)):
            return l == r

        case (.dismissKeyboard, .dismissKeyboard):
            return true

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
        case .replaceDefault:
            key = .replace_default
        case let .replaceLastCharacters(value):
            hasher.combine(value)
            key = .replace_last_characters
        case let .delete(value):
            hasher.combine(value)
            key = .delete
        case let .longDelete(value):
            hasher.combine(value)
            key = .long_delete
        case let .smartDelete(value):
            hasher.combine(value)
            key = .smart_delete
        case .smartDeleteDefault:
            key = .smart_delete_default
        case .complete:
            key = .complete
        case let .moveCursor(value):
            hasher.combine(value)
            key = .move_cursor
        case let .longMoveCursor(value):
            hasher.combine(value)
            key = .long_move_cursor
        case let .smartMoveCursor(value):
            hasher.combine(value)
            key = .smart_move_cursor
        case let .moveTab(destination):
            hasher.combine(destination)
            key = .move_tab
        case .toggleCursorBar:
            key = .toggle_cursor_bar
        case .toggleTabBar:
            key = .toggle_tab_bar
        case .toggleCapslockState:
            key = .toggle_capslock_state
        case let .openURL(value):
            hasher.combine(value)
            key = .open_url
        case .dismissKeyboard:
            key = .dismiss_keyboard
        }
        hasher.combine(key)
    }
}
