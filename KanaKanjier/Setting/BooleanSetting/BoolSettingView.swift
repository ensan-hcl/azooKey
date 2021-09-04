//
//  BoolSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct BoolSettingView<SettingKey: BoolKeyboardSettingKey>: View {
    init(_ key: SettingKey) {}
    @State private var isOn = false

    var body: some View {
        Toggle(isOn: .init(get: {SettingKey.value}, set: {SettingKey.value = $0})) {
            Text(SettingKey.title)
            Button {
                isOn = true
            }label: {
                Image(systemName: "info.circle")
            }
        }
        .toggleStyle(.switch)
        .alert(isPresented: $isOn) {
            Alert(
                title: Text(SettingKey.explanation),
                dismissButton: .default(Text("OK")) {
                    isOn = false
                }
            )
        }
    }
}
