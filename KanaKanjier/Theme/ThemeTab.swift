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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")){
                    NavigationLink("テーマを作成", destination: ThemeEditView())
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
                    }
        .navigationViewStyle(StackNavigationViewStyle())
        .font(.body)
    }
}
