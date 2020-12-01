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
    private init(){}

    var halfKanaSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .halfKana,
        screenName: "半角カナ変換",
        description: "半角カタカナへの変換を候補に表示します。",
        defaultValue: true
    ))

    var enableSoundSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .enableSound,
        screenName: "キー音のON/OFF",
        description: "キーを押した際に音を鳴らします",
        defaultValue: false
    ))

    var typographyLetterSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .typographyLetter,
        screenName: "装飾英字変換",
        description: "「𝕥𝕪𝕡𝕠𝕘𝕣𝕒𝕡𝕙𝕪」のような装飾字体を候補に表示します。",
        defaultValue: true
    ))
    
    var wesJapCalenderSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .wesJapCalender,
        screenName: "西暦⇄和暦変換",
        description: "「2020ねん→令和2年」「れいわ2ねん→2020年」のように西暦と和暦を変換して候補に表示します。",
        defaultValue: true
    ))

    var unicodeCandidateSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .unicodeCandidate,
        screenName: "unicode変換",
        description: "「u3042→あ」のように、入力されたunicode番号に対応する文字に変換します。",
        defaultValue: true
    ))
    
    var stopLearningWhenSearchSetting = SettingItemViewModel(SettingItem<Bool>(
        identifier: .stopLearningWhenSearch,
        screenName: "検索時は学習を停止",
        description: "web検索などで入力した単語を学習しません。",
        defaultValue: false
    ))
    
    var koganaKeyFlickSetting = SettingItemViewModel(SettingItem<KeyFlickSetting>(
        identifier: .koganaKeyFlick,
        screenName: "「小ﾞﾟ」キーのフリック割り当て",
        description: "「小ﾞﾟ」キーの「左」「上」「右」フリックに、好きな文字列を割り当てて利用することができます。",
        defaultValue: KeyFlickSetting(targetKeyIdentifier: "kogana")
    ))

    var numberTabCustomKeysSetting = SettingItemViewModel(SettingItem<RomanCustomKeys>(
        identifier: .numberTabCustomKeys,
        screenName: "数字タブのカスタムキー機能",
        description: "数字タブの「、。！？…」部分に好きな記号や文字を割り当てて利用することができます。",
        defaultValue: RomanCustomKeys.defaultValue
    ))

    
    var keyboardTypeSetting = SettingItemViewModel(SettingItem<KeyboardType>(
        identifier: .keyboardType,
        screenName: "キーボードの種類",
        description: "フリック入力とローマ字入力が選択できます",
        defaultValue: .flick
    ))

    var memorySetting = SettingItemViewModel(SettingItem<LearningType>(
        identifier: .learningType,
        screenName: "学習の使用",
        description: "「新たに学習し、反映する(デフォルト)」「新たな学習を停止する」「新たに学習せず、これまでの学習も反映しない」選択できます。この設定の変更で学習結果が消えることはありません。",
        defaultValue: .inputAndOutput
    ))

    var memoryResetSetting = SettingItemViewModel(SettingItem<MemoryResetCondition>(
        identifier: .memoryReset,
        screenName: "学習のリセット",
        description: "学習履歴を全て消去します。この操作は取り消せません。",
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
