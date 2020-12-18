//
//  RomanCustomKeysSettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

fileprivate class SelectState: ObservableObject{
    @Published var targetIndex = -1
    @Published var selectedIndex = -1
    @Published var longpressTargetIndex = -1
    @Published var longpressSelectedIndex = -1

    func reset(){
        self.selectedIndex = -1
        self.targetIndex = -1
    }
}
fileprivate class EditState: ObservableObject{
    enum State{
        case none
        case drag
        case label
        case action
    }
    @Published var state = State.none
    var allowDrag: Bool {
        return state == .drag
    }
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

struct RomanCustomKeysItemView: View {
    @ObservedObject private var selectState = SelectState()
    @ObservedObject private var editState = EditState()

    typealias ItemViewModel = SettingItemViewModel<RomanCustomKeysValue>
    typealias ItemModel = SettingItem<RomanCustomKeysValue>

    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    var padding: CGFloat {
        return spacing/2
    }

    let screenWidth = UIScreen.main.bounds.width

    var keySize: CGSize {
        return CGSize(width: screenWidth/12.2, height: screenWidth/9)
    }
    var spacing: CGFloat {
        (screenWidth - keySize.width * 10)/(9+0.5)
    }
    func romanScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keySize.width * CGFloat(normal) + spacing * CGFloat(normal - 1)
        let necessarySpacing = spacing * CGFloat(count - 1)
        return (width - necessarySpacing) / CGFloat(count)
    }
    var width: CGFloat {
        return romanScaledKeyWidth(normal: 7, for: viewModel.value.keys.count)
    }
    var variationWidth: CGFloat {
        return romanScaledKeyWidth(normal: 7, for: 7)
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

    var body: some View {
        VStack{
            Spacer(minLength: 10)
                .fixedSize()
            Text("編集したいキーを選択してください。")
                .font(.caption)
            HStack(spacing: 0){
                ForEach(viewModel.value.keys.indices, id: \.self){i in
                    if editState.allowDrag && selectState.targetIndex == i{
                        separator
                            .focus(.accentColor, focused: true)
                    }
                    DraggableItem(selectState: selectState, editState: editState, index: i, label: viewModel.value.keys[i].name, update: update, onEnd: onEnd)
                        .frame(width: width, height: keySize.height)
                        .padding(padding)
                        .zIndex(selectState.selectedIndex == i ? 1:0)
                }
                if editState.allowDrag && selectState.targetIndex == viewModel.value.keys.endIndex{
                    separator
                        .focus(.accentColor, focused: true)
                }
            }.scaledToFit()
            if viewModel.value.keys.isEmpty{
                VStack{
                    Button{
                        viewModel.value.keys.append(RomanCustomKey(name: "", input: "", longpresses: []))
                        selectState.selectedIndex = 0
                        selectState.longpressSelectedIndex = -1
                        editState.state = .action
                    }label: {
                        Text("キーを追加する")
                    }
                    Button{
                        viewModel.value.keys = RomanCustomKeysValue.defaultValue.keys
                        selectState.longpressSelectedIndex = -1
                    }label: {
                        Text("デフォルトに戻す")
                    }

                }
            }
            if self.selectState.selectedIndex != -1{
                Spacer(minLength: 50)
                    .fixedSize()
                Text("長押しした時の候補")
                let longpresses = viewModel.value.keys[selectState.selectedIndex].longpresses
                HStack(spacing: 0){
                    ForEach(longpresses.indices, id: \.self){i in
                        if editState.allowDrag && selectState.longpressTargetIndex == i{
                            separator
                                .focus(.accentColor, focused: true)
                        }
                        DraggableItem(selectState: selectState, editState: editState, index: i, label: longpresses[i].name, long: true, update: longPressUpdate, onEnd: longPressOnEnd)
                            .frame(width: variationWidth, height: keySize.height)
                            .padding(padding)
                            .zIndex(selectState.longpressSelectedIndex == i ? 1:0)
                    }
                    if editState.allowDrag && selectState.longpressTargetIndex == longpresses.endIndex{
                        separator
                            .focus(.accentColor, focused: true)
                    }
                }.scaledToFit()
                if longpresses.isEmpty{
                    Button{
                        viewModel.value.keys[selectState.selectedIndex].longpresses.append(RomanVariationKey(name: "", input: ""))
                        selectState.longpressSelectedIndex = self.viewModel.value.keys[selectState.selectedIndex].longpresses.endIndex - 1
                        editState.state = .action
                    }label: {
                        Text("追加する")
                    }
                }
            }
            Spacer()
            if editState.editLabel{
                labelEditor
            }
            if editState.editAction{
                actionEditor
            }
            if selectState.selectedIndex != -1{
                HStack{
                    Group{
                        ToolBarButton(systemImage: "trash", labelText: "削除"){
                            if editState.state == .none{
                                let sIndex = selectState.selectedIndex
                                let lpsIndex = selectState.longpressSelectedIndex
                                if lpsIndex == -1 && sIndex != -1{
                                    self.selectState.selectedIndex = -1
                                    self.viewModel.value.keys.remove(at: sIndex)
                                }else{
                                    self.selectState.longpressSelectedIndex = -1
                                    self.viewModel.value.keys[sIndex].longpresses.remove(at: lpsIndex)
                                }
                            }
                        }
                        .foregroundColor(editState.state == .none ? .primary:.systemGray)

                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "arrow.left.arrow.right", labelText: "移動"){
                            editState.toggle(.drag)
                        }
                        .foregroundColor(editState.allowDrag ? .accentColor:.primary)
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
                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "plus", labelText: "追加"){
                            let sIndex = selectState.selectedIndex
                            let lpsIndex = selectState.longpressSelectedIndex
                            if lpsIndex == -1{
                                self.viewModel.value.keys.append(RomanCustomKey(name: "", longpresses: []))
                                selectState.selectedIndex = self.viewModel.value.keys.endIndex - 1
                                editState.state = .action
                            }else{
                                self.viewModel.value.keys[sIndex].longpresses.append(RomanVariationKey(name: "", input: ""))
                                selectState.longpressSelectedIndex = self.viewModel.value.keys[sIndex].longpresses.endIndex - 1
                                editState.state = .action
                            }

                        }
                        .foregroundColor(.primary)

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
            Text("キーに表示される文字を設定します。")
                .font(.caption)
            Text("入力される文字とは異なっていても構いません。")
                .font(.caption)

            let sIndex = selectState.selectedIndex
            let lpsIndex = selectState.longpressSelectedIndex
            if lpsIndex == -1 && sIndex != -1{
                TextField("ラベル", text: $viewModel.value.keys[sIndex].name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }else{
                TextField("ラベル", text: $viewModel.value.keys[sIndex].longpresses[lpsIndex].name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    var actionEditor: some View {
        VStack{
            Text("キーを押して入力される文字を設定します。")
                .font(.caption)
            Text("キーの見た目は「ラベル」で設定できます。")
                .font(.caption)

            let sIndex = selectState.selectedIndex
            let lpsIndex = selectState.longpressSelectedIndex
            if lpsIndex == -1 && sIndex != -1{
                TextField("入力される文字", text: $viewModel.value.keys[sIndex].input, onCommit: {
                    if viewModel.value.keys[sIndex].name.isEmpty{
                        viewModel.value.keys[sIndex].name = viewModel.value.keys[sIndex].input
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }else{
                TextField("入力される文字", text: $viewModel.value.keys[sIndex].longpresses[lpsIndex].input, onCommit: {
                    if viewModel.value.keys[sIndex].longpresses[lpsIndex].name.isEmpty{
                        viewModel.value.keys[sIndex].longpresses[lpsIndex].name = viewModel.value.keys[sIndex].longpresses[lpsIndex].input
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    private func pointedIndex(index: Int, delta: CGFloat) -> Int{
        if delta.isZero{
            return index
        }

        let endIndex: Int
        let width: CGFloat
        if selectState.longpressSelectedIndex == -1{
            endIndex = viewModel.value.keys.endIndex
            width = self.width
        }else{
            endIndex = viewModel.value.keys[selectState.selectedIndex].longpresses.endIndex
            width = self.variationWidth
        }

        if delta < 0{
            //負の場合
            var position = CGFloat.zero
            var index = index
            while index >= 0{
                position -= (width + padding*2)
                if position < delta{
                    return index
                }
                index -= 1
            }
            return 0
        }else{
            //正の場合
            var position = CGFloat.zero
            var index = index + 1
            while index < endIndex{
                position += (width + padding*2)
                if delta < position{
                    return index
                }

                index += 1
            }
            return endIndex
        }

    }

    func update(index: Int, delta: CGFloat){
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.targetIndex = targetIndex
    }

    func longPressUpdate(index: Int, delta: CGFloat){
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.longpressTargetIndex = targetIndex
    }

    func onEnd(){
        let selectedIndex = selectState.selectedIndex
        let targetIndex = selectState.targetIndex
        if targetIndex != -1{
            if selectedIndex > targetIndex{
                let item = self.viewModel.value.keys.remove(at: selectedIndex)
                self.viewModel.value.keys.insert(item, at: targetIndex)
                self.selectState.selectedIndex = targetIndex
            }else if selectedIndex < targetIndex{
                self.viewModel.value.keys.insert(self.viewModel.value.keys[selectedIndex], at: targetIndex)
                self.viewModel.value.keys.remove(at: selectedIndex)
                self.selectState.selectedIndex = targetIndex - 1
            }
        }
        self.selectState.targetIndex = -1
    }

    func longPressOnEnd(){
        let selectedKeyIndex = selectState.selectedIndex
        let selectedIndex = selectState.longpressSelectedIndex
        let targetIndex = selectState.longpressTargetIndex
        if targetIndex != -1{
            if selectedIndex > targetIndex{
                let item = viewModel.value.keys[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                viewModel.value.keys[selectedKeyIndex].longpresses.insert(item, at: targetIndex)
                self.selectState.longpressSelectedIndex = targetIndex
            }else if selectedIndex < targetIndex{
                viewModel.value.keys[selectedKeyIndex].longpresses.insert(viewModel.value.keys[selectedKeyIndex].longpresses[selectedIndex], at: targetIndex)
                viewModel.value.keys[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                self.selectState.longpressSelectedIndex = targetIndex - 1
            }
        }
        self.selectState.longpressTargetIndex = -1

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

private struct DraggableItem: View {
    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    @GestureState var dragState = DragState.inactive
    @State var viewState: CGSize = .zero
    @ObservedObject private var selectState: SelectState
    @ObservedObject private var editState: EditState

    let index: Int
    let label: String
    let long: Bool

    let onEnd: () -> ()
    let update: (Int, CGFloat) -> ()

    init(selectState: SelectState, editState: EditState, index: Int, label: String, long: Bool = false, update: @escaping (Int, CGFloat) -> (), onEnd: @escaping () -> ()){
        self.selectState = selectState
        self.editState = editState
        self.index = index
        self.label = label
        self.long = long
        self.update = update
        self.onEnd = onEnd
    }

    var focused: Bool {
        if long && selectState.longpressSelectedIndex == index{
            return true
        }
        if !long && selectState.selectedIndex == index{
            return selectState.longpressSelectedIndex == -1
        }
        return false
    }

    var strokeColor: Color {
        if focused{
            return .accentColor
        }
        if longpressFocused{
            return .systemGray
        }
        return .primary
    }

    var longpressFocused: Bool {
        return !long && selectState.selectedIndex == index && selectState.longpressSelectedIndex != -1
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(strokeColor)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
            .focus(.accentColor, focused: focused)
            .focus(.systemGray, focused: longpressFocused)

            .overlay(Text(label))
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .onTapGesture {
                if !long{
                    self.selectState.selectedIndex = index
                    self.selectState.longpressSelectedIndex = -1
                }else{
                    self.selectState.longpressSelectedIndex = index
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragState){value, state, transaction in
                        if !long{
                            if self.selectState.selectedIndex == index && editState.allowDrag{
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        }else{
                            if self.selectState.longpressSelectedIndex == index && editState.allowDrag{
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        }
                    }
                    .onEnded {_ in
                        if editState.allowDrag{
                            self.onEnd()
                        }
                    }
            )
    }
}

