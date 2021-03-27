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
    @State private var tabBarData: TabBarData
    @State private var manager: CustardManager
    @State private var showImportView = false
    @ObservedObject private var storeVariableSection = Store.variableSection

    init(){
        var manager = CustardManager.load()
        self._manager = State(initialValue: manager)
        if let tabBarData = try? manager.tabbar(identifier: 0){
            self._tabBarData = State(initialValue: tabBarData)
        }else{
            self._tabBarData = State(initialValue: TabBarData.default)
            do{
                try manager.saveTabBarData(tabBarData: self.tabBarData)
            }catch{
                debug(error)
            }
        }
    }

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    Section(header: Text("カスタムタブ")){
                        VStack{
                            Text("好きな文字や文章を並べたオリジナルのタブを作成することができます。")
                        }
                        ImageSlideshowView(pictures: ["custard_1", "custard_2", "custard_3",])
                        NavigationLink(destination: ManageCustardView(manager: $manager)){
                            HStack{
                                Text("カスタムタブの管理")
                                    .foregroundColor(.accentColor)
                                Spacer()
                            }
                        }
                    }
                    Section(header: Text("タブバー")){
                        Text("カスタムタブを使うにはタブバーを利用します。")
                        Image("tabBar_1")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: Store.shared.imageMaximumWidth)
                        DisclosureGroup("使い方"){
                            Text("変換候補欄に何も表示されていない状態で、変換候補欄を長押しすると表示されます。")
                            Text("フリック入力では左上の「☆123」・ローマ字入力では左下の「123」「#+=」キーを長押ししても表示されます。")
                        }
                        DisclosureGroup("もっと便利にする"){
                            Text("タブバーを編集し、タブの並び替え、削除、追加を行ったり、文字の入力やカーソルの移動など様々な機能を追加することができます。")
                            NavigationLink(destination: EditingTabBarView(tabBarData: $tabBarData, manager: $manager)){
                                HStack{
                                    Text("タブバーを編集")
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                }
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
                                    .foregroundColor(.accentColor)
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
                                    .foregroundColor(.accentColor)
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
            .onChange(of: storeVariableSection.importFile){ value in
                showImportView = value != nil
            }
            if showImportView{
                URLImportCustardView(manager: $manager)
            }
        }
    }
}

