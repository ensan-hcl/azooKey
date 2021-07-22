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
        case none, drag
    }

    @Published var state = State.none
    @Published var details = false

    var allowDrag: Bool {
        return state == .drag
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
    @State private var bottomSheetShown = false
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
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 10)
                    .fixedSize()
                if editState.allowDrag {
                    Text("キーをドラッグして移動してください。")  // TODO: ローカライズ
                        .padding(.vertical)
                } else {
                    Text("編集したいキーを選択してください。")
                        .padding(.vertical)
                }
                if viewModel.value.keys.isEmpty {
                    Button("デフォルトに戻す") {
                        viewModel.value.keys = QwertyCustomKeysValue.defaultValue.keys
                        selection.longpressSelectIndex = -1
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
                    DraggableView(items: $viewModel.value.keys[selection.selectIndex].longpresses, selection: $selection.longpressSelectIndex, enabled: selection.longpressEnabled && editState.allowDrag, width: variationWidth, height: keySize.height, padding: padding) {item, isSelected in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.accentColor : .primary)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
                            .focus(.accentColor, focused: isSelected)
                            .overlay(Text(item.name))
                    }
                }
                Spacer()
            }
            .onChange(of: selection) { newValue in
                bottomSheetShown = newValue.selectIndex != -1
                editState.state = .none
            }
            .navigationBarTitle("カスタムキーの設定", displayMode: .inline)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height * 0.7
            ) {
                Form {
                    if selection.selectIndex != -1 {
                        Section(header: Text("移動・追加")) { // TODO: ローカライズ
                            Button("このキーを並び替える") { // TODO: ローカライズ
                                bottomSheetShown = false
                                editState.toggle(.drag)
                            }
                            Button("キーを追加する", action: self.addPressKey)
                            Button("このキーに長押しキーを追加する") { // TODO: ローカライズ
                                self.addLongpressKey(sIndex: selection.selectIndex)
                            }
                        }
                        Section(header: Text("入力")) {
                            if self.isInputTextEditable {
                                Text("キーを押して入力される文字を設定します。")
                                TextField("入力", text: $viewModel.value[.input, selection])
                                    .textFieldStyle(.roundedBorder)
                                    .submitLabel(.done)
                            } else {
                                Text("このキーには入力以外のアクションが設定されています。現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                                Button("入力を設定する") {
                                    viewModel.value[.input, selection] = ""
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        Section(header: Text("ラベル")) {
                            Text("キーに表示される文字を設定します。")
                            TextField("ラベル", text: $viewModel.value[selection].name)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                        }
                        Section(header: Text("アクション")) {
                            Text("キーを押したときの動作をより詳しく設定します。")
                            NavigationLink("アクションを編集する", destination: CodableActionDataEditor($viewModel.value[selection].actions, availableCustards: CustardManager.load().availableCustards))
                                .foregroundColor(.accentColor)
                        }
                        Button("削除") {
                            bottomSheetShown = false
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
                        .foregroundColor(.red)
                    } else {
                        Button("キーを追加する", action: self.addPressKey)
                    }
                }
            }
        }
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

    private func addPressKey() {
        self.viewModel.value.keys.append(QwertyCustomKey(name: "", actions: [.input("")], longpresses: []))
        selection.selectIndex = self.viewModel.value.keys.endIndex - 1
    }

    private func addLongpressKey(sIndex: Int) {
        self.viewModel.value.keys[sIndex].longpresses.append(QwertyVariationKey(name: "", actions: [.input("")]))
        selection.longpressSelectIndex = self.viewModel.value.keys[sIndex].longpresses.endIndex - 1
    }
}
