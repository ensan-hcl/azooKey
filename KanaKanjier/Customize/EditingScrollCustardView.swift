//
//  EditingScrollCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/24.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct EditingItem{
    init(words: String = "é\n√\nπ\nΩ", identifier: String = "", columnKeyCount: String = "", rowKeyCount: String = "", direction: CustardInterfaceLayoutScrollValue.ScrollDirection = .vertical) {
        self.words = words
        self.identifier = identifier
        self.columnKeyCount = columnKeyCount
        self.rowKeyCount = rowKeyCount
        self.direction = direction
    }

    init?(data: UserMadeCustard){
        if case let .gridScroll(value) = data{
            self = EditingItem(words: value.words, identifier: value.tabName, columnKeyCount: value.columnCount, rowKeyCount: value.screenRowCount, direction: value.direction)
        }else{
            return nil
        }
    }


    var words: String = """
    é
    √
    π
    Ω
    """
    var identifier = ""
    var columnKeyCount = ""
    var rowKeyCount = ""
    var direction = CustardInterfaceLayoutScrollValue.ScrollDirection.vertical

}

fileprivate extension CustardInterfaceLayoutScrollValue.ScrollDirection{

    var label: LocalizedStringKey {
        switch self{
        case .vertical:
            return "縦"
        case .horizontal:
            return "横"
        }
    }

}
struct EditingScrollCustardView: View {
    private let base: [CustardKeyPositionSpecifier: CustardInterfaceKey] = [
        .grid_scroll(0): .system(.change_keyboard),
        .grid_scroll(1): .custom(.init(design: .init(label: .systemImage("list.dash"), color: .special), press_action: [.toggleTabBar], longpress_action: [], variation: [])),
        .grid_scroll(2): .custom(.init(design: .init(label: .systemImage("delete.left"), color: .special), press_action: [.delete(1)], longpress_action: [.delete(1)], variation: [])),
        .grid_scroll(3): .system(.enter),
    ]

    @Environment(\.presentationMode) private var presentationMode

    @State private var showPreview = false
    @State private var editingItems = EditingItem()

    @Binding private var manager: CustardManager

    init(manager: Binding<CustardManager>, editingItem: EditingItem? = nil){
        self._manager = manager
        if let editingItem = editingItem{
            self._editingItems = State(initialValue: editingItem)
        }
    }

    var body: some View {
        VStack{
            GeometryReader{geometry in
                VStack{
                    Form{
                        TextField("タブの名前", text: $editingItems.identifier)
                        Text("一行ずつ登録したい文字や単語を入力してください")
                        Button("プレビュー"){
                            UIApplication.shared.closeKeyboard()
                            showPreview = true
                        }
                        DisclosureGroup{
                            HStack{
                                Text("スクロール方向")
                                Spacer()
                                Picker("スクロール方向", selection: $editingItems.direction){
                                    Text("縦").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.vertical)
                                    Text("横").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.horizontal)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            HStack{
                                Text("一列のキー数")
                                Spacer()
                                TextField("一列のキー数", text: $editingItems.columnKeyCount)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            HStack{
                                Text("画面\(editingItems.direction.label)方向のキー数")
                                Spacer()
                                TextField("画面\(editingItems.direction.label)方向のキー数", text: $editingItems.rowKeyCount).keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                        } label: {
                            Text("詳細設定")
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)

                    TextEditor(text: $editingItems.words)
                        .frame(height: geometry.size.height * 0.6)

                }
                BottomSheetView(
                    isOpen: $showPreview,
                    maxHeight: Design.shared.keyboardScreenHeight + 40,
                    minHeight: 0
                ) {
                    ZStack(alignment: .top){
                        Color(.secondarySystemBackground)
                        KeyboardPreview(theme: .default, defaultTab: .custard(makeCustard(data: editingItems)))
                    }
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("カスタムタブを作る"), displayMode: .inline)
        .navigationBarItems(
            leading: Button("キャンセル"){
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("保存"){
                self.save()
                presentationMode.wrappedValue.dismiss()
            })
    }

    func makeCustard(data: EditingItem) -> Custard {
        var keys: [CustardKeyPositionSpecifier: CustardInterfaceKey] = base

        for substring in data.words.split(separator: "\n"){
            let string = String(substring)
            keys[.grid_scroll(.init(keys.count))] = .custom(.init(design: .init(label: .text(string), color: .normal), press_action: [.input(string)], longpress_action: [], variation: []))
        }

        let columnKeyCount = max(Int(data.columnKeyCount) ?? 8, 1)
        let rowKeyCount = max(Double(data.rowKeyCount) ?? 4, 1)
        debug(data.identifier, data.identifier.isEmpty ? "new_tab" : data.identifier)
        return Custard(
            custard_version: .v1_0,
            identifier: data.identifier.isEmpty ? "new_tab" : data.identifier,
            display_name: data.identifier.isEmpty ? "新しいカスタムタブ" : data.identifier,
            language: .undefined,
            input_style: .direct,
            interface: .init(
                key_style: .flick,
                key_layout: .gridScroll(.init(direction: data.direction, columnKeyCount: columnKeyCount, screenRowKeyCount: rowKeyCount)),
                keys: keys
            )
        )
    }

    func save(){
        do{
            try self.manager.saveCustard(
                custard: makeCustard(data: editingItems),
                metadata: .init(origin: .userMade),
                userData: .gridScroll(
                    .init(
                        tabName: editingItems.identifier,
                        direction: editingItems.direction,
                        columnCount: editingItems.columnKeyCount,
                        screenRowCount: editingItems.rowKeyCount,
                        words: editingItems.words
                    )
                )
            )
        }catch{
            debug(error)
        }
    }
}
