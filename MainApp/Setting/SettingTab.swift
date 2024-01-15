//
//  SettingTab.swift
//  MainApp
//
//  Created by ensan on 2020/09/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import AzooKeyUtils
import KeyboardViews
import StoreKit
import SwiftUI

struct SettingTabView: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var appStates: MainAppStates
    private func canFlickLayout(_ layout: LanguageLayout) -> Bool {
        if layout == .flick {
            return true
        }
        if case .custard = layout {
            return true
        }
        return false
    }

    private func canQwertyLayout(_ layout: LanguageLayout) -> Bool {
        if layout == .qwerty {
            return true
        }
        return false
    }

    private func isCustard(_ layout: LanguageLayout) -> Bool {
        if case .custard = layout {
            return true
        }
        return false
    }

    var body: some View {
        NavigationView {
            Form {
                Section("キーボードの種類") {
                    NavigationLink("キーボードの種類を設定する", destination: KeyboardLayoutTypeDetailsView())
                }
                Section("ライブ変換") {
                    BoolSettingView(.liveConversion)
                    NavigationLink("詳しい設定", destination: LiveConversionSettingView())
                }
                Section("カスタムキー") {
                    CustomKeysSettingView()
                    if !self.isCustard(appStates.japaneseLayout) || !self.isCustard(appStates.englishLayout) {
                        BoolSettingView(.useNextCandidateKey)
                    }
                    if self.canQwertyLayout(appStates.englishLayout) {
                        BoolSettingView(.useShiftKey)
                        // Version 2.2.2以前にインストールしており、UseShiftKey.valueがtrueの人にのみこのオプションを表示する
                        if #unavailable(iOS 18), let initialVersion = SharedStore.initialAppVersion, initialVersion <= .azooKey_v2_2_2, UseShiftKey.value == true {
                            BoolSettingView(.keepDeprecatedShiftKeyBehavior)
                        }
                    }
                    if !SemiStaticStates.shared.needsInputModeSwitchKey, self.canFlickLayout(appStates.japaneseLayout) {
                        BoolSettingView(.enablePasteButton)
                    }
                }
                Section("バー") {
                    BoolSettingView(.useReflectStyleCursorBar)
                    BoolSettingView(.displayTabBarButton)
                    BoolSettingView(.enableClipboardHistoryManagerTab)
                    if SemiStaticStates.shared.hasFullAccess {
                        NavigationLink("「ペーストを許可」のダイアログについて", destination: PasteFromOtherAppsPermissionTipsView())
                    }
                    NavigationLink("タブバーを編集", destination: EditingTabBarView(manager: $appStates.custardManager))
                }
                // デバイスが触覚フィードバックをサポートしている場合のみ表示する
                if SemiStaticStates.shared.hapticsAvailable {
                    Section("サウンドと振動") {
                        BoolSettingView(.enableKeySound)
                        BoolSettingView(.enableKeyHaptics)
                    }
                } else {
                    Section("サウンド") {
                        BoolSettingView(.enableKeySound)
                    }
                }
                Section("表示") {
                    KeyboardHeightSettingView(.keyboardHeightScale)
                    FontSizeSettingView(.keyViewFontSize, .key, availableValueRange: 15 ... 28)
                    FontSizeSettingView(.resultViewFontSize, .result, availableValueRange: 12...24)
                }

                Section("操作性") {
                    BoolSettingView(.hideResetButtonInOneHandedMode)
                    if self.canFlickLayout(appStates.japaneseLayout) {
                        FlickSensitivitySettingView(.flickSensitivity)
                    }
                }
                Section("変換") {
                    BoolSettingView(.englishCandidate)
                    BoolSettingView(.halfKanaCandidate)
                    BoolSettingView(.fullRomanCandidate)
                    BoolSettingView(.typographyLetter)
                    BoolSettingView(.unicodeCandidate)
                    MarkedTextSettingView(.markedTextSetting)
                    ContactImportSettingView()
                    NavigationLink("絵文字と顔文字", destination: AdditionalDictManageView())
                }
                Section("言語") {
                    PreferredLanguageSettingView()
                }
                Section("ユーザ辞書") {
                    BoolSettingView(.useOSUserDict)
                    NavigationLink("azooKeyユーザ辞書", destination: AzooKeyUserDictionaryView())
                }
                Section("テンプレート") {
                    NavigationLink("テンプレートの管理", destination: TemplateListView())
                }
                Section("学習機能") {
                    LearningTypeSettingView()
                    MemoryResetSettingItemView()
                }
                Section("カスタムタブ") {
                    NavigationLink("カスタムタブの管理", destination: ManageCustardView(manager: $appStates.custardManager))
                }
                Section("オープンソースソフトウェア") {
                    Text("azooKeyはオープンソースソフトウェアであり、GitHubでソースコードを公開しています。")
                    FallbackLink("View azooKey on GitHub", destination: URL(string: "https://github.com/ensan-hcl/azooKey")!)
                    NavigationLink("Acknowledgements", destination: OpenSourceSoftwaresLicenseView())
                }
                Section("このアプリについて") {
                    NavigationLink("お問い合わせ", destination: ContactView())
                    FallbackLink("プライバシーポリシー", destination: URL(string: "https://azookey.netlify.app/PrivacyPolicy")!)
                        .foregroundStyle(.primary)
                    FallbackLink("利用規約", destination: URL(string: "https://azookey.netlify.app/TermsOfService")!)
                        .foregroundStyle(.primary)
                    NavigationLink("更新履歴", destination: UpdateInformationView())
                    HStack {
                        Text("URL Scheme")
                        Spacer()
                        Text(verbatim: "azooKey://").font(.system(.body, design: .monospaced))
                    }
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(verbatim: SharedStore.currentAppVersion?.description ?? "取得中です")
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if appStates.requestReviewManager.shouldTryRequestReview, appStates.requestReviewManager.shouldRequestReview() {
                    requestReview()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
