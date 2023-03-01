//
//  BoolKeyboardSetting.swift
//  BoolKeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

protocol BoolKeyboardSettingKey: KeyboardSettingKey, StoredInUserDefault where Value == Bool {
    /// 有効化時に実行される処理
    static func onEnabled() -> LocalizedStringKey?
    /// 無効化時に実行される処理
    static func onDisabled()
}
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
    static func onEnabled() -> LocalizedStringKey? { nil }
    static func onDisabled() {}

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

struct LiveConversionInputMode: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "ライブ変換"
    static let explanation: LocalizedStringKey = "入力中の文字列を自動的に変換します。"
    static let defaultValue = true
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
    // TODO: Localize
    static let title: LocalizedStringKey = "キーの音"
    static let explanation: LocalizedStringKey = "キーを押した際に音を鳴らします♪"
    static let defaultValue = false
    static let key: String = "sound_enable_setting"
}

extension KeyboardSettingKey where Self == EnableKeySound {
    static var enableKeySound: Self { .init() }
}

// TODO: Localize
/// キーボードの触覚フィードバックを有効化する設定
/// - note: この機能はフルアクセスがないと実現できない
struct EnableKeyHaptics: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "振動フィードバック"
    static let explanation: LocalizedStringKey = "キーを押した際に端末を振動させます。"
    static let defaultValue = false
    static let key: String = "enable_key_haptics"
    static let requireFullAccess: Bool = true
}

extension KeyboardSettingKey where Self == EnableKeyHaptics {
    static var enableKeyHaptics: Self { .init() }
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

struct UseBetaMoveCursorBar: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "新しいカーソルバーを使う (試験版)"
    static let explanation: LocalizedStringKey = "新しいカーソルバーを有効化します。\n試験的機能のため、予告なく提供を終了する可能性があります。"
    static let defaultValue = false
    static let key: String = "use_move_cursor_bar_beta"
}

extension KeyboardSettingKey where Self == UseBetaMoveCursorBar {
    static var useBetaMoveCursorBar: Self { .init() }
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

// TODO: Localize
/// クリップボード履歴マネージャを有効化する設定
/// - note: この機能はフルアクセスがないと実現できない
struct EnableClipboardHistoryManagerTab: BoolKeyboardSettingKey {
    static let title: LocalizedStringKey = "クリップボードの履歴を保存"
    static let explanation: LocalizedStringKey = "コピーした文字列の履歴を保存し、専用のタブから入力できるようにします。"
    static let defaultValue = false
    static let key: String = "enable_clipboard_history_manager_tab"
    static let requireFullAccess: Bool = true
    static func onEnabled() -> LocalizedStringKey? {
        do {
            var manager = CustardManager.load()
            var tabBarData = (try? manager.tabbar(identifier: 0)) ?? .default
            if !tabBarData.items.contains(where: {$0.actions == [.moveTab(.system(.__clipboard_history_tab))]}) {
                tabBarData.items.append(TabBarItem(label: .text("コピー履歴"), actions: [.moveTab(.system(.__clipboard_history_tab))]))
            }
            try manager.saveTabBarData(tabBarData: tabBarData)
            return "タブバーに「コピー履歴」ボタンを追加しました。"
        } catch {
            debug("EnableClipboardHistoryManagerTab onEnabled", error)
            return nil
        }
    }
    static func onDisabled() {
        do {
            var manager = CustardManager.load()
            var tabBarData = (try? manager.tabbar(identifier: 0)) ?? .default
            tabBarData.items.removeAll {
                $0.actions == [.moveTab(.system(.__clipboard_history_tab))]
            }
            try manager.saveTabBarData(tabBarData: tabBarData)
        } catch {
            debug("EnableClipboardHistoryManagerTab onEnabled", error)
        }
    }
}

extension KeyboardSettingKey where Self == EnableClipboardHistoryManagerTab {
    static var enableClipboardHistoryManagerTab: Self { .init() }
}
