//
//  ContentView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var isPresented = true

    @State private var messageManager = MessageManager()
    @State private var showWalkthrough = false

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
            .fullScreenCover(isPresented: $storeVariableSection.requireFirstOpenView) {
                EnableAzooKeyView()
            }
            .onChange(of: selection) {value in
                if value == 2 {
                    if ContainerInternalSetting.shared.walkthroughState.shouldDisplay(identifier: .extensions) {
                        self.showWalkthrough = true
                    }
                }
            }
            .onChange(of: storeVariableSection.importFile) { value in
                if value != nil {
                    selection = 2
                }
            }
            .sheet(isOpen: $showWalkthrough, maxHeight: UIScreen.main.bounds.height * 0.9, minHeight: 0, headerColor: .background) {
                CustomizeTabWalkthroughView(isShowing: $showWalkthrough)
                    .background(Color.background)
            }
            ForEach(messageManager.necessaryMessages, id: \.id) {data in
                if messageManager.requireShow(data.id) {
                    switch data.id {
                    case .mock, .liveconversion_introduction, .ver1_8_autocomplete_introduction:
                        EmptyView()
                    case .ver1_9_user_dictionary_update:
                        // ユーザ辞書を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            let builder = LOUDSBuilder(txtFileSplit: 2048)
                            builder.process()
                            Store.shared.noticeReloadUserDict()
                        }
                    case .iOS15_4_new_emoji:
                        // 絵文字を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            AdditionalDictManager().userDictUpdate()
                        }
                    }
                }
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
