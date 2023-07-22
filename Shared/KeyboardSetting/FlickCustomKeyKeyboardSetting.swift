//
//  FlickCustomKeyKeyboardSetting.swift
//  FlickCustomKeyKeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import KeyboardViews
import SwiftUI

extension StoredInUserDefault where Value == KeyFlickSetting {
    @MainActor static func get() -> Value? {
        let value = SharedStore.userDefaults.value(forKey: key)
        if let value, let data = KeyFlickSetting.get(value) {
            return data
        }
        return nil
    }
    @MainActor static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
    }
}

extension KeyFlickSetting: Savable {
    typealias SaveValue = Data
    var saveValue: Data {
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(self) {
            return encodedValue
        } else {
            return Data()
        }
    }
}

protocol FlickCustomKeyKeyboardSetting: KeyboardSettingKey, StoredInUserDefault where Value == KeyFlickSetting {
    static var identifier: CustomizableFlickKey { get }
}
extension FlickCustomKeyKeyboardSetting {
    static var defaultValue: Value {
        identifier.defaultSetting
    }
    @MainActor static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

struct KoganaFlickCustomKey: FlickCustomKeyKeyboardSetting {
    static let title: LocalizedStringKey = "「小ﾞﾟ」キーのフリック割り当て"
    static let explanation: LocalizedStringKey = "「小ﾞﾟ」キーの「左」「上」「右」フリックに、好きな文字列を割り当てて利用することができます。"
    static let identifier = CustomizableFlickKey.kogana
    static let key: String = "kogana_flicks"
}

extension KeyboardSettingKey where Self == KoganaFlickCustomKey {
    static var koganaFlickCustomKey: Self { .init() }
}

struct KanaSymbolsFlickCustomKey: FlickCustomKeyKeyboardSetting {
    static let title: LocalizedStringKey = "「､｡?!」キーのフリック割り当て"
    static let explanation: LocalizedStringKey = "「､｡?!」キーの「左」「上」「右」フリックに割り当てられた文字を変更することができます。"
    static let identifier = CustomizableFlickKey.kanaSymbols
    static let key: String = "kana_symbols_flick"
}

extension KeyboardSettingKey where Self == KanaSymbolsFlickCustomKey {
    static var kanaSymbolsFlickCustomKey: Self { .init() }
}

struct SymbolsTabFlickCustomKey: FlickCustomKeyKeyboardSetting {
    static let title: LocalizedStringKey = "「☆123」キーのフリック割り当て"
    static let explanation: LocalizedStringKey = "「☆123」キーの「上」「右」「下」フリックに、好きな操作を割り当てて利用することができます。"
    static let identifier = CustomizableFlickKey.symbolsTab
    static let key: String = "symbols_tab_flick"
}

extension KeyboardSettingKey where Self == SymbolsTabFlickCustomKey {
    static var symbolsTabFlickCustomKey: Self { .init() }
}

struct AbcTabFlickCustomKey: FlickCustomKeyKeyboardSetting {
    static let title: LocalizedStringKey = "「abc」キーのフリック割り当て"
    static let explanation: LocalizedStringKey = "「abc」キーの「上」「右」「下」フリックに、好きな操作を割り当てて利用することができます。"
    static let identifier = CustomizableFlickKey.abcTab
    static let key: String = "abc_tab_flick"
}

extension KeyboardSettingKey where Self == AbcTabFlickCustomKey {
    static var abcTabFlickCustomKey: Self { .init() }
}

struct HiraTabFlickCustomKey: FlickCustomKeyKeyboardSetting {
    static let title: LocalizedStringKey = "「あいう」キーのフリック割り当て"
    static let explanation: LocalizedStringKey = "「あいう」キーの「上」「右」「下」フリックに、好きな操作を割り当てて利用することができます。"
    static let identifier = CustomizableFlickKey.hiraTab
    static let key: String = "hira_tab_flick"
}

extension KeyboardSettingKey where Self == HiraTabFlickCustomKey {
    static var hiraTabFlickCustomKey: Self { .init() }
}
