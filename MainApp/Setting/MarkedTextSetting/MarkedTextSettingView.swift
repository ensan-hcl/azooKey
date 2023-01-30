//
//  MarkedTextSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/26.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct MarkedTextSettingView: View {
    typealias SettingKey = MarkedTextSettingKey
    init(_ key: SettingKey) {}
    @State private var isOn = false
    @State private var setting = SettingUpdater<SettingKey>()

    func forward(_ settingValue: MarkedTextSettingKey.Value) -> Bool {
        if settingValue == .disabled {
            return false
        } else {
            return true
        }
    }

    func backward(_ boolValue: Bool) -> MarkedTextSettingKey.Value {
        if boolValue {
            return .enabled
        } else {
            return .disabled
        }
    }

    var body: some View {
        Toggle(isOn: $setting.value.converted(forward: forward, backward: backward)) {
            HStack {
                Text(SettingKey.title)
                Button {
                    isOn = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .toggleStyle(.switch)
        .onAppear {
            setting.reload()
        }
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
