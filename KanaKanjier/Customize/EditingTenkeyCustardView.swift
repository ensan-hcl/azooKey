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

struct EditingTenkeyCustardView: View {
    private static let emptyKeys: [KeyPosition: UserMadeTenKeyCustard.KeyData] = (0..<5).reduce(into: [:]) {dict, x in
        (0..<4).forEach {y in
            dict[.gridFit(x: x, y: y)] = .init(model: .custom(.empty), width: 1, height: 1)
        }
    }
    private static let emptyItem: UserMadeTenKeyCustard = .init(tabName: "新規タブ", rowCount: "5", columnCount: "4", inputStyle: .direct, language: .none, keys: emptyKeys, addTabBarAutomatically: true)

    @Environment(\.presentationMode) private var presentationMode

    private let base: UserMadeTenKeyCustard
    @State private var editingItem: UserMadeTenKeyCustard
    @Binding private var manager: CustardManager

    private var models: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)] {
        return (0..<layout.rowCount).reduce(into: [:]) {dict, x in
            (0..<layout.columnCount).forEach {y in
                if let value = editingItem.keys[.gridFit(x: x, y: y)] {
                    dict[.gridFit(x: x, y: y)] = (value.model.flickKeyModel, value.width, value.height)
                } else {
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
                    if case let .gridFit(x: x, y: y) = item.key {
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

    var body: some View {
        VStack {
            Form {
                TextField("タブの名前", text: $editingItem.tabName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("プレビュー") {
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
                NavigationLink(destination: CustardInterfaceKeyEditor(key: $editingItem.keys[.gridFit(x: x, y: y)].model)) {
                    view.disabled(true)
                }
            }
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
