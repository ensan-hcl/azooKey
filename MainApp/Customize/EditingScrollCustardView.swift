//
//  EditingScrollCustardView.swift
//  MainApp
//
//  Created by ensan on 2021/02/24.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI
import SwiftUIUtils
import SwiftUtils

fileprivate extension CustardInterfaceLayoutScrollValue.ScrollDirection {
    var label: LocalizedStringKey {
        switch self {
        case .vertical:
            return "縦"
        case .horizontal:
            return "横"
        }
    }
}

struct EditingScrollCustardView: CancelableEditor {
    private static let `default`: [CustardKeyPositionSpecifier: CustardInterfaceKey] = [
        .gridScroll(0): .system(.changeKeyboard),
        .gridScroll(1): .custom(.init(design: .init(label: .systemImage("list.bullet"), color: .special), press_actions: [.toggleTabBar], longpress_actions: .none, variations: [])),
        .gridScroll(2): .custom(.init(design: .init(label: .systemImage("delete.left"), color: .special), press_actions: [.delete(1)], longpress_actions: .init(repeat: [.delete(1)]), variations: [])),
        .gridScroll(3): .system(.enter)
    ]
    private static let emptyItem: UserMadeGridScrollCustard = .init(tabName: "", direction: .vertical, columnCount: "", rowCount: "", words: "é\n√\nπ\nΩ", addTabBarAutomatically: true)
    let base: UserMadeGridScrollCustard

    @Environment(\.dismiss) private var dismiss

    @State private var showPreview = false
    @State private var editingItem: UserMadeGridScrollCustard
    @Binding private var manager: CustardManager

    init(manager: Binding<CustardManager>, editingItem: UserMadeGridScrollCustard? = nil) {
        self._manager = manager
        self.base = editingItem ?? Self.emptyItem
        self._editingItem = State(initialValue: self.base)
    }

    var body: some View {
        VStack {
            GeometryReader {geometry in
                VStack {
                    Form {
                        TextField("タブの名前", text: $editingItem.tabName)
                            .submitLabel(.done)
                        Text("一行ずつ登録したい文字や単語を入力してください")
                        Button("プレビュー") {
                            UIApplication.shared.closeKeyboard()
                            showPreview = true
                        }
                        DisclosureGroup("詳細設定") {
                            HStack {
                                Text("スクロール方向")
                                Spacer()
                                Picker("スクロール方向", selection: $editingItem.direction) {
                                    Text("縦").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.vertical)
                                    Text("横").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.horizontal)
                                }
                                .pickerStyle(.segmented)
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
                            Toggle("自動的にタブバーに追加", isOn: $editingItem.addTabBarAutomatically)
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)

                    TextEditor(text: $editingItem.words)
                        .frame(height: geometry.size.height * 0.6)

                }
                BottomSheetView(
                    isOpen: $showPreview,
                    maxHeight: Design.keyboardScreenHeight(upsideComponent: nil, orientation: MainAppDesign.keyboardOrientation) + 40,
                    minHeight: 0
                ) {
                    KeyboardPreview(defaultTab: .custard(makeCustard(data: editingItem)))
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("カスタムタブを作る"), displayMode: .inline)
        .navigationBarItems(
            leading: Button("キャンセル", action: cancel),
            trailing: Button("保存") {
                self.save()
                self.dismiss()
            }
        )
    }

    private func makeCustard(data: UserMadeGridScrollCustard) -> Custard {
        var keys: [CustardKeyPositionSpecifier: CustardInterfaceKey] = Self.default
        // TODO: ここで「|」および「\|」が特殊な動作に充てられていることを明確化する
        for substring in data.words.split(separator: "\n") {
            let target = substring.components(separatedBy: "\\|").map {$0.components(separatedBy: "|")}.reduce(into: [String]()) {array, value in
                if let last = array.last, let first = value.first {
                    array.removeLast()
                    array.append([last, first].joined(separator: "|"))
                    array.append(contentsOf: value.dropFirst())
                } else {
                    array.append(contentsOf: value)
                }
            }
            guard let input = target.first else {
                continue
            }
            let label = target.count > 1 ? target[1] : input
            keys[.gridScroll(.init(keys.count))] = .custom(.init(design: .init(label: .text(label), color: .normal), press_actions: [.input(input)], longpress_actions: .none, variations: []))
        }

        let rowCount = max(Double(data.rowCount) ?? 8, 1)
        let columnCount = max(Double(data.columnCount) ?? 4, 1)
        return Custard(
            identifier: data.tabName.isEmpty ? "new_tab" : data.tabName,
            language: .none,
            input_style: .direct,
            metadata: .init(custard_version: .v1_2, display_name: data.tabName.isEmpty ? "New tab" : data.tabName),
            interface: .init(
                keyStyle: .tenkeyStyle,
                keyLayout: .gridScroll(.init(direction: data.direction, rowCount: rowCount, columnCount: columnCount)),
                keys: keys
            )
        )
    }

    private func save() {
        do {
            try self.manager.saveCustard(
                custard: makeCustard(data: editingItem),
                metadata: .init(origin: .userMade),
                userData: .gridScroll(editingItem),
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
