//
//  UserSetting.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

typealias FlickCustomKeySettingData = (labelType: KeyLabelType, actions: [ActionType], longpressActions: LongpressActionType, flick: [FlickDirection: FlickedKeyModel])

struct SettingData{
    private static let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
    private let boolSettingItems: [Setting] = [.unicodeCandidate, .wesJapCalender, .halfKana, .fullRoman, .typographyLetter, .enableSound, .englishCandidate, .useOSuserDict]
    private let flickCustomKeySettingItems: [Setting] = [.koganaKeyFlick, .kanaSymbolsKeyFlick, .hiraTabKeyFlick, .abcTabKeyFlick, .symbolsTabKeyFlick]

    private var boolSettings: [Setting: Bool]
    private var languageLayoutSetting: [Setting: LanguageLayout]
    private var flickCustomKeySetting: [Setting: FlickCustomKeySettingData]
    static var shared = SettingData()

    private init(){
        self.boolSettings = boolSettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getBoolSetting(setting)
        }
        self.languageLayoutSetting = [Setting.englishKeyboardLayout, Setting.japaneseKeyboardLayout].reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getLanguageLayoutSetting(setting)
        }
        self.flickCustomKeySetting = flickCustomKeySettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getFlickCustomKeySetting(for: setting)
        }
    }

    mutating func reload(){
        //bool値の設定を更新
        self.boolSettings = boolSettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getBoolSetting(setting)
        }
        //レイアウトの設定を更新
        self.languageLayoutSetting = [Setting.englishKeyboardLayout, Setting.japaneseKeyboardLayout].reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getLanguageLayoutSetting(setting)
        }
        //フリックカスタムキーの設定を更新
        self.flickCustomKeySetting = flickCustomKeySettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getFlickCustomKeySetting(for: setting)
        }

        self.learningType = Self.learningTypeSetting(.inputAndOutput)

        self.resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
        self.keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1
    }

    internal func bool(for key: Setting) -> Bool {
        self.boolSettings[key, default: false]
    }

    internal func languageLayout(for key: Setting) -> LanguageLayout {
        if key == .englishKeyboardLayout, let layout = self.languageLayoutSetting[Setting.japaneseKeyboardLayout]{
            return self.languageLayoutSetting[key, default: layout]
        }
        return self.languageLayoutSetting[key, default: .flick]
    }

    private static func getFlickCustomKeySetting(for key: Setting) -> FlickCustomKeySettingData {
        let value = Self.userDefaults.value(forKey: key.key)
        let setting: KeyFlickSetting
        if let value = value, let data = KeyFlickSetting.get(value){
            setting = data
        }else{
            setting = DefaultSetting.flickCustomKey(key)!
        }
        let targets: [(path: KeyPath<KeyFlickSetting,FlickCustomKey>, direction: FlickDirection)] = [(\.left, .left), (\.top, .top), (\.right, .right), (\.bottom, .bottom)]
        let dict: [FlickDirection: FlickedKeyModel] = targets.reduce(into: [:]){dict, target in
            let item = setting[keyPath: target.path]
            if item.label == ""{
                return
            }
            let model = FlickedKeyModel(
                labelType: .text(item.label),
                pressActions: item.actions.map{$0.actionType},
                longPressActions: item.longpressActions.longpressActionType
            )
            dict[target.direction] = model
        }
        return (.text(setting.center.label), setting.center.actions.map{$0.actionType}, setting.center.longpressActions.longpressActionType, dict)
    }

    internal func flickCustomKeySetting(for key: Setting) -> FlickCustomKeySettingData {
        self.flickCustomKeySetting[key, default: (.text("エラー"), [], .none, [:])]
    }

    private static func get(_ setting: Setting) -> KeyboardLayout {
        switch setting{
        case .japaneseKeyboardLayout, .englishKeyboardLayout:
            if let string = Self.userDefaults.string(forKey: setting.key), let type = KeyboardLayout.get(string){
                return type
            }else{
                userDefaults.set(KeyboardLayout.flick.rawValue, forKey: setting.key)
                return .flick
            }
        default: return .flick
        }
    }

    var learningType: LearningType = Self.learningTypeSetting(.inputAndOutput)

    var resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
    var keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1

    private static func getKeyboardLayoutSetting(_ setting: Setting) -> KeyboardLayout {
        switch setting{
        case .japaneseKeyboardLayout, .englishKeyboardLayout:
            if let string = Self.userDefaults.string(forKey: setting.key), let type = KeyboardLayout.get(string){
                return type
            }else{
                userDefaults.set(KeyboardLayout.flick.rawValue, forKey: setting.key)
                return .flick
            }
        default: return .flick
        }
    }

    private static func getLanguageLayoutSetting(_ setting: Setting) -> LanguageLayout {
        switch setting{
        case .japaneseKeyboardLayout, .englishKeyboardLayout:
            if let data = Self.userDefaults.data(forKey: setting.key), let type = LanguageLayout.get(data){
                return type
            }else if let string = Self.userDefaults.string(forKey: setting.key), let type = KeyboardLayout.get(string){
                switch type{
                case .flick: return .flick
                case .qwerty: return .qwerty
                }
            }else{
                userDefaults.set(KeyboardLayout.flick.rawValue, forKey: setting.key)
                return .flick
            }
        default: return .flick
        }
    }

    private static func getBoolSetting(_ setting: Setting) -> Bool {
        if let object = Self.userDefaults.object(forKey: setting.key), let bool = object as? Bool{
            return bool
        }else if let bool = DefaultSetting.bool(setting){
            return bool
        }
        return false
    }

    private static func getDoubleSetting(_ setting: Setting) -> Double? {
        if let object = Self.userDefaults.object(forKey: setting.key), let value = object as? Double{
            return value
        }else if let value = DefaultSetting.double(setting){
            return value
        }
        return nil
    }

    private static func learningTypeSetting(_ current: LearningType) -> LearningType {
        let result: LearningType
        if let object = Self.userDefaults.object(forKey: Setting.learningType.key),
           let value = LearningType.get(object){
            result = value
        }else{
            result = DefaultSetting.memorySetting
        }
        return result
    }

    static func checkResetSetting() -> Bool {
        if let object = Self.userDefaults.object(forKey: Setting.memoryReset.key),
           let identifier = MemoryResetCondition.identifier(object){
            if let finished = UserDefaults.standard.string(forKey: "finished_reset"), finished == identifier{
                return false
            }
            UserDefaults.standard.set(identifier, forKey: "finished_reset")
            return true
        }
        return false
    }

    mutating func writeLearningTypeSetting(to type: LearningType) {
        Self.userDefaults.set(type.saveValue, forKey: Setting.learningType.key)
        self.learningType = type
    }

    var qwertyNumberTabKeySetting: [QwertyKeyModel] {
        let customKeys: QwertyCustomKeysValue
        if let value = Self.userDefaults.value(forKey: Setting.numberTabCustomKeys.key), let keys = QwertyCustomKeysValue.get(value){
            customKeys = keys
        }else if let defaultValue = DefaultSetting.qwertyCustomKeys(.numberTabCustomKeys){
            customKeys = defaultValue
        }else{
            return []
        }
        let keys = customKeys.keys
        let count = keys.count
        let scale = (7, count)
        return keys.map{key in
            QwertyKeyModel(
                labelType: .text(key.name),
                pressActions: key.actions.map{$0.actionType},
                variationsModel: VariationsModel(
                    key.longpresses.map{item in
                        (label: .text(item.name), actions: item.actions.map{$0.actionType})
                    }
                ),
                for: scale
            )
        }
    }
}
