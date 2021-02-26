//
//  FlickCustomKeySettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

fileprivate final class SelectState: ObservableObject{
    @Published var selectedPosition: FlickKeyPosition? = nil

    func reset(){
        self.selectedPosition = nil
    }
}
fileprivate final class EditState: ObservableObject{
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
        .background(Color(.secondarySystemBackground))
    }
}

struct EditingFlickCustomKey{
    var label: String
    var input: String
}

struct FlickCustomKeysSettingView: View {
    @ObservedObject private var selectState = SelectState()
    @ObservedObject private var editState = EditState()

    typealias ItemViewModel = SettingItemViewModel<KeyFlickSetting>
    typealias ItemModel = SettingItem<KeyFlickSetting>

    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    @State private var inputValue = ""

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

    private var separator: some View {
        Rectangle()
            .frame(width: 2, height: keySize.height*0.9)
            .foregroundColor(.accentColor)
    }

    private func label(_ position: FlickKeyPosition) -> Binding<String> {
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

    private func label(_ position: FlickKeyPosition) -> String {
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

    private func isPossiblePosition(_ position: FlickKeyPosition) -> Bool {
        return self.viewModel.value.identifier.ablePosition.contains(position)
    }

    var body: some View {
        VStack{
            Spacer(minLength: 10)
                .fixedSize()
            Text("編集したい方向を選択してください。")
                .font(.caption)

            VStack{
                CustomKeySettingFlickKeyView(.top, label: label(.top), selectState: selectState)
                    .frame(width: keySize.width, height: keySize.height)
                HStack{
                    CustomKeySettingFlickKeyView(.left, label: label(.left), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                    CustomKeySettingFlickKeyView(.center, label: label(.center), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                    CustomKeySettingFlickKeyView(.right, label: label(.right), selectState: selectState)
                        .frame(width: keySize.width, height: keySize.height)
                }
                CustomKeySettingFlickKeyView(.bottom, label: label(.bottom), selectState: selectState)
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
                        ToolBarButton(systemImage: "arrow.triangle.2.circlepath", labelText: "リセット"){
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
        .onChange(of: inputValue){value in
            switch selectState.selectedPosition{
            case .none:
                return
            case .left:
                self.viewModel.value.left.actions = [.input(value)]
            case .top:
                self.viewModel.value.top.actions = [.input(value)]
            case .right:
                self.viewModel.value.right.actions = [.input(value)]
            case .bottom:
                self.viewModel.value.bottom.actions = [.input(value)]
            case .center:
                self.viewModel.value.center.actions = [.input(value)]
            }
        }
        .onChange(of: selectState.selectedPosition){value in
            switch selectState.selectedPosition{
            case .none:
                return
            case .left:
                inputValue = getInputText(actions: self.viewModel.value.left.actions) ?? ""
            case .top:
                inputValue = getInputText(actions: self.viewModel.value.top.actions) ?? ""
            case .right:
                inputValue = getInputText(actions: self.viewModel.value.right.actions) ?? ""
            case .bottom:
                inputValue = getInputText(actions: self.viewModel.value.bottom.actions) ?? ""
            case .center:
                inputValue = getInputText(actions: self.viewModel.value.center.actions) ?? ""
            }
        }
    }

    private func getInputText(actions: [CodableActionData]) -> String? {
        if actions.count == 1, let action = actions.first, case let .input(value) = action{
            return value
        }
        return nil
    }

    private var labelEditor: some View {
        VStack{
            if let key = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(key){
                Text("キーに表示される文字を設定します。")
                    .font(.caption)
                Text("入力される文字とは異なっていても構いません。")
                    .font(.caption)
                TextField("ラベル", text: label(key))
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

    private var  actionEditor: some View {
        VStack{
            if let key = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(key){
                Text("キーを押して入力される文字を設定します。")
                    .font(.caption)
                Text("キーの見た目は「ラベル」で設定できます。")
                    .font(.caption)
                TextField("ラベル", text: $inputValue)
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

    private func reload(){
        if let position = selectState.selectedPosition, self.isPossiblePosition(position){
            let bindedLabel: Binding<String> = label(position)
            bindedLabel.wrappedValue = viewModel.value.identifier.defaultLabel[position, default: ""]
            inputValue = viewModel.value.identifier.defaultInput[position, default: ""]
        }
    }
}

private struct ToolBarButton: View{
    let systemImage: String
    let labelText: LocalizedStringKey
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

private struct CustomKeySettingFlickKeyView: View {
    private let position: FlickKeyPosition
    private let label: String
    @ObservedObject private var selectState: SelectState

    init(_ position: FlickKeyPosition, label: String, selectState: SelectState){
        self.position = position
        self.label = label
        self.selectState = selectState
    }

    private var focused: Bool {
        return selectState.selectedPosition == position
    }

    private var strokeColor: Color {
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
