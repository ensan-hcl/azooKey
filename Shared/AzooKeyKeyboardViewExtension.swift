//
//  AzooKeyKeyboardViewExtension.swift
//  azooKey
//
//  Created by β α on 2023/07/22.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import Foundation
import KeyboardViews

enum AzooKeyKeyboardViewExtension: ApplicationSpecificKeyboardViewExtension {
    typealias ThemeExtension = AzooKeySpecificTheme

    typealias MessageProvider = AzooKeyMessageProvider

    typealias SettingProvider = AzooKeySettingProvider
}

@MainActor enum AzooKeySettingProvider: ApplicationSpecificKeyboardViewSettingProvider {
    static var preferredLanguage: KeyboardViews.PreferredLanguage {
        PreferredLanguageSetting.value
    }

    static var japaneseKeyboardLayout: KeyboardViews.LanguageLayout {
        JapaneseKeyboardLayout.value
    }

    static var englishKeyboardLayout: KeyboardViews.LanguageLayout {
        EnglishKeyboardLayout.value
    }

    static var koganaFlickCustomKey: KeyboardViews.KeyFlickSetting {
        KoganaFlickCustomKey.value
    }

    static var symbolsTabFlickCustomKey: KeyboardViews.KeyFlickSetting {
        SymbolsTabFlickCustomKey.value
    }

    static var abcTabFlickCustomKey: KeyboardViews.KeyFlickSetting {
        AbcTabFlickCustomKey.value
    }

    static var hiraTabFlickCustomKey: KeyboardViews.KeyFlickSetting {
        HiraTabFlickCustomKey.value
    }

    static var kanaSymbolsFlickCustomKey: KeyboardViews.KeyFlickSetting {
        KanaSymbolsFlickCustomKey.value
    }

    static var numberTabCustomKeysSetting: KeyboardViews.QwertyCustomKeysValue {
        NumberTabCustomKeysSetting.value
    }

    static var flickSensitivity: Double {
        FlickSensitivitySettingKey.value
    }

    static var resultViewFontSize: Double {
        ResultViewFontSize.value
    }

    static var keyViewFontSize: Double {
        KeyViewFontSize.value
    }

    static var keyboardHeight: Double {
        KeyboardHeightScaleSettingKey.value
    }

    static var enableSound: Bool {
        EnableKeySound.value
    }

    static var enableHaptics: Bool {
        EnableKeyHaptics.value
    }

    static var enablePasteButton: Bool {
        EnablePasteButton.value
    }

    static var displayTabBarButton: Bool {
        DisplayTabBarButton.value
    }

    static var hideResetButtonInOneHandedMode: Bool {
        HideResetButtonInOneHandedMode.value
    }

    static var useBetaMoveCursorBar: Bool {
        UseBetaMoveCursorBar.value
    }

    static var canResetLearningForCandidate: Bool {
        LearningTypeSetting.value.needUsingMemory
    }

    static func get(_ key: KeyboardViews.CustomizableFlickKey) -> KeyboardViews.KeyFlickSetting.SettingData {
        let setting: KeyFlickSetting
        switch key {
        case .kogana:
            setting = KoganaFlickCustomKey.value
        case .kanaSymbols:
            setting = KanaSymbolsFlickCustomKey.value
        case .hiraTab:
            setting = HiraTabFlickCustomKey.value
        case .abcTab:
            setting = AbcTabFlickCustomKey.value
        case .symbolsTab:
            setting = SymbolsTabFlickCustomKey.value
        }
        return setting.compiled()
    }
}

struct ClipboardHistoryManagerConfig: ClipboardHistoryManagerConfiguration {
    @MainActor var enabled: Bool {
        EnableClipboardHistoryManagerTab.value
    }

    var saveDirectory: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)
    }

    var maxCount: Int {
        50
    }
}

struct TabManagerConfig: TabManagerConfiguration {
    var preferredLanguage: KeyboardViews.PreferredLanguage {
        AzooKeySettingProvider.preferredLanguage
    }

    var japaneseLayout: KeyboardViews.LanguageLayout {
        AzooKeySettingProvider.japaneseKeyboardLayout
    }

    var englishLayout: KeyboardViews.LanguageLayout {
        AzooKeySettingProvider.englishKeyboardLayout
    }

    var custardManager: any KeyboardViews.CustardManagerProtocol {
        CustardManager.load()
    }
}
