//
//  DoubleKeyboardSetting.swift
//  DoubleKeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public protocol DoubleKeyboardSettingKey: KeyboardSettingKey, StoredInUserDefault where Value == Double {}

public extension StoredInUserDefault where Value == Double {
    @MainActor
    static func get() -> Value? {
        let object = SharedStore.userDefaults.object(forKey: key)
        return object as? Value
    }
    @MainActor
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue, forKey: key)
    }
}

public extension DoubleKeyboardSettingKey {
    @MainActor static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

public struct ResultViewFontSize: DoubleKeyboardSettingKey {
    public static let title: LocalizedStringKey = "変換候補の表示サイズ"
    public static let explanation: LocalizedStringKey = "変換候補の文字の大きさを指定できます。"
    public static let defaultValue: Double = -1
    public static let key: String = "result_view_font_size"
}

extension KeyboardSettingKey where Self == ResultViewFontSize {
    public static var resultViewFontSize: Self { .init() }
}

public struct KeyViewFontSize: DoubleKeyboardSettingKey {
    public static let title: LocalizedStringKey = "キーの表示サイズ"
    public static let explanation: LocalizedStringKey = "キーの文字の大きさを指定できます。文字が大きすぎる場合表示が崩れることがあります。"
    public static let defaultValue: Double = -1
    public static let key: String = "key_view_font_size"
}

extension KeyboardSettingKey where Self == KeyViewFontSize {
    public static var keyViewFontSize: Self { .init() }
}

/// フリック感度。値は0.5~2.0くらいを想定。でかい方が鈍い。
public struct FlickSensitivitySettingKey: DoubleKeyboardSettingKey {
    public static let title: LocalizedStringKey = "フリックの感度"
    public static let explanation: LocalizedStringKey = "どれだけ指を動かしたらフリックと判定するか調整できます。"
    public static let defaultValue: Double = 1
    public static let key: String = "flick_sensitivity_setting"
}

extension KeyboardSettingKey where Self == FlickSensitivitySettingKey {
    public static var flickSensitivity: Self { .init() }
}

/// キーボードの高さを調整できます。
public struct KeyboardHeightScaleSettingKey: DoubleKeyboardSettingKey {
    public static let title: LocalizedStringKey = "キーボードの高さ"
    public static let explanation: LocalizedStringKey = "キーボードの高さを調整できます。"
    public static let defaultValue: Double = 1
    public static let key: String = "keyboard_height_scale"
}

extension KeyboardSettingKey where Self == KeyboardHeightScaleSettingKey {
    public static var keyboardHeightScale: Self { .init() }
}
