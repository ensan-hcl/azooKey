//
//  ApplicationSpecificKeyboardViewSettingProvider.swift
//
//
//  Created by ensan on 2023/07/22.
//

import Foundation

@MainActor public protocol ApplicationSpecificKeyboardViewSettingProvider {
    static var koganaFlickCustomKey: KeyFlickSetting { get }
    static var kanaSymbolsFlickCustomKey: KeyFlickSetting { get }
    static var hiraTabFlickCustomKey: KeyFlickSetting { get }
    static var abcTabFlickCustomKey: KeyFlickSetting { get }
    static var symbolsTabFlickCustomKey: KeyFlickSetting { get }

    static var numberTabCustomKeysSetting: QwertyCustomKeysValue { get }

    static var preferredLanguage: PreferredLanguage { get }

    static var japaneseKeyboardLayout: LanguageLayout { get }
    static var englishKeyboardLayout: LanguageLayout { get }

    static var flickSensitivity: Double { get }
    static var resultViewFontSize: Double { get }
    static var keyViewFontSize: Double { get }

    static var enableSound: Bool { get }
    static var enableHaptics: Bool { get }
    static var enablePasteButton: Bool { get }
    static var displayTabBarButton: Bool { get }
    static var hideResetButtonInOneHandedMode: Bool { get }
    static var useSliderStyleCursorBar: Bool { get }
    static var useShiftKey: Bool { get }

    static var canResetLearningForCandidate: Bool { get }

    static func get(_: CustomizableFlickKey) -> KeyFlickSetting.SettingData
}
