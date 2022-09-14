//
//  IntKeyboardSetting.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/15.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol IntKeyboardSettingKey: KeyboardSettingKey, StoredInUserDefault where Value == Int {}

extension StoredInUserDefault where Value == Int {
    static func get() -> Value? {
        let object = SharedStore.userDefaults.object(forKey: key)
        return object as? Value
    }
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue, forKey: key)
    }
}

extension IntKeyboardSettingKey {
    static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

struct AutomaticCompletionTresholdKey: IntKeyboardSettingKey {
    static let title: LocalizedStringKey = "自動確定の頻度"
    static let explanation: LocalizedStringKey = "ライブ変換中の自動確定の強さを設定できます。強くするほど、すぐに確定しようとします。"
    static let defaultValue: Int = 15
    static let key: String = "automatic_completion_treshold"
}

extension KeyboardSettingKey where Self == AutomaticCompletionTresholdKey {
    static var automaticCompletionTreshold: Self { .init() }
}
