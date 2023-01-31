//
//  BoolSettingView.swift
//  MainApp
//
//  Created by ensan on 2020/11/09.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI

struct BoolSettingView<SettingKey: BoolKeyboardSettingKey>: View {
    init(_ key: SettingKey) {}
    @State private var isOn = false
    @State private var setting = SettingUpdater<SettingKey>()

    var body: some View {
        Toggle(isOn: $setting.value) {
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
