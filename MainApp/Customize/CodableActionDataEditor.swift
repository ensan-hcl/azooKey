//
//  KeyActionsEditView.swift
//  MainApp
//
//  Created by ensan on 2021/02/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import Combine
import CustardKit
import Foundation
import SwiftUI

extension CodableActionData {
    var hasAssociatedValue: Bool {
        switch self {
        case .delete, .smartDelete, .input, .replaceLastCharacters, .moveCursor, .smartMoveCursor, .moveTab, .launchApplication: return true
        case  .enableResizingMode, .complete, .replaceDefault, .smartDeleteDefault, .toggleCapsLockState, .toggleCursorBar, .toggleTabBar, .dismissKeyboard, .__paste: return false
        }
    }

    var label: LocalizedStringKey {
        switch self {
        case let .input(value): return "「\(value)」を入力"
        case let .moveCursor(value): return "\(String(value))文字分カーソルを移動"
        case let .smartMoveCursor(value): return "\(value.targets.joined(separator: ","))の隣までカーソルを移動"
        case let .delete(value): return "\(String(value))文字削除"
        case let .smartDelete(value): return "\(value.targets.joined(separator: ","))の隣まで削除"
        case .__paste: return "ペーストする"
        case .moveTab: return "タブの移動"
        case .replaceLastCharacters: return "文字を置換"
        case .complete: return "確定"
        case .replaceDefault: return "大文字/小文字、拗音/濁音/半濁音の切り替え"
        case .smartDeleteDefault: return "文頭まで削除"
        case .toggleCapsLockState: return "Caps lockのモードの切り替え"
        case .toggleCursorBar: return "カーソルバーの切り替え"
        case .toggleTabBar: return "タブバーの切り替え"
        case .dismissKeyboard: return "キーボードを閉じる"
        case .enableResizingMode: return "片手モードをオンにする"
        case let .launchApplication(value):
            // TODO: Localize
            switch value.scheme {
            case .azooKey:
                return "azooKey本体アプリを開く"
            case .shortcuts:
                return "ショートカットを実行する"
            }
//        case .setBoolState: return "Bool変数を設定"
//        case .boolSwitch: return "条件分岐"
//        case let .setCursorBar(value):
//            // TODO: LOCALIZE
//            switch value {
//            case .on: return "カーソルバーを表示する"
//            case .off: return "カーソルバーを消す"
//            case .toggle: return "カーソルバーの切り替え"
//            }
//        case let .setCapsLockState(value):
//            // TODO: LOCALIZE
//            switch value {
//            case .on: return "Caps lockのモードのオン"
//            case .off: return "Caps lockのモードのオフ"
//            case .toggle: return "Caps lockのモードの切り替え"
//            }
//        case let .setTabBar(value):
//            // TODO: LOCALIZE
//            switch value {
//            case .on: return "タブバーを表示する"
//            case .off: return "タブバーを消す"
//            case .toggle: return "タブバーの切り替え"
//            }
        }
    }
}

struct EditingCodableActionData: Identifiable, Equatable {
    typealias ID = UUID
    let id = UUID()
    var data: CodableActionData
    init(_ data: CodableActionData) {
        self.data = data
    }
}

struct CodableActionDataEditor: View {
    @State private var editMode = EditMode.inactive
    @State private var bottomSheetShown = false
    @State private var actions: [EditingCodableActionData]
    @Binding private var data: [CodableActionData]
    private let availableCustards: [String]

    init(_ actions: Binding<[CodableActionData]>, availableCustards: [String]) {
        self._data = actions
        self._actions = State(initialValue: actions.wrappedValue.map {EditingCodableActionData($0)})
        self.availableCustards = availableCustards
    }

    private func add(new action: CodableActionData) {
        withAnimation(Animation.interactiveSpring()) {
            actions.append(EditingCodableActionData(action))
        }
    }

    var body: some View {
        GeometryReader {geometry in
            Form {
                Section {
                    Text("上から順に実行されます")
                }
                Section {
                    Button {
                        self.bottomSheetShown = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("アクションを追加")
                        }
                    }
                }
                Section(header: Text("アクション")) {
                    DisclosuringList($actions) { $action in
                        CodableActionEditor(action: $action, availableCustards: availableCustards)
                    } label: { action in
                        Text(action.data.label)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: onMove)
                    .disclosed { item in item.data.hasAssociatedValue }
                }
            }
            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height * 0.7
            ) {
                ActionPicker { action in
                    add(new: action)
                    bottomSheetShown = false
                }
            }
        }
        .onChange(of: actions) {_ in
            self.data = actions.map {$0.data}
        }
        .navigationBarTitle(Text("動作の編集"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .environment(\.editMode, $editMode)
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

    private func delete(at offsets: IndexSet) {
        actions.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        actions.move(fromOffsets: source, toOffset: destination)
    }
}

private struct CodableActionEditor: View {
    init(action: Binding<EditingCodableActionData>, availableCustards: [String]) {
        self.availableCustards = availableCustards
        self._action = action
    }

    @Binding private var action: EditingCodableActionData
    private let availableCustards: [String]

    var body: some View {
        switch action.data {
        case let .input(value):
            ActionEditTextField("入力する文字", action: $action) {value} convert: {.input($0)}
        case let .delete(count):
            ActionEditIntegerTextField("削除する文字数", action: $action) {"\(count)"} convert: {value in
                if let count = Int(value) {
                    return .delete(count)
                }
                return nil
            }
            Text("負の値を指定すると右側の文字を削除します")
        case let .moveCursor(count):
            ActionEditIntegerTextField("移動する文字数", action: $action) {"\(count)"} convert: {value in
                if let count = Int(value) {
                    return .moveCursor(count)
                }
                return nil
            }
            Text("負の値を指定すると左にカーソルが動きます")
        case .moveTab:
            ActionMoveTabEditView($action, availableCustards: availableCustards)
        case .replaceLastCharacters:
            EmptyView()
        case let .launchApplication(item):
            if item.target.hasPrefix("run-shortcut?") {
                ActionEditTextField("オプション", action: $action) {String(item.target.dropFirst("run-shortcut?".count))} convert: {value in
                    .launchApplication(LaunchItem(scheme: .shortcuts, target: "run-shortcut?" + value))
                }
                FallbackLink("オプションの設定方法", destination: URL(string: "https://support.apple.com/ja-jp/guide/shortcuts/apd624386f42/ios")!)
            } else {
                Text("このアプリでは編集できないアクションです")
            }
        default:
            EmptyView()
        }
    }
}

private struct ActionEditTextField: View {
    private let title: LocalizedStringKey
    @Binding private var action: EditingCodableActionData
    private let convert: (String) -> CodableActionData?
    init(_ title: LocalizedStringKey, action: Binding<EditingCodableActionData>, initialValue: () -> String?, convert: @escaping (String) -> CodableActionData?) {
        self.title = title
        self.convert = convert
        self._action = action
        if let initialValue = initialValue() {
            self._value = State(initialValue: initialValue)
        }
    }

    @State private var value = ""

    var body: some View {
        TextField(title, text: $value)
            .onChange(of: value) {value in
                if let data = convert(value) {
                    action.data = data
                }
            }
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
    }
}

private struct ActionEditIntegerTextField: View {
    private let title: LocalizedStringKey
    private let range: ClosedRange<Int>
    @Binding private var action: EditingCodableActionData
    private let convert: (String) -> CodableActionData?
    init(_ title: LocalizedStringKey, action: Binding<EditingCodableActionData>, range: ClosedRange<Int> = .min ... .max, initialValue: () -> String?,  convert: @escaping (String) -> CodableActionData?) {
        self.title = title
        self.range = range
        self.convert = convert
        self._action = action
        if let initialValue = initialValue() {
            self._value = State(initialValue: initialValue)
        }
    }

    @State private var value = ""

    var body: some View {
        IntegerTextField(title, text: $value, range: range)
            .onChange(of: value) {value in
                if let data = convert(value) {
                    action.data = data
                }
            }
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
    }
}

private struct ActionMoveTabEditView: View {
    @Binding private var action: EditingCodableActionData
    private let availableCustards: [String]
    @State private var selectedTab: TabData = .system(.user_japanese)

    init(_ action: Binding<EditingCodableActionData>, availableCustards: [String]) {
        self.availableCustards = availableCustards
        self._action = action
        if case let .moveTab(value) = action.wrappedValue.data {
            self._selectedTab = State(initialValue: value)
        }
    }

    var body: some View {
        AvailableTabPicker(selectedTab, availableCustards: self.availableCustards) {tab in
            self.action.data = .moveTab(tab)
        }
    }
}

extension TabData {
    var label: LocalizedStringKey {
        switch self {
        case let .system(tab):
            switch tab {
            case .user_japanese:
                return "日本語(設定に合わせる)"
            case .user_english:
                return "英語(設定に合わせる)"
            case .flick_japanese:
                return "日本語(フリック入力)"
            case .flick_english:
                return "英語(フリック入力)"
            case .flick_numbersymbols:
                return "記号と数字(フリック入力)"
            case .qwerty_japanese:
                return "日本語(ローマ字入力)"
            case .qwerty_english:
                return "英語(ローマ字入力)"
            case .qwerty_numbers:
                return "数字(ローマ字入力)"
            case .qwerty_symbols:
                return "記号(ローマ字入力)"
            case .last_tab:
                return "最後に表示していたタブ"
            case .__clipboard_history_tab:
                return "クリップボードの履歴"
            }
        case let .custom(identifier):
            return LocalizedStringKey(identifier)
        }
    }
}

struct AvailableTabPicker: View {
    @State private var selectedTab: TabData = .system(.user_japanese)
    private let items: [(label: String, tab: TabData)]
    private let process: (TabData) -> Void

    init(_ initialValue: TabData, availableCustards: [String]? = nil, onChange process: @escaping (TabData) -> Void = {_ in}) {
        self._selectedTab = State(initialValue: initialValue)
        self.process = process
        var dict: [(label: String, tab: TabData)] = [
            ("日本語(設定に合わせる)", .system(.user_japanese)),
            ("英語(設定に合わせる)", .system(.user_english)),
            ("記号と数字(フリック入力)", .system(.flick_numbersymbols)),
            ("数字(ローマ字入力)", .system(.qwerty_numbers)),
            ("記号(ローマ字入力)", .system(.qwerty_symbols)),
            ("最後に表示していたタブ", .system(.last_tab)),
            ("クリップボードの履歴", .system(.__clipboard_history_tab)),
            ("日本語(フリック入力)", .system(.flick_japanese)),
            ("日本語(ローマ字入力)", .system(.qwerty_japanese)),
            ("英語(フリック入力)", .system(.flick_english)),
            ("英語(ローマ字入力)", .system(.qwerty_english))
        ]
        (availableCustards ?? CustardManager.load().availableCustards) .forEach {
            dict.insert(($0, .custom($0)), at: 0)
        }
        self.items = dict
    }

    var body: some View {
        Picker(selection: $selectedTab, label: Text("移動先のタブ")) {
            ForEach(items.indices, id: \.self) {i in
                Text(LocalizedStringKey(items[i].label)).tag(items[i].tab)
            }
        }
        .onChange(of: selectedTab, perform: process)
    }
}

struct CodableLongpressActionDataEditor: View {
    @State private var editMode = EditMode.inactive
    @State private var bottomSheetShown = false
    @State private var addTarget: AddTarget = .start

    private enum AddTarget {
        case `repeat`
        case start
    }

    @State private var startActions: [EditingCodableActionData]
    @State private var repeatActions: [EditingCodableActionData]
    @Binding private var data: CodableLongpressActionData
    private let availableCustards: [String]

    init(_ actions: Binding<CodableLongpressActionData>, availableCustards: [String]) {
        self._data = actions
        self._startActions = State(initialValue: actions.wrappedValue.start.map {EditingCodableActionData($0)})
        self._repeatActions = State(initialValue: actions.wrappedValue.repeat.map {EditingCodableActionData($0)})
        self.availableCustards = availableCustards
    }

    private func add(new action: CodableActionData) {
        withAnimation(Animation.interactiveSpring()) {
            switch self.addTarget {
            case .start:
                startActions.append(EditingCodableActionData(action))
            case .repeat:
                repeatActions.append(EditingCodableActionData(action))
            }
        }
    }

    var body: some View {
        GeometryReader {geometry in
            Form {
                Section {
                    Text("上から順に実行されます")
                }
                Section(header: Text("押し始めのアクション")) {
                    Button {
                        self.addTarget = .start
                        self.bottomSheetShown = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("アクションを追加")
                        }
                    }
                    DisclosuringList($startActions) { $action in
                        CodableActionEditor(action: $action, availableCustards: availableCustards)
                    } label: { action in
                        Text(action.data.label)
                    }
                    .onDelete(perform: {startActions.remove(atOffsets: $0)})
                    .onMove(perform: {startActions.move(fromOffsets: $0, toOffset: $1)})
                    .disclosed { item in item.data.hasAssociatedValue }
                }
                Section(header: Text("押している間のアクション")) {
                    Button {
                        self.addTarget = .repeat
                        self.bottomSheetShown = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("アクションを追加")
                        }
                    }
                    DisclosuringList($repeatActions) { $action in
                        CodableActionEditor(action: $action, availableCustards: availableCustards)
                    } label: { action in
                        Text(action.data.label)
                    }
                    .onDelete(perform: {repeatActions.remove(atOffsets: $0)})
                    .onMove(perform: {repeatActions.move(fromOffsets: $0, toOffset: $1)})
                    .disclosed { item in item.data.hasAssociatedValue }
                }
            }
            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height * 0.7
            ) {
                ActionPicker { action in
                    add(new: action)
                    bottomSheetShown = false
                }
            }
        }
        .onChange(of: startActions) {value in
            self.data.start = value.map {$0.data}
        }
        .onChange(of: repeatActions) {value in
            self.data.repeat = value.map {$0.data}
        }
        .navigationBarTitle(Text("動作の編集"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .environment(\.editMode, $editMode)
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
}

private struct ActionPicker: View {
    private let process: (CodableActionData) -> Void

    init(process: @escaping (CodableActionData) -> Void) {
        self.process = process
    }

    var body: some View {
        Form {
            Section(header: Text("基本")) {
                Button("タブの移動") {
                    process(.moveTab(.system(.user_japanese)))
                }
                Button("タブバーの表示") {
                    process(.toggleTabBar)
                }
                Button("カーソル移動") {
                    process(.moveCursor(-1))
                }
                Button("文字の入力") {
                    process(.input("😁"))
                }
                Button("文字の削除") {
                    process(.delete(1))
                }
                if SemiStaticStates.shared.hasFullAccess {
                    Button("ペースト") {
                        process(.__paste)
                    }
                }
            }
            Section(header: Text("高度")) {
                Button("文頭まで削除") {
                    process(.smartDeleteDefault)
                }
                Button("片手モードをオン") {
                    process(.enableResizingMode)
                }
                Button("入力の確定") {
                    process(.complete)
                }
                Button("Caps lock") {
                    process(.toggleCapsLockState)
                }
                Button("カーソルバーの表示") {
                    process(.toggleCursorBar)
                }
                Button("ショートカットを実行") {
                    process(.launchApplication(.init(scheme: .shortcuts, target: "run-shortcut?name=[名前]&input=[入力]&text=[テキスト]")))
                }
                Button("キーボードを閉じる") {
                    process(.dismissKeyboard)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
