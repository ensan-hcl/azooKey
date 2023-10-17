//
//  EditingTenkeyCustardView.swift
//  MainApp
//
//  Created by ensan on 2021/04/22.
//  Copyright © 2021 ensan. All rights reserved.
//

import AzooKeyUtils
import CustardKit
import Foundation
import KeyboardViews
import SwiftUI
import SwiftUIUtils
import SwiftUtils

extension CustardInterfaceCustomKey {
    static let empty: Self = .init(design: .init(label: .text(""), color: .normal), press_actions: [], longpress_actions: .none, variations: [])
}

fileprivate extension Dictionary where Key == KeyPosition, Value == UserMadeTenKeyCustard.KeyData {
    subscript(key: Key) -> Value {
        get {
            self[key, default: .init(model: .custom(.empty), width: 1, height: 1)]
        }
        set {
            self[key] = newValue
        }
    }
}

@MainActor
struct EditingTenkeyCustardView: CancelableEditor {
    private static let emptyKey: UserMadeTenKeyCustard.KeyData = .init(model: .custom(.empty), width: 1, height: 1)
    private static let emptyKeys: [KeyPosition: UserMadeTenKeyCustard.KeyData] = (0..<5).reduce(into: [:]) {dict, x in
        (0..<4).forEach {y in
            dict[.gridFit(x: x, y: y)] = emptyKey
        }
    }
    private static let emptyItem: UserMadeTenKeyCustard = .init(tabName: "新規タブ", rowCount: "5", columnCount: "4", inputStyle: .direct, language: .none, keys: emptyKeys, addTabBarAutomatically: true)

    @Environment(\.dismiss) private var dismiss

    let base: UserMadeTenKeyCustard
    @StateObject private var variableStates = VariableStates(clipboardHistoryManagerConfig: ClipboardHistoryManagerConfig(), tabManagerConfig: TabManagerConfig(), userDefaults: UserDefaults.standard)
    @State private var editingItem: UserMadeTenKeyCustard
    @Binding private var manager: CustardManager
    @State private var showPreview = false
    @State private var copiedKey: UserMadeTenKeyCustard.KeyData?
    private var models: [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)] {
        (0..<layout.rowCount).reduce(into: [:]) {dict, x in
            (0..<layout.columnCount).forEach {y in
                if let value = editingItem.keys[.gridFit(x: x, y: y)] {
                    dict[.gridFit(x: x, y: y)] = (value.model.flickKeyModel(extension: AzooKeyKeyboardViewExtension.self), value.width, value.height)
                } else if !editingItem.emptyKeys.contains(.gridFit(x: x, y: y)) {
                    dict[.gridFit(x: x, y: y)] = (CustardInterfaceKey.custom(.empty).flickKeyModel(extension: AzooKeyKeyboardViewExtension.self), 1, 1)
                }
            }
        }
    }

    private var layout: CustardInterfaceLayoutGridValue {
        .init(rowCount: max(Int(editingItem.rowCount) ?? 1, 1), columnCount: max(Int(editingItem.columnCount) ?? 1, 1))
    }

    private var custard: Custard {
        Custard(
            identifier: editingItem.tabName,
            language: editingItem.language,
            input_style: editingItem.inputStyle,
            metadata: .init(
                custard_version: .v1_2,
                display_name: editingItem.tabName
            ),
            interface: .init(
                keyStyle: .tenkeyStyle,
                keyLayout: .gridFit(layout),
                keys: editingItem.keys.reduce(into: [:]) {dict, item in
                    if case let .gridFit(x: x, y: y) = item.key, !editingItem.emptyKeys.contains(item.key) {
                        dict[.gridFit(.init(x: x, y: y, width: item.value.width, height: item.value.height))] = item.value.model
                    }
                }
            )
        )
    }

    init(manager: Binding<CustardManager>, editingItem: UserMadeTenKeyCustard? = nil) {
        self._manager = manager
        self.base = editingItem ?? Self.emptyItem
        self._editingItem = State(initialValue: self.base)
    }

    private func isCovered(at position: (x: Int, y: Int)) -> Bool {
        for x in 0...position.x {
            for y in 0...position.y {
                if x == position.x && y == position.y {
                    continue
                }
                if let model = models[.gridFit(x: x, y: y)] {
                    // 存在範囲にpositionがあれば
                    if x ..< x + model.width ~= position.x && y ..< y + model.height ~= position.y {
                        return true
                    }
                }
            }
        }
        return false
    }

    private var interfaceSize: CGSize {
        .init(width: UIScreen.main.bounds.width, height: Design.keyboardHeight(screenWidth: UIScreen.main.bounds.width, orientation: MainAppDesign.keyboardOrientation))
    }

    var body: some View {
        VStack {
            GeometryReader {_ in
                VStack {
                    Form {
                        TextField("タブの名前", text: $editingItem.tabName)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                        Button("プレビュー") {
                            showPreview = true
                            UIApplication.shared.closeKeyboard()
                        }
                        HStack {
                            Text("縦方向キー数")
                            Spacer()
                            IntegerTextField("縦方向キー数", text: $editingItem.columnCount, range: 1 ... .max)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                        }
                        HStack {
                            Text("横方向キー数")
                            Spacer()
                            IntegerTextField("横方向キー数", text: $editingItem.rowCount, range: 1 ... .max)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                        }
                        Picker("言語", selection: $editingItem.language) {
                            Text("なし").tag(CustardLanguage.none)
                            Text("日本語").tag(CustardLanguage.ja_JP)
                            Text("英語").tag(CustardLanguage.en_US)
                        }
                        Picker("入力方式", selection: $editingItem.inputStyle) {
                            Text("そのまま入力").tag(CustardInputStyle.direct)
                            Text("ローマ字かな入力").tag(CustardInputStyle.roman2kana)
                        }
                        Toggle("自動的にタブバーに追加", isOn: $editingItem.addTabBarAutomatically)
                    }
                    CustardFlickKeysView<AzooKeyKeyboardViewExtension, _>(models: models, tabDesign: .init(width: layout.rowCount, height: layout.columnCount, interfaceSize: interfaceSize, layout: .flick, orientation: MainAppDesign.keyboardOrientation), layout: layout) {(view: FlickKeyView<AzooKeyKeyboardViewExtension>, x: Int, y: Int) in
                        if editingItem.emptyKeys.contains(.gridFit(x: x, y: y)) {
                            if !isCovered(at: (x, y)) {
                                Button {
                                    editingItem.emptyKeys.remove(.gridFit(x: x, y: y))
                                } label: {
                                    view.disabled(true)
                                        .opacity(0)
                                        .overlay(
                                            Rectangle().stroke(style: .init(lineWidth: 2, dash: [5]))
                                        )
                                        .overlay(
                                            Image(systemName: "plus.circle")
                                                .foregroundStyle(.accentColor)
                                        )
                                }
                            }
                        } else {
                            NavigationLink(destination: CustardInterfaceKeyEditor(data: $editingItem.keys[.gridFit(x: x, y: y)])) {
                                view.disabled(true)
                                    .border(Color.primary)
                            }
                            .contextMenu {
                                // TODO: これ、OSのクリップボード使ったほうがいいのかも
                                // TODO: Swap、DuplicateみたいなAPIも追加したい
                                Button {
                                    copiedKey = editingItem.keys[.gridFit(x: x, y: y)]
                                } label: {
                                    Label("コピーする", systemImage: "doc.on.doc")
                                }
                                Button {
                                    if let copiedKey {
                                        editingItem.keys[.gridFit(x: x, y: y)] = copiedKey
                                    }
                                } label: {
                                    Label("ペーストする", systemImage: "doc.on.clipboard")
                                }
                                .disabled(copiedKey == nil)
                                Button {
                                    editingItem.columnCount = Int(editingItem.columnCount)?.advanced(by: 1).description ?? editingItem.columnCount
                                    for px in 0 ..< Int(layout.rowCount) {
                                        for py in (y + 1 ..< Int(layout.columnCount)).reversed() {
                                            editingItem.keys[.gridFit(x: px, y: py + 1)] = editingItem.keys[.gridFit(x: px, y: py)]
                                        }
                                    }
                                    for px in 0 ..< Int(layout.rowCount) {
                                        editingItem.keys[.gridFit(x: px, y: y + 1)] = nil
                                    }
                                    editingItem.emptyKeys = editingItem.emptyKeys.mapSet { item in
                                        switch item {
                                        case .gridFit(x: let px, y: let py) where y + 1 <= py:
                                            return .gridFit(x: px, y: py + 1)
                                        default:
                                            return item
                                        }
                                    }
                                } label: {
                                    Label("下に行を追加", systemImage: "plus")
                                }
                                Button {
                                    editingItem.columnCount = Int(editingItem.columnCount)?.advanced(by: 1).description ?? editingItem.columnCount
                                    for px in 0 ..< Int(layout.rowCount) {
                                        for py in (y ..< Int(layout.columnCount)).reversed() {
                                            editingItem.keys[.gridFit(x: px, y: py + 1)] = editingItem.keys[.gridFit(x: px, y: py)]
                                        }
                                    }
                                    for px in 0 ..< Int(layout.rowCount) {
                                        editingItem.keys[.gridFit(x: px, y: y)] = nil
                                    }
                                    editingItem.emptyKeys = editingItem.emptyKeys.mapSet { item in
                                        switch item {
                                        case .gridFit(x: let px, y: let py) where y <= py:
                                            return .gridFit(x: px, y: py + 1)
                                        default:
                                            return item
                                        }
                                    }
                                } label: {
                                    Label("上に行を追加", systemImage: "plus")
                                }
                                Button {
                                    editingItem.rowCount = Int(editingItem.rowCount)?.advanced(by: 1).description ?? editingItem.rowCount
                                    for px in (x + 1 ..< Int(layout.rowCount)).reversed() {
                                        for py in 0 ..< Int(layout.columnCount) {
                                            editingItem.keys[.gridFit(x: px + 1, y: py)] = editingItem.keys[.gridFit(x: px, y: py)]
                                        }
                                    }
                                    for py in 0 ..< Int(layout.columnCount) {
                                        editingItem.keys[.gridFit(x: x + 1, y: py)] = nil
                                    }
                                    editingItem.emptyKeys = editingItem.emptyKeys.mapSet { item in
                                        switch item {
                                        case .gridFit(x: let px, y: let py) where x + 1 <= px:
                                            return .gridFit(x: px + 1, y: py)
                                        default:
                                            return item
                                        }
                                    }
                                } label: {
                                    Label("右に列を追加", systemImage: "plus")
                                }
                                Button {
                                    editingItem.rowCount = Int(editingItem.rowCount)?.advanced(by: 1).description ?? editingItem.rowCount
                                    for px in (x ..< Int(layout.rowCount)).reversed() {
                                        for py in 0 ..< Int(layout.columnCount) {
                                            editingItem.keys[.gridFit(x: px + 1, y: py)] = editingItem.keys[.gridFit(x: px, y: py)]
                                        }
                                    }
                                    for py in 0 ..< Int(layout.columnCount) {
                                        editingItem.keys[.gridFit(x: x, y: py)] = nil
                                    }
                                    editingItem.emptyKeys = editingItem.emptyKeys.mapSet { item in
                                        switch item {
                                        case .gridFit(x: let px, y: let py) where x <= px:
                                            return .gridFit(x: px + 1, y: py)
                                        default:
                                            return item
                                        }
                                    }
                                } label: {
                                    Label("左に列を追加", systemImage: "plus")

                                }
                                Divider()
                                Button(role: .destructive) {
                                    editingItem.emptyKeys.insert(.gridFit(x: x, y: y))
                                } label: {
                                    Label("削除する", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                                Button(role: .destructive) {
                                    removeRow(y: y)
                                } label: {
                                    Label("この行を削除", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                                Button(role: .destructive) {
                                    removeColumn(x: x)
                                } label: {
                                    Label("この列を削除", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    .environmentObject(variableStates)
                }
                // FIXME: editingItemを更新しても`custard`が変更されない不具合
                BottomSheetView(
                    isOpen: $showPreview,
                    maxHeight: Design.keyboardScreenHeight(upsideComponent: nil, orientation: MainAppDesign.keyboardOrientation) + 40,
                    minHeight: 0
                ) {
                    KeyboardPreview(defaultTab: .custard(custard))
                }
            }
            .onChange(of: layout) {_ in
                updateModel()
            }
            .background(Color.secondarySystemBackground)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Text("カスタムタブを作る"))
            .navigationBarItems(
                leading: Button("キャンセル", role: .cancel, action: {self.cancel()}),
                trailing: Button("保存") {
                    self.save()
                    self.dismiss()
                }
            )
        }
        .onAppear {
            variableStates.setInterfaceSize(orientation: MainAppDesign.keyboardOrientation, screenWidth: SemiStaticStates.shared.screenWidth)
        }
    }

    private func removeColumn(x: Int) {
        for px in x + 1 ..< Int(layout.rowCount) {
            for py in 0 ..< Int(layout.columnCount) {
                editingItem.keys[.gridFit(x: px - 1, y: py)] = editingItem.keys[.gridFit(x: px, y: py)]
            }
        }
        editingItem.rowCount = Int(editingItem.rowCount)?.advanced(by: -1).description ?? editingItem.rowCount
        editingItem.emptyKeys = editingItem.emptyKeys.compactMapSet { item in
            switch item {
            case .gridFit(x: let px, y: _) where px == x:
                return nil
            case .gridFit(x: let px, y: let py) where x + 1 <= px:
                return .gridFit(x: px - 1, y: py)
            default:
                return item
            }
        }
    }

    private func removeRow(y: Int) {
        for px in 0 ..< Int(layout.rowCount) {
            for py in y + 1 ..< Int(layout.columnCount) {
                editingItem.keys[.gridFit(x: px, y: py - 1)] = editingItem.keys[.gridFit(x: px, y: py)]
            }
        }
        editingItem.columnCount = Int(editingItem.columnCount)?.advanced(by: -1).description ?? editingItem.columnCount
        editingItem.emptyKeys = editingItem.emptyKeys.compactMapSet { item in
            switch item {
            case .gridFit(x: _, y: let py) where y == py:
                return nil
            case .gridFit(x: let px, y: let py) where y + 1 <= py:
                return .gridFit(x: px, y: py - 1)
            default:
                return item
            }
        }
    }

    private func updateModel() {
        let layout = layout
        (0..<layout.rowCount).forEach {x in
            (0..<layout.columnCount).forEach {y in
                if !editingItem.keys.keys.contains(.gridFit(x: x, y: y)) {
                    editingItem.keys[.gridFit(x: x, y: y)] = .init(model: .custom(.empty), width: 1, height: 1)
                }
            }
        }
        for key in editingItem.keys.keys {
            guard case let .gridFit(x: x, y: y) = key else {
                continue
            }
            if x < 0 || layout.rowCount <= x || y < 0 || layout.columnCount <= y {
                if editingItem.keys[key] == Self.emptyKey {
                    editingItem.keys[key] = nil
                }
            }
        }
    }

    private func save() {
        do {
            try self.manager.saveCustard(
                custard: custard,
                metadata: .init(origin: .userMade),
                userData: .tenkey(editingItem),
                updateTabBar: editingItem.addTabBarAutomatically
            )
        } catch {
            debug(error)
        }
    }

    func cancel() {
        self.dismiss()
    }
}
