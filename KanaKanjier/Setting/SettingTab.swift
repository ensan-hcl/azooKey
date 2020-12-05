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
    @State private var pid : Int32 = 0

    @ObservedObject private var storeVariableSection = Store.variableSection
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("キーボードの種類")){
                    KeyboardTypeSettingItemView(Store.shared.keyboardTypeSetting)
                }
                switch storeVariableSection.KeyboardType{
                case .flick:
                    Section(header: Text("カスタムキー")){
                        Text(Store.shared.koganaKeyFlickSetting.item.description)
                        ImageSlideshowView(pictures: ["flickCustomKeySetting0","flickCustomKeySetting1","flickCustomKeySetting2"])
                        KeyFlickSettingItemView(Store.shared.koganaKeyFlickSetting)
                    }
                case .roman:
                    Section(header: Text("カスタムキー")){
                        Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
                        ImageSlideshowView(pictures: ["romanCustomKeySetting0","romanCustomKeySetting1","romanCustomKeySetting2"])
                        NavigationLink(destination: RomanCustomKeysItemView(Store.shared.numberTabCustomKeysSetting)){
                            HStack{
                                Text("設定する")
                                Spacer()
                            }
                        }
                    }
                }
                Section(header: Text("サウンド")){
                    BooleanSettingItemView(Store.shared.enableSoundSetting)
                }
                Section(header: Text("変換")){
                    BooleanSettingItemView(Store.shared.halfKanaSetting)
                    BooleanSettingItemView(Store.shared.typographyLetterSetting)
                    BooleanSettingItemView(Store.shared.wesJapCalenderSetting)
                    BooleanSettingItemView(Store.shared.unicodeCandidateSetting)
                    NavigationLink(destination: AdditionalDictManageView()) {
                        HStack{
                            Text("絵文字と顔文字")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: AzooKeyUserDictionaryView()) {
                        HStack{
                            Text("azooKeyユーザ辞書")
                            Spacer()
                        }
                    }
                }
                Section(header: Text("学習機能")){
                    //BooleanSettingItemView(Store.shared.stopLearningWhenSearchSetting)
                    LearningTypeSettingItemView(Store.shared.memorySetting)
                    MemoryResetSettingItemView(Store.shared.memoryResetSetting)
                }
                Section(header: Text("このアプリについて")){
                    NavigationLink(destination: ContactView()) {
                        HStack{
                            Text("お問い合わせ")
                            Spacer()
                        }
                    }
                    /*
                    HStack{
                        Text("レビューする")
                        Spacer()
                    }.onTapGesture {

                        print("押されたよ")
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                     */
                    FallbackLink("プライバシーポリシー", destination: URL(string: "https://azookey.netlify.app/PrivacyPolicy")!)
                        .foregroundColor(.primary)
                    FallbackLink("利用規約", destination: URL(string: "https://azookey.netlify.app/TermsOfService")!)
                        .foregroundColor(.primary)
                    NavigationLink(destination: UpdateInfomationView()) {
                        HStack{
                            Text("更新履歴")
                            Spacer()
                        }
                    }
                    HStack{
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "取得中です")
                    }

                }

            }
            .navigationBarTitle(Text("設定"), displayMode: .large)

        }
        .font(.body)
    }
}

struct SettingTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingTabView()
    }
}
