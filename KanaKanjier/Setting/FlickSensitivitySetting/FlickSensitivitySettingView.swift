//
//  FlickSensitivitySettingView.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/10.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct FlickSensitivitySettingView: View {
    typealias SettingKey = FlickSensitivitySettingKey
    @State private var localValue: Double = SettingKey.value

    init(_ key: SettingKey) {}

    private var explanation: LocalizedStringKey {
        switch localValue {
        case 0.33 ... 0.5: return "設定: とても反応しにくい"
        case 0.5 ... 0.8: return "設定: 反応しにくい"
        case 0.8 ... 1.2: return "設定: 普通"
        case 1.2 ... 2: return "設定: 反応しやすい"
        case 2 ... 4: return "設定: とても反応しやすい"
        default: return "設定: 普通"
        }
    }

    var body: some View {
        Text(explanation)
        HStack {
            Text("フリックの感度")
            Slider(value: $localValue, in: 0.33 ... 4) { (_: Bool) in
                SettingKey.value = localValue
            }
        }
    }

}
