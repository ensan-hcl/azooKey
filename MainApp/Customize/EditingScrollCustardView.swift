//
//  EditingScrollCustardView.swift
//  MainApp
//
//  Created by ensan on 2021/02/24.
//  Copyright © 2021 ensan. All rights reserved.
//

import AzooKeyUtils
import CustardKit
import Foundation
import UniformTypeIdentifiers
import KeyboardViews
import SwiftUI
import SwiftUIUtils
import SwiftUtils

fileprivate extension CustardInterfaceLayoutScrollValue.ScrollDirection {
    var label: LocalizedStringKey {
        switch self {
        case .vertical:
            "縦"
        case .horizontal:
            "横"
        }
    }
}

@MainActor
struct EditingScrollCustardView: CancelableEditor {
    private static let emptyItem: UserMadeGridScrollCustard = .init(
        tabName: "",
        direction: .vertical,
        columnCount: "4",
        rowCount: "4",
        keys: [
            .init(model: .system(.changeKeyboard), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .systemImage("list.bullet"), color: .special), press_actions: [.toggleTabBar], longpress_actions: .none, variations: [])), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .systemImage("delete.left"), color: .special), press_actions: [.delete(1)], longpress_actions: .init(repeat: [.delete(1)]), variations: [])), width: 1, height: 1),
            .init(model: .system(.enter), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .text("おはよう"), color: .normal), press_actions: [.input("おはよう")], longpress_actions: .none, variations: [])), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .text("こんにちは"), color: .normal), press_actions: [.input("こんにちは")], longpress_actions: .none, variations: [])), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .text("おつかれさま"), color: .normal), press_actions: [.input("おつかれさま")], longpress_actions: .none, variations: [])), width: 1, height: 1),
            .init(model: .custom(.init(design: .init(label: .text("おやすみ"), color: .normal), press_actions: [.input("おやすみ")], longpress_actions: .none, variations: [])), width: 1, height: 1),
        ],
        addTabBarAutomatically: true
    )
    let base: UserMadeGridScrollCustard

    @Environment(\.dismiss) private var dismiss

    @State private var showPreview = false
    @State private var editingItem: UserMadeGridScrollCustard
    @Binding private var manager: CustardManager
    @State private var addingItem = ""
    @State private var dragFrom: UUID?
    @StateObject private var variableStates = VariableStates(clipboardHistoryManagerConfig: ClipboardHistoryManagerConfig(), tabManagerConfig: TabManagerConfig(), userDefaults: UserDefaults.standard)

    init(manager: Binding<CustardManager>, editingItem: UserMadeGridScrollCustard? = nil) {
        self._manager = manager
        self.base = editingItem ?? Self.emptyItem
        self._editingItem = State(initialValue: self.base)
    }
    
    private var interfaceSize: CGSize {
        .init(width: UIScreen.main.bounds.width, height: Design.keyboardHeight(screenWidth: UIScreen.main.bounds.width, orientation: MainAppDesign.keyboardOrientation))
    }

    var body: some View {
        VStack {
            Form {
                TextField("タブの名前", text: $editingItem.tabName)
                    .submitLabel(.done)
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
            HStack {
                Spacer()
                if showPreview {
                    Button("閉じる", systemImage: "xmark.circle") {
                        showPreview = false
                    }
                    .font(.title)
                } else {
                    Button("プレビュー", systemImage: "eye") {
                        UIApplication.shared.closeKeyboard()
                        showPreview = true
                    }
                    .font(.title)
                }
            }
            .labelStyle(.iconOnly)
            .padding(.horizontal, 8)
            if showPreview {
                KeyboardPreview(defaultTab: .custard(makeCustard(data: editingItem)))
            } else {
                HStack {
                    TextField("登録する文字", text: $addingItem)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                    Button("追加", systemImage: "plus") {
                        guard !self.addingItem.isEmpty else {
                            return
                        }
                        self.editingItem.keys.append(
                            .init(
                                model: .custom(
                                    .init(
                                        design: .init(label: .text(addingItem), color: .normal),
                                        press_actions: [.input(addingItem)],
                                        longpress_actions: .none,
                                        variations: []
                                    )
                                ),
                                width: 1,
                                height: 1
                            )
                        )
                        self.addingItem = ""
                    }
                    .disabled(self.addingItem.isEmpty)
                    .labelStyle(.titleOnly)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.systemGray5)
                    }
                }
                .padding(.horizontal, 5)
                CustardScrollKeysView<AzooKeyKeyboardViewExtension, UUID, _>(
                    models: self.editingItem.keys.map {
                        ($0.model, $0.id)
                    },
                    tabDesign: .init(width: Double(editingItem.rowCount) ?? 4, height: Double(editingItem.columnCount) ?? 8, interfaceSize: interfaceSize, orientation: .vertical),
                    layout: .init(
                            direction: editingItem.direction,
                            rowCount: Double(editingItem.rowCount) ?? 4,
                            columnCount: Double(editingItem.columnCount) ?? 8
                        )
                    ) {(view, keyId) in
                        if let itemIndex = editingItem.keys.firstIndex(where: {$0.id == keyId}) {
                            NavigationLink(destination: CustardInterfaceKeyEditor(data: $editingItem.keys[itemIndex], target: .simple)) {
                                view.disabled(true)
                            }
                            .onDrag {
                                self.dragFrom = keyId
                                return NSItemProvider(contentsOf: URL(string: "\(keyId)")!)!
                            }
                            .onDrop(of: [.url], delegate: DropViewDelegate {
                                //from
                                guard let fromIndex = editingItem.keys.firstIndex (where: {$0.id == self.dragFrom}),
                                      let toIndex = editingItem.keys.firstIndex (where: {$0.id == keyId}) else {
                                    return
                                }
                                editingItem.keys.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                            })
                            .contextMenu {
                                Button("削除する", systemImage: "trash", role: .destructive) {
                                    self.editingItem.keys.removeAll {
                                        $0.id == keyId
                                    }
                                }
                            }
                        }
                  }
                    .environmentObject(variableStates)
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(Text("カスタムタブを作る"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("キャンセル", role: .cancel, action: {self.cancel()})
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    self.save()
                    self.dismiss()
                }
            }
        }
    }

    private func makeCustard(data: UserMadeGridScrollCustard) -> Custard {
        var keys: [CustardKeyPositionSpecifier: CustardInterfaceKey] = [:]
        for (index, keyData) in zip(data.keys.indices, data.keys) {
            let position: CustardKeyPositionSpecifier = .gridScroll(GridScrollPositionSpecifier(index))
            keys[position] = keyData.model
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

private struct DropViewDelegate: DropDelegate {
    let onMove: () -> ()

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        withAnimation(.default) {
            self.onMove()
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
