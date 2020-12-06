//
//  UserSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum Setting: String {
    case keyboardType = "keyboard_type"
    case numberTabCustomKeys = "roman_number_custom_keys"
    case koganaKeyFlick = "kogana_flicks"
    case learningType = "memory_learining_styple_setting"
    case stopLearningWhenSearch = "stop_learning_when_search"
    case unicodeCandidate = "unicode_candidate"
    case wesJapCalender = "western_japanese_calender_candidate"
    case typographyLetter = "typography_roman_candidate"
    case halfKana = "half_kana_candidate"
    case memoryReset = "memory_reset_setting"
    case enableSound = "sound_enable_setting"
    case resultViewFontSize = "result_view_font_size"
    case keyViewFontSize = "key_view_font_size"

    var key: String {
        self.rawValue
    }
}

struct DefaultSetting{
    static let shared = DefaultSetting()
    private init(){}

    func getBoolDefaultSetting(_ setting: Setting) -> Bool? {
        switch setting{
        case .wesJapCalender, .typographyLetter, .halfKana, .unicodeCandidate:
            return true
        case .stopLearningWhenSearch, .enableSound:
            return false
        default:
            return nil
        }
    }

    func getDoubleSetting(_ setting: Setting) -> Double? {
        switch setting{
        case .resultViewFontSize:
            return 18
        case .keyViewFontSize:
            return -1
        default: return nil
        }
    }

    func romanCustomKeyDefaultSetting(_ setting: Setting) -> RomanCustomKeys? {
        switch setting{
        case .numberTabCustomKeys:
            return RomanCustomKeys.defaultValue
        default:
            return nil
        }
    }

    let koganaKeyFlickSettingDefault = ("", "", "", "")
    let keyboardTypeSettingDefault = KeyboardType.flick
    let memorySettingDefault = LearningType.inputAndOutput
}
