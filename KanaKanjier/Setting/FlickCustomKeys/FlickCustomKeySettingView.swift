//
//  FlickCustomKeySettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

fileprivate extension FlickKeyPosition{
    var keyPath: WritableKeyPath<KeyFlickSetting, FlickCustomKey> {
        switch self{
        case .left:
            return \.left
        case .top:
            return \.top
        case .right:
            return \.right
        case .bottom:
            return \.bottom
        case .center:
            return \.center
        }
    }

    var bindedKeyPath: KeyPath<Binding<KeyFlickSetting>, Binding<FlickCustomKey>> {
        switch self{
        case .left:
            return \.left
        case .top:
            return \.top
        case .right:
            return \.right
        case .bottom:
            return \.bottom
        case .center:
            return \.center
        }
    }

}

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
        case input
        case tab
    }
    @Published var state = State.none
    @Published var details = false

    var editLabel: Bool {
        return state == .label
    }
    var editInput: Bool {
        return state == .input
    }
    var editTab: Bool {
        return state == .tab
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
                Text("あいう").tag(CustomizableFlickKey.hiraTab)
                Text("abc").tag(CustomizableFlickKey.abcTab)
                Text("☆123").tag(CustomizableFlickKey.symbolsTab)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selection{
            case .kogana:
                FlickCustomKeysSettingView(Store.shared.koganaKeyFlickSetting)
            case .kanaSymbols:
                FlickCustomKeysSettingView(Store.shared.kanaSymbolsKeyFlickSetting)
            case .hiraTab:
                FlickCustomKeysSettingView(Store.shared.hiraTabKeyFlickSetting)
            case .abcTab:
                FlickCustomKeysSettingView(Store.shared.abcTabKeyFlickSetting)
            case .symbolsTab:
                FlickCustomKeysSettingView(Store.shared.symbolsTabKeyFlickSetting)
            }
        }
        .background(Color.secondarySystemBackground)
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
        return self.$viewModel.value[keyPath: position.bindedKeyPath].label
    }

    private func label(_ position: FlickKeyPosition) -> String {
        if !self.isPossiblePosition(position){
            return viewModel.value.identifier.defaultSetting[keyPath: position.keyPath].label
        }
        return self.viewModel.value[keyPath: position.keyPath].label
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
            if editState.editTab{
                tabEditor
            }
            if editState.editInput{
                inputEditor
            }
            if selectState.selectedPosition != nil{
                HStack{
                    ForEach(specifiers){specifier in
                        Spacer()
                        self.button(specifier: specifier)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
                .padding()
                Spacer(minLength: 20)
                    .fixedSize()
            }
        }.navigationBarTitle("カスタムキーの設定", displayMode: .inline)
        .navigationBarItems(trailing: Button(editState.details ? "完了" : "詳細設定"){
            editState.state = .none
            editState.details.toggle()
        })
        .onChange(of: selectState.selectedPosition){value in
            if let position = selectState.selectedPosition{
                inputValue = getInputText(actions: self.viewModel.value[keyPath: position.keyPath].actions) ?? ""
            }
        }
    }

    private func getInputText(actions: [CodableActionData]) -> String? {
        if actions.count == 1, let action = actions.first, case let .input(value) = action{
            return value
        }
        return nil
    }

    private func getTab(actions: [CodableActionData]) -> CodableTabData? {
        if actions.count == 1, let action = actions.first, case let .moveTab(value) = action{
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


    var actions: Binding<[CodableActionData]>? {
        selectState.selectedPosition.flatMap{
            self.$viewModel.value[keyPath: $0.bindedKeyPath].actions
        }
    }

    var longpressActions: Binding<CodableLongpressActionData>?{
        selectState.selectedPosition.flatMap{
            self.$viewModel.value[keyPath: $0.bindedKeyPath].longpressActions
        }
    }

    private var inputEditor: some View {
        VStack{
            if let position = selectState.selectedPosition, self.getInputText(actions: viewModel.value[keyPath: position.keyPath].actions) == nil{
                Text("このキーには入力以外のアクションが設定されています。")
                    .font(.caption)
                Text("現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                    .font(.caption)
                Button("入力を設定する"){
                    viewModel.value[keyPath: position.keyPath].actions = [.input("")]
                }
            }else if let key = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(key){
                Text("キーを押して入力される文字を設定します。")
                    .font(.caption)
                Text("キーの見た目は「ラベル」で設定できます。")
                    .font(.caption)
                TextField("入力", text: $inputValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .onChange(of: inputValue){value in
                        if let position = selectState.selectedPosition{
                            self.viewModel.value[keyPath: position.keyPath].actions = [.input(value)]
                        }
                    }
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

    private var tabEditor: some View {
        VStack{
            if let position = selectState.selectedPosition{
                if !viewModel.value.identifier.ablePosition.contains(position){
                    Text("このキーは編集できません。")
                        .font(.caption)
                }else if let tab = self.getTab(actions: viewModel.value[keyPath: position.keyPath].actions){
                    Text("キーを押して移動するタブを設定します。")
                        .font(.caption)
                    AvailableTabPicker(tab){value in
                        viewModel.value[keyPath: position.keyPath].actions = [.moveTab(value)]
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    Text("移動先：\(tab.label)")
                        .font(.caption)
                }else{
                    Text("このキーにはタブ移動以外のアクションが設定されています。")
                        .font(.caption)
                    Text("現在のアクションを消去して移動するタブを設定するには「タブを設定する」を押してください")
                        .font(.caption)
                    Button("タブを設定する"){
                        viewModel.value[keyPath: position.keyPath].actions = [.moveTab(.system(.user_japanese))]
                    }
                }
            }
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    private func reload(){
        if let position = selectState.selectedPosition, self.isPossiblePosition(position){
            viewModel.value[keyPath: position.keyPath] = viewModel.value.identifier.defaultSetting[keyPath: position.keyPath]
            inputValue = self.getInputText(actions: viewModel.value.identifier.defaultSetting[keyPath: position.keyPath].actions) ?? ""
        }
    }

    private enum ToolBarButtonSpecifier: Int, Identifiable {
        case reload
        case input
        case tab
        case label
        case actions
        case longpressActions

        var id: Int {
            self.rawValue
        }
    }

    private var specifiers: [ToolBarButtonSpecifier] {
        if editState.details{
            return [.reload, .actions, .longpressActions, .label]
        }else{
            switch self.viewModel.value.identifier{
            case .kanaSymbols, .kogana:
                return [.reload, .input, .label]
            case .hiraTab, .abcTab, .symbolsTab:
                return [.reload, .tab, .label]
            }
        }
    }

    @ViewBuilder
    private func button(specifier: ToolBarButtonSpecifier) -> some View {
        switch specifier{
        case .reload:
            ToolBarButton(systemImage: "arrow.triangle.2.circlepath", labelText: "リセット"){
                if self.editState.state == .none{
                    self.reload()
                }
            }
            .foregroundColor(editState.state == .none ? .primary : .systemGray)
        case .input:
            ToolBarButton(systemImage: "text.cursor", labelText: "入力"){
                editState.toggle(.input)
            }
            .foregroundColor(editState.editInput ? .accentColor : .primary)
        case .tab:
            ToolBarButton(systemImage: "square.on.square", labelText: "タブ"){
                editState.toggle(.tab)
            }
            .foregroundColor(editState.editTab ? .accentColor : .primary)
        case .label:
            ToolBarButton(systemImage: "questionmark.square", labelText: "ラベル"){
                editState.toggle(.label)
            }
            .foregroundColor(editState.editLabel ? .accentColor : .primary)
        case .actions:
            let color: Color = (selectState.selectedPosition.flatMap{viewModel.value.identifier.ablePosition.contains($0)} ?? false) ? .primary : .systemGray
            if let position = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(position), let actions = actions{
                NavigationLink(destination: CodableActionDataEditor(actions, availableCustards: CustardManager.load().availableCustards)){
                    ToolBarButtonLabel(systemImage: "terminal", labelText: "アクション")
                }
                .foregroundColor(color)
            }else{
                ToolBarButtonLabel(systemImage: "terminal", labelText: "アクション")
                    .foregroundColor(color)
            }
        case .longpressActions:
            let color: Color = (selectState.selectedPosition.flatMap{viewModel.value.identifier.ablePosition.contains($0)} ?? false) ? .primary : .systemGray
            if let position = selectState.selectedPosition, viewModel.value.identifier.ablePosition.contains(position), let longpressActions = longpressActions{
                NavigationLink(destination: CodableLongpressActionDataEditor(longpressActions, availableCustards: CustardManager.load().availableCustards)){
                    ToolBarButtonLabel(systemImage: "terminal", labelText: "長押し")
                }
                .foregroundColor(color)
            }else{
                ToolBarButtonLabel(systemImage: "terminal", labelText: "長押し")
                    .foregroundColor(color)
            }
        }
    }
}

private struct ToolBarButtonLabel: View {
    let systemImage: String
    let labelText: LocalizedStringKey

    var body: some View {
        VStack{
            Image(systemName: systemImage)
                .font(.system(size: 23))
            Spacer()
            Text(labelText)
                .font(.system(size: 10))
        }
    }
}

private struct ToolBarButton: View {
    let systemImage: String
    let labelText: LocalizedStringKey
    let action: () -> ()

    var body: some View {
        Button{
            action()
        }label: {
            ToolBarButtonLabel(systemImage: systemImage, labelText: labelText)
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
