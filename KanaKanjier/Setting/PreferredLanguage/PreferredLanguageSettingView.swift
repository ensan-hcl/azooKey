//
//  PreferredLanguageSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private struct OptionalTranslator: Intertranslator {
    typealias First = KeyboardLanguage?
    typealias Second = KeyboardLanguage

    static func convert(_ first: First) -> Second {
        return first ?? .none
    }

    static func convert(_ second: KeyboardLanguage) -> KeyboardLanguage? {
        switch second {
        case .none:
            return nil
        default:
            return second
        }
    }
}

struct PreferredLanguageSettingView: View {
    @State private var selection: PreferredLanguage
    init() {
        self._selection = .init(initialValue: PreferredLanguageSetting.value)
    }

    var body: some View {
        Group {
            Picker("第1言語", selection: $selection.first) {
                Text("日本語").tag(KeyboardLanguage.ja_JP)
                Text("英語").tag(KeyboardLanguage.en_US)
            }
            Picker("第2言語", selection: $selection.second.converted(OptionalTranslator.self)) {
                Text("日本語").tag(KeyboardLanguage.ja_JP)
                Text("英語").tag(KeyboardLanguage.en_US)
                Text("指定しない").tag(KeyboardLanguage.none)
            }
        }.onChange(of: selection) { value in
            PreferredLanguageSetting.value = value
        }
    }
}
