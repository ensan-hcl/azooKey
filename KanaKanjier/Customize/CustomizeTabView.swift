//
//  CustomizeTabView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import StoreKit

struct CustomizeTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("カスタムタブ")){
                    VStack{
                        Text("あなたの好きな文字だけを並べたオリジナルのタブを作成することができます。")
                    }
                    NavigationLink(destination: FlickCustomKeysSettingSelectView()){
                        HStack{
                            Text("設定する")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: TabNavigationEditView()){
                        HStack{
                            Text("タブ移動ビューを編集")
                            Spacer()
                        }
                    }
                    VStack{
                        Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                    }
                    FallbackLink("カスタムタブファイルの作り方", destination: "https://google.com")
                }

                Section(header: Text("カスタムキー")){
                    VStack{
                        Text("「小ﾞﾟ」キーと「､｡?!」キーで入力する文字をカスタマイズすることができます。")
                        ImageSlideshowView(pictures: ["flickCustomKeySetting0","flickCustomKeySetting1","flickCustomKeySetting2"])
                    }
                    NavigationLink(destination: FlickCustomKeysSettingSelectView()){
                        HStack{
                            Text("設定する")
                            Spacer()
                        }
                    }
                    VStack{
                        Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
                        ImageSlideshowView(pictures: ["romanCustomKeySetting0","romanCustomKeySetting1","romanCustomKeySetting2"])
                    }
                    NavigationLink(destination: RomanCustomKeysItemView(Store.shared.numberTabCustomKeysSettingNew)){
                        HStack{
                            Text("設定する")
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("拡張"), displayMode: .large)
            .onAppear(){
                if Store.shared.shouldTryRequestReview, Store.shared.shouldRequestReview(){
                    if let windowScene = UIApplication.shared.windows.first?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

