//
//  Tab.swift
//  azooKey
//
//  Created by ensan on 2022/12/20.
//  Copyright © 2022 ensan. All rights reserved.
//

import CustardKit
import Foundation
@preconcurrency import KanaKanjiConverterModule

public enum UpsideComponent: Equatable, Sendable {
    case search([ConverterBehaviorSemantics.ReplacementTarget])
}

public enum Tab: Equatable {
    case existential(ExistentialTab)
    case user_dependent(UserDependentTab)
    case last_tab

    public enum ExistentialTab: Equatable {
        case flick_hira
        case flick_abc
        case flick_numbersymbols
        case qwerty_hira
        case qwerty_abc
        case qwerty_number
        case qwerty_symbols
        case custard(Custard)
        case special(SpecialTab)

        public static func == (lhs: ExistentialTab, rhs: ExistentialTab) -> Bool {
            switch (lhs, rhs) {
            case (.flick_hira, .flick_hira), (.flick_abc, .flick_abc), (.flick_numbersymbols, .flick_numbersymbols), (.qwerty_hira, .qwerty_hira), (.qwerty_abc, .qwerty_abc), (.qwerty_number, .qwerty_number), (.qwerty_symbols, .qwerty_symbols): return true
            case (.custard(let l), .custard(let r)):
                return l.identifier == r.identifier
                    && l.input_style == r.input_style
                    && l.language == r.language
                    && l.metadata == r.metadata
                    && l.interface == r.interface
            default: return false
            }
        }

        var inputStyle: InputStyle {
            switch self {
            case .qwerty_hira:
                return .roman2kana
            case let .custard(custard):
                switch custard.input_style {
                case .direct:
                    return .direct
                case .roman2kana:
                    return .roman2kana
                }
            default:
                return .direct
            }
        }

        public var layout: KeyboardLayout {
            switch self {
            case .flick_hira, .flick_abc, .flick_numbersymbols:
                return .flick
            case .qwerty_hira, .qwerty_abc, .qwerty_number, .qwerty_symbols:
                return .qwerty
            case let .custard(custard):
                switch custard.interface.keyStyle {
                case .tenkeyStyle:
                    return .flick
                case .pcStyle:
                    return .qwerty
                }
            case .special:
                // FIXME: 仮置き
                return .flick
            }
        }

        var language: KeyboardLanguage? {
            switch self {
            case .flick_abc, .qwerty_abc:
                return .en_US
            case .flick_hira, .qwerty_hira:
                return .ja_JP
            case let .custard(custard):
                switch custard.language {
                case .ja_JP:
                    return .ja_JP
                case .en_US:
                    return .en_US
                case .el_GR:
                    return .el_GR
                case .undefined:
                    return nil
                case .none:
                    return KeyboardLanguage.none
                }
            case .flick_numbersymbols, .qwerty_number, .qwerty_symbols:
                return nil
            case .special:
                return KeyboardLanguage.none
            }
        }

        public var replacementTarget: [ConverterBehaviorSemantics.ReplacementTarget] {
            switch self {
            case .special(.emoji):
                return [.emoji]
            default: return []
            }
        }
    }

    public enum SpecialTab: Equatable {
        case clipboard_history_tab
        case emoji
    }

    public enum UserDependentTab: Equatable {
        case japanese
        case english
    }
}
