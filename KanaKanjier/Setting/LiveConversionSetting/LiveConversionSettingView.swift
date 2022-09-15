//
//  LiveConversionSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/15.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct LiveConversionSettingView: View {
    private static let stregth: [AutomaticCompletionStrengthKey.Value] = [.disabled, .weak, .normal, .strong, .ultrastrong]
    @State private var autocompletionStrength: AutomaticCompletionStrengthKey.Value = .normal
    init() {
        self._autocompletionStrength = State(initialValue: AutomaticCompletionStrengthKey.value)
    }
    var body: some View {
        Form {
            Section {
                BoolSettingView(.liveConversion)
            }
            Section(header: Text("自動確定")) {
                Text("自動確定を使うと長い文章を打っているときに候補の選択がしやすくなります。")
                Picker("自動確定の速さ", selection: $autocompletionStrength) {
                    Text("しない").tag(Self.stregth[0])
                    Text("ゆっくり").tag(Self.stregth[1])
                    Text("普通").tag(Self.stregth[2])
                    Text("少し速い").tag(Self.stregth[3])
                    Text("速い").tag(Self.stregth[4])
                }
                .onChange(of: autocompletionStrength) { newValue in
                    AutomaticCompletionStrengthKey.value = newValue
                }
            }
        }.navigationBarTitle(Text("ライブ変換の設定"), displayMode: .inline)
    }
}
