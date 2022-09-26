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

    var bindedValue: Binding<Bool> {
        return .init(get: {
            if SettingKey.value == .disabled {
                return false
            } else {
                return true
            }
        }, set: { newValue in
            if newValue {
                SettingKey.value = .enabled
            } else {
                SettingKey.value = .disabled
            }
        })
    }

    var body: some View {
        Toggle(isOn: bindedValue) {
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
