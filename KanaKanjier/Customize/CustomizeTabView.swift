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
    @State private var manager: CustardManager

    init(){
        let manager = CustardManager.load()
        self._manager = State(initialValue: manager)
        if let tabBarData = try? manager.tabbar(identifier: 0){
            self._tabBarData = State(initialValue: tabBarData)
        }else{
            self._tabBarData = State(initialValue: TabBarData(identifier: 0, items: [
                TabBarItem(label: .text("あいう"), actions: [.moveTab(.system(.user_japanese))]),
                TabBarItem(label: .text("ABC"), actions: [.moveTab(.system(.user_english))]),
            ]))
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("カスタムタブ")){
                    VStack{
                        Text("あなたの好きな文字や文章を並べたオリジナルのタブを作成することができます。")
                    }
                    Image("custard_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Store.shared.imageMaximumWidth)

                    NavigationLink(destination: ManageCustardView(manager: $manager)){
                        HStack{
                            Text("カスタムタブの管理")
                            Spacer()
                        }
                    }
                }
                Section(header: Text("タブバー")){
                    Text("タブバーはカスタムタブを利用した際のタブ移動をサポートします。「記号タブ」キーを長押しすることで表示され、タブを移動することが可能です。")
                    Image("tabBar_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Store.shared.imageMaximumWidth)

                    Text("タブバーを編集し、タブの並び替え、削除、追加を行ったり、文字の入力やカーソルの移動など様々な機能を追加することができます。")
                    NavigationLink(destination: EditingTabBarView(tabBarData: $tabBarData, manager: $manager)){
                        HStack{
                            Text("タブバーを編集")
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
                        ImageSlideshowView(pictures: ["qwertyCustomKeySetting0","qwertyCustomKeySetting1","qwertyCustomKeySetting2"])
                    }
                    NavigationLink(destination: QwertyCustomKeysItemView(Store.shared.numberTabCustomKeysSettingNew)){
                        HStack{
                            Text("設定する")
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("拡張"), displayMode: .large)
            .onAppear(){
                if let tabBarData = try? manager.tabbar(identifier: 0){
                    self.tabBarData = tabBarData
                }
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

