//
//  PreferredLanguageSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct PreferredLanguageSettingView: View {
    typealias ItemViewModel = SettingItemViewModel<PreferredLanguage>
    typealias ItemModel = SettingItem<PreferredLanguage>

    init(_ viewModel: ItemViewModel) {
        self.item = viewModel.item
        self.viewModel = viewModel
        self._secondLanguage = State(initialValue: viewModel.value.second ?? .none)
    }
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    @State private var secondLanguage: KeyboardLanguage    // 選択値と連携するプロパティ

    var body: some View {
        Picker(selection: $viewModel.value.first, label: Text("第1言語")) {
            Text("日本語").tag(KeyboardLanguage.ja_JP)
            Text("英語").tag(KeyboardLanguage.en_US)
        }
        Picker(selection: $secondLanguage, label: Text("第2言語")) {
            Text("日本語").tag(KeyboardLanguage.ja_JP)
            Text("英語").tag(KeyboardLanguage.en_US)
            Text("指定しない").tag(KeyboardLanguage.none)
        }
        .onChange(of: secondLanguage) { value in
            if value == .none {
                viewModel.value.second = nil
            } else {
                viewModel.value.second = value
            }
        }
    }
}
