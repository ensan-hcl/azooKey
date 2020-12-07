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
    var body: some View {
        ZStack{
            TabView(selection: $selection){
                TipsTabView()
                    .tabItem {
                        VStack {
                            Image(systemName: "lightbulb.fill").font(.system(size: 20, weight: .light)).foregroundColor(.systemGray2)
                            Text("使い方")
                        }
                    }
                    .tag(0)
                SettingTabView()
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "wrench.fill").font(.system(size: 20, weight: .light)).foregroundColor(.systemGray2)
                            Text("設定")
                        }
                    }
                    .tag(1)
                /*
                TestView()
                    .tabItem {
                        VStack {
                            Image(systemName: "wrench.fill").font(.system(size: 20, weight: .light)).foregroundColor(.systemGray2)
                            Text("設定")
                        }
                    }
                    .tag(2)
                */

            }.fullScreenCover(isPresented: $storeVariableSection.requireFirstOpenView){
                EnableAzooKeyView()
            }            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
