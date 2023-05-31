//
//  KeyboardHeightSettingView.swift
//  MainApp
//
//  Created by ensan on 2023/03/04.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct KeyboardHeightSettingView: View {
    typealias SettingKey = KeyboardHeightScaleSettingKey
    @State private var enabled: Bool
    @State private var showAlert = false
    @State private var setting: SettingUpdater<SettingKey>

    @MainActor init(_ key: SettingKey) {
        self._setting = .init(initialValue: .init())
        if SettingKey.value == 1 {
            _enabled = .init(initialValue: false)
        } else {
            _enabled = .init(initialValue: true)
        }
    }

    var body: some View {
        Toggle(isOn: $enabled) {
            HStack {
                Text(SettingKey.title)
                Button {
                    showAlert = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }.onChange(of: enabled) { newValue in
            if !newValue {
                setting.value = 1
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(SettingKey.explanation), dismissButton: .default(Text("OK")))
        }

        if enabled {
            // 対数スケールでBindingすると編集がしやすい
            Slider(value: $setting.value.converted(forward: log2, backward: {pow(2, $0)}), in: -1.1 ... 1.1)
        }
    }
}
