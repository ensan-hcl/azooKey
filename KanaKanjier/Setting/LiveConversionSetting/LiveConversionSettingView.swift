//
//  LiveConversionSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2022/09/15.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct LiveConversionSettingView: View {
    private static let stregth = [Int.max, 16, 13, 10, 6]
    @State private var autocompletionStrength = 0
    init() {
        self._autocompletionStrength = State(initialValue: Self.stregth.firstIndex(of: AutomaticCompletionTresholdKey.value) ?? 2)
    }
    var body: some View {
        Form {
            Section {
                BoolSettingView(.liveConversion)
            }
            Section(header: Text("自動確定")) {
                Text("自動確定を使うと長い文章を打っているときに候補の選択がしやすくなります。")
                Picker("自動確定の速さ", selection: $autocompletionStrength) {
                    Text("しない").tag(0)
                    Text("ゆっくり").tag(1)
                    Text("普通").tag(2)
                    Text("速い").tag(3)
                    Text("とても速い").tag(4)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .onChange(of: autocompletionStrength) { newValue in
                    if 0 <= newValue && newValue < Self.stregth.count {
                        AutomaticCompletionTresholdKey.value = Self.stregth[newValue]
                    }
                }
            }
        }.navigationBarTitle(Text("ライブ変換の設定"), displayMode: .inline)
    }
}
