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
import SwiftUIUtils

struct CustomizeTabView: View {
    @EnvironmentObject private var appStates: MainAppStates

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section(header: Text("カスタムタブ")) {
                        ImageSlideshowView(pictures: ["custard_1", "custard_2", "custard_3" ])
                            .listRowSeparator(.hidden, edges: .bottom)
                        Text("好きな文字や文章を並べたオリジナルのタブを作成することができます。")
                        NavigationLink("カスタムタブの管理", destination: ManageCustardView(manager: $appStates.custardManager))
                            .foregroundColor(.accentColor)
                    }

                    Section(header: Text("タブバー")) {
                        CenterAlignedView {
                            Image("tabBar_1")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: MainAppDesign.imageMaximumWidth)
                        }
                        .listRowSeparator(.hidden, edges: .bottom)
                        Text("カスタムタブを使うにはタブバーを利用します。")
                        DisclosureGroup("使い方") {
                            Text("あずきのマークを押すと表示されます。")
                            Text("フリック入力では左上の「☆123」・ローマ字入力では左下の「123」「#+=」キーを長押ししても表示されます。")
                        }
                        BoolSettingView(.displayTabBarButton)
                        NavigationLink("タブバーを編集", destination: EditingTabBarView(manager: $appStates.custardManager))
                            .foregroundColor(.accentColor)
                    }

                    Section(header: Text("カスタムキー")) {
                        CustomKeysSettingView()
                    }
                }
                .navigationBarTitle(Text("拡張"), displayMode: .large)
                .onAppear {
                    if RequestReviewManager.shared.shouldTryRequestReview, RequestReviewManager.shared.shouldRequestReview() {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}
