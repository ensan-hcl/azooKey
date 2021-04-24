//
//  EditingTenkeyCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension CustardInterfaceCustomKey {
    static let empty: Self = .init(design: .init(label: .text(""), color: .normal), press_actions: [], longpress_actions: .none, variations: [])
}

fileprivate extension Dictionary where Key == KeyPosition, Value == UserMadeTenKeyCustard.KeyData {
    subscript(key: Key) -> Value {
        get {
            return self[key, default: .init(model: .custom(.empty), width: 1, height: 1)]
        }
        set {
            self[key] = newValue
        }
    }
}

struct EditingTenkeyCustardView: CancelableEditor {
    private static let emptyKey: UserMadeTenKeyCustard.KeyData = .init(model: .custom(.empty), width: 1, height: 1)
    private static let emptyKeys: [KeyPosition: UserMadeTenKeyCustard.KeyData] = (0..<5).reduce(into: [:]) {dict, x in
        (0..<4).forEach {y in
            dict[.gridFit(x: x, y: y)] = emptyKey
        }
    }
    private static let emptyItem: UserMadeTenKeyCustard = .init(tabName: "新規タブ", rowCount: "5", columnCount: "4", inputStyle: .direct, language: .none, keys: emptyKeys, addTabBarAutomatically: true)

    @Environment(\.presentationMode) private var presentationMode

    let base: UserMadeTenKeyCustard
    @State private var editingItem: UserMadeTenKeyCustard
    @Binding private var manager: CustardManager
    @State private var showPreview = false
    private var models: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)] {
        return (0..<layout.rowCount).reduce(into: [:]) {dict, x in
            (0..<layout.columnCount).forEach {y in
                if let value = editingItem.keys[.gridFit(x: x, y: y)] {
                    dict[.gridFit(x: x, y: y)] = (value.model.flickKeyModel, value.width, value.height)
                } else if !editingItem.emptyKeys.contains(.gridFit(x: x, y: y)) {
                    dict[.gridFit(x: x, y: y)] = (CustardInterfaceKey.custom(.empty).flickKeyModel, 1, 1)
                }
            }
        }
    }

    private var layout: CustardInterfaceLayoutGridValue {
        .init(rowCount: max(Int(editingItem.rowCount) ?? 1, 1), columnCount: max(Int(editingItem.columnCount) ?? 1, 1))
    }

    private var custard: Custard {
        return Custard.init(
            identifier: editingItem.tabName,
            language: editingItem.language,
            input_style: editingItem.inputStyle,
            metadata: .init(
                custard_version: .v1_0,
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

    var body: some View {
        VStack {
            GeometryReader {_ in
                VStack {
            Form {
                TextField("タブの名前", text: $editingItem.tabName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("プレビュー") {
                    showPreview = true
                    UIApplication.shared.closeKeyboard()
                }
                HStack {
                    Text("縦方向キー数")
                    Spacer()
                    TextField("縦方向キー数", text: $editingItem.columnCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    Text("横方向キー数")
                    Spacer()
                    TextField("横方向キー数", text: $editingItem.rowCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Picker("言語", selection: $editingItem.language) {
                    Text("なし").tag(CustardLanguage.none)
                    Text("日本語").tag(CustardLanguage.ja_JP)
                    Text("英語").tag(CustardLanguage.en_US)
                }
                Picker("入力方式", selection: $editingItem.inputStyle) {
                    Text("そのまま入力").tag(CustardInputStyle.direct)
                    Text("ローマ字入力").tag(CustardInputStyle.roman2kana)
                }
                Toggle("自動的にタブバーに追加", isOn: $editingItem.addTabBarAutomatically)
            }
            CustardFlickKeysView(models: models, tabDesign: .init(width: layout.rowCount, height: layout.columnCount, layout: .flick, orientation: .vertical), layout: layout, needSuggest: false) {view, x, y in
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
                                        .foregroundColor(.accentColor)
                                )
                        }
                    }
                } else {
                    NavigationLink(destination: CustardInterfaceKeyEditor(data: $editingItem.keys[.gridFit(x: x, y: y)])) {
                        view.disabled(true)
                            .border(Color.primary)
                    }
                    .contextMenu {
                        Button {
                            editingItem.emptyKeys.insert(.gridFit(x: x, y: y))
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("削除する")
                            }
                        }
                    }
                }
            }
                }
            BottomSheetView(
                isOpen: $showPreview,
                maxHeight: Design.shared.keyboardScreenHeight + 40,
                minHeight: 0
            ) {
                ZStack(alignment: .top) {
                    Color.secondarySystemBackground
                    KeyboardPreview(theme: .default, defaultTab: .custard(custard))
                }
            }

        }
        .onChange(of: editingItem.rowCount) {_ in
            updateModel()
        }
        .onChange(of: editingItem.columnCount) {_ in
            updateModel()
        }
        .background(Color.secondarySystemBackground)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(Text("カスタムタブを作る"))
        .navigationBarItems(
            leading: Button("キャンセル", action: cancel),
            trailing: Button("保存") {
                self.save()
                presentationMode.wrappedValue.dismiss()
            }
        )
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
        presentationMode.wrappedValue.dismiss()
    }
}
