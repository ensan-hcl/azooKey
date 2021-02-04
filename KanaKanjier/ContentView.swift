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

    init(){
        Store.shared.appDidOpen()
    }

    var body: some View {
        ZStack{
            TabView(selection: $selection){
                TipsTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "lightbulb.fill").font(.system(size: 20, weight: .light))
                                .foregroundColor(.systemGray2)
                            Text("使い方")
                        }
                    }
                    .tag(0)
                SettingTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "wrench.fill").font(.system(size: 20, weight: .light))
                                .foregroundColor(.systemGray2)
                            Text("設定")
                        }
                    }
                    .tag(1)
                ThemeTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "photo").font(.system(size: 20, weight: .light))
                                .foregroundColor(.systemGray2)
                            Text("着せ替え")
                        }
                    }
                    .tag(2)
            }.fullScreenCover(isPresented: $storeVariableSection.requireFirstOpenView){
                EnableAzooKeyView()
            }
            ForEach(messageManager.necessaryMessages, id: \.id){data in
                if messageManager.requireShow(data.id){
                    switch data.id{
                    case .mock:
                        EmptyView()
                    case .ver1_5_update_loudstxt:
                        DataUpdateView(id: data.id, manager: $messageManager){
                            let builder = LOUDSBuilder(txtFileSplit: 2048)
                            builder.process()
                            Store.shared.noticeReloadUserDict()
                        }
                    }
                }
            }
        }
    }
}
