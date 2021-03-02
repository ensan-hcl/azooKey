//
//  EditingScrollCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/24.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

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
        .grid_scroll(3): .system(.enter(1)),
    ]

    @Environment(\.presentationMode) private var presentationMode

    @State private var showPreview = false
    @State private var editingItem = UserMadeGridScrollCustard(tabName: "", direction: .vertical, columnCount: "", screenRowCount: "", words: "é\n√\nπ\nΩ", addTabBarAutomatically: true)
    @Binding private var manager: CustardManager

    init(manager: Binding<CustardManager>, editingItem: UserMadeGridScrollCustard? = nil){
        self._manager = manager
        if let editingItem = editingItem{
            self._editingItem = State(initialValue: editingItem)
        }
    }

    var body: some View {
        VStack{
            GeometryReader{geometry in
                VStack{
                    Form{
                        TextField("タブの名前", text: $editingItem.tabName)
                        Text("一行ずつ登録したい文字や単語を入力してください")
                        Button("プレビュー"){
                            UIApplication.shared.closeKeyboard()
                            showPreview = true
                        }
                        DisclosureGroup{
                            HStack{
                                Text("スクロール方向")
                                Spacer()
                                Picker("スクロール方向", selection: $editingItem.direction){
                                    Text("縦").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.vertical)
                                    Text("横").tag(CustardInterfaceLayoutScrollValue.ScrollDirection.horizontal)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            switch editingItem.direction{
                            case .horizontal:
                                HStack{
                                    Text("縦方向キー数")
                                    Spacer()
                                    TextField("縦方向キー数", text: $editingItem.columnCount)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                HStack{
                                    Text("横方向キー数")
                                    Spacer()
                                    TextField("横方向キー数", text: $editingItem.screenRowCount).keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            case .vertical:
                                HStack{
                                    Text("横方向キー数")
                                    Spacer()
                                    TextField("横方向キー数", text: $editingItem.columnCount)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                HStack{
                                    Text("縦方向キー数")
                                    Spacer()
                                    TextField("縦方向キー数", text: $editingItem.screenRowCount).keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            Toggle(isOn: $editingItem.addTabBarAutomatically){
                                Text("自動的にタブバーに追加")
                            }
                        } label: {
                            Text("詳細設定")
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)

                    TextEditor(text: $editingItem.words)
                        .frame(height: geometry.size.height * 0.6)

                }
                BottomSheetView(
                    isOpen: $showPreview,
                    maxHeight: Design.shared.keyboardScreenHeight + 40,
                    minHeight: 0
                ) {
                    ZStack(alignment: .top){
                        Color(.secondarySystemBackground)
                        KeyboardPreview(theme: .default, defaultTab: .custard(makeCustard(data: editingItem)))
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

    func makeCustard(data: UserMadeGridScrollCustard) -> Custard {
        var keys: [CustardKeyPositionSpecifier: CustardInterfaceKey] = base

        for substring in data.words.split(separator: "\n"){
            let target = substring.components(separatedBy: "\\|").map{$0.components(separatedBy: "|")}.reduce(into: [String]()){array, value in
                if let last = array.last, let first = value.first{
                    array.removeLast()
                    array.append([last, first].joined(separator: "|"))
                    array.append(contentsOf: value.dropFirst())
                }else{
                    array.append(contentsOf: value)
                }
            }
            guard let input = target.first else {
                continue
            }
            let label = target.count > 1 ? target[1] : input
            keys[.grid_scroll(.init(keys.count))] = .custom(.init(design: .init(label: .text(label), color: .normal), press_action: [.input(input)], longpress_action: [], variation: []))
        }

        let columnKeyCount = max(Int(data.columnCount) ?? 8, 1)
        let rowKeyCount = max(Double(data.screenRowCount) ?? 4, 1)
        return Custard(
            custard_version: .v1_0,
            identifier: data.tabName.isEmpty ? "new_tab" : data.tabName,
            display_name: data.tabName.isEmpty ? "New tab" : data.tabName,
            language: .none,
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
                custard: makeCustard(data: editingItem),
                metadata: .init(origin: .userMade),
                userData: .gridScroll(editingItem),
                updateTabBar: editingItem.addTabBarAutomatically
            )
        }catch{
            debug(error)
        }
    }
}
