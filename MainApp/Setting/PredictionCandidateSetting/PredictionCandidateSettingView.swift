//
//  PredictionCandidateSettingView.swift
//  azooKey
//
//  Created by ensan on 2023/02/18.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct PredictionCandidateSettingView: View {
    typealias SettingKey = PredictionCandidateSettingKey
    init(_ key: SettingKey) {}
    @State private var isOn = false
    @State private var setting = SettingUpdater<SettingKey>()

    var body: some View {
        // TODO: Localize
        Picker(selection: $setting.value) {
            Text("短く表示").tag(SettingKey.Value.short)
            Text("全て表示").tag(SettingKey.Value.long)
            Text("無効化").tag(SettingKey.Value.disabled)
        } label: {
            HStack {
                Text(SettingKey.title)
                Button {
                    isOn = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
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
