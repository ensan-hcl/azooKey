//
//  QwertyCustomKeysItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

fileprivate final class SelectState: ObservableObject, Hashable {
    @Published var targetIndex = -1
    @Published var selectedIndex = -1
    @Published var longpressTargetIndex = -1
    @Published var longpressSelectedIndex = -1

    func reset() {
        self.selectedIndex = -1
        self.targetIndex = -1
    }

    static func == (lhs: SelectState, rhs: SelectState) -> Bool {
        return lhs.selectedIndex == rhs.selectedIndex && lhs.longpressSelectedIndex == rhs.longpressSelectedIndex && lhs.targetIndex == rhs.targetIndex && lhs.longpressTargetIndex == rhs.longpressTargetIndex
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(targetIndex)
        hasher.combine(longpressTargetIndex)
        hasher.combine(selectedIndex)
        hasher.combine(longpressSelectedIndex)
    }
}

fileprivate final class EditState: ObservableObject {
    enum State {
        case none
        case drag
        case label
        case action
    }
    @Published var state = State.none
    @Published var details = false
    var allowDrag: Bool {
        return state == .drag
    }
    var editLabel: Bool {
        return state == .label
    }
    var editAction: Bool {
        return state == .action
    }

    func toggle(_ state: State) {
        if self.state == state {
            self.state = .none
        } else {
            self.state = state
        }
    }
}

private protocol QwertyKey {
    var actions: [CodableActionData] {get set}
    var name: String {get set}
}

extension QwertyCustomKey: QwertyKey {}
extension QwertyVariationKey: QwertyKey {}

fileprivate extension QwertyCustomKeysValue {
    subscript(_ state: SelectState) -> QwertyKey {
        get {
            let sIndex = state.selectedIndex
            let lpsIndex = state.longpressSelectedIndex
            if lpsIndex == -1 && sIndex != -1 {
                return self.keys[sIndex]
            } else {
                return self.keys[sIndex].longpresses[lpsIndex]
            }
        }
        set {
            let sIndex = state.selectedIndex
            guard sIndex >= 0 else {
                return
            }
            let lpsIndex = state.longpressSelectedIndex
            if lpsIndex == -1, let key = newValue as? QwertyCustomKey {
                self.keys[sIndex] = key
            } else if let key = newValue as? QwertyVariationKey {
                self.keys[sIndex].longpresses[lpsIndex] = key
            }
        }
    }
}

struct QwertyCustomKeysItemView: View {
    @ObservedObject private var selectState = SelectState()
    @ObservedObject private var editState = EditState()

    typealias ItemViewModel = SettingItemViewModel<QwertyCustomKeysValue>
    typealias ItemModel = SettingItem<QwertyCustomKeysValue>

    private let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    @State private var inputValue = ""

    private var padding: CGFloat {
        return spacing / 2
    }

    private let screenWidth = UIScreen.main.bounds.width

    private var keySize: CGSize {
        return CGSize(width: screenWidth / 12.2, height: screenWidth / 9)
    }
    private var spacing: CGFloat {
        (screenWidth - keySize.width * 10) / (9 + 0.5)
    }
    private func romanScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keySize.width * CGFloat(normal) + spacing * CGFloat(normal - 1)
        let necessarySpacing = spacing * CGFloat(count - 1)
        return (width - necessarySpacing) / CGFloat(count)
    }
    private var width: CGFloat {
        return romanScaledKeyWidth(normal: 7, for: viewModel.value.keys.count)
    }
    private var variationWidth: CGFloat {
        return romanScaledKeyWidth(normal: 7, for: 7)
    }

    init(_ viewModel: ItemViewModel) {
        self.item = viewModel.item
        self.viewModel = viewModel
    }

    private var separator: some View {
        Rectangle()
            .frame(width: 2, height: keySize.height * 0.9)
            .foregroundColor(.accentColor)
    }

    var body: some View {
        VStack {
            Spacer(minLength: 10)
                .fixedSize()
            Text("編集したいキーを選択してください。")
                .padding(.vertical)
            VStack {
                Button("キーを追加する", action: self.addPressKey)
                if viewModel.value.keys.isEmpty {
                    Button("デフォルトに戻す") {
                        viewModel.value.keys = QwertyCustomKeysValue.defaultValue.keys
                        selectState.longpressSelectedIndex = -1
                    }
                }
            }
            HStack(spacing: 0) {
                ForEach(viewModel.value.keys.indices, id: \.self) {i in
                    if editState.allowDrag && selectState.targetIndex == i {
                        separator
                            .focus(.accentColor, focused: true)
                    }
                    DraggableItem(selectState: selectState, editState: editState, index: i, label: viewModel.value.keys[i].name, update: update, onEnd: onEnd)
                        .frame(width: width, height: keySize.height)
                        .padding(padding)
                        .zIndex(selectState.selectedIndex == i ? 1:0)
                }
                if editState.allowDrag && selectState.targetIndex == viewModel.value.keys.endIndex {
                    separator
                        .focus(.accentColor, focused: true)
                }
            }.scaledToFit()
            if self.selectState.selectedIndex != -1 {
                Spacer(minLength: 50)
                    .fixedSize()
                Text("長押しした時の候補")
                    .padding(.vertical)
                Button("追加する"){
                    self.addLongpressKey(sIndex: self.selectState.selectedIndex)
                }
                let longpresses = viewModel.value.keys[selectState.selectedIndex].longpresses
                HStack(spacing: 0) {
                    ForEach(longpresses.indices, id: \.self) {i in
                        if editState.allowDrag && selectState.longpressTargetIndex == i {
                            separator
                                .focus(.accentColor, focused: true)
                        }
                        DraggableItem(selectState: selectState, editState: editState, index: i, label: longpresses[i].name, long: true, update: longPressUpdate, onEnd: longPressOnEnd)
                            .frame(width: variationWidth, height: keySize.height)
                            .padding(padding)
                            .zIndex(selectState.longpressSelectedIndex == i ? 1:0)
                    }
                    if editState.allowDrag && selectState.longpressTargetIndex == longpresses.endIndex {
                        separator
                            .focus(.accentColor, focused: true)
                    }
                }.scaledToFit()
            }
            Spacer()
            if editState.editLabel {
                labelEditor
            }
            if editState.editAction {
                inputEditor
            }
            if selectState.selectedIndex != -1 {
                HStack {
                    ForEach(specifiers) {specifier in
                        Spacer()
                        self.button(specifier: specifier)
                        Spacer()
                    }
                }
                .frame(maxHeight: 50)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
                .padding()
                Spacer(minLength: 20)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarTitle("カスタムキーの設定", displayMode: .inline)
        .navigationBarItems(trailing: Button(editState.details ? "完了" : "詳細設定") {
            self.reloadInputValue()
            editState.state = .none
            editState.details.toggle()
        })
        .background(Color.secondarySystemBackground)
        .onChange(of: selectState.selectedIndex) {_ in
            self.reloadInputValue()
        }
        .onChange(of: selectState.longpressSelectedIndex) {_ in
            self.reloadInputValue()
        }
    }

    private func reloadInputValue() {
        if selectState.selectedIndex != -1, let string = getInputText(actions: viewModel.value[selectState].actions) {
            inputValue = string
        }
    }

    private func getInputText(actions: [CodableActionData]) -> String? {
        if actions.count == 1, let action = actions.first, case let .input(value) = action {
            return value
        }
        return nil
    }

    private var labelEditor: some View {
        VStack {
            Text("キーに表示される文字を設定します。")
                .font(.caption)
            Text("入力される文字とは異なっていても構いません。")
                .font(.caption)
            TextField("ラベル", text: $viewModel.value[selectState].name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
    }

    private var inputEditor: some View {
        VStack {
            if self.getInputText(actions: viewModel.value[selectState].actions) == nil {
                Text("このキーには入力以外の複数のアクションが設定されています。")
                    .font(.caption)
                Text("現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                    .font(.caption)
                Button("入力を設定する") {
                    inputValue = ""
                    viewModel.value[selectState].actions = [.input("")]
                }
            } else {
                Text("キーを押して入力される文字を設定します。")
                    .font(.caption)
                Text("キーの見た目は「ラベル」で設定できます。")
                    .font(.caption)
                TextField("入力される文字", text: $inputValue)
                    .onChange(of: inputValue) { string in
                        viewModel.value[selectState].actions = [.input(string)]
                        if viewModel.value[selectState].name.isEmpty {
                            viewModel.value[selectState].name = string
                        }
                    }
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

    private func pointedIndex(index: Int, delta: CGFloat) -> Int {
        if delta.isZero {
            return index
        }

        let endIndex: Int
        let width: CGFloat
        if selectState.longpressSelectedIndex == -1 {
            endIndex = viewModel.value.keys.endIndex
            width = self.width
        } else {
            endIndex = viewModel.value.keys[selectState.selectedIndex].longpresses.endIndex
            width = self.variationWidth
        }

        if delta < 0 {
            // 負の場合
            var position = CGFloat.zero
            var index = index
            while index >= 0 {
                position -= (width + padding * 2)
                if position < delta {
                    return index
                }
                index -= 1
            }
            return 0
        } else {
            // 正の場合
            var position = CGFloat.zero
            var index = index + 1
            while index < endIndex {
                position += (width + padding * 2)
                if delta < position {
                    return index
                }

                index += 1
            }
            return endIndex
        }

    }

    private func update(index: Int, delta: CGFloat) {
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.targetIndex = targetIndex
    }

    private func longPressUpdate(index: Int, delta: CGFloat) {
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.longpressTargetIndex = targetIndex
    }

    private func onEnd() {
        let selectedIndex = selectState.selectedIndex
        let targetIndex = selectState.targetIndex
        if targetIndex != -1 {
            if selectedIndex > targetIndex {
                let item = self.viewModel.value.keys.remove(at: selectedIndex)
                self.viewModel.value.keys.insert(item, at: targetIndex)
                self.selectState.selectedIndex = targetIndex
            } else if selectedIndex < targetIndex {
                self.viewModel.value.keys.insert(self.viewModel.value.keys[selectedIndex], at: targetIndex)
                self.viewModel.value.keys.remove(at: selectedIndex)
                self.selectState.selectedIndex = targetIndex - 1
            }
        }
        self.selectState.targetIndex = -1
    }

    private func longPressOnEnd() {
        let selectedKeyIndex = selectState.selectedIndex
        let selectedIndex = selectState.longpressSelectedIndex
        let targetIndex = selectState.longpressTargetIndex
        if targetIndex != -1 {
            if selectedIndex > targetIndex {
                let item = viewModel.value.keys[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                viewModel.value.keys[selectedKeyIndex].longpresses.insert(item, at: targetIndex)
                self.selectState.longpressSelectedIndex = targetIndex
            } else if selectedIndex < targetIndex {
                viewModel.value.keys[selectedKeyIndex].longpresses.insert(viewModel.value.keys[selectedKeyIndex].longpresses[selectedIndex], at: targetIndex)
                viewModel.value.keys[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                self.selectState.longpressSelectedIndex = targetIndex - 1
            }
        }
        self.selectState.longpressTargetIndex = -1
    }

    private enum ToolBarButtonSpecifier: Int, Identifiable {
        case delete
        case move
        case input
        case label
        case actions

        var id: Int {
            self.rawValue
        }
    }

    private var specifiers: [ToolBarButtonSpecifier] {
        if editState.details {
            return [.delete, .move, .actions, .label]
        } else {
            return [.delete, .move, .input, .label]
        }
    }

    @ViewBuilder
    private func button(specifier: ToolBarButtonSpecifier) -> some View {
        switch specifier {
        case .delete:
            ToolBarButton(systemImage: "trash", labelText: "削除") {
                if editState.state == .none {
                    let sIndex = selectState.selectedIndex
                    let lpsIndex = selectState.longpressSelectedIndex
                    if lpsIndex == -1 && sIndex != -1 {
                        self.selectState.selectedIndex = -1
                        self.viewModel.value.keys.remove(at: sIndex)
                    } else {
                        self.selectState.longpressSelectedIndex = -1
                        self.viewModel.value.keys[sIndex].longpresses.remove(at: lpsIndex)
                    }
                }
            }
            .foregroundColor(editState.state == .none ? .primary:.systemGray)
        case .move:
            ToolBarButton(systemImage: "arrow.left.arrow.right", labelText: "移動") {
                editState.toggle(.drag)
            }
            .foregroundColor(editState.allowDrag ? .accentColor:.primary)
        case .input:
            ToolBarButton(systemImage: "text.cursor", labelText: "入力") {
                editState.toggle(.action)
            }
            .foregroundColor(editState.editAction ? .accentColor:.primary)
        case .label:
            ToolBarButton(systemImage: "questionmark.square", labelText: "ラベル") {
                editState.toggle(.label)
            }
            .foregroundColor(editState.editLabel ? .accentColor : .primary)
        case .actions:
            NavigationLink(destination: CodableActionDataEditor($viewModel.value[selectState].actions, availableCustards: CustardManager.load().availableCustards)) {
                ToolBarButtonLabel(systemImage: "terminal", labelText: "アクション")
            }
            .foregroundColor(.primary)
        }
    }

    private func addPressKey() {
        self.viewModel.value.keys.append(QwertyCustomKey(name: "", actions: [.input("")], longpresses: []))
        selectState.selectedIndex = self.viewModel.value.keys.endIndex - 1
        editState.state = .action
    }
    private func addLongpressKey(sIndex: Int) {
        self.viewModel.value.keys[sIndex].longpresses.append(QwertyVariationKey(name: "", actions: [.input("")]))
        selectState.longpressSelectedIndex = self.viewModel.value.keys[sIndex].longpresses.endIndex - 1
        editState.state = .action
    }

}

private struct ToolBarButtonLabel: View {
    init(systemImage: String, labelText: LocalizedStringKey) {
        self.systemImage = systemImage
        self.labelText = labelText
    }

    private let systemImage: String
    private let labelText: LocalizedStringKey

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 23))
            Spacer()
            Text(labelText)
                .font(.system(size: 10))
        }
    }
}

private struct ToolBarButton: View {
    init(systemImage: String, labelText: LocalizedStringKey, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.labelText = labelText
        self.action = action
    }

    private let systemImage: String
    private let labelText: LocalizedStringKey
    private let action: () -> Void

    var body: some View {
        Button {
            action()
        }label: {
            ToolBarButtonLabel(systemImage: systemImage, labelText: labelText)
        }
        .padding(.horizontal, 10)
    }
}

private struct DraggableItem: View {
    private enum DragState {
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

    @GestureState private var dragState = DragState.inactive
    @State private var viewState: CGSize = .zero
    @ObservedObject private var selectState: SelectState
    @ObservedObject private var editState: EditState

    private let index: Int
    private let label: String
    private let long: Bool

    private let onEnd: () -> Void
    private let update: (Int, CGFloat) -> Void

    init(selectState: SelectState, editState: EditState, index: Int, label: String, long: Bool = false, update: @escaping (Int, CGFloat) -> Void, onEnd: @escaping () -> Void) {
        self.selectState = selectState
        self.editState = editState
        self.index = index
        self.label = label
        self.long = long
        self.update = update
        self.onEnd = onEnd
    }

    private var focused: Bool {
        if long && selectState.longpressSelectedIndex == index {
            return true
        }
        if !long && selectState.selectedIndex == index {
            return selectState.longpressSelectedIndex == -1
        }
        return false
    }

    private var strokeColor: Color {
        if focused {
            return .accentColor
        }
        if longpressFocused {
            return .systemGray
        }
        return .primary
    }

    private var longpressFocused: Bool {
        return !long && selectState.selectedIndex == index && selectState.longpressSelectedIndex != -1
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(strokeColor)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
            .focus(.accentColor, focused: focused)
            .focus(.systemGray, focused: longpressFocused)

            .overlay(Text(label))
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .onTapGesture {
                if !long {
                    self.selectState.selectedIndex = index
                    self.selectState.longpressSelectedIndex = -1
                } else {
                    self.selectState.longpressSelectedIndex = index
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragState) {value, state, _ in
                        if !long {
                            if self.selectState.selectedIndex == index && editState.allowDrag {
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        } else {
                            if self.selectState.longpressSelectedIndex == index && editState.allowDrag {
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        }
                    }
                    .onEnded {_ in
                        if editState.allowDrag {
                            self.onEnd()
                        }
                    }
            )
    }
}
