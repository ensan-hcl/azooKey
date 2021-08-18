//
//  LanguageLayoutKeyboardSetting.swift
//  LanguageLayoutKeyboardSetting
//
//  Created by β α on 2021/08/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum LanguageLayout {
    case flick
    case qwerty
    case custard(String)
}

extension LanguageLayout: Codable, Hashable {
    private enum CodingKeys: CodingKey {
        case flick
        case qwerty
        case custard
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .flick:
            try container.encode(true, forKey: .flick)
        case .qwerty:
            try container.encode(true, forKey: .qwerty)
        case let .custard(value):
            try container.encode(value, forKey: .custard)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode LanguageLayout."
                )
            )
        }
        switch key {
        case .flick:
            self = .flick
        case .qwerty:
            self = .qwerty
        case .custard:
            let value = try container.decode(
                String.self,
                forKey: .custard
            )
            self = .custard(value)
        }
    }
}

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

extension StoredInUserDefault where Value == LanguageLayout {
    static func get() -> Value? {
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
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
    }
}

protocol LanguageLayoutKeyboardSetting: KeyboardSettingKey, StoredInUserDefault where Value == LanguageLayout {}
extension LanguageLayoutKeyboardSetting {
    static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

struct JapaneseKeyboardLayout: LanguageLayoutKeyboardSetting {
    static let title: LocalizedStringKey = "日本語キーボードの種類"
    static let explanation: LocalizedStringKey = "日本語の入力方法をフリック入力とローマ字入力から選択できます。"
    static let defaultValue: LanguageLayout = .flick
    static let key: String = "keyboard_type"
}

extension KeyboardSettingKey where Self == JapaneseKeyboardLayout {
    static var japaneseKeyboardLayout: Self { .init() }
}

struct EnglishKeyboardLayout: LanguageLayoutKeyboardSetting {
    static let title: LocalizedStringKey = "英語キーボードの種類"
    static let explanation: LocalizedStringKey = "英語の入力方法をフリック入力とローマ字入力から選択できます。"
    static let defaultValue: LanguageLayout = .flick
    static let key: String = "keyboard_type_en"
}

extension KeyboardSettingKey where Self == EnglishKeyboardLayout {
    static var englishKeyboardLayout: Self { .init() }
}
