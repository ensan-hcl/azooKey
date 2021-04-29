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
    
    init() {
        var manager = CustardManager.load()
        self._manager = State(initialValue: manager)
        if let tabBarData = try? manager.tabbar(identifier: 0) {
            self._tabBarData = State(initialValue: tabBarData)
        } else {
            self._tabBarData = State(initialValue: TabBarData.default)
            do {
                try manager.saveTabBarData(tabBarData: self.tabBarData)
            } catch {
                debug(error)
            }
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section(header: Text("カスタムタブ")) {
                        VStack {
                            Text("好きな文字や文章を並べたオリジナルのタブを作成することができます。")
                        }
                        ImageSlideshowView(pictures: ["custard_1", "custard_2", "custard_3" ])
                        NavigationLink("カスタムタブの管理", destination: ManageCustardView(manager: $manager))
                            .foregroundColor(.accentColor)
                    }
                    Section(header: Text("タブバー")) {
                        Text("カスタムタブを使うにはタブバーを利用します。")
                        CenterAlignedView {
                            Image("tabBar_1")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: Store.shared.imageMaximumWidth)
                        }
                        DisclosureGroup("使い方") {
                            Text("変換候補欄に何も表示されていない状態で、変換候補欄を長押しすると表示されます。")
                            Text("フリック入力では左上の「☆123」・ローマ字入力では左下の「123」「#+=」キーを長押ししても表示されます。")
                        }
                        NavigationLink("タブバーを編集", destination: EditingTabBarView(tabBarData: $tabBarData, manager: $manager))
                            .foregroundColor(.accentColor)
                    }
                    
                    Section(header: Text("カスタムキー")) {
                        VStack {
                            Text("「小ﾞﾟ」キーと「､｡?!」キーで入力する文字をカスタマイズすることができます。")
                            ImageSlideshowView(pictures: ["flickCustomKeySetting0", "flickCustomKeySetting1", "flickCustomKeySetting2"])
                        }
                        NavigationLink("設定する", destination: FlickCustomKeysSettingSelectView())
                            .foregroundColor(.accentColor)
                        VStack {
                            Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
                            ImageSlideshowView(pictures: ["qwertyCustomKeySetting0", "qwertyCustomKeySetting1", "qwertyCustomKeySetting2"])
                        }
                        NavigationLink("設定する", destination: QwertyCustomKeysItemView(Store.shared.numberTabCustomKeysSettingNew))
                            .foregroundColor(.accentColor)
                    }
                }
                .navigationBarTitle(Text("拡張"), displayMode: .large)
                .onAppear {
                    if let tabBarData = try? manager.tabbar(identifier: 0) {
                        self.tabBarData = tabBarData
                    }
                    if Store.shared.shouldTryRequestReview, Store.shared.shouldRequestReview() {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onChange(of: storeVariableSection.importFile) { value in
                showImportView = value != nil
            }
            if showImportView {
                URLImportCustardView(manager: $manager)
            }
        }
    }
}
