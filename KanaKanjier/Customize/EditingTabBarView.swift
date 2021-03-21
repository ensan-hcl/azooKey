//
//  TabNavigationEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct EditingTabBarItem: Identifiable, Equatable {
    let id = UUID()
    var label: TabBarItemLabelType
    var actions: [CodableActionData]
    var disclosed: Bool

    init(label: TabBarItemLabelType, actions: [CodableActionData], disclosed: Bool = false){
        self.label = label
        self.actions = actions
        self.disclosed = disclosed
    }
}

struct EditingTabBarView: View {
    @Binding private var manager: CustardManager
    @Binding private var tabBarData: TabBarData
    @State private var items: [EditingTabBarItem] = []
    @State private var editMode = EditMode.inactive

    init(tabBarData: Binding<TabBarData>, manager: Binding<CustardManager>){
        self._items = State(initialValue: tabBarData.wrappedValue.items.indices.map{i in
            EditingTabBarItem(
                label: tabBarData.wrappedValue.items[i].label,
                actions: tabBarData.wrappedValue.items[i].actions
            )
        })
        self._tabBarData = tabBarData
        self._manager = manager
    }

    var body: some View {
        Form {
            Section{
                Button{
                    withAnimation(Animation.interactiveSpring()){
                        items.append(
                            EditingTabBarItem(
                                label: .text("アイテム"),
                                actions: [.moveTab(.system(.user_japanese))]
                            )
                        )
                    }
                } label: {
                    HStack{
                        Image(systemName: "plus")
                        Text("アイテムを追加")
                    }
                }
            }

            Section(header: Text("アイテム")){
                List{
                    ForEach($items){item in
                        HStack{
                            VStack(spacing: 20){
                                DisclosureGroup{
                                    HStack{
                                        Text("表示")
                                        Spacer()
                                        TabNavigationViewItemLabelEditView("ラベルを設定", label: item.label)
                                    }
                                    NavigationLink(destination: CodableActionDataEditor(item.actions, availableCustards: manager.availableCustards)){
                                        Text("押した時の動作")
                                        Spacer()
                                        Text(makeLabelText(item: item.wrappedValue))
                                            .foregroundColor(.gray)
                                    }
                                } label: {
                                    switch item.wrappedValue.label{
                                    case let .text(text):
                                        Text(text)
                                    case let .imageAndText(value):
                                        HStack{
                                            Image(systemName: value.systemName)
                                            Text(value.text)
                                        }
                                    case let .image(image):
                                        Image(systemName: image)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: onMove)
                }
            }
        }
        .onDisappear{
            self.save()
        }
        .navigationBarTitle(Text("タブバーの編集"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .environment(\.editMode, $editMode)
    }

    private func makeLabelText(item: EditingTabBarItem) -> LocalizedStringKey {
        if let label = item.actions.first?.label{
            if item.actions.count > 1{
                return "\(label, color: .gray)など"
            }else{
                return "\(label, color: .gray)"
            }
        }
        return "動作なし"
    }

    private func save(){
        do{
            debug("セーブする！", self.items)
            self.tabBarData = TabBarData(identifier: tabBarData.identifier, items: self.items.map{
                TabBarItem(label: $0.label, actions: $0.actions)
            })
            try manager.saveTabBarData(tabBarData: self.tabBarData)
        } catch {
            debug(error)
        }
    }

    private var editButton: some View {
        Button{
            switch editMode{
            case .inactive:
                editMode = .active
            case .active, .transient:
                editMode = .inactive
            @unknown default:
                editMode = .inactive
            }
        } label: {
            switch editMode{
            case .inactive:
                Text("削除と順番")
            case .active, .transient:
                Text("完了")
            @unknown default:
                Text("完了")
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct TabNavigationViewItemLabelEditView: View {
    internal init(_ placeHolder: LocalizedStringKey, label: Binding<TabBarItemLabelType>) {
        self.placeHolder = placeHolder
        self._label = label
        switch label.wrappedValue{
        case let .text(text):
            self._labelText = State(initialValue: text)
        case let .image(systemName: image):
            break
        case let .imageAndText(value):
            break
        }
    }

    @Binding private var label: TabBarItemLabelType
    @State private var labelText = ""

    private let placeHolder: LocalizedStringKey

    var body: some View {
        TextField(placeHolder, text: $labelText)
            .onChange(of: labelText){value in
                label = .text(value)
            }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
