//
//  LanguageLayoutKeyboardSetting.swift
//  LanguageLayoutKeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import KeyboardViews
import SwiftUI

extension LanguageLayout: Savable {
    typealias SaveValue = Data
    var saveValue: Data {
        if let encodedValue = try? JSONEncoder().encode(self) {
            return encodedValue
        } else {
            return Data()
        }
    }

    static func get(_ value: Any) -> LanguageLayout? {
        if let data = value as? Data, let layout = try? JSONDecoder().decode(Self.self, from: data) {
            return layout
        }
        return nil
    }
}

public extension StoredInUserDefault where Value == LanguageLayout {
    @MainActor static func get() -> Value? {
        if let data = SharedStore.userDefaults.data(forKey: key), let type = LanguageLayout.get(data) {
            return type
        } else if let string = SharedStore.userDefaults.string(forKey: key), let type = KeyboardLayout.get(string) {
            switch type {
            case .flick: return .flick
            case .qwerty: return .qwerty
            }
        }
        return nil
    }
    @MainActor static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
    }
}

public protocol LanguageLayoutKeyboardSetting: KeyboardSettingKey, StoredInUserDefault where Value == LanguageLayout {}
public extension LanguageLayoutKeyboardSetting {
    @MainActor static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

public struct JapaneseKeyboardLayout: LanguageLayoutKeyboardSetting {
    public static let title: LocalizedStringKey = "日本語キーボードの種類"
    public static let explanation: LocalizedStringKey = "日本語の入力方法をフリック入力とローマ字入力から選択できます。"
    public static let defaultValue: LanguageLayout = .flick
    public static let key: String = "keyboard_type"
}

public extension KeyboardSettingKey where Self == JapaneseKeyboardLayout {
    static var japaneseKeyboardLayout: Self { .init() }
}

public struct EnglishKeyboardLayout: LanguageLayoutKeyboardSetting {
    public static let title: LocalizedStringKey = "英語キーボードの種類"
    public static let explanation: LocalizedStringKey = "英語の入力方法をフリック入力とローマ字入力から選択できます。"
    public static let defaultValue: LanguageLayout = .flick
    public static let key: String = "keyboard_type_en"
}

public extension KeyboardSettingKey where Self == EnglishKeyboardLayout {
    static var englishKeyboardLayout: Self { .init() }
}

extension KeyboardLayout: Savable {
    typealias SaveValue = String
    var saveValue: String {
        self.rawValue
    }

    static func get(_ value: Any) -> KeyboardLayout? {
        if let string = value as? String {
            return self.init(rawValue: string)
        }
        return nil
    }
}
