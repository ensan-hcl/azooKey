//
//  PreferredLanguageKeyboardSetting.swift
//  PreferredLanguageKeyboardSetting
//
//  Created by β α on 2021/08/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct PreferredLanguage: Codable, Hashable {
    var first: KeyboardLanguage
    var second: KeyboardLanguage?
}

extension PreferredLanguage: Savable {
    typealias SaveValue = Data

    var saveValue: Data {
        if let encodedValue = try? JSONEncoder().encode(self) {
            return encodedValue
        } else {
            return Data()
        }
    }

    static func get(_ value: Any) -> Self? {
        if let data = value as? Data, let result = try? JSONDecoder().decode(Self.self, from: data) {
            return result
        }
        return nil
    }
}

struct PreferredLanguageSetting: KeyboardSettingKey {
    typealias Value = PreferredLanguage
    static let title: LocalizedStringKey = "入力する言語"
    static let explanation: LocalizedStringKey = "キーボード上で入力する言語を選択できます。"
    static let defaultValue: PreferredLanguage = PreferredLanguage(first: .ja_JP, second: .en_US)
    private static let key = "preferred_language_order"
    static var value: PreferredLanguage {
        get {
            if let value = SharedStore.userDefaults.value(forKey: key), let data = PreferredLanguage.get(value) {
                return data
            }
            return defaultValue
        }
        set {
            SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
        }
    }
}

extension KeyboardSettingKey where Self == PreferredLanguageSetting {
    static var preferredLanguage: Self { .init() }
}
