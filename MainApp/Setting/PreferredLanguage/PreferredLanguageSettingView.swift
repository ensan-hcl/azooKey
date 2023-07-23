//
//  PreferredLanguageSettingView.swift
//  MainApp
//
//  Created by ensan on 2021/03/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import enum KanaKanjiConverterModule.KeyboardLanguage
import struct KeyboardViews.PreferredLanguage

struct PreferredLanguageSettingView: View {
    // Viewを動的に更新するためには設定を`@State`としておく必要がある。
    @State private var selection: PreferredLanguage
    @MainActor init() {
        self._selection = .init(initialValue: PreferredLanguageSetting.value)
    }

    @MainActor private var firstLanguage: Binding<KeyboardLanguage> {
        Binding(
            get: {
                selection.first
            },
            set: { newValue in
                selection.first = newValue
                PreferredLanguageSetting.value.first = newValue
                if selection.second == newValue {
                    switch newValue {
                    case .ja_JP:
                        selection.second = .en_US
                        PreferredLanguageSetting.value.second = .en_US
                    case .en_US, .el_GR:
                        selection.second = .ja_JP
                        PreferredLanguageSetting.value.second = .ja_JP
                    case .none:
                        selection.second = nil
                        PreferredLanguageSetting.value.second = nil
                    }
                }
            }
        )
    }

    @MainActor private var secondLanguage: Binding<KeyboardLanguage> {
        Binding(
            get: {
                selection.second ?? .none
            },
            set: { newValue in
                let language: KeyboardLanguage?
                switch newValue {
                case .none:
                    language = nil
                default:
                    language = newValue
                }

                selection.second = language
                PreferredLanguageSetting.value.second = language
            }
        )
    }

    var body: some View {
        Group {
            Picker("第1言語", selection: firstLanguage) {
                Text("日本語").tag(KeyboardLanguage.ja_JP)
                Text("英語").tag(KeyboardLanguage.en_US)
            }
            Picker("第2言語", selection: secondLanguage) {
                if selection.first != .ja_JP {
                    Text("日本語").tag(KeyboardLanguage.ja_JP)
                }
                if selection.first != .en_US {
                    Text("英語").tag(KeyboardLanguage.en_US)
                }
                Text("指定しない").tag(KeyboardLanguage.none)
            }
        }
    }
}
