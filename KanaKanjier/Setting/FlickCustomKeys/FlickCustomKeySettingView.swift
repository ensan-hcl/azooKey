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

    @State private var inputValue = ""
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
                    CustomKeySettingFlickKeyView(.top, label: label(.top), selectedPosition: $selectedPosition)
                        .frame(width: keySize.width, height: keySize.height)
                    HStack {
                        CustomKeySettingFlickKeyView(.left, label: label(.left), selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                        CustomKeySettingFlickKeyView(.center, label: label(.center), selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                        CustomKeySettingFlickKeyView(.right, label: label(.right), selectedPosition: $selectedPosition)
                            .frame(width: keySize.width, height: keySize.height)
                    }
                    CustomKeySettingFlickKeyView(.bottom, label: label(.bottom), selectedPosition: $selectedPosition)
                        .frame(width: keySize.width, height: keySize.height)
                }
                Spacer()
            }.navigationBarTitle("カスタムキーの設定", displayMode: .inline)
            .onChange(of: selectedPosition) {value in
                if let position = value {
                    inputValue = getInputText(actions: self.viewModel.value[keyPath: position.keyPath].actions) ?? ""
                    bottomSheetShown = true
                } else {
                    bottomSheetShown = false
                }
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
                                    if self.getInputText(actions: viewModel.value[keyPath: position.keyPath].actions) != nil || viewModel.value[keyPath: position.keyPath].actions.isEmpty {
                                        Text("キーを押して入力される文字を設定します。")
                                        TextField("入力", text: $inputValue)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .onChange(of: inputValue) {value in
                                                self.viewModel.value[keyPath: position.keyPath].actions = [.input(value)]
                                            }
                                    } else {
                                        Text("このキーには入力以外のアクションが設定されています。現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                                        Button("入力を設定する") {
                                            viewModel.value[keyPath: position.keyPath].actions = [.input("")]
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
                                TextField("ラベル", text: label(position))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            if let actions = actions {
                                Section(header: Text("アクション")) {
                                    Text("キーを押したときの動作をより詳しく設定します。")
                                    NavigationLink(destination: CodableActionDataEditor(actions, availableCustards: CustardManager.load().availableCustards)) {
                                        Text("アクションを編集する")
                                    }
                                    .foregroundColor(.accentColor)
                                }
                            }

                            if let longpressActions = longpressActions {
                                Section(header: Text("長押しアクション")) {
                                    Text("キーを長押ししたときの動作をより詳しく設定します。")
                                    NavigationLink(destination: CodableLongpressActionDataEditor(longpressActions, availableCustards: CustardManager.load().availableCustards)) {
                                        Text("長押しアクションを編集する")
                                            .foregroundColor(.accentColor)
                                    }
                                    .foregroundColor(.accentColor)
                                }
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
        Text("このキーには入力以外のアクションが設定されています。現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
        Button("入力を設定する") {
            viewModel.value[keyPath: keyPath].actions = [.input("")]
        }
        .foregroundColor(.accentColor)
    }

    private func label(_ position: FlickKeyPosition) -> Binding<String> {
        return self.$viewModel.value[keyPath: position.bindedKeyPath].label
    }

    private func label(_ position: FlickKeyPosition) -> String {
        if !self.isPossiblePosition(position) {
            return viewModel.value.identifier.defaultSetting[keyPath: position.keyPath].label
        }
        return self.viewModel.value[keyPath: position.keyPath].label
    }

    private func isPossiblePosition(_ position: FlickKeyPosition) -> Bool {
        return self.viewModel.value.identifier.ablePosition.contains(position)
    }

    private func getInputText(actions: [CodableActionData]) -> String? {
        if actions.count == 1, let action = actions.first, case let .input(value) = action {
            return value
        }
        return nil
    }

    private func getTab(actions: [CodableActionData]) -> TabData? {
        if actions.count == 1, let action = actions.first, case let .moveTab(value) = action {
            return value
        }
        return nil
    }

    private var actions: Binding<[CodableActionData]>? {
        selectedPosition.flatMap {
            self.$viewModel.value[keyPath: $0.bindedKeyPath].actions
        }
    }

    private var longpressActions: Binding<CodableLongpressActionData>? {
        selectedPosition.flatMap {
            self.$viewModel.value[keyPath: $0.bindedKeyPath].longpressActions
        }
    }

    private func reload() {
        if let position = selectedPosition, self.isPossiblePosition(position) {
            viewModel.value[keyPath: position.keyPath] = viewModel.value.identifier.defaultSetting[keyPath: position.keyPath]
            inputValue = self.getInputText(actions: viewModel.value.identifier.defaultSetting[keyPath: position.keyPath].actions) ?? ""
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
