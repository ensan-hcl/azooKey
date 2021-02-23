//
//  KeyActionsEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class EditingCodableActionData: Identifiable, Equatable, ObservableObject {
    typealias ID = UUID
    let id = UUID()
    @Published var data: CodableActionData
    init(_ data: CodableActionData){
        self.data = data
    }

    static func == (lhs: EditingCodableActionData, rhs: EditingCodableActionData) -> Bool {
        return lhs.id == rhs.id && lhs.data == rhs.data
    }
}


final class EditingCodableActions: Equatable, ObservableObject {
    @Published var list: [EditingCodableActionData]
    init(_ list: [EditingCodableActionData]){
        self.list = list
    }

    static func == (lhs: EditingCodableActions, rhs: EditingCodableActions) -> Bool {
        return lhs.list == rhs.list
    }
}

struct KeyActionsEditView: View {
    @Binding private var item: EditingTabBarItem
    @State private var editMode = EditMode.inactive
    @State private var bottomSheetShown = false
    @StateObject private var actions: EditingCodableActions
    private let availableCustards: [String]

    init(_ item: Binding<EditingTabBarItem>, actions: EditingCodableActions, availableCustards: [String]){
        self._item = item
        self._actions = StateObject(wrappedValue: actions)
        self.availableCustards = availableCustards
    }

    func add(new action: CodableActionData){
        actions.list.append(EditingCodableActionData(action))
    }

    var body: some View {
        GeometryReader{geometry in
            Form {
                Section{
                    Text("上から順に実行されます")
                }
                Section{
                    Button{
                        self.bottomSheetShown = true
                    } label: {
                        HStack{
                            Image(systemName: "plus")
                            Text("アクションを追加")
                        }
                    }
                }
                Section(header: Text("アクション")){
                    List{
                        ForEach(actions.list){(action: EditingCodableActionData) in
                            HStack{
                                VStack(spacing: 20){
                                    if action.data.hasAssociatedValue{
                                        DisclosureGroup{
                                            switch action.data{
                                            case .delete:
                                                ActionDeleteEditView(action)
                                            case .input:
                                                ActionInputEditView(action)
                                            case .moveCursor:
                                                ActionMoveCursorEditView(action)
                                                Text("負の値を指定すると左にカーソルが動きます")
                                            case .moveTab:
                                                ActionMoveTabEditView(action, availableCustards: availableCustards)
                                            case .openApp:
                                                ActionOpenAppEditView(action)
                                                Text("このアクションはiOSのメジャーアップデートで利用できなくなる可能性があります")
                                            default:
                                                EmptyView()
                                            }
                                        } label :{
                                            Text(action.data.label)
                                        }
                                    }else{
                                        Text(action.data.label)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: onMove)
                    }
                }
            }
            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height * 0.7
            ) {
                let press: (CodableActionData) -> () = { action in
                    add(new: action)
                    bottomSheetShown = false
                }
                Form{
                    Button("タブの移動"){
                        press(.moveTab(.system(.user_hira)))
                    }
                    Button("文字の入力"){
                        press(.input("😁"))
                    }
                    Button("文字の削除"){
                        press(.delete(1))
                    }
                    Button("文頭まで削除"){
                        press(.smoothDelete)
                    }
                    Button("タブバーの表示"){
                        press(.toggleTabBar)
                    }
                    Button("カーソル移動"){
                        press(.moveCursor(-1))
                    }
                    Button("Capslock"){
                        press(.toggleCapsLockState)
                    }
                    Button("カーソル移動画面の表示"){
                        press(.toggleCursorMovingView)
                    }
                    Button("アプリを開く"){
                        press(.openApp("azooKey://"))
                    }
                }
                .foregroundColor(.primary)
                .listRowBackground(Color.gray)
            }
        }
        .onChange(of: actions){value in
            debug("内部的チェンジ")
            item.actions = actions
        }
        .navigationBarTitle(Text("動作の編集"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .environment(\.editMode, $editMode)
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
        actions.list.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        actions.list.move(fromOffsets: source, toOffset: destination)
    }

}

struct ActionDeleteEditView: View {
    @ObservedObject private var action: EditingCodableActionData

    internal init(_ action: EditingCodableActionData) {
        self.action = action
        if case let .delete(count) = action.data{
            self._value = State(initialValue: "\(count)")
        }
    }

    @State private var value = ""

    var body: some View {
        TextField("削除する文字数", text: $value)
            .onChange(of: value){value in
                if let count = Int(value){
                    action.data = .delete(max(count, 0))
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct ActionInputEditView: View {
    @ObservedObject private var action: EditingCodableActionData

    internal init(_ action: EditingCodableActionData) {
        self.action = action
        if case let .input(value) = action.data{
            self._value = State(initialValue: "\(value)")
        }
    }

    @State private var value = ""

    var body: some View {
        TextField("入力する文字", text: $value)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: value){value in
                action.data = .input(value)
            }
    }
}

struct ActionOpenAppEditView: View {
    @ObservedObject private var action: EditingCodableActionData

    internal init(_ action: EditingCodableActionData) {
        self.action = action
        if case let .openApp(value) = action.data{
            self._value = State(initialValue: "\(value)")
        }
    }

    @State private var value = ""

    var body: some View {
        TextField("URL Scheme", text: $value)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: value){value in
                action.data = .openApp(value)
            }
    }
}


struct ActionMoveTabEditView: View {
    @ObservedObject private var action: EditingCodableActionData
    private let items: [(label: String, tab: CodableTabData)]
    @State private var selectedTab: CodableTabData = .system(.user_hira)

    internal init(_ action: EditingCodableActionData, availableCustards: [String]) {
        self.action = action
        if case let .moveTab(value) = action.data{
            self._selectedTab = State(initialValue: value)
        }
        var dict: [(label: String, tab: CodableTabData)] = [
            ("日本語(設定に合わせる)", .system(.user_hira)),
            ("英語(設定に合わせる)", .system(.user_abc)),
            ("記号と数字(フリック入力)", .system(.flick_numbersymbols)),
            ("数字(ローマ字入力)", .system(.qwerty_number)),
            ("記号(ローマ字入力)", .system(.qwerty_symbols)),
            ("日本語(フリック入力)", .system(.flick_hira)),
            ("日本語(ローマ字入力)", .system(.qwerty_hira)),
            ("英語(フリック入力)", .system(.flick_abc)),
            ("英語(ローマ字入力)", .system(.qwerty_abc))
        ]
        availableCustards.forEach{
            dict.insert(($0, .custom($0)), at: 0)
        }
        self.items = dict
    }

    var body: some View {
        Picker(selection: $selectedTab, label: Text("タブを選択")){
            ForEach(items.indices, id: \.self){i in
                Text(items[i].label).tag(items[i].tab)
            }
        }
        .onChange(of: selectedTab){value in
            self.action.data = .moveTab(value)
        }
    }
}


struct ActionMoveCursorEditView: View {
    @ObservedObject private var action: EditingCodableActionData

    internal init(_ action: EditingCodableActionData) {
        self.action = action
        if case let .moveCursor(count) = action.data{
            self._value = State(initialValue: "\(count)")
        }
    }

    @State private var value = ""

    var body: some View {
        TextField("移動する文字数", text: $value)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: value){ value in
                if let count = Int(value){
                    action.data = .moveCursor(count)
                }
            }
    }
}

