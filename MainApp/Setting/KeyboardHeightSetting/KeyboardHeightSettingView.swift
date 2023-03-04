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
    @State private var auto: Bool
    @State private var showAlert = false
    @State private var setting = SettingUpdater<SettingKey>()

    init(_ key: SettingKey) {
        if SettingKey.value == 1 {
            _auto = .init(initialValue: true)
        } else {
            _auto = .init(initialValue: false)
        }
    }

    var body: some View {
        Text("キーボードの高さ")
        Toggle(isOn: $auto) {
            Text("自動")
        }.onChange(of: auto) { newValue in
            if newValue {
                setting.value = 1
            }
        }
        if !auto {
            // 対数スケールでBindingすると編集がしやすい
            Slider(value: $setting.value.converted(forward: log2, backward: {pow(2, $0)}), in: -1.1 ... 1.1)
        }
    }
}

