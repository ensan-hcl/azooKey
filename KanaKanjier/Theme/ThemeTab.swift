//
//  ThemeTab.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/04.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct ThemeTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var selection = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")){
                    NavigationLink("テーマを作成", destination: ThemeEditView())
                }
                Section(header: Text("選ぶ")){
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) { // カラム数の指定
                        ForEach(Store.shared.themeIndexManager.indices.reversed(), id: \.self) { index in
                            if let _preview = try? Store.shared.themeIndexManager.preview(at: index),
                               let preview = _preview{
                                Image(uiImage: preview)
                                    .resizable()
                                    .scaledToFit()
                                    .overlay(
                                        Group{
                                            if selection == index{
                                                Image(systemName: "checkmark.circle.fill")
                                                    .renderingMode(.original)
                                                    .font(.system(size: 50))
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        selection = index
                                        Store.shared.themeIndexManager.select(at: index)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .font(.body)
    }
}
