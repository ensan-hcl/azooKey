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
        defaultValue: true
    ))

    var fullRomanSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .fullRoman,
        defaultValue: true
    ))

    var enableSoundSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .enableSound,
        defaultValue: false
    ))

    var typographyLetterSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .typographyLetter,
        defaultValue: true
    ))
    
    var wesJapCalenderSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .wesJapCalender,
        defaultValue: true
    ))

    var englishCandidateSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .englishCandidate,
        defaultValue: true
    ))

    var unicodeCandidateSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .unicodeCandidate,
        defaultValue: true
    ))
    
    var stopLearningWhenSearchSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .stopLearningWhenSearch,
        defaultValue: false
    ))
    
    var koganaKeyFlickSetting = SettingItemViewModel(SettingItem<KeyFlickSetting>(
        identifier: .koganaKeyFlick,
        defaultValue: CustomizableFlickKey.kogana.defaultSetting
    ))

    var kanaSymbolsKeyFlickSetting = SettingItemViewModel(SettingItem<KeyFlickSetting>(
        identifier: .kanaSymbolsKeyFlick,
        defaultValue: CustomizableFlickKey.kanaSymbols.defaultSetting
    ))

    var numberTabCustomKeysSettingNew = SettingItemViewModel(SettingItem<RomanCustomKeysValue>(
        identifier: .numberTabCustomKeys,
        defaultValue: RomanCustomKeysValue.defaultValue
    ))


    var keyboardTypeSetting = SettingItemViewModel(SettingItem<KeyboardLayoutType>(
        identifier: .keyboardType,
        defaultValue: .flick
    ))

    var englishKeyboardTypeSetting = SettingItemViewModel(SettingItem<KeyboardLayoutType>(
        identifier: .englishKeyboardType,
        defaultValue: .flick
    ))

    var resultViewFontSizeSetting = SettingItemViewModel(SettingItem<FontSizeSetting>(
        identifier: .resultViewFontSize,
        defaultValue: -1
    ))

    var keyViewFontSizeSetting = SettingItemViewModel(SettingItem<FontSizeSetting>(
        identifier: .keyViewFontSize,
        defaultValue: -1
    ))

    var memorySetting = SettingItemViewModel(SettingItem<LearningType>(
        identifier: .learningType,
        defaultValue: .inputAndOutput
    ))

    var memoryResetSetting = SettingItemViewModel(SettingItem<MemoryResetCondition>(
        identifier: .memoryReset,
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

    let imageMaximumWidth: CGFloat = 500

    var shouldTryRequestReview: Bool = false

    func shouldRequestReview() -> Bool {
        self.shouldTryRequestReview = false
        if let lastDate = UserDefaults.standard.value(forKey: "last_reviewed_date") as? Date{
            if -lastDate.timeIntervalSinceNow < 10000000{   //約3ヶ月半経過していたら
                return false
            }
        }

        let rand = Int.random(in: 0...4)

        if rand == 0{
            UserDefaults.standard.set(Date(), forKey: "last_reviewed_date")
            return true
        }
        return false
    }

}

class StoreVariableSection: ObservableObject{
    @Published var isKeyboardActivated: Bool = Store.shared.isKeyboardActivated
    @Published var requireFirstOpenView: Bool = !Store.shared.isKeyboardActivated
    @Published var keyboardType: KeyboardLayoutType = .flick
}
