//
//  CustomizeTabView.swift
//  MainApp
//
//  Created by ensan on 2021/02/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI

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
                        ImageSlideshowView(pictures: ["custard_1", "custard_2", "custard_3" ])
                            .listRowSeparator(.hidden, edges: .bottom)
                        Text("好きな文字や文章を並べたオリジナルのタブを作成することができます。")
                        NavigationLink("カスタムタブの管理", destination: ManageCustardView(manager: $manager))
                            .foregroundColor(.accentColor)
                    }

                    Section(header: Text("タブバー")) {
                        CenterAlignedView {
                            Image("tabBar_1")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: Store.shared.imageMaximumWidth)
                        }
                        .listRowSeparator(.hidden, edges: .bottom)
                        Text("カスタムタブを使うにはタブバーを利用します。")
                        DisclosureGroup("使い方") {
                            Text("あずきのマークを押すと表示されます。")
                            Text("フリック入力では左上の「☆123」・ローマ字入力では左下の「123」「#+=」キーを長押ししても表示されます。")
                        }
                        BoolSettingView(.displayTabBarButton)
                        NavigationLink("タブバーを編集", destination: EditingTabBarView(tabBarData: $tabBarData, manager: $manager))
                            .foregroundColor(.accentColor)
                    }

                    Section(header: Text("カスタムキー")) {
                        CustomKeysSettingView()
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
            .navigationViewStyle(.stack)
            .onChange(of: storeVariableSection.importFile) { value in
                showImportView = value != nil
            }
            if showImportView {
                URLImportCustardView(manager: $manager)
            }
        }
    }
}
