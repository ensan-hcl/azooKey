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

    var explanation: String {
        switch self{
        case .keyboardType:
            return "フリック入力とローマ字入力が選択できます。"
        case .numberTabCustomKeys:
            return "数字タブの「、。！？…」部分に好きな記号や文字を割り当てて利用することができます。"
        case .koganaKeyFlick:
            return "「小ﾞﾟ」キーの「左」「上」「右」フリックに、好きな文字列を割り当てて利用することができます。"
        case .learningType:
            return "「新たに学習し、反映する(デフォルト)」「新たな学習を停止する」「新たに学習せず、これまでの学習も反映しない」選択できます。この設定の変更で学習結果が消えることはありません。"
        case .stopLearningWhenSearch:
            return "web検索などで入力した単語を学習しません。"
        case .unicodeCandidate:
            return "「u3042→あ」のように、入力されたunicode番号に対応する文字に変換します。接頭辞にはu, u+, U, U+が使えます。"
        case .wesJapCalender:
            return "「2020ねん→令和2年」「れいわ2ねん→2020年」のように西暦と和暦を相互に変換して候補に表示します。"
        case .typographyLetter:
            return "英字入力をした際、「𝕥𝕪𝕡𝕠𝕘𝕣𝕒𝕡𝕙𝕪」のような装飾字体を候補に表示します。"
        case .halfKana:
            return "半角ｶﾀｶﾅへの変換を候補に表示します。"
        case .memoryReset:
            return "学習履歴を全て消去します。この操作は取り消せません。"
        case .enableSound:
            return "キーを押した際に音を鳴らします。"
        case .resultViewFontSize:
            return "変換候補の文字の大きさを指定できます。"
        case .keyViewFontSize:
            return "キーの文字の大きさを指定できます。文字が大きすぎる場合表示が崩れることがあります。"
        }
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
        case .resultViewFontSize, .keyViewFontSize:
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
