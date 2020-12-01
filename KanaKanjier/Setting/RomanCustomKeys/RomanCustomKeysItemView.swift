//
//  RomanCustomKeysItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI


struct RomanCustomKeysItemView: View {
    typealias ItemViewModel = SettingItemViewModel<RomanCustomKeys>
    typealias ItemModel = SettingItem<RomanCustomKeys>

    let screenSize: CGSize

    init(_ viewModel: ItemViewModel){
        self.item = viewModel.item
        self.viewModel = viewModel
        self.screenSize = UIScreen.main.bounds.size
    }
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    @State private var editMode = EditMode.active

    var body: some View {
        VStack{
            HStack{
                ForEach(viewModel.value.list.indices, id: \.self){i in
                    if viewModel.value.list[i].main{
                        VStack{
                            Text(viewModel.value.list[i].value)
                                .frame(width: screenSize.width/10, height: screenSize.width/10*1.4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                        .frame(width: screenSize.width/10, height: screenSize.width/10*1.4)
                                )
                            Text("キー\(viewModel.value.getKeyIndex(at: i)+1)")
                                .font(.caption)
                        }
                    }
                }
            }
            List{
                ForEach(viewModel.value.list.indices, id: \.self){i in
                    if viewModel.value.list[i].main{
                        HStack{
                            Text("キー\(viewModel.value.getKeyIndex(at: i)+1)")
                            TextField("入力される文字", text: $viewModel.value.list[i].value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .shadow(color: .gray, radius: 1)
                            Spacer()
                            toggleMainButton(at: i)
                        }
                    }else{
                        HStack{
                            Image(systemName: "chevron.right")
                                .font(.caption)
                            Text("キー\(viewModel.value.getKeyIndex(at: i)+1)長押し")
                            TextField("入力される文字", text: $viewModel.value.list[i].value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .shadow(color: .gray, radius: 1)
                            Spacer()
                            toggleMainButton(at: i)
                        }
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
                .deleteDisabled(self.editMode != .active)
                Text("\(Image(systemName: "chevron.right")),\(Image(systemName: "chevron.left"))をタップすることで長押しキーを切り替え可能です。")
            }
            .navigationBarItems(trailing: addButton2)
            .environment(\.editMode, $editMode)
        }
        .navigationBarTitle("カスタムキー")

    }

    private func toggleMainButton(at index: Int) -> some View {
        Group{
            if self.editMode.isEditing{
                Image(systemName: self.viewModel.value.list[index].main ? "chevron.right":"chevron.left")
                    .foregroundColor(.gray)
                    .padding(5)
                    .onTapGesture {
                        self.toggleMain(at: index)
                    }
            }
        }
    }

    private var editButton: some View {
        Group{
            switch self.editMode{
            case .active:
                Button{
                    self.editMode = .inactive
                    UIApplication.shared.closeKeyboard()
                } label: {
                    Text("完了")
                }
            default:
                Button{
                    self.editMode = .active
                } label: {
                    Text("編集")
                }
            }
        }
    }

    private var addButton2: some View {
        Button{
            self.add()
        }label: {
            Text("キーを追加")
        }
    }


    private var addButton: some View {
        HStack{
            Spacer()
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                )
                .onTapGesture {
                    self.add()
                }
        }
    }

    func toggleMain(at index: Int){
        self.viewModel.value.toggleMain(at: index)
    }

    func delete(at offsets: IndexSet) {
        print(Array(offsets))
        self.viewModel.value.remove(at: offsets)
    }

    func move(at offsets: IndexSet, to index: Int) {
        print(Array(offsets), index, self.viewModel.value.list.indices)
        self.viewModel.value.move(at: offsets, to: index)
    }

    func add() {
        self.viewModel.value.add()
    }

}

