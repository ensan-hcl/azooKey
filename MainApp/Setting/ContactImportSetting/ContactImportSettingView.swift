//
//  ContactImportSettingView.swift
//  azooKey
//
//  Created by miwa on 2023/09/23.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import AzooKeyUtils
import KeyboardViews
import SwiftUI

struct ContactImportSettingView: View {
    @State private var manager = ContactAuthManager()
    @State private var showExplanation = false
    @State private var showRequireFullAccessAlert = false
    @State private var setting: SettingUpdater<EnableContactImport>
    @State private var showAuthErrorMessage = false

    @MainActor init() {
        self._setting = .init(initialValue: .init())
    }

    @MainActor private var disabled: Bool {
        !SemiStaticStates.shared.hasFullAccess
    }

    @MainActor private var enabledButDenied: Bool {
        setting.value && manager.authState != .authorized
    }

    @MainActor @ViewBuilder private var control: some View {
        Toggle(isOn: $setting.value) {
            HStack {
                Text(EnableContactImport.title)
                Button {
                    self.showExplanation = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                Image(systemName: "f.circle.fill")
                    .foregroundStyle(.purple)
                if self.enabledButDenied {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
    }

    var body: some View {
        Group {
            if disabled {
                control
                    .disabled(true)
                    .onTapGesture {
                        showRequireFullAccessAlert = true
                    }
            } else if enabledButDenied {
                control
                    .disabled(true)
                    .onTapGesture {
                        showAuthErrorMessage = true
                    }
            } else {
                control
            }
        }
        .onChange(of: setting.value) { enabled in
            if enabled && manager.authState == .notDetermined {
                manager.requestAuthForContact { (granted, _) in
                    if !granted {
                        self.showAuthErrorMessage = true
                    }
                }
            } else if enabled && manager.authState == .denied {
                self.showAuthErrorMessage = true
            }
        }
        .onAppear {
            setting.reload()
        }
        .alert("設定を　有効化できません", isPresented: $showAuthErrorMessage) {
            Button("「設定」アプリを開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            Button("キャンセル", role: .cancel) {
                self.setting.value = false
            }
        } message: {
            Text("「連絡先」へのアクセスを許可する必要があります")
        }
        .alert(EnableContactImport.explanation, isPresented: $showExplanation) {
            Button("OK") {
                self.showExplanation = false
            }
        }
        .alert(EnableContactImport.explanation, isPresented: $showRequireFullAccessAlert) {
            Button("キャンセル", role: .cancel) {
                showRequireFullAccessAlert = false
            }
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Button("「設定」アプリを開く") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    showRequireFullAccessAlert = false
                }
            }
        } message: {
            Text("この機能にはフルアクセスが必要です。この機能を使いたい場合は、「設定」>「キーボード」でフルアクセスを有効にしてください。")
        }
    }
}
