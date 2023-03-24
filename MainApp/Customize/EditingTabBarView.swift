//
//  TabNavigationEditView.swift
//  MainApp
//
//  Created by ensan on 2021/02/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct EditingTabBarItem: Identifiable, Equatable {
    let id = UUID()
    var label: TabBarItemLabelType
    var actions: [CodableActionData]
    var disclosed: Bool

    init(label: TabBarItemLabelType, actions: [CodableActionData], disclosed: Bool = false) {
        self.label = label
        self.actions = actions
        self.disclosed = disclosed
    }
}

struct EditingTabBarView: View {
    @Binding private var manager: CustardManager
    @State private var items: [EditingTabBarItem] = []
    @State private var editMode = EditMode.inactive
    @State private var lastUpdateDate: Date

    init(manager: Binding<CustardManager>) {
        let tabBarData = (try? manager.wrappedValue.tabbar(identifier: 0)) ?? .default
        self._items = State(initialValue: tabBarData.items.indices.map {i in
            EditingTabBarItem(
                label: tabBarData.items[i].label,
                actions: tabBarData.items[i].actions
            )
        })
        self._lastUpdateDate = State(initialValue: tabBarData.lastUpdateDate ?? .now)
        self._manager = manager
    }

    var body: some View {
        Form {
            Text("タブバーを編集し、タブの並び替え、削除、追加を行ったり、文字の入力やカーソルの移動など様々な機能を追加することができます。")
            Section {
                Button(action: add) {
                    Label("アイテムを追加", systemImage: "plus")
                }
            }
            Section(header: Text("アイテム")) {
                DisclosuringList($items) { $item in
                    HStack {
                        Label("ラベル", systemImage: "rectangle.and.pencil.and.ellipsis")
                        Spacer()
                        TabNavigationViewItemLabelEditView("ラベルを設定", label: $item.label)
                    }
                    NavigationLink(destination: CodableActionDataEditor($item.actions, availableCustards: manager.availableCustards)) {
                        Label("アクション", systemImage: "terminal")

                        Text(makeLabelText(item: item))
                            .foregroundColor(.gray)
                    }
                } label: { item in
                    label(labelType: item.label)
                        .contextMenu {
                            Button(role: .destructive) {
                                items.removeAll(where: {$0.id == item.id})
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
        .onAppear {
            if let tabBarData = try? manager.tabbar(identifier: 0), tabBarData.lastUpdateDate != self.lastUpdateDate {
                self.items = tabBarData.items.indices.map {i in
                    EditingTabBarItem(
                        label: tabBarData.items[i].label,
                        actions: tabBarData.items[i].actions
                    )
                }
            }
        }
        .onChange(of: items) {newValue in
            self.save(newValue)
        }
        .navigationBarTitle(Text("タブバーの編集"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .environment(\.editMode, $editMode)
    }

    @ViewBuilder private func label(labelType: TabBarItemLabelType) -> some View {
        switch labelType {
        case let .text(text):
            Text(text)
        case let .imageAndText(value):
            HStack {
                Image(systemName: value.systemName)
                Text(value.text)
            }
        case let .image(image):
            Image(systemName: image)
        }
    }

    private func makeLabelText(item: EditingTabBarItem) -> LocalizedStringKey {
        if let label = item.actions.first?.label {
            if item.actions.count > 1 {
                return "\(label, color: .gray)など"
            } else {
                return "\(label, color: .gray)"
            }
        }
        return "動作なし"
    }

    private func save(_ items: [EditingTabBarItem]) {
        do {
            debug("EditingTabBarView.save")
            let newLastUpdateDate: Date = .now
            let tabBarData = TabBarData(identifier: 0, lastUpdateDate: newLastUpdateDate, items: items.map {
                TabBarItem(label: $0.label, actions: $0.actions)
            })
            try manager.saveTabBarData(tabBarData: tabBarData)
            self.lastUpdateDate = newLastUpdateDate
        } catch {
            debug(error)
        }
    }

    private var editButton: some View {
        Button {
            switch editMode {
            case .inactive:
                editMode = .active
            case .active, .transient:
                editMode = .inactive
            @unknown default:
                editMode = .inactive
            }
        } label: {
            switch editMode {
            case .inactive:
                Text("削除と順番")
            case .active, .transient:
                Text("完了")
            @unknown default:
                Text("完了")
            }
        }
    }

    private func add() {
        withAnimation(Animation.interactiveSpring()) {
            items.append(
                EditingTabBarItem(
                    label: .text("アイテム"),
                    actions: [.moveTab(.system(.user_japanese))]
                )
            )
        }
    }

    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func move(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct TabNavigationViewItemLabelEditView: View {
    init(_ placeHolder: LocalizedStringKey, label: Binding<TabBarItemLabelType>) {
        self.placeHolder = placeHolder
        self._label = label
        switch label.wrappedValue {
        case let .text(text):
            self._labelText = State(initialValue: text)
        case .image:
            break
        case .imageAndText:
            break
        }
    }

    @Binding private var label: TabBarItemLabelType
    @State private var labelText = ""

    private let placeHolder: LocalizedStringKey

    var body: some View {
        TextField(placeHolder, text: $labelText)
            .onChange(of: labelText) {value in
                label = .text(value)
            }
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
    }
}
