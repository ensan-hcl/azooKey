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
public enum CodableTabData: Hashable {
    /// - tabs prepared by default
    case system(SystemTab)
    /// - tabs made as custom tabs.
    case custom(String)

    /// - system tabs
    public enum SystemTab: String, Codable {
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

public extension CodableTabData {
    private enum ValueType: String, Codable{
        case custom, system
    }

    private var valueType: ValueType {
        switch self{
        case .system: return .system
        case .custom: return .custom
        }
    }

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
        hasher.combine(valueType)
        switch self{
        case let .system(tab):
            hasher.combine(tab)
        case let .custom(tab):
            hasher.combine(tab)
        }
    }
}

public struct ScanItem: Codable, Hashable {
    public init(targets: [String], direction: ScanItem.Direction) {
        self.targets = targets
        self.direction = direction
    }

    let targets: [String]
    let direction: Direction

    public enum Direction: String, Codable {
        case forward
        case backward
    }
}
/// - アクション
/// - actions done in key pressing
public enum CodableActionData: Codable, Equatable {
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
    case smartDelete(ScanItem)

    /// - complete current inputting words
    case complete

    /// - move cursor  specified count forward. when you specify negative number, the cursor moves backword
    case moveCursor(Int)

    /// - move cursor to the ` direction` until `target` appears in the direction of travel..
    /// - if `target` is `[".", ","]`, `direction` is `.backward`, and current text is `I love this. But |she likes`, after the action, the text become `I love this.| But she likes`.
    case smartMoveCursor(ScanItem)

    /// - move to specified tab
    case moveTab(CodableTabData)

    /// - enable keyboard resizing mode
    case enableResizingMode

    /// - toggle show or not show the cursor move bar
    case toggleCursorBar

    /// - toggle caps lock or not
    case toggleCapsLockState

    /// - toggle show or not show the tab bar
    case toggleTabBar

    /// - dismiss keyboard
    case dismissKeyboard

    /// - open specified url scheme.
    /// - warning: this action could be deleted in future iOS.
    /// - warning: some of url schemes doesn't work.
    case openURL(String)    //iOSのバージョンによって消える可能性がある
}

public extension CodableActionData{
    enum CodingKeys: CodingKey {
        case type
        case text
        case count
        case table
        case destination
        case tab_type, identifier
        case direction, targets
    }

    private enum ValueType: String, Codable{
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
        case enable_resizing_mode
        case toggle_cursor_bar
        case toggle_tab_bar
        case toggle_caps_lock_state
        case warning_private_forbidden_should_not_use_open_url
        case dismiss_keyboard
    }

    private var key: ValueType {
        switch self {
        case .complete: return .complete
        case .delete: return .delete
        case .dismissKeyboard: return .dismiss_keyboard
        case .input: return .input
        case .moveCursor: return .move_cursor
        case .moveTab: return .move_tab
        case .openURL: return .warning_private_forbidden_should_not_use_open_url
        case .replaceDefault: return .replace_default
        case .replaceLastCharacters: return .replace_last_characters
        case .smartDelete: return .smart_delete
        case .smartDeleteDefault: return .smart_delete_default
        case .smartMoveCursor: return .smart_move_cursor
        case .enableResizingMode: return .enable_resizing_mode
        case .toggleCapsLockState: return .toggle_caps_lock_state
        case .toggleCursorBar: return .toggle_cursor_bar
        case .toggleTabBar: return .toggle_tab_bar
        }
    }
    private struct CodableTabArgument{
        internal init(tab: CodableTabData) {
            self.tab = tab
        }
        private var tab: CodableTabData

        private enum TabType: String, Codable{
            case custom, system
        }

        func containerEncode(container: inout KeyedEncodingContainer<CodingKeys>) throws {
            switch tab{
            case .system:
                try container.encode(TabType.system, forKey: .tab_type)
            case .custom:
                try container.encode(TabType.custom, forKey: .tab_type)
            }
            switch tab {
            case let .system(value as Encodable),
                 let .custom(value as Encodable):
                try value.containerEncode(container: &container, key: .identifier)
            }
        }

        static func containerDecode(container: KeyedDecodingContainer<CodingKeys>) throws -> CodableTabData {
            let type = try container.decode(TabType.self, forKey: .tab_type)
            switch type {
            case .system:
                let tab = try container.decode(CodableTabData.SystemTab.self, forKey: .identifier)
                return .system(tab)
            case .custom:
                let tab = try container.decode(String.self, forKey: .identifier)
                return .custom(tab)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.key, forKey: .type)
        switch self {
        case let .input(value):
            try container.encode(value, forKey: .text)
        case let .replaceLastCharacters(value):
            try container.encode(value, forKey: .table)
        case let .delete(value), let .moveCursor(value):
            try container.encode(value, forKey: .count)
        case let .smartDelete(value), let .smartMoveCursor(value):
            try container.encode(value.direction, forKey: .direction)
            try container.encode(value.targets, forKey: .targets)
        case let .moveTab(value):
            try CodableTabArgument(tab: value).containerEncode(container: &container)
        case let .openURL(value):
            try container.encode(value, forKey: .destination)
        case .dismissKeyboard, .enableResizingMode, .toggleTabBar, .toggleCursorBar, .toggleCapsLockState, .complete, .smartDeleteDefault, .replaceDefault: break
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueType = try container.decode(ValueType.self, forKey: .type)
        switch valueType {
        case .input:
            let value = try container.decode(String.self, forKey: .text)
            self = .input(value)
        case .replace_default:
            self = .replaceDefault
        case .replace_last_characters:
            let value = try container.decode([String: String].self, forKey: .table)
            self = .replaceLastCharacters(value)
        case .delete:
            let value = try container.decode(Int.self, forKey: .count)
            self = .delete(value)
        case .smart_delete_default:
            self = .smartDeleteDefault
        case .smart_delete:
            let direction = try container.decode(ScanItem.Direction.self, forKey: .direction)
            let targets = try container.decode([String].self, forKey: .targets)
            self = .smartDelete(.init(targets: targets, direction: direction))
        case .complete:
            self = .complete
        case .move_cursor:
            let value = try container.decode(Int.self, forKey: .count)
            self = .moveCursor(value)
        case .smart_move_cursor:
            let direction = try container.decode(ScanItem.Direction.self, forKey: .direction)
            let targets = try container.decode([String].self, forKey: .targets)
            self = .smartMoveCursor(.init(targets: targets, direction: direction))
        case .move_tab:
            let value = try CodableTabArgument.containerDecode(container: container)
            self = .moveTab(value)
        case .enable_resizing_mode:
            self = .enableResizingMode
        case .toggle_cursor_bar:
            self = .toggleCursorBar
        case .toggle_caps_lock_state:
            self = .toggleCapsLockState
        case .toggle_tab_bar:
            self = .toggleTabBar
        case .dismiss_keyboard:
            self = .dismissKeyboard
        case .warning_private_forbidden_should_not_use_open_url:
            let value = try container.decode(String.self, forKey: .destination)
            self = .openURL(value)
        }
    }
}

public extension CodableActionData {
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

        case (.enableResizingMode, .enableResizingMode):
            return true
        case (.toggleTabBar, .toggleTabBar):
            return true
        case (.toggleCursorBar,.toggleCursorBar):
            return true
        case (.toggleCapsLockState,.toggleCapsLockState):
            return true
        case let (.openURL(l), .openURL(r)):
            return l == r

        case (.dismissKeyboard, .dismissKeyboard):
            return true

        default:
            return false
        }
    }
    /*
    func hash(into hasher: inout Hasher) {
        let key: ValueType
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
        case .enableResizingMode:
            key = .enable_resizing_mode
        case .toggleCursorBar:
            key = .toggle_cursor_bar
        case .toggleTabBar:
            key = .toggle_tab_bar
        case .toggleCapsLockState:
            key = .toggle_caps_lock_state
        case let .openURL(value):
            hasher.combine(value)
            key = .warning_private_forbidden_should_not_use_open_url
        case .dismissKeyboard:
            key = .dismiss_keyboard
        }
        hasher.combine(key)
    }
     */

}

public struct CodableLongpressActionData: Codable, Equatable {
    public static let none = CodableLongpressActionData()
    public init(start: [CodableActionData] = [], repeat: [CodableActionData] = []) {
        self.start = start
        self.repeat = `repeat`
    }

    var start: [CodableActionData]
    var `repeat`: [CodableActionData]
}
