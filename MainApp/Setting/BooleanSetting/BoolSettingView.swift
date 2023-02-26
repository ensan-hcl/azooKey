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

    private var toggle: some View {
        Toggle(isOn: $setting.value) {
            HStack {
                Text(SettingKey.title)
                Button {
                    isOn = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                if SettingKey.requireFullAccess {
                    Image(systemName: "f.circle.fill")
                        .foregroundColor(.purple)
                }
            }
        }
        .toggleStyle(.switch)
    }

    var body: some View {
        Group {
            if disabled {
                toggle
                    .disabled(true)
                    .onTapGesture {
                        isOn = true
                    }
            } else {
                toggle
            }
        }
        .onAppear {
            setting.reload()
        }
        .alert(isPresented: $isOn) {
            // TODO: Localize
            if disabled, let url = URL(string: UIApplication.openSettingsURLString) {
                return Alert(
                    title: Text(SettingKey.explanation),
                    message: Text("この機能にはフルアクセスが必要です。この機能を使いたい場合は、「設定」>「キーボード」でフルアクセスを有効にしてください。"),
                    primaryButton: .cancel {
                        isOn = false
                    },
                    secondaryButton: .default(Text("「設定」アプリを開く")) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        isOn = false
                    }
                )
            } else {
                return Alert(
                    title: Text(SettingKey.explanation),
                    dismissButton: .default(Text("OK")) {
                        isOn = false
                    }
                )
            }
        }
    }

    private var disabled: Bool {
        SettingKey.requireFullAccess && !Store.shared.isFullAccessEnabled
    }
}
