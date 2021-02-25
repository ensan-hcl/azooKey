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

extension CodableActionData{
    var hasAssociatedValue: Bool {
        switch self{
        case .delete(_), .input(_), .moveCursor(_), .moveTab(_), .openApp(_): return true
        case .complete, .exchangeCharacter, .smoothDelete,.toggleCapsLockState, .toggleCursorMovingView, .toggleTabBar, .dismissKeyboard: return false
        }
    }

    var label: LocalizedStringKey {
        switch self{
        case let .delete(value): return "\(String(value))文字削除"
        case .complete: return "確定"
        case .exchangeCharacter: return "大文字/小文字、拗音/濁音/半濁音の切り替え"
        case let .input(value): return "「\(value)」を入力"
        case let .moveCursor(value): return "\(String(value))文字分カーソルを移動"
        case .moveTab(_): return "タブの移動"
        case .smoothDelete: return "文頭まで削除"
        case .toggleCapsLockState: return "Capslockのモードの切り替え"
        case .toggleCursorMovingView: return "カーソルバーの切り替え"
        case .toggleTabBar: return "タブバーの切り替え"
        case .dismissKeyboard: return "キーボードを閉じる"
        case .openApp(_): return "アプリを開く"
        }
    }
}

struct EditingCodableActionData: Identifiable, Equatable {
    typealias ID = UUID
    let id = UUID()
    var data: CodableActionData
    init(_ data: CodableActionData){
        self.data = data
    }

    static func == (lhs: EditingCodableActionData, rhs: EditingCodableActionData) -> Bool {
        return lhs.id == rhs.id && lhs.data == rhs.data
    }
}

struct KeyActionsEditView: View {
    @State private var editMode = EditMode.inactive
    @State private var bottomSheetShown = false
    @Binding private var actions: [EditingCodableActionData]
    private let availableCustards: [String]

    init(_ actions: Binding<[EditingCodableActionData]>, availableCustards: [String]){
        self._actions = actions
        self.availableCustards = availableCustards
    }

    func add(new action: CodableActionData){
        actions.append(EditingCodableActionData(action))
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
                        ForEach($actions){(action: Binding<EditingCodableActionData>) in
                            HStack{
                                VStack(spacing: 20){
                                    if action.wrappedValue.data.hasAssociatedValue{
                                        DisclosureGroup{
                                            switch action.wrappedValue.data{
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
                                            Text(action.wrappedValue.data.label)
                                        }
                                    }else{
                                        Text(action.wrappedValue.data.label)
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
                    Section(header: Text("基本")){
                        Button("タブの移動"){
                            press(.moveTab(.system(.user_japanese)))
                        }
                        Button("タブバーの表示"){
                            press(.toggleTabBar)
                        }
                        Button("文字の入力"){
                            press(.input("😁"))
                        }
                        Button("文字の削除"){
                            press(.delete(1))
                        }
                    }
                    Section(header: Text("高度")){
                        Button("文頭まで削除"){
                            press(.smoothDelete)
                        }
                        Button("カーソル移動"){
                            press(.moveCursor(-1))
                        }
                        Button("入力の確定"){
                            press(.complete)
                        }
                        Button("Capslock"){
                            press(.toggleCapsLockState)
                        }
                        Button("カーソルバーの表示"){
                            press(.toggleCursorMovingView)
                        }
                        Button("キーボードを閉じる"){
                            press(.dismissKeyboard)
                        }
                        Button("アプリを開く"){
                            press(.openApp("azooKey://"))
                        }
                    }
                }
                .foregroundColor(.primary)
            }
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
        actions.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        actions.move(fromOffsets: source, toOffset: destination)
    }

}

struct ActionDeleteEditView: View {
    @Binding private var action: EditingCodableActionData

    internal init(_ action: Binding<EditingCodableActionData>) {
        self._action = action
        if case let .delete(count) = action.wrappedValue.data{
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
    @Binding private var action: EditingCodableActionData

    internal init(_ action: Binding<EditingCodableActionData>) {
        self._action = action
        if case let .input(value) = action.wrappedValue.data{
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
    @Binding private var action: EditingCodableActionData

    internal init(_ action: Binding<EditingCodableActionData>) {
        self._action = action
        if case let .openApp(value) = action.wrappedValue.data{
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
    @Binding private var action: EditingCodableActionData
    private let items: [(label: String, tab: CodableTabData)]
    @State private var selectedTab: CodableTabData = .system(.user_japanese)

    internal init(_ action: Binding<EditingCodableActionData>, availableCustards: [String]) {
        self._action = action
        if case let .moveTab(value) = action.wrappedValue.data{
            self._selectedTab = State(initialValue: value)
        }
        var dict: [(label: String, tab: CodableTabData)] = [
            ("日本語(設定に合わせる)", .system(.user_japanese)),
            ("英語(設定に合わせる)", .system(.user_english)),
            ("記号と数字(フリック入力)", .system(.flick_numbersymbols)),
            ("数字(ローマ字入力)", .system(.qwerty_number)),
            ("記号(ローマ字入力)", .system(.qwerty_symbols)),
            ("日本語(フリック入力)", .system(.flick_japanese)),
            ("日本語(ローマ字入力)", .system(.qwerty_japanese)),
            ("英語(フリック入力)", .system(.flick_english)),
            ("英語(ローマ字入力)", .system(.qwerty_english))
        ]
        availableCustards.forEach{
            dict.insert(($0, .custom($0)), at: 0)
        }
        self.items = dict
    }

    var body: some View {
        Picker(selection: $selectedTab, label: Text("タブを選択")){
            ForEach(items.indices, id: \.self){i in
                Text(LocalizedStringKey(items[i].label)).tag(items[i].tab)
            }
        }
        .onChange(of: selectedTab){value in
            self.action.data = .moveTab(value)
        }
    }
}


struct ActionMoveCursorEditView: View {
    @Binding private var action: EditingCodableActionData

    internal init(_ action: Binding<EditingCodableActionData>) {
        self._action = action
        if case let .moveCursor(count) = action.wrappedValue.data{
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

