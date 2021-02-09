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
    @State private var selection = Store.shared.themeIndexManager.selectedIndex

    @State private var refresh = false
    func theme(at index: Int) -> ThemeData? {
        do{
            return try Store.shared.themeIndexManager.theme(at: index)
        } catch {
            debug(error)
            return nil
        }
    }

    private var listSection: some View {
        ForEach(Store.shared.themeIndexManager.indices.reversed(), id: \.self) { index in
            if let theme = theme(at: index){
                HStack{
                    KeyboardPreview(theme: theme, scale: 0.6)
                        .disabled(true)
                    GeometryReader{geometry in
                        CenterAlignedView{
                            VStack{
                                Spacer()
                                Circle()
                                    .fill(selection == index ? Color.blue : Color.systemGray4)
                                    .frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(Font.system(size: geometry.size.width/3).weight(.bold))
                                            .foregroundColor(.white)
                                    )
                                    .onTapGesture {
                                        selection = index
                                        Store.shared.themeIndexManager.select(at: index)
                                    }
                                Spacer()
                            }
                        }
                    }
                }
                .contextMenu{
                    Button{

                    }label: {
                        Image(systemName: "pencil")
                        Text("編集する")
                    }

                    Button{

                    }label: {
                        Image(systemName: "trash")
                        Text("削除する")
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")){
                    NavigationLink("テーマを作成", destination: ThemeEditView())
                }
                Section(header: Text("選ぶ")){
                    if refresh{
                        listSection
                    }else{
                        listSection
                    }
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .font(.body)
        .onChange(of: storeVariableSection.japaneseKeyboardLayout){_ in
            SettingData.shared.reload() //設定をリロードする
            self.refresh.toggle()
        }
    }
}
