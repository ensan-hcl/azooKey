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

    var body: some View {
        NavigationView {
            Form {
                Group {
                    Section(header: Text("キーボードの種類")) {
                        NavigationLink("キーボードの種類を設定する", destination: KeyboardLayoutTypeDetailsView())
                    }
                }
                Section(header: Text("ライブ変換")) {
                    BoolSettingView(.liveConversion)
                    NavigationLink("詳しい設定", destination: LiveConversionSettingView())
                }

                Group {
                    Section(header: Text("カスタムキー")) {
                        CustomKeysSettingView()
                        if !SemiStaticStates.shared.needsInputModeSwitchKey, self.canFlickLayout(appStates.japaneseLayout) {
                            BoolSettingView(.enablePasteButton)
                        }
                    }
                    Section(header: Text("タブバー")) {
                        BoolSettingView(.displayTabBarButton)
                        BoolSettingView(.enableClipboardHistoryManagerTab)
                        if SemiStaticStates.shared.hasFullAccess {
                            NavigationLink("「ペーストを許可」のダイアログについて", destination: PasteFromOtherAppsPermissionTipsView())
                        }
                        NavigationLink("タブバーを編集", destination: EditingTabBarView(manager: $appStates.custardManager))
                    }
                    Section(header: Text("カーソルバー")) {
                        BoolSettingView(.useBetaMoveCursorBar)
                        FallbackLink("フィードバックを募集します", destination: "https://forms.gle/vZ8Ftuu9BJBEi98h7", icon: .link)
                    }
                    // デバイスが触覚フィードバックをサポートしている場合のみ表示する
                    if SemiStaticStates.shared.hapticsAvailable {
                        Section(header: Text("サウンドと振動")) {
                            BoolSettingView(.enableKeySound)
                            BoolSettingView(.enableKeyHaptics)
                        }
                    } else {
                        Section(header: Text("サウンド")) {
                            BoolSettingView(.enableKeySound)
                        }
                    }
                    Section(header: Text("表示")) {
                        KeyboardHeightSettingView(.keyboardHeightScale)
                        FontSizeSettingView(.keyViewFontSize, .key, availableValueRange: 15 ... 28)
                        FontSizeSettingView(.resultViewFontSize, .result, availableValueRange: 12...24)
                    }
                    Section(header: Text("操作性")) {
                        BoolSettingView(.hideResetButtonInOneHandedMode)
                        if self.canFlickLayout(appStates.japaneseLayout) {
                            FlickSensitivitySettingView(.flickSensitivity)
                        }
                    }
                }
                Group {
                    Section(header: Text("変換")) {
                        BoolSettingView(.englishCandidate)
                        BoolSettingView(.halfKanaCandidate)
                        BoolSettingView(.fullRomanCandidate)
                        BoolSettingView(.typographyLetter)
                        BoolSettingView(.unicodeCandidate)
                        MarkedTextSettingView(.markedTextSetting)
                        ContactImportSettingView()
                        NavigationLink("絵文字と顔文字", destination: AdditionalDictManageView())
                    }

                    Section(header: Text("言語")) {
                        PreferredLanguageSettingView()
                    }

                    Section(header: Text("ユーザ辞書")) {
                        BoolSettingView(.useOSUserDict)
                        NavigationLink("azooKeyユーザ辞書", destination: AzooKeyUserDictionaryView())
                    }

                    Section(header: Text("テンプレート")) {
                        NavigationLink("テンプレートの管理", destination: TemplateListView())
                    }

                    Section(header: Text("学習機能")) {
                        LearningTypeSettingView()
                        MemoryResetSettingItemView()
                    }

                    Section(header: Text("カスタムタブ")) {
                        NavigationLink("カスタムタブの管理", destination: ManageCustardView(manager: $appStates.custardManager))
                    }
                }
                Section(header: Text("オープンソースソフトウェア")) {
                    Text("azooKeyはオープンソースソフトウェアであり、GitHubでソースコードを公開しています。")
                    FallbackLink("View azooKey on GitHub", destination: URL(string: "https://github.com/ensan-hcl/azooKey")!)
                    NavigationLink("Acknowledgements", destination: OpenSourceSoftwaresLicenseView())
                }
                Section(header: Text("このアプリについて")) {
                    NavigationLink("お問い合わせ", destination: ContactView())
                    FallbackLink("プライバシーポリシー", destination: URL(string: "https://azookey.netlify.app/PrivacyPolicy")!)
                        .foregroundStyle(.primary)
                    FallbackLink("利用規約", destination: URL(string: "https://azookey.netlify.app/TermsOfService")!)
                        .foregroundStyle(.primary)
                    NavigationLink("更新履歴", destination: UpdateInformationView())
                    HStack {
                        Text("URL Scheme")
                        Spacer()
                        Text("azooKey://").font(.system(.body, design: .monospaced))
                    }
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(SharedStore.currentAppVersion?.description ?? "取得中です")
                    }
                }
            }
            .navigationBarTitle(Text("設定"), displayMode: .large)
            .onAppear {
                if appStates.requestReviewManager.shouldTryRequestReview, appStates.requestReviewManager.shouldRequestReview() {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
