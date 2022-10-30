//
//  MarkedTextSetting.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/26.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct MarkedTextSettingKey: KeyboardSettingKey {
    static var value: Value {
        get {
            let string = SharedStore.userDefaults.string(forKey: key)
            if let string, let value = Value(rawValue: string) {
                return value
            }
            return defaultValue
        }
        set {
            SharedStore.userDefaults.set(newValue.rawValue, forKey: key)
        }
    }

    enum Value: String {
        case disabled
        case enabled
        case auto
    }

    static let title: LocalizedStringKey = "入力中のテキストを保護 (試験版)"
    static let explanation: LocalizedStringKey = "入力中のテキストを保護し、Webアプリなどでの入力において挙動を安定させます。\n試験的機能のため、仕様の変更、不具合などが発生する可能性があります。"
    static let defaultValue: Value = .disabled
    static let key: String = "marked_text_setting_beta"
}

extension KeyboardSettingKey where Self == MarkedTextSettingKey {
    static var markedTextSetting: Self { .init() }
}
