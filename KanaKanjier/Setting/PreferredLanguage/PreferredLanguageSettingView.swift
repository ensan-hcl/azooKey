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
    typealias ItemViewModel = SettingItemViewModel<PreferredLanguage>
    private typealias ItemModel = SettingItem<PreferredLanguage>

    init(_ viewModel: ItemViewModel) {
        self.item = viewModel.item
        self.viewModel = viewModel
    }

    private let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    var body: some View {
        Picker("第1言語", selection: $viewModel.value.first) {
            Text("日本語").tag(KeyboardLanguage.ja_JP)
            Text("英語").tag(KeyboardLanguage.en_US)
        }
        Picker("第2言語", selection: $viewModel.value.second.converted(OptionalTranslator.self)) {
            Text("日本語").tag(KeyboardLanguage.ja_JP)
            Text("英語").tag(KeyboardLanguage.en_US)
            Text("指定しない").tag(KeyboardLanguage.none)
        }
    }
}
