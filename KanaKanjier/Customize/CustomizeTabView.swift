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
    @State private var tabBarData: TabBarData

    init(){
        if let tabBarData = try? VariableStates.shared.custardManager.tabbar(identifier: 0){
            self._tabBarData = State(initialValue: tabBarData)
        }else{
            self._tabBarData = State(initialValue: TabBarData(identifier: 0, items: [
                TabBarItem(label: .text("あいう"), actions: [.moveTab(.system(.user_hira))]),
                TabBarItem(label: .text("ABC"), actions: [.moveTab(.system(.user_abc))]),
                TabBarItem(label: .text("①②③"), actions: [.moveTab(.custom("123"))])
            ]))
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タブバー")){
                    Text("タブバーはあなたの入力をサポートします。「記号キー」の長押しで出現し、タブの移動、文字の入力、カーソルの移動、その他たくさんの機能を自由に設定できます。")
                    Image("tabBar_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Store.shared.imageMaximumWidth)

                    NavigationLink(destination: EditingTabBarView(tabBarData: $tabBarData)){
                        HStack{
                            Text("タブバーを編集")
                            Spacer()
                        }
                    }

                }
                Section(header: Text("カスタムタブ")){
                    VStack{
                        Text("あなたの好きな文字だけを並べたオリジナルのタブを作成することができます。")
                    }
                    NavigationLink(destination: ManageCustardView()){
                        HStack{
                            Text("カスタムタブの管理")
                            Spacer()
                        }
                    }
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

