//
//  ContentView.swift
//  MainApp
//
//  Created by ensan on 2020/09/03.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStates: MainAppStates
    @State private var selection = 0
    @State private var isPresented = true

    @State private var messageManager = MessageManager()
    @State private var showWalkthrough = false
    @State private var importFileURL: URL? = nil

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                TipsTabView()
                    .tabItem {
                        TabItem(title: "使い方", systemImage: "lightbulb.fill")
                    }
                    .tag(0)
                ThemeTabView()
                    .tabItem {
                        TabItem(title: "着せ替え", systemImage: "photo")
                    }
                    .tag(1)
                CustomizeTabView()
                    .tabItem {
                        TabItem(title: "拡張", systemImage: "gearshape.2.fill")
                    }
                    .tag(2)
                SettingTabView()
                    .tabItem {
                        TabItem(title: "設定", systemImage: "wrench.fill")
                    }
                    .tag(3)
            }
            .fullScreenCover(isPresented: $appStates.requireFirstOpenView) {
                EnableAzooKeyView()
            }
            .onChange(of: selection) {value in
                if value == 2 {
                    if ContainerInternalSetting.shared.walkthroughState.shouldDisplay(identifier: .extensions) {
                        self.showWalkthrough = true
                    }
                }
            }
            .onOpenURL { url in
                importFileURL = url
            }
            .sheet(isPresented: $showWalkthrough) {
                CustomizeTabWalkthroughView(isShowing: $showWalkthrough)
                    .background(Color.background)
            }
            ForEach(messageManager.necessaryMessages, id: \.id) {data in
                if messageManager.requireShow(data.id) {
                    switch data.id {
                    case .mock:
                        EmptyView()
                    case .ver1_9_user_dictionary_update:
                        // ユーザ辞書を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            let builder = LOUDSBuilder(txtFileSplit: 2048)
                            builder.process()
                        }
                    case .iOS15_4_new_emoji, .iOS16_4_new_emoji:
                        // 絵文字を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            AdditionalDictManager().userDictUpdate()
                        }
                    }
                }
            }
            if importFileURL != nil {
                URLImportCustardView(manager: $appStates.custardManager, url: $importFileURL)
            }
        }
    }
}

private struct TabItem: View {
    init(title: LocalizedStringKey, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    private let title: LocalizedStringKey
    private let systemImage: String

    var body: some View {
        VStack {
            Image(systemName: systemImage).font(.system(size: 20, weight: .light))
                .foregroundColor(.systemGray2)
            Text(title)
        }
    }
}
