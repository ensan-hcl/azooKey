//
//  BoolKeyboardSetting.swift
//  BoolKeyboardSetting
//
//  Created by β α on 2021/08/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol BoolKeyboardSettingKey: KeyboardSettingKey, StoredInUserDefault where Value == Bool {}

extension StoredInUserDefault where Value == Bool {
    static func get() -> Value? {
        let object = SharedStore.userDefaults.object(forKey: key)
        return object as? Bool
    }
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue, forKey: key)
    }
}

extension BoolKeyboardSettingKey {
    static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

struct UnicodeCandidate: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "unicode変換"
    static let explanation: LocalizedStringKey = "「u3042→あ」のように、入力されたunicode番号に対応する文字に変換します。接頭辞にはu, u+, U, U+が使えます。"
    static let defaultValue = true
    static let key: String = "unicode_candidate"
}

extension KeyboardSettingKey where Self == UnicodeCandidate {
    static var unicodeCandidate: Self { .init() }
}

struct WesternJapaneseCalender: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "西暦⇄和暦変換"
    static let explanation: LocalizedStringKey = "「2020ねん→令和2年」「れいわ2ねん→2020年」のように西暦と和暦を相互に変換して候補に表示します。"
    static let defaultValue = true
    static let key: String = "western_japanese_calender_candidate"
}

extension KeyboardSettingKey where Self == WesternJapaneseCalender {
    static var westernJapaneseCalender: Self { .init() }
}

struct LiveConversionInputMode: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "ライブ変換" // TODO: Localize
    static let explanation: LocalizedStringKey = "入力中の文字列を自動的に変換します。" // TODO: Localize
    static let defaultValue = false
    static let key: String = "live_conversion"
}

extension KeyboardSettingKey where Self == LiveConversionInputMode {
    static var liveConversion: Self { .init() }
}

struct TypographyLetter: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "装飾英字変換"
    static let explanation: LocalizedStringKey = "英字入力をした際、「𝕥𝕪𝕡𝕠𝕘𝕣𝕒𝕡𝕙𝕪」のような装飾字体を候補に表示します。"
    static let defaultValue = true
    static let key: String = "typography_roman_candidate"
}

extension KeyboardSettingKey where Self == TypographyLetter {
    static var typographyLetter: Self { .init() }
}

struct EnglishCandidate: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "日本語入力中の英単語変換"
    static let explanation: LocalizedStringKey = "「いんてれsちんg」→「interesting」のように、ローマ字日本語入力中も英語への変換候補を表示します。"
    static let defaultValue = true
    static let key: String = "roman_english_candidate"
}

extension KeyboardSettingKey where Self == EnglishCandidate {
    static var englishCandidate: Self { .init() }
}

struct HalfKanaCandidate: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "半角カナ変換"
    static let explanation: LocalizedStringKey = "半角ｶﾀｶﾅへの変換を候補に表示します。"
    static let defaultValue = true
    static let key: String = "half_kana_candidate"
}

extension KeyboardSettingKey where Self == HalfKanaCandidate {
    static var halfKanaCandidate: Self { .init() }
}

struct FullRomanCandidate: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "全角英数字変換"
    static let explanation: LocalizedStringKey = "全角英数字(ａｂｃ１２３)への変換候補を表示します。"
    static let defaultValue = true
    static let key: String = "full_roman_candidate"
}

extension KeyboardSettingKey where Self == FullRomanCandidate {
    static var fullRomanCandidate: Self { .init() }
}

struct MemoryResetFlag: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "学習のリセット"
    static let explanation: LocalizedStringKey = "学習履歴を全て消去します。この操作は取り消せません。"
    static let defaultValue = false
    static let key: String = "memory_reset_setting"
}

extension KeyboardSettingKey where Self == MemoryResetFlag {
    static var memoryResetFlag: Self { .init() }
}

struct EnableKeySound: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "キー音のON/OFF"
    static let explanation: LocalizedStringKey = "キーを押した際に音を鳴らします♪"
    static let defaultValue = false
    static let key: String = "sound_enable_setting"
}

extension KeyboardSettingKey where Self == EnableKeySound {
    static var enableKeySound: Self { .init() }
}

struct UseOSUserDict: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "OSのユーザ辞書の利用"
    static let explanation: LocalizedStringKey = "OS標準のユーザ辞書を利用します。"
    static let defaultValue = false
    static let key: String = "use_OS_user_dict"
}

extension KeyboardSettingKey where Self == UseOSUserDict {
    static var useOSUserDict: Self { .init() }
}

struct DisplayTabBarButton: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "タブバーボタン"
    static let explanation: LocalizedStringKey = "変換候補欄が空のときにタブバーボタンを表示します"
    static let defaultValue = true
    static let key: String = "display_tab_bar_button"
}

extension KeyboardSettingKey where Self == DisplayTabBarButton {
    static var displayTabBarButton: Self { .init() }
}

struct StopLearningWhenSearch: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "検索時は学習を停止"
    static let explanation: LocalizedStringKey = "web検索などで入力した単語を学習しません。"
    static let defaultValue = false
    static let key: String = "stop_learning_when_search"
}

extension KeyboardSettingKey where Self == StopLearningWhenSearch {
    static var stopLearningWhenSearch: Self { .init() }
}
