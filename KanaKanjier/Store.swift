//
//  Store.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

class Store{
    static let shared = Store()
    static var variableSection = StoreVariableSection()
    var feedbackGenerator = UINotificationFeedbackGenerator()
    private init(){}

    var halfKanaSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .halfKana,
        screenName: "半角カナ変換",
        defaultValue: true
    ))

    var enableSoundSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .enableSound,
        screenName: "キー音のON/OFF",
        defaultValue: false
    ))

    var typographyLetterSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .typographyLetter,
        screenName: "装飾英字変換",
        defaultValue: true
    ))
    
    var wesJapCalenderSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .wesJapCalender,
        screenName: "西暦⇄和暦変換",
        defaultValue: true
    ))

    var unicodeCandidateSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .unicodeCandidate,
        screenName: "unicode変換",
        defaultValue: true
    ))
    
    var stopLearningWhenSearchSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .stopLearningWhenSearch,
        screenName: "検索時は学習を停止",
        defaultValue: false
    ))
    
    var koganaKeyFlickSetting = SettingItemViewModel(SettingItem<KeyFlickSetting>(
        identifier: .koganaKeyFlick,
        screenName: "「小ﾞﾟ」キーのフリック割り当て",
        defaultValue: KeyFlickSetting(targetKeyIdentifier: "kogana")
    ))
/*
    var numberTabCustomKeysSetting = SettingItemViewModel(SettingItem<RomanCustomKeys>(
        identifier: .numberTabCustomKeys,
        screenName: "数字タブのカスタムキー機能",
        defaultValue: RomanCustomKeys.defaultValue
    ))
*/
    var numberTabCustomKeysSettingNew = SettingItemViewModel(SettingItem<RomanCustomKeysValue>(
        identifier: .numberTabCustomKeys,
        screenName: "数字タブのカスタムキー機能",
        defaultValue: RomanCustomKeysValue.defaultValue
    ))


    var keyboardTypeSetting = SettingItemViewModel(SettingItem<KeyboardType>(
        identifier: .keyboardType,
        screenName: "キーボードの種類",
        defaultValue: .flick
    ))

    var resultViewFontSizeSetting = SettingItemViewModel(SettingItem<FontSizeSetting>(
        identifier: .resultViewFontSize,
        screenName: "変換候補の表示サイズ",
        defaultValue: -1
    ))

    var keyViewFontSizeSetting = SettingItemViewModel(SettingItem<FontSizeSetting>(
        identifier: .keyViewFontSize,
        screenName: "キーの表示サイズ",
        defaultValue: -1
    ))

    var memorySetting = SettingItemViewModel(SettingItem<LearningType>(
        identifier: .learningType,
        screenName: "学習の使用",
        defaultValue: .inputAndOutput
    ))

    var memoryResetSetting = SettingItemViewModel(SettingItem<MemoryResetCondition>(
        identifier: .memoryReset,
        screenName: "学習のリセット",
        defaultValue: .none
    ))

    func noticeReloadUserDict(){
        let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
        userDefaults.set(true, forKey: "reloadUserDict")
    }

    var isKeyboardActivated: Bool {
        let bundleName = SharedStore.bundleName
        guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else{
            return true
        }
        return keyboards.contains(bundleName)
    }
    
    func iconFont(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font? {
        return Font.custom("AzooKeyIcon-Regular", size: size, relativeTo: style)
    }

}

class StoreVariableSection: ObservableObject{
    @Published var isKeyboardActivated: Bool = Store.shared.isKeyboardActivated
    @Published var requireFirstOpenView: Bool = !Store.shared.isKeyboardActivated
    @Published var KeyboardType: KeyboardType = .flick
}
