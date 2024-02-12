//
//  ThemeTab.swift
//  MainApp
//
//  Created by ensan on 2021/02/04.
//  Copyright © 2021 ensan. All rights reserved.
//

import AzooKeyUtils
import KeyboardViews
import SwiftUI
import SwiftUIUtils
import SwiftUtils

@MainActor
struct ThemeTabView: View {
    @Namespace private var namespace
    @EnvironmentObject private var appStates: MainAppStates
    @State private var manager = ThemeIndexManager.load()

    @State private var editViewIndex: Int?
    @State private var editViewEnabled = false

    private func theme(at index: Int) -> AzooKeyTheme? {
        do {
            return try manager.theme(at: index)
        } catch {
            debug(error)
            return nil
        }
    }

    @MainActor
    private func circle(width: CGFloat, systemName: String, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: width, height: width)
            .overlay(
                Image(systemName: systemName)
                    .font(Font.system(size: width / 2).weight(.bold))
                    .foregroundStyle(.white)
            )
    }

    private var tab: Tab.ExistentialTab {
        switch appStates.japaneseLayout {
        case .flick:
            return .flick_hira
        case .qwerty:
            return .qwerty_hira
        case let .custard(identifier):
            return .custard((try? CustardManager.load().custard(identifier: identifier)) ?? .errorMessage)
        }
    }

    @MainActor @ViewBuilder
    private var listSection: some View {
        let tab = tab
        ForEach(manager.indices.reversed(), id: \.self) { index in
            if let theme = theme(at: index) {
                HStack {
                    ZStack {
                        KeyboardPreview(theme: theme, defaultTab: tab)
                            .disabled(true)
                            .overlay {
                                if manager.selectedIndex == index || manager.selectedIndexInDarkMode == index {
                                    Color.black.opacity(0.3)
                                }
                            }
                            .onTapGesture {
                                if manager.selectedIndex != index && manager.selectedIndexInDarkMode != index {
                                    self.manager.select(at: index)
                                }
                            }
                        if manager.selectedIndex == manager.selectedIndexInDarkMode,
                           manager.selectedIndex == index {
                            circle(width: 80, systemName: "checkmark", color: .blue)
                                .matchedGeometryEffect(id: "selected_theme_checkmark", in: namespace)
                        } else if manager.selectedIndex == index {
                            circle(width: 80, systemName: "sun.max.fill", color: .blue)
                                .matchedGeometryEffect(id: "selected_theme_light", in: namespace)
                        } else if manager.selectedIndexInDarkMode == index {
                            circle(width: 80, systemName: "moon.fill", color: .blue)
                                .matchedGeometryEffect(id: "selected_theme_dark", in: namespace)
                        }
                    }
                    Spacer()
                    VStack {
                        if manager.selectedIndex == manager.selectedIndexInDarkMode {
                            if manager.selectedIndex != index {
                                Button("選択", systemImage: "checkmark") {
                                    manager.select(at: index)
                                }
                            }
                        } else {
                            if manager.selectedIndex != index {
                                Button("ライトモード", systemImage: "sun.max.fill") {
                                    manager.selectForLightMode(at: index)
                                }
                            }
                            if manager.selectedIndexInDarkMode != index {
                                Button("ダークモード", systemImage: "moon.fill") {
                                    manager.selectForDarkMode(at: index)
                                }
                            }
                        }
                        if index != 0 {
                            Button("編集", systemImage: "slider.horizontal.3") {
                                editViewIndex = index
                                editViewEnabled = true
                            }
                        }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(LargeButtonStyle(backgroundColor: .systemGray5))
                    .frame(maxWidth: 100)
                    Spacer()
                    // 編集用
                    if editViewIndex == index {
                        NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                            EmptyView()
                        }.frame(maxWidth: 1)
                    }
                }
                .contextMenu {
                    if self.manager.selectedIndex == self.manager.selectedIndexInDarkMode {
                        Button("ライトモードで使用", systemImage: "sun.max.fill") {
                            manager.selectForLightMode(at: index)
                        }
                        Button("ダークモードで使用", systemImage: "moon.fill") {
                            manager.selectForDarkMode(at: index)
                        }
                    }
                    Button("編集する", systemImage: "slider.horizontal.3") {
                        editViewIndex = index
                        editViewEnabled = true
                    }
                    .disabled(index == 0)
                    Button("削除する", systemImage: "trash", role: .destructive) {
                        manager.remove(index: index)
                    }
                    .disabled(index == 0)
                }
            }
        }
        .animation(.easeIn(duration: 0.15), value: manager.selectedIndex)
        .animation(.easeIn(duration: 0.15), value: manager.selectedIndexInDarkMode)
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
                        .foregroundStyle(.primary)
                        if editViewIndex == nil {
                            NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                                EmptyView()
                            }
                        }
                    }
                }
                Section(header: Text("選ぶ")) {
                    listSection
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }
}
