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
    @State private var refresh = false
    @State private var manager = ThemeIndexManager.load()

    @State private var editViewIndex: Int? = nil
    @State private var editViewEnabled = false

    func theme(at index: Int) -> ThemeData? {
        do{
            return try manager.theme(at: index)
        } catch {
            debug(error)
            return nil
        }
    }

    private var listSection: some View {
        ForEach(manager.indices.reversed(), id: \.self) { index in
            if let theme = theme(at: index){
                HStack{
                    KeyboardPreview(theme: theme, scale: 0.6)
                        .disabled(true)
                    GeometryReader{geometry in
                        CenterAlignedView{
                            VStack{
                                Spacer()
                                Circle()
                                    .fill(manager.selectedIndex == index ? Color.blue : Color.systemGray4)
                                    .frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(Font.system(size: geometry.size.width/3).weight(.bold))
                                            .foregroundColor(.white)
                                    )
                                Spacer()
                            }
                        }
                    }
                    if editViewIndex == index{
                        NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled){
                            EmptyView()
                        }.frame(maxWidth: 1)
                    }
                }
                .onTapGesture {
                    manager.select(at: index)
                }
                .contextMenu{
                    Button{
                        editViewIndex = index
                        editViewEnabled = true
                    }label: {
                        Image(systemName: "pencil")
                        Text("編集する")
                    }.disabled(index == 0)

                    Button{
                        manager.remove(index: index)
                    }label: {
                        Image(systemName: "trash")
                        Text("削除する")
                    }.disabled(index == 0)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")){
                    HStack{
                            Button{
                                editViewIndex = nil
                                editViewEnabled = true
                            }label: {
                                Text("着せ替えを作成")
                                    .foregroundColor(.primary)
                            }
                            if editViewIndex == nil{
                                NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled){
                                    EmptyView()
                                }
                            }
                    }
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
            .onAppear{
                //この位置にonAppearを置く。NavigationViewは画面の遷移中常に現れている。
                self.refresh.toggle()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: storeVariableSection.japaneseLayout){_ in
            SettingData.shared.reload() //設定をリロードする
            self.refresh.toggle()
        }
    }
}
