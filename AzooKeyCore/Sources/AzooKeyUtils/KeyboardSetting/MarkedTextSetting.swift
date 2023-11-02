//
//  MarkedTextSetting.swift
//  azooKey
//
//  Created by ensan on 2022/09/26.
//  Copyright © 2022 ensan. All rights reserved.
//

import SwiftUI

public struct MarkedTextSettingKey: KeyboardSettingKey {
    @MainActor public static var value: Value {
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

    public enum Value: String, Sendable {
        case disabled
        case enabled
        case auto
    }

    public static let title: LocalizedStringKey = "入力中のテキストを保護 (試験版)"
    public static let explanation: LocalizedStringKey = "入力中のテキストを保護し、Webアプリなどでの入力において挙動を安定させます。\n試験的機能のため、仕様の変更、不具合などが発生する可能性があります。"
    public static let defaultValue: Value = .disabled
    public static let key: String = "marked_text_setting_beta"
}

public extension KeyboardSettingKey where Self == MarkedTextSettingKey {
    static var markedTextSetting: Self { .init() }
}
