//
//  QwertyCustomKeyKeyboardSetting.swift
//  QwertyCustomKeyKeyboardSetting
//
//  Created by β α on 2021/08/11.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

protocol QwertyCustomKeyKeyboardSetting: KeyboardSettingKey where Value == QwertyCustomKeysValue {
}

struct NumberTabCustomKeysSetting: QwertyCustomKeyKeyboardSetting {
    static let defaultValue: QwertyCustomKeysValue = .defaultValue
    static let title: LocalizedStringKey = "数字タブのカスタムキー機能"
    static let explanation: LocalizedStringKey = "数字タブの「、。！？…」部分に好きな記号や文字を割り当てて利用することができます。"
    private static var key = "roman_number_custom_keys"
    static var value: QwertyCustomKeysValue {
        get {
            if let value = SharedStore.userDefaults.value(forKey: key), let keys = QwertyCustomKeysValue.get(value) {
                return keys
            }
            return defaultValue
        }
        set {
            SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
        }
    }
}

extension KeyboardSettingKey where Self == NumberTabCustomKeysSetting {
    static var numberTabCustomKeys: Self { .init() }
}
