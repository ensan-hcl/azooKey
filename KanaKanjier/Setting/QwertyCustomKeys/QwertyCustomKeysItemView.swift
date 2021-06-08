//
//  QwertyCustomKeysItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

private final class EditState: ObservableObject {
    enum State {
        case none, drag, label, action
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

private extension QwertyCustomKeysValue {
    subscript(_ state: Selection) -> QwertyKey {
        get {
            let sIndex = state.selectIndex
            let lpsIndex = state.longpressSelectIndex
            if lpsIndex == -1 && sIndex != -1 {
                return self.keys[sIndex]
            } else {
                return self.keys[sIndex].longpresses[lpsIndex]
            }
        }
        set {
            let sIndex = state.selectIndex
            guard sIndex >= 0 else {
                return
            }
            let lpsIndex = state.longpressSelectIndex
            if lpsIndex == -1, let key = newValue as? QwertyCustomKey {
                self.keys[sIndex] = key
            } else if let key = newValue as? QwertyVariationKey {
                self.keys[sIndex].longpresses[lpsIndex] = key
            }
        }
    }

    enum InputKey {case input}

    subscript(_ key: InputKey, _ state: Selection) -> String {
        get {
            if case let .input(value) = self[state].actions.first {
                return value
            }
            return ""
        }
        set {
            self[state].actions = [.input(newValue)]
        }
    }
}

private struct Selection: Hashable {
    var selectIndex = -1 {
        didSet {
            if selectIndex != -1 {
                self.longpressSelectIndex = -1
                self.enabled = true
                self.longpressEnabled = false
            } else {
                self.enabled = false
            }
        }
    }
    var longpressSelectIndex = -1 {
        didSet {
            self.enabled = longpressSelectIndex == -1
            self.longpressEnabled = longpressSelectIndex != -1
        }
    }
    var enabled = false
    var longpressEnabled = false
}

struct QwertyCustomKeysItemView: View {
    @StateObject private var editState = EditState()
    @State private var selection = Selection()

    typealias ItemViewModel = SettingItemViewModel<QwertyCustomKeysValue>
    typealias ItemModel = SettingItem<QwertyCustomKeysValue>

    private let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

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
                        selection.longpressSelectIndex = -1
                    }
                }
            }
            DraggableView(items: $viewModel.value.keys, selection: $selection.selectIndex, enabled: selection.enabled && editState.allowDrag, width: width, height: keySize.height, padding: padding) {item, isSelected in
                let strokeColor: Color = {
                    if !isSelected {
                        return .primary
                    }
                    if selection.longpressSelectIndex != -1 {
                        return .systemGray
                    }
                    return .accentColor
                }()
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeColor)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
                    .focus(.accentColor, focused: isSelected && selection.longpressSelectIndex == -1)
                    .focus(.systemGray, focused: isSelected && selection.longpressSelectIndex != -1)
                    .overlay(Text(item.name))
            }

            if selection.selectIndex != -1 {
                Spacer(minLength: 50)
                    .fixedSize()
                Text("長押しした時の候補")
                    .padding(.vertical)
                Button("追加する") {
                    self.addLongpressKey(sIndex: selection.selectIndex)
                }
                DraggableView(items: $viewModel.value.keys[selection.selectIndex].longpresses, selection: $selection.longpressSelectIndex, enabled: selection.longpressEnabled && editState.allowDrag, width: variationWidth, height: keySize.height, padding: padding) {item, isSelected in
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : .primary)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
                        .focus(.accentColor, focused: isSelected)
                        .overlay(Text(item.name))
                }
            }
            Spacer()
            if editState.editLabel {
                labelEditor
            }
            if editState.editAction {
                inputEditor
            }
            if selection.selectIndex != -1 {
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
            editState.state = .none
            editState.details.toggle()
        })
        .background(Color.secondarySystemBackground)
    }

    private var isInputTextEditable: Bool {
        let actions = viewModel.value[selection].actions
        if actions.count == 1, case .input = actions.first {
            return true
        }
        if actions.isEmpty {
            return true
        }
        return false
    }

    private var labelEditor: some View {
        VStack {
            Text("キーに表示される文字を設定します。")
                .font(.caption)
            Text("入力される文字とは異なっていても構いません。")
                .font(.caption)
            TextField("ラベル", text: $viewModel.value[selection].name)
                .textFieldStyle(.roundedBorder)
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
            if !isInputTextEditable {
                Text("このキーには入力以外の複数のアクションが設定されています。")
                    .font(.caption)
                Text("現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                    .font(.caption)
                Button("入力を設定する") {
                    viewModel.value[.input, selection] = ""
                }
            } else {
                Text("キーを押して入力される文字を設定します。")
                    .font(.caption)
                Text("キーの見た目は「ラベル」で設定できます。")
                    .font(.caption)
                TextField("入力される文字", text: $viewModel.value[.input, selection])
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: 80)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.systemGray6).shadow(color: .primary, radius: 1, x: 0, y: 1))
        .padding()
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
                    let sIndex = selection.selectIndex
                    let lpsIndex = selection.longpressSelectIndex
                    if lpsIndex == -1 && sIndex != -1 {
                        selection.selectIndex = -1
                        self.viewModel.value.keys.remove(at: sIndex)
                    } else {
                        selection.longpressSelectIndex = -1
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
            NavigationLink(destination: CodableActionDataEditor($viewModel.value[selection].actions, availableCustards: CustardManager.load().availableCustards)) {
                ToolBarButton(systemImage: "terminal", labelText: "アクション")
            }
            .foregroundColor(.primary)
        }
    }

    private func addPressKey() {
        self.viewModel.value.keys.append(QwertyCustomKey(name: "", actions: [.input("")], longpresses: []))
        selection.selectIndex = self.viewModel.value.keys.endIndex - 1
        editState.state = .action
    }

    private func addLongpressKey(sIndex: Int) {
        self.viewModel.value.keys[sIndex].longpresses.append(QwertyVariationKey(name: "", actions: [.input("")]))
        selection.longpressSelectIndex = self.viewModel.value.keys[sIndex].longpresses.endIndex - 1
        editState.state = .action
    }
}

private struct ToolBarButton: View {
    init(systemImage: String, labelText: LocalizedStringKey, action: (() -> Void)? = nil) {
        self.systemImage = systemImage
        self.labelText = labelText
        self.action = action
    }

    private let systemImage: String
    private let labelText: LocalizedStringKey
    private let action: (() -> Void)?

    var label: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 23))
            Spacer()
            Text(labelText)
                .font(.system(size: 10))
        }
    }

    var body: some View {
        if let action = action {
            Button.init(action: action, label: { label })
                .padding(.horizontal, 10)
        } else {
            label
        }
    }
}
