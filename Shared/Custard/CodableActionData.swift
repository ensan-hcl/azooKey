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
public enum CodableTabData: Codable, Hashable {
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

public extension CodableTabData{
    enum CodingKeys: CodingKey{
        case type
        case destination
    }

    private enum ValueType: String, Codable{
        case custom, system
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .system(value):
            try container.encode(ValueType.system, forKey: .type)
            try container.encode(value, forKey: .destination)
        case let .custom(value):
            try container.encode(ValueType.custom, forKey: .type)
            try container.encode(value, forKey: .destination)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueType = try container.decode(ValueType.self, forKey: .type)
        switch valueType {
        case .system:
            let value = try container.decode(SystemTab.self,forKey: .destination)
            self = .system(value)
        case .custom:
            let value = try container.decode(String.self,forKey: .destination)
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

public extension CodableTabData {
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
            hasher.combine(ValueType.system)
        case let .custom(tab):
            hasher.combine(tab)
            hasher.combine(ValueType.custom)
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
public enum CodableActionData: Codable, Hashable {
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

public extension CodableActionData{
    enum CodingKeys: CodingKey {
        case type
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
        case toggle_cursor_bar
        case toggle_tab_bar
        case toggle_capslock_state
        case open_url
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

    private struct InputArgument: Codable {
        var type: ValueType = .input
        var text: String
    }
    private struct CountArgument: Codable {
        var type: ValueType
        var count: Int
    }
    private struct TableArgument<Key: Codable&Hashable, Value: Codable>: Codable {
        var type: ValueType
        var table: [Key: Value]
    }
    private struct DestinationArgument<Destination: Codable>: Codable {
        var type: ValueType
        var destination: Destination
    }
    private struct CodableTabArgument: Codable {
        internal init(type: CodableActionData.ValueType, tab: CodableTabData) {
            self.type = type
            self.tab = tab
        }
        
        var type: ValueType
        var tab: CodableTabData

        enum CodingKeys: CodingKey{
            case type, tab_type, identifier
        }

        private enum TabType: String, Codable{
            case custom, system
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            switch tab {
            case let .system(value):
                try container.encode(TabType.system, forKey: .tab_type)
                try container.encode(value, forKey: .identifier)
            case let .custom(value):
                try container.encode(TabType.custom, forKey: .tab_type)
                try container.encode(value, forKey: .identifier)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(ValueType.self, forKey: .type)
            let tabType = try container.decode(TabType.self, forKey: .tab_type)
            switch tabType {
            case .system:
                let value = try container.decode(CodableTabData.SystemTab.self, forKey: .identifier)
                self.tab = .system(value)
            case .custom:
                let value = try container.decode(String.self, forKey: .identifier)
                self.tab = .custom(value)
            }
        }
    }
    private struct ScanArgument: Codable {
        var type: ValueType
        var direction: ScanItem.Direction
        var targets: [String]
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .input(value):
            try InputArgument(text: value).encode(to: encoder)
        case let .replaceLastCharacters(value):
            try TableArgument(type: .replace_last_characters, table: value).encode(to: encoder)
        case let .delete(value):
            try CountArgument(type: .delete, count: value).encode(to: encoder)
        case let .smartDelete(value):
            try ScanArgument(type: .smart_delete, direction: value.direction, targets: value.targets).encode(to: encoder)
        case let .moveCursor(value):
            try CountArgument(type: .move_cursor, count: value).encode(to: encoder)
        case let .smartMoveCursor(value):
            try ScanArgument(type: .smart_move_cursor, direction: value.direction, targets: value.targets).encode(to: encoder)
        case let .moveTab(value):
            try CodableTabArgument(type: .move_tab, tab: value).encode(to: encoder)
        case let .openURL(value):
            try DestinationArgument(type: .open_url, destination: value).encode(to: encoder)
        case .dismissKeyboard, .toggleTabBar, .toggleCursorBar, .toggleCapslockState, .complete, .smartDeleteDefault, .replaceDefault:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.key, forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueType = try container.decode(ValueType.self, forKey: .type)
        switch valueType {
        case .input:
            let value = try InputArgument.init(from: decoder)
            self = .input(value.text)
        case .replace_default:
            self = .replaceDefault
        case .replace_last_characters:
            let value = try TableArgument<String,String>.init(from: decoder)
            self = .replaceLastCharacters(value.table)
        case .delete:
            let value = try CountArgument.init(from: decoder)
            self = .delete(value.count)
        case .smart_delete_default:
            self = .smartDeleteDefault
        case .smart_delete:
            let value = try ScanArgument.init(from: decoder)
            self = .smartDelete(.init(targets: value.targets, direction: value.direction))
        case .complete:
            self = .complete
        case .move_cursor:
            let value = try CountArgument.init(from: decoder)
            self = .moveCursor(value.count)
        case .smart_move_cursor:
            let value = try ScanArgument.init(from: decoder)
            self = .smartMoveCursor(.init(targets: value.targets, direction: value.direction))
        case .move_tab:
            let value = try CodableTabArgument.init(from: decoder)
            self = .moveTab(value.tab)
        case .toggle_cursor_bar:
            self = .toggleCursorBar
        case .toggle_capslock_state:
            self = .toggleCapslockState
        case .toggle_tab_bar:
            self = .toggleTabBar
        case .dismiss_keyboard:
            self = .dismissKeyboard
        case .open_url:
            let value = try DestinationArgument<String>.init(from: decoder)
            self = .openURL(value.destination)
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

public struct CodableLongpressActionData: Codable, Equatable {
    public static let none = CodableLongpressActionData()
    public init(start: [CodableActionData] = [], repeat: [CodableActionData] = []) {
        self.start = start
        self.repeat = `repeat`
    }

    var start: [CodableActionData]
    var `repeat`: [CodableActionData]
}
