//
//  FlickCustomKeySettingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//
import Foundation
import SwiftUI

fileprivate extension FlickKeyPosition {
    var keyPath: WritableKeyPath<KeyFlickSetting, FlickCustomKey> {
        switch self {
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
        switch self {
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

private extension KeyFlickSetting {
    enum InputKey { case input }
    subscript(_ key: InputKey, position: FlickKeyPosition) -> String {
        get {
            if case let .input(value) = self[keyPath: position.keyPath].actions.first {
                return value
            }
            return ""
        }
        set {
            self[keyPath: position.keyPath].actions = [.input(newValue)]
        }
    }

    enum LabelKey { case label }
    subscript(_ key: LabelKey, position: FlickKeyPosition) -> String {
        get {
            self[keyPath: position.keyPath].label
        }
        set {
            self[keyPath: position.keyPath].label = newValue
        }
    }

}

struct FlickCustomKeysSettingSelectView: View {
    @State private var selection: CustomizableFlickKey = .kogana
    var body: some View {
        VStack {
            Picker(selection: $selection, label: Text("カスタムするキー")) {
                Text("小ﾞﾟ").tag(CustomizableFlickKey.kogana)
                Text("､｡?!").tag(CustomizableFlickKey.kanaSymbols)
                Text("あいう").tag(CustomizableFlickKey.hiraTab)
                Text("abc").tag(CustomizableFlickKey.abcTab)
                Text("☆123").tag(CustomizableFlickKey.symbolsTab)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selection {
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

struct FlickCustomKeysSettingView: View {
    @State private var selectedPosition: FlickKeyPosition?

    typealias ItemViewModel = SettingItemViewModel<KeyFlickSetting>
    typealias ItemModel = SettingItem<KeyFlickSetting>

    private let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    @State private var bottomSheetShown = false

    init(_ viewModel: ItemViewModel) {
        self.item = viewModel.item
        self.viewModel = viewModel
    }

    private let screenWidth = UIScreen.main.bounds.width

    private var keySize: CGSize {
        CGSize(width: screenWidth / 5.6, height: screenWidth / 8)
    }
    private var spacing: CGFloat {
        (screenWidth - keySize.width * 5) / 5
    }

    var body: some View {
        GeometryReader {geometry in
            VStack {
                Text("編集したい方向を選択してください。")
                    .padding(.vertical)

                VStack {
                    CustomKeySettingFlickKeyView(.top, label: viewModel.value[.label, .top], selectedPosition: $selectedPosition)
                        .frame(width: keySize.width, height: keySize.height)
                    HStack {
                        CustomKeySettingFlickKeyView(.left, label: viewModel.value[.label, .left], selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                        CustomKeySettingFlickKeyView(.center, label: viewModel.value[.label, .center], selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                        CustomKeySettingFlickKeyView(.right, label: viewModel.value[.label, .right], selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                    }
                    CustomKeySettingFlickKeyView(.bottom, label: viewModel.value[.label, .bottom], selectedPosition: $selectedPosition)
                        .frame(width: keySize.width, height: keySize.height)
                }
                Spacer()
            }.navigationBarTitle("カスタムキーの設定", displayMode: .inline)
            .onChange(of: selectedPosition) {value in
                bottomSheetShown = value != nil
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            if let position = selectedPosition {
                BottomSheetView(
                    isOpen: self.$bottomSheetShown,
                    maxHeight: geometry.size.height * 0.7
                ) {
                    Form {
                        if isPossiblePosition(position) {
                            switch mainEditor {
                            case .input:
                                Section(header: Text("入力")) {
                                    if self.isInputActionEditable(actions: viewModel.value[keyPath: position.keyPath].actions) {
                                        Text("キーを押して入力される文字を設定します。")
                                        TextField("入力", text: $viewModel.value[.input, position])
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text("このキーには入力以外のアクションが設定されています。現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                                        Button("入力を設定する") {
                                            viewModel.value[.input, position] = ""
                                        }
                                        .foregroundColor(.accentColor)
                                    }
                                }
                            case .tab:
                                Section(header: Text("タブ")) {
                                    let tab = self.getTab(actions: viewModel.value[keyPath: position.keyPath].actions)
                                    if tab != nil || viewModel.value[keyPath: position.keyPath].actions.isEmpty {
                                        Text("キーを押して移動するタブを設定します。")
                                        AvailableTabPicker(tab ?? .system(.user_japanese)) {value in
                                            viewModel.value[keyPath: position.keyPath].actions = [.moveTab(value)]
                                        }
                                    } else {
                                        tabSetter(keyPath: position.keyPath)
                                    }
                                }
                            }
                            Section(header: Text("ラベル")) {
                                Text("キーに表示される文字を設定します。")
                                TextField("ラベル", text: $viewModel.value[.label, position])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Section(header: Text("アクション")) {
                                Text("キーを押したときの動作をより詳しく設定します。")
                                NavigationLink("アクションを編集する", destination: CodableActionDataEditor($viewModel.value[keyPath: position.bindedKeyPath].actions, availableCustards: CustardManager.load().availableCustards))
                                .foregroundColor(.accentColor)
                            }
                            Section(header: Text("長押しアクション")) {
                                Text("キーを長押ししたときの動作をより詳しく設定します。")
                                NavigationLink("長押しアクションを編集する", destination: CodableLongpressActionDataEditor($viewModel.value[keyPath: position.bindedKeyPath].longpressActions, availableCustards: CustardManager.load().availableCustards))
                                .foregroundColor(.accentColor)
                            }
                            Button("リセット") {
                                self.reload()
                            }
                            .foregroundColor(.red)
                        } else {
                            Text("このキーは編集できません")
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }

    @ViewBuilder private func tabSetter(keyPath: WritableKeyPath<KeyFlickSetting, FlickCustomKey>) -> some View {
        Text("このキーにはタブ移動以外のアクションが設定されています。現在のアクションを消去して移動するタブを設定するには「タブを設定する」を押してください")
        Button("タブを設定する") {
            viewModel.value[keyPath: keyPath].actions = [.moveTab(.system(.user_japanese))]
        }
        .foregroundColor(.accentColor)
    }

    private func isPossiblePosition(_ position: FlickKeyPosition) -> Bool {
        return self.viewModel.value.identifier.ablePosition.contains(position)
    }

    private func isInputActionEditable(actions: [CodableActionData]) -> Bool {
        if actions.count == 1, case .input = actions.first {
            return true
        }
        if actions.isEmpty {
            return true
        }
        return false
    }

    private func getTab(actions: [CodableActionData]) -> TabData? {
        if actions.count == 1, let action = actions.first, case let .moveTab(value) = action {
            return value
        }
        return nil
    }

    private func reload() {
        if let position = selectedPosition, self.isPossiblePosition(position) {
            viewModel.value[keyPath: position.keyPath] = viewModel.value.identifier.defaultSetting[keyPath: position.keyPath]
        }
    }

    private enum MainEditorSpecifier {
        case input
        case tab
    }

    private var mainEditor: MainEditorSpecifier {
        switch self.viewModel.value.identifier {
        case .kanaSymbols, .kogana:
            return .input
        case .hiraTab, .abcTab, .symbolsTab:
            return .tab
        }
    }
}
