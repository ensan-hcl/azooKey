//
//  CustardInterfaceKeyEditor.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private enum LabelType {
    case text, systemImage
}

fileprivate extension CustardInterfaceKey {
    enum SystemKey { case system }
    enum CustomKey { case custom }

    subscript(key: CustomKey) -> CustardInterfaceCustomKey {
        get {
            if case let .custom(value) = self {
                return value
            }
            return .init(design: .init(label: .text(""), color: .normal), press_actions: [], longpress_actions: .none, variations: [])
        }
        set {
            self = .custom(newValue)
        }
    }

    subscript(key: SystemKey) -> CustardInterfaceSystemKey {
        get {
            if case let .system(value) = self {
                return value
            }
            return .enter
        }
        set {
            self = .system(newValue)
        }
    }
}

fileprivate extension FlickKeyPosition {
    var flickDirection: FlickDirection? {
        switch self {
        case .left: return .left
        case .top: return .top
        case .right: return .right
        case .bottom: return .bottom
        case .center: return nil
        }
    }
}

fileprivate extension CustardInterfaceCustomKey {
    subscript(direction: FlickDirection) -> CustardInterfaceVariationKey {
        get {
            if let variation = self.variations.first(where: {$0.type == .flickVariation(direction)})?.key {
                return variation
            }
            return .init(design: .init(label: .text("")), press_actions: [], longpress_actions: .none)
        }
        set {
            if let index = self.variations.firstIndex(where: {$0.type == .flickVariation(direction)}) {
                self.variations[index].key = newValue
            } else {
                self.variations.append(.init(type: .flickVariation(direction), key: newValue))
            }
        }
    }

    enum LabelTextKey { case labelText }
    enum LabelImageNameKey { case labelImageName }
    enum LabelTypeKey { case labelType }
    enum PressActionKey { case pressAction }
    enum InputActionKey { case inputAction }
    enum LongpressActionKey { case longpressAction }

    subscript(label: LabelTextKey, position: FlickKeyPosition) -> String {
        get {
            if let direction = position.flickDirection {
                return self[direction][.labelText]
            }
            if case let .text(value) = self.design.label {
                return value
            }
            return ""
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.labelText] = newValue
            } else {
                self.design.label = .text(newValue)
            }
        }
    }

    subscript(label: LabelImageNameKey, position: FlickKeyPosition) -> String {
        get {
            if let direction = position.flickDirection {
                return self[direction][.labelImageName]
            }
            if case let .systemImage(value) = self.design.label {
                return value
            }
            return ""
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.labelImageName] = newValue
            } else {
                self.design.label = .systemImage(newValue)
            }
        }
    }

    subscript(label: LabelTypeKey, position: FlickKeyPosition) -> LabelType {
        get {
            if let direction = position.flickDirection {
                return self[direction][.labelType]
            }
            switch self.design.label {
            case .systemImage: return .systemImage
            case .text: return .text
            }
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.labelType] = newValue
            } else {
                switch newValue {
                case .text:
                    self.design.label = .text("")
                case .systemImage:
                    self.design.label = .systemImage("circle.fill")
                }
            }
        }
    }

    subscript(action: PressActionKey, position: FlickKeyPosition) -> [CodableActionData] {
        get {
            if let direction = position.flickDirection {
                return self[direction][.pressAction]
            }
            return self.press_actions
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.pressAction] = newValue
            } else {
                self.press_actions = newValue
            }
        }
    }

    subscript(inputAction: InputActionKey, position: FlickKeyPosition) -> String {
        get {
            if let direction = position.flickDirection {
                return self[direction][.inputAction]
            }
            if case let .input(value) = self.press_actions.first {
                return value
            }
            return ""
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.inputAction] = newValue
            } else {
                self.press_actions = [.input(newValue)]
            }
        }
    }

    subscript(action: LongpressActionKey, position: FlickKeyPosition) -> CodableLongpressActionData {
        get {
            if let direction = position.flickDirection {
                return self[direction][.longpressAction]
            }
            return self.longpress_actions
        }
        set {
            if let direction = position.flickDirection {
                self[direction][.longpressAction] = newValue
            } else {
                self.longpress_actions = newValue
            }
        }
    }
}

fileprivate extension CustardInterfaceVariationKey {
    enum LabelTextKey { case labelText }
    enum PressActionKey { case pressAction }
    enum InputActionKey { case inputAction }
    enum LongpressActionKey { case longpressAction }
    enum LabelImageNameKey { case labelImageName }
    enum LabelTypeKey { case labelType }

    subscript(label: LabelTextKey) -> String {
        get {
            if case let .text(value) = self.design.label {
                return value
            }
            return ""
        }
        set {
            self.design.label = .text(newValue)
        }
    }

    subscript(label: LabelImageNameKey) -> String {
        get {
            if case let .systemImage(value) = self.design.label {
                return value
            }
            return ""
        }
        set {
            self.design.label = .systemImage(newValue)
        }
    }

    subscript(label: LabelTypeKey) -> LabelType {
        get {
            switch self.design.label {
            case .systemImage: return .systemImage
            case .text: return .text
            }
        }
        set {
            switch newValue {
            case .text:
                self.design.label = .text("")
            case .systemImage:
                self.design.label = .systemImage("circle.fill")
            }
        }
    }

    subscript(pressAction: PressActionKey) -> [CodableActionData] {
        get {
            return self.press_actions
        }
        set {
            self.press_actions = newValue
        }
    }

    subscript(inputAction: InputActionKey) -> String {
        get {
            if case let .input(value) = self.press_actions.first {
                return value
            }
            return ""
        }
        set {
            self.press_actions = [.input(newValue)]
        }
    }

    subscript(longpressAction: LongpressActionKey) -> CodableLongpressActionData {
        get {
            return self.longpress_actions
        }
        set {
            self.longpress_actions = newValue
        }
    }
}

private struct IntStringConversion: Intertranslator {
    typealias First = Int
    typealias Second = String

    static func convert(_ first: Int) -> String {
        return String(first)
    }
    static func convert(_ second: String) -> Int {
        return max(Int(second) ?? 1, 1)
    }
}

struct CustardInterfaceKeyEditor: View {
    @Binding private var key: CustardInterfaceKey
    @Binding private var width: Int
    @Binding private var height: Int
    private let intStringConverter = IntStringConversion.self

    @State private var selectedPosition: FlickKeyPosition = .center
    @State private var bottomSheetShown = false

    init(data: Binding<UserMadeTenKeyCustard.KeyData>) {
        self._key = data.model
        self._width = data.width
        self._height = data.height
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
                switch key {
                case let .custom(value):
                    Text("編集したい方向を選択してください。")
                        .padding(.vertical)
                    keysView(key: value)
                    BottomSheetView(isOpen: self.$bottomSheetShown, maxHeight: geometry.size.height * 0.7) {
                        customKeyEditor(position: selectedPosition)
                    }
                case .system:
                    systemKeyEditor()
                }
            }
        }
        .onChange(of: selectedPosition) {_ in
            bottomSheetShown = true
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(Text("キーの編集"))
    }

    private var keyPicker: some View {
        Picker("キーの種類", selection: $key) {
            if [CustardInterfaceKey.system(.enter), .custom(.flickSpace), .custom(.flickDelete), .system(.changeKeyboard), .system(.flickKogaki), .system(.flickKutoten), .system(.flickHiraTab), .system(.flickAbcTab), .system(.flickStar123Tab)].contains(key) {
                Text("カスタム").tag(CustardInterfaceKey.custom(.empty))
            } else {
                Text("カスタム").tag(key)
            }
            Text("改行キー").tag(CustardInterfaceKey.system(.enter))
            Text("削除キー").tag(CustardInterfaceKey.custom(.flickDelete))
            Text("空白キー").tag(CustardInterfaceKey.custom(.flickSpace))
            Text("地球儀キー").tag(CustardInterfaceKey.system(.changeKeyboard))
            Text("小書き・濁点化キー").tag(CustardInterfaceKey.system(.flickKogaki))
            Text("句読点キー").tag(CustardInterfaceKey.system(.flickKutoten))
            Text("日本語タブキー").tag(CustardInterfaceKey.system(.flickHiraTab))
            Text("英語タブキー").tag(CustardInterfaceKey.system(.flickAbcTab))
            Text("記号タブキー").tag(CustardInterfaceKey.system(.flickStar123Tab))
        }
    }

    @ViewBuilder private var sizePicker: some View {
        HStack {
            Text("縦")
            TextField("縦", text: $height.converted(intStringConverter))
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
        }
        HStack {
            Text("横")
            TextField("横", text: $width.converted(intStringConverter))
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
        }
    }

    private func systemKeyEditor() -> some View {
        Form {
            Section {
                keyPicker
            }
            Section(header: Text("キーのサイズ")) {
                sizePicker
            }
            Section {
                Button("リセット") {
                    key = .custom(.empty)
                }.foregroundColor(.red)
            }
        }
    }

    private func isInputActionEditable(position: FlickKeyPosition) -> Bool {
        let actions = self.key[.custom][.pressAction, position]
        if actions.count == 1, case .input = actions.first {
            return true
        }
        if actions.isEmpty {
            return true
        }
        return false
    }

    private func customKeyEditor(position: FlickKeyPosition) -> some View {
        Form {
            Section(header: Text("入力")) {
                if self.isInputActionEditable(position: position) {
                    Text("キーを押して入力される文字を設定します。")
                    // FIXME: バグを防ぐため一時的にBindingオブジェクトを手動生成する形にしている
                    TextField("入力", text: Binding(
                                get: {
                                    key[.custom][.inputAction, position]
                                },
                                set: {
                                    key[.custom][.inputAction, position] = $0
                                })
                    )
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                } else {
                    Text("このキーには入力以外のアクションが設定されています。現在のアクションを消去して入力する文字を設定するには「入力を設定する」を押してください")
                    Button("入力を設定する") {
                        key[.custom][.inputAction, position] = ""
                    }
                    .foregroundColor(.accentColor)
                }
            }
            Section(header: Text("ラベル")) {
                Text("キーに表示される文字を設定します。")
                Picker("ラベルの種類", selection: $key[.custom][.labelType, position]) {
                    Text("テキスト").tag(LabelType.text)
                    Text("システムアイコン").tag(LabelType.systemImage)
                }
                switch key[.custom][.labelType, position] {
                case .text:
                    TextField("ラベル", text: Binding(
                                get: {
                                    key[.custom][.labelText, position]
                                },
                                set: {
                                    key[.custom][.labelText, position] = $0
                                })
                    )
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                case .systemImage:
                    TextField("アイコンの名前", text: Binding(
                                get: {
                                    key[.custom][.labelImageName, position]
                                },
                                set: {
                                    key[.custom][.labelImageName, position] = $0
                                })
                    )
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                }
            }
            if position == .center {
                Section(header: Text("キーの色")) {
                    Text("キーの色を設定します。")
                    Picker("キーの色", selection: $key[.custom].design.color) {
                        Text("通常のキー").tag(CustardKeyDesign.ColorType.normal)
                        Text("特別なキー").tag(CustardKeyDesign.ColorType.special)
                        Text("押されているキー").tag(CustardKeyDesign.ColorType.selected)
                    }
                }
            }
            Section(header: Text("アクション")) {
                Text("キーを押したときの動作をより詳しく設定します。")
                NavigationLink("アクションを編集する", destination: CodableActionDataEditor($key[.custom][.pressAction, position], availableCustards: CustardManager.load().availableCustards))
                    .foregroundColor(.accentColor)
            }
            Section(header: Text("長押しアクション")) {
                Text("キーを長押ししたときの動作をより詳しく設定します。")
                NavigationLink("長押しアクションを編集する", destination: CodableLongpressActionDataEditor($key[.custom][.longpressAction, position], availableCustards: CustardManager.load().availableCustards))
                    .foregroundColor(.accentColor)
            }

            if position == .center {
                Section(header: Text("キーのサイズ")) {
                    sizePicker
                }
                Section {
                    keyPicker
                }
                Section {
                    Button("リセット") {
                        key = .custom(.empty)
                    }.foregroundColor(.red)
                }
            }
            if let direction = position.flickDirection {
                Button("クリア") {
                    key[.custom].variations.removeAll {
                        $0.type == .flickVariation(direction)
                    }
                }.foregroundColor(.red)
            }
        }
    }

    private func keysView(key: CustardInterfaceCustomKey) -> some View {
        VStack {
            keyView(key: key, position: .top)
            HStack {
                keyView(key: key, position: .left)
                keyView(key: key, position: .center)
                keyView(key: key, position: .right)
            }
            keyView(key: key, position: .bottom)
        }
    }

    @ViewBuilder private func keyView(key: CustardInterfaceCustomKey, position: FlickKeyPosition) -> some View {
        switch key[.labelType, position] {
        case .text:
            CustomKeySettingFlickKeyView(position, label: key[.labelText, position], selectedPosition: $selectedPosition)
                .frame(width: keySize.width, height: keySize.height)
        case .systemImage:
            CustomKeySettingFlickKeyView(position, selectedPosition: $selectedPosition) {
                Image(systemName: key[.labelImageName, position])
            }
            .frame(width: keySize.width, height: keySize.height)
        }
    }
}
