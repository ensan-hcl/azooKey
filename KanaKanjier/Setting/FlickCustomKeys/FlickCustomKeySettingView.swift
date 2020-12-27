//
//  FlickCustomKeySettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

fileprivate class SelectState: ObservableObject{
    @Published var selectedPosition: FlickKeyPosition? = nil

    func reset(){
        self.selectedPosition = nil
    }
}
fileprivate class EditState: ObservableObject{
    enum State{
        case none
        case label
        case action
    }
    @Published var state = State.none
    var editLabel: Bool {
        return state == .label
    }
    var editAction: Bool {
        return state == .action
    }

    func toggle(_ state: State){
        if self.state == state{
            self.state = .none
        }else{
            self.state = state
        }
    }
}

struct FlickCustomKeysSettingSelectView: View {
    @State private var selection: CustomizableFlickKey = .kogana
    var body: some View {
        VStack{
            Picker(selection: $selection, label: Text("カスタムするキー")){
                Text("小ﾞﾟ").tag(CustomizableFlickKey.kogana)
                Text("､｡?!").tag(CustomizableFlickKey.kanaSymbols)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selection{
            case .kogana:
                FlickCustomKeysSettingView(Store.shared.koganaKeyFlickSetting)
            case .kanaSymbols:
                FlickCustomKeysSettingView(Store.shared.kanaSymbolsKeyFlickSetting)
            }
        }
    }
}

struct FlickCustomKeysSettingView: View {
    @ObservedObject private var selectState = SelectState()
    @ObservedObject private var editState = EditState()

    typealias ItemViewModel = SettingItemViewModel<KeyFlickSetting>
    typealias ItemModel = SettingItem<KeyFlickSetting>

    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    var padding: CGFloat {
        spacing/2
    }

    let screenWidth = UIScreen.main.bounds.width

    var keySize: CGSize {
        CGSize(width: screenWidth/5.6, height: screenWidth/8)
    }
    var spacing: CGFloat {
        (screenWidth - keySize.width * 5)/5
    }

    init(_ viewModel: ItemViewModel){
        self.item = viewModel.item
        self.viewModel = viewModel
    }

    var separator: some View {
        Rectangle()
            .frame(width: 2, height: keySize.height*0.9)
            .foregroundColor(.accentColor)
    }

    func input(_ position: FlickKeyPosition) -> Binding<String> {
        switch position{
        case .left:
            return self.$viewModel.value.left.input
        case .top:
            return self.$viewModel.value.top.input
        case .right:
            return self.$viewModel.value.right.input
        case .bottom:
            return self.$viewModel.value.bottom.input
        case .center:
            return self.$viewModel.value.center.input
        }
    }

    func label(_ position: FlickKeyPosition) -> Binding<String> {
        switch position{
        case .left:
            return self.$viewModel.value.left.label
        case .top:
            return self.$viewModel.value.top.label
        case .right:
            return self.$viewModel.value.right.label
        case .bottom:
            return self.$viewModel.value.bottom.label
        case .center:
            return self.$viewModel.value.center.label
        }
    }

    func label(_ position: FlickKeyPosition) -> String {
        if !self.isPossiblePosition(position){
            return viewModel.value.identifier.defaultLabel[position]!
        }
        switch position{
        case .left:
            return self.viewModel.value.left.label
        case .top:
            return self.viewModel.value.top.label
        case .right:
            return self.viewModel.value.right.label
        case .bottom:
            return self.viewModel.value.bottom.label
        case .center:
            return self.viewModel.value.center.label
        }
    }

    func isPossiblePosition(_ position: FlickKeyPosition) -> Bool {
        return self.viewModel.value.identifier.ablePosition.contains(position)
    }

    var body: some View {
        VStack{
            Spacer(minLength: 10)
                .fixedSize()
            Text("編集したい方向を選択してください。")
                .font(.caption)

            VStack{
                FlickKeyView(.top, label: label(.top), selectState: selectState)
                    .frame(width: keySize.width, height: keySize.height)
                HStack{
                    FlickKeyView(.left, label: label(.left), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                    FlickKeyView(.center, label: label(.center), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                    FlickKeyView(.right, label: label(.right), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                }
                FlickKeyView(.bottom, label: label(.bottom), selectState: selectState)
                    .frame(width: keySize.width, height: keySize.height)
            }
            Spacer()
            if editState.editLabel{
                labelEditor
            }
            if editState.editAction{
                actionEditor
            }

            if selectState.selectedPosition != nil{
                HStack{
                    Group{
                        ToolBarButton(systemImage: "arrow.triangle.2.circlepath", labelText: "デフォルトに戻す"){
                            self.reload()
                        }
                        .foregroundColor(editState.state == .none ? .primary:.systemGray)
                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "text.cursor", labelText: "入力"){
                            editState.toggle(.action)
                        }
                        .foregroundColor(editState.editAction ? .accentColor:.primary)
                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "questionmark.square", labelText: "ラベル"){
                            editState.toggle(.label)
                        }
                        .foregroundColor(editState.editLabel ? .accentColor:.primary)
                    }
                }
                .frame(maxHeight: 50)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
                .padding()
                Spacer(minLength: 20)
                    .fixedSize()
            }
        }.navigationBarTitle("カスタムキーの設定", displayMode: .inline)
    }

    var labelEditor: some View {
        VStack{
            if let key = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(key){
                TextField("ラベル", text: label(key))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                Text("キーに表示される文字を設定します。")
                    .font(.caption)
                Text("入力される文字とは異なっていても構いません。")
                    .font(.caption)
            }else{
                Text("このキーは編集できません。")
                    .font(.caption)
            }
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    var actionEditor: some View {
        VStack{
            if let key = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(key){
                Text("キーを押して入力される文字を設定します。")
                    .font(.caption)
                Text("キーの見た目は「ラベル」で設定できます。")
                    .font(.caption)
                TextField("ラベル", text: input(key))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }else{
                Text("このキーは編集できません。")
                    .font(.caption)
            }

        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    func reload(){
        if let position = selectState.selectedPosition, self.isPossiblePosition(position){
            let bindedLabel: Binding<String> = label(position)
            let bindedInput: Binding<String> = input(position)
            bindedLabel.wrappedValue = viewModel.value.identifier.defaultLabel[position, default: ""]
            bindedInput.wrappedValue = viewModel.value.identifier.defaultInput[position, default: ""]
        }
    }
}

private struct ToolBarButton: View{
    let systemImage: String
    let labelText: String
    let action: () -> ()

    var body: some View {
        Button{
            action()
        }label: {
            VStack{
                Image(systemName: systemImage)
                    .font(.system(size: 23))
                Spacer()
                Text(labelText)
                    .font(.system(size: 10))

            }
        }
        .padding(.horizontal, 10)
    }
}

private struct FlickKeyView: View {
    let position: FlickKeyPosition
    let label: String
    @ObservedObject private var selectState: SelectState

    init(_ position: FlickKeyPosition, label: String, selectState: SelectState){
        self.position = position
        self.label = label
        self.selectState = selectState
    }

    var focused: Bool {
        return selectState.selectedPosition == position
    }

    var strokeColor: Color {
        if focused{
            return .accentColor
        }
        return .primary
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(strokeColor)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
            .focus(.accentColor, focused: focused)
            .overlay(Text(label))
            .onTapGesture {
                self.selectState.selectedPosition = position
            }
    }
}
