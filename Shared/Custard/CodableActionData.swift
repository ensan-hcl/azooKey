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
        case qwerty_numbers

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
    case input(String)

    /// - exchange character "あ→ぁ", "は→ば", "a→A"
    case replaceDefault

    /// - replace string at the trailing of cursor following to specified table
    case replaceLastCharacters([String: String])

    /// - delete action specified count of characters
    case delete(Int)

    /// - delete to beginning of the sentence
    case smartDeleteDefault

    /// - delete to the ` direction` until `target` appears in the direction of travel..
    /// - if `target` is `[".", ","]`, `direction` is `.backward`, and current text is `I love this. But |she likes`, after the action, the text become `I love this.|she likes`.
    case smartDelete(SmartDeleteItem)

    /// - complete current inputting words
    case complete

    /// - move cursor  specified count forward. when you specify negative number, the cursor moves backword
    case moveCursor(Int)

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
    enum CodingKeys: String, Codable, CodingKey{
        case action
        case input
        case replace_default
        case replace_last_characters
        case delete
        case smart_delete
        case smart_delete_default
        case complete
        case move_cursor
        case smart_move_cursor
        case move_tab
        case toggle_cursor_bar
        case toggle_tab_bar
        case toggle_capslock_state
        case open_url
        case dismiss_keyboard
    }

    private var key: CodingKeys {
        switch self {
        case .complete: return .complete
        case .delete: return .delete
        case .dismissKeyboard: return .dismiss_keyboard
        case .input: return .input
        case .moveCursor: return .move_cursor
        case .moveTab: return .move_tab
        case .openURL: return .open_url
        case .replaceDefault: return .replace_default
        case .replaceLastCharacters: return .replace_last_characters
        case .smartDelete: return .smart_delete
        case .smartDeleteDefault: return .smart_delete_default
        case .smartMoveCursor: return .smart_move_cursor
        case .toggleCapslockState: return .toggle_capslock_state
        case .toggleCursorBar: return .toggle_cursor_bar
        case .toggleTabBar: return .toggle_tab_bar
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //{"action": "action_identifier"}
        try container.encode(self.key, forKey: .action)
        switch self {
        case let .input(value):
            try container.encode(value, forKey: self.key)
        case let .replaceLastCharacters(value):
            try container.encode(value, forKey: self.key)
        case let .delete(value):
            try container.encode(value, forKey: self.key)
        case let .smartDelete(value):
            try container.encode(value, forKey: self.key)
        case let .moveCursor(value):
            try container.encode(value, forKey: self.key)
        case let .smartMoveCursor(value):
            try container.encode(value, forKey: self.key)
        case let .moveTab(value):
            try container.encode(value, forKey: self.key)
        case let .openURL(value):
            try container.encode(value, forKey: self.key)
        case .dismissKeyboard, .toggleTabBar, .toggleCursorBar, .toggleCapslockState, .complete, .smartDeleteDefault, .replaceDefault:
            break
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actionType = try container.decode(CodingKeys.self, forKey: .action)
        switch actionType {
        case .action:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Failed to decode CodableActionData: keys are \(container.allKeys)."
                )
            )
        case .input:
            let value = try container.decode(
                String.self,
                forKey: actionType
            )
            self = .input(value)
        case .replace_default:
            self = .replaceDefault
        case .replace_last_characters:
            let value = try container.decode(
                [String: String].self,
                forKey: actionType
            )
            self = .replaceLastCharacters(value)
        case .delete:
            let value = try container.decode(
                Int.self,
                forKey: actionType
            )
            self = .delete(value)
        case .smart_delete_default:
            self = .smartDeleteDefault
        case .smart_delete:
            let value = try container.decode(
                SmartDeleteItem.self,
                forKey: actionType
            )
            self = .smartDelete(value)
        case .complete:
            self = .complete
        case .move_cursor:
            let value = try container.decode(
                Int.self,
                forKey: actionType
            )
            self = .moveCursor(value)
        case .smart_move_cursor:
            let value = try container.decode(
                SmartMoveCursorItem.self,
                forKey: actionType
            )
            self = .smartMoveCursor(value)
        case .move_tab:
            let destination = try container.decode(
                CodableTabData.self,
                forKey: actionType
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
                forKey: actionType
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

        case (.replaceDefault, .replaceDefault):
            return true
        case let (.replaceLastCharacters(l), .replaceLastCharacters(r)):
            return l == r

        case let (.delete(l), .delete(r)):
            return l == r
        case (.smartDeleteDefault, .smartDeleteDefault):
            return true
        case let (.smartDelete(l), .smartDelete(r)):
            return l == r

        case (.complete, .complete):
            return true

        case let (.moveCursor(l),.moveCursor(r)):
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
        case .replaceDefault:
            key = .replace_default
        case let .replaceLastCharacters(value):
            hasher.combine(value)
            key = .replace_last_characters
        case let .delete(value):
            hasher.combine(value)
            key = .delete
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

struct CodableLongpressActionData: Codable, Equatable {
    static let none = CodableLongpressActionData()
    internal init(start: [CodableActionData] = [], repeat: [CodableActionData] = []) {
        self.start = start
        self.repeat = `repeat`
    }

    var start: [CodableActionData]
    var `repeat`: [CodableActionData]
}
