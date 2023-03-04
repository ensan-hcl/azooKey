//
//  DoubleKeyboardSetting.swift
//  DoubleKeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

protocol DoubleKeyboardSettingKey: KeyboardSettingKey, StoredInUserDefault where Value == Double {}

extension StoredInUserDefault where Value == Double {
    static func get() -> Value? {
        let object = SharedStore.userDefaults.object(forKey: key)
        return object as? Value
    }
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue, forKey: key)
    }
}

extension DoubleKeyboardSettingKey {
    static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

struct ResultViewFontSize: DoubleKeyboardSettingKey {
    static let title: LocalizedStringKey = "変換候補の表示サイズ"
    static let explanation: LocalizedStringKey = "変換候補の文字の大きさを指定できます。"
    static let defaultValue: Double = -1
    static let key: String = "result_view_font_size"
}

extension KeyboardSettingKey where Self == ResultViewFontSize {
    static var resultViewFontSize: Self { .init() }
}

struct KeyViewFontSize: DoubleKeyboardSettingKey {
    static let title: LocalizedStringKey = "キーの表示サイズ"
    static let explanation: LocalizedStringKey = "キーの文字の大きさを指定できます。文字が大きすぎる場合表示が崩れることがあります。"
    static let defaultValue: Double = -1
    static let key: String = "key_view_font_size"
}

extension KeyboardSettingKey where Self == KeyViewFontSize {
    static var keyViewFontSize: Self { .init() }
}

/// フリック感度。値は0.5~2.0くらいを想定。でかい方が鈍い。
struct FlickSensitivitySettingKey: DoubleKeyboardSettingKey {
    static let title: LocalizedStringKey = "フリックの感度"
    static let explanation: LocalizedStringKey = "どれだけ指を動かしたらフリックと判定するか調整できます。"
    static let defaultValue: Double = 1
    static let key: String = "flick_sensitivity_setting"
}

extension KeyboardSettingKey where Self == FlickSensitivitySettingKey {
    static var flickSensitivity: Self { .init() }
}

/// キーボードの高さを調整できます。
struct KeyboardHeightScaleSettingKey: DoubleKeyboardSettingKey {
    static let title: LocalizedStringKey = "キーボードの高さ"
    static let explanation: LocalizedStringKey = "キーボードの高さを調整できます。"
    static let defaultValue: Double = 1
    static let key: String = "keyboard_height_scale"
}

extension KeyboardSettingKey where Self == KeyboardHeightScaleSettingKey {
    static var keyboardHeightScale: Self { .init() }
}
