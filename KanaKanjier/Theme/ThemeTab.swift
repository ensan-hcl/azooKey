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

    @State private var editViewIndex: Int?
    @State private var editViewEnabled = false

    private func theme(at index: Int) -> ThemeData? {
        do {
            return try manager.theme(at: index)
        } catch {
            debug(error)
            return nil
        }
    }

    private var listSection: some View {
        ForEach(manager.indices.reversed(), id: \.self) { index in
            if let theme = theme(at: index) {
                HStack {
                    KeyboardPreview(theme: theme, scale: 0.6)
                        .disabled(true)
                    GeometryReader {geometry in
                        if manager.selectedIndex == manager.selectedIndexInDarkMode {
                            CenterAlignedView {
                                VStack {
                                    Spacer()
                                    Circle()
                                        .fill(manager.selectedIndex == index ? Color.blue : Color.systemGray4)
                                        .frame(width: geometry.size.width / 1.5, height: geometry.size.width / 1.5)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(Font.system(size: geometry.size.width / 3).weight(.bold))
                                                .foregroundColor(.white)
                                        )
                                    Spacer()
                                }
                                .onTapGesture {
                                    manager.select(at: index)
                                }
                            }
                        } else {
                            CenterAlignedView {
                                VStack {
                                    Spacer()
                                    Circle()
                                        .fill(manager.selectedIndex == index ? Color.blue : Color.systemGray4)
                                        .frame(width: geometry.size.width / 1.5, height: geometry.size.width / 1.5)
                                        .overlay(
                                            Image(systemName: "sun.max.fill")
                                                .font(Font.system(size: geometry.size.width / 3).weight(.bold))
                                                .foregroundColor(.white)
                                        )
                                        .padding()
                                        .onTapGesture {
                                            manager.selectForLightMode(at: index)
                                        }
                                    Circle()
                                        .fill(manager.selectedIndexInDarkMode == index ? Color.blue : Color.systemGray4)
                                        .frame(width: geometry.size.width / 1.5, height: geometry.size.width / 1.5)
                                        .overlay(
                                            Image(systemName: "moon.fill")
                                                .font(Font.system(size: geometry.size.width / 3).weight(.bold))
                                                .foregroundColor(.white)
                                        )
                                        .padding()
                                        .onTapGesture {
                                            manager.selectForDarkMode(at: index)
                                        }
                                    Spacer()
                                }
                            }

                        }
                    }
                    if editViewIndex == index {
                        NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                            EmptyView()
                        }.frame(maxWidth: 1)
                    }
                }
                .contextMenu {
                    if self.manager.selectedIndex == self.manager.selectedIndexInDarkMode {
                        Button {
                            manager.selectForLightMode(at: index)
                        } label: {
                            Image(systemName: "sun.max.fill")
                            // TODO: Localize
                            Text("ライトモードで使用")
                        }
                        Button {
                            manager.selectForDarkMode(at: index)
                        } label: {
                            Image(systemName: "moon.fill")
                            // TODO: Localize
                            Text("ダークモードで使用")
                        }
                    }
                    Button {
                        editViewIndex = index
                        editViewEnabled = true
                    } label: {
                        Image(systemName: "pencil")
                        Text("編集する")
                    }.disabled(index == 0)
                    Button {
                        manager.remove(index: index)
                    } label: {
                        Label("削除する", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(index == 0)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")) {
                    HStack {
                        Button("着せ替えを作成") {
                            editViewIndex = nil
                            editViewEnabled = true
                        }
                        .foregroundColor(.primary)
                        if editViewIndex == nil {
                            NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                                EmptyView()
                            }
                        }
                    }
                }
                Section(header: Text("選ぶ")) {
                    if refresh {
                        listSection
                    } else {
                        listSection
                    }
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
            .onAppear {
                // この位置にonAppearを置く。NavigationViewは画面の遷移中常に現れている。
                self.refresh.toggle()
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: storeVariableSection.japaneseLayout) {_ in
            self.refresh.toggle()
        }
    }
}
