//
//  EditingTenkeyCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private struct KeysKeyData: Hashable {
    var model: CustardInterfaceKey
    var width: Int
    var height: Int
}

extension CustardInterfaceCustomKey {
    static let empty: Self = .init(design: .init(label: .text(""), color: .normal), press_actions: [], longpress_actions: .none, variations: [])
}

fileprivate extension Dictionary where Key == KeyPosition, Value == KeysKeyData {
    subscript(key: Key) -> KeysKeyData {
        get {
            return self[key, default: .init(model: .custom(.empty), width: 1, height: 1)]
        }
        set {
            self[key] = newValue
        }
    }
}

// TODO: CancelableEditorへの準拠
struct EditingTenkeyCustardView: View {
    private static let emptyKey: CustardInterfaceKey = .custom(.init(design: .init(label: .text(""), color: .normal), press_actions: [], longpress_actions: .none, variations: []))
    private static let `default` = Custard.init(
        identifier: "new_tab",
        language: .none,
        input_style: .direct,
        metadata: .init(
            custard_version: .v1_0,
            display_name: "新規タブ"
        ),
        interface: .init(
            keyStyle: .tenkeyStyle,
            keyLayout: .gridFit(.init(rowCount: 5, columnCount: 4)),
            keys: (0..<5).reduce(into: [:]) {dict, x in
                (0..<4).forEach {y in
                    dict[.gridFit(.init(x: x, y: y))] = emptyKey
                }
            }
        )
    )
    @State private var editingItem = UserMadeTenKeyCustard(tabName: "新規タブ", rowCount: "5", columnCount: "4", inputStyle: .direct, language: .none, addTabBarAutomatically: true)
    @State private var keys: [KeyPosition: KeysKeyData] = Self.default.interface.keys.reduce(into: [:]) {dict, item in
        if case let .gridFit(value) = item.key {
            dict[.gridFit(x: value.x, y: value.y)] = .init(model: item.value, width: value.width, height: value.height)
        }
    }

    private var models: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)] {
        return (0..<layout.rowCount).reduce(into: [:]) {dict, x in
            (0..<layout.columnCount).forEach {y in
                if let value = keys[.gridFit(x: x, y: y)] {
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

    init(manager: Binding<CustardManager>) {
    }

    var body: some View {
        VStack {
            Form {
                Button("プレビュー") {
                    UIApplication.shared.closeKeyboard()
                }
                DisclosureGroup("詳細設定") {
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
                    Text("入力方式")
                }
            }
            CustardFlickKeysView(models: models, tabDesign: .init(width: layout.rowCount, height: layout.columnCount, layout: .flick, orientation: .vertical), layout: layout, needSuggest: false) {view, x, y in
                NavigationLink(destination: CustardInterfaceKeyEditor(key: $keys[.gridFit(x: x, y: y)].model)) {
                    view.disabled(true)
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(Text("カスタムタブを作る"))
    }
}
