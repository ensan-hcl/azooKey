//
//  SettingTab.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import StoreKit

struct SettingTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("キーボードの種類")) {
                    NavigationLink("キーボードの種類を設定する", destination: KeyboardLayoutTypeDetailsView())
                }
                Section(header: Text("言語")) {
                    PreferredLanguageSettingView()
                }
                Section(header: Text("カスタムキー")) {
                    CustomKeysSettingView()
                }
                Group {
                    Section(header: Text("タブバー")) {
                        BoolSettingView(.displayTabBarButton)
                    }
                    Section(header: Text("サウンド")) {
                        BoolSettingView(.enableKeySound)
                    }
                    Section(header: Text("表示")) {
                        FontSizeSettingView(.keyViewFontSize, .key, availableValues: [
                            -1,
                             15,
                             16,
                             17,
                             18,
                             19,
                             20,
                             21,
                             22,
                             23,
                             24,
                             25,
                             26,
                             27,
                             28
                        ])
                        FontSizeSettingView(.resultViewFontSize, .result, availableValues: [
                            -1,
                             12,
                             13,
                             14,
                             15,
                             16,
                             17,
                             18,
                             19,
                             20,
                             21,
                             22,
                             23,
                             24
                        ])
                    }
                }
                Section(header: Text("変換")) {
                    BoolSettingView(.liveConversion)
                    BoolSettingView(.englishCandidate)
                    BoolSettingView(.halfKanaCandidate)
                    BoolSettingView(.fullRomanCandidate)
                    BoolSettingView(.typographyLetter)
                    BoolSettingView(.westernJapaneseCalender)
                    BoolSettingView(.unicodeCandidate)
                    NavigationLink("絵文字と顔文字", destination: AdditionalDictManageView())
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
                Section(header: Text("このアプリについて")) {
                    NavigationLink("お問い合わせ", destination: ContactView())
                    FallbackLink("プライバシーポリシー", destination: URL(string: "https://azookey.netlify.app/PrivacyPolicy")!)
                        .foregroundColor(.primary)
                    FallbackLink("利用規約", destination: URL(string: "https://azookey.netlify.app/TermsOfService")!)
                        .foregroundColor(.primary)
                    NavigationLink("更新履歴", destination: UpdateInfomationView())
                    NavigationLink("オープンソースソフトウェア", destination: OpenSourceSoftWaresLicenceView())
                    HStack {
                        Text("URL Scheme")
                        Spacer()
                        Text("azooKey://").font(.system(.body, design: .monospaced))
                    }
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "取得中です")
                    }
                }
            }
            .navigationBarTitle(Text("設定"), displayMode: .large)
            .onAppear {
                if Store.shared.shouldTryRequestReview, Store.shared.shouldRequestReview() {
                    if let windowScene = UIApplication.shared.windows.first?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
