//
//  File.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct KeyboardLayoutSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<KeyboardLayout>
    typealias ItemModel = SettingItem<KeyboardLayout>

    @State private var selection: KeyboardLayout = .flick
    @State private var ignoreChange = false
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    let language: Language
    let setTogether: Bool

    private let types = KeyboardLayout.allCases

    enum Language{
        case japanese
        case english

        var name: LocalizedStringKey {
            switch self {
            case .japanese:
                return "日本語"
            case .english:
                return "英語"
            }
        }
    }

    let id: Int

    init(_ viewModel: ItemViewModel, language: Language = .japanese, setTogether: Bool = false, id: Int = 0){
        self.language = language
        self.setTogether = setTogether
        self.item = viewModel.item
        self.viewModel = viewModel
        self._selection = State(initialValue: viewModel.value)
        self.id = id
    }

    var labelText: LocalizedStringKey {
        if setTogether{
            return "\(Text("キーボードの種類"))(\(Text("現在")): \(Text(viewModel.value.string)))"
        }else{
            return "\(Text(language.name)) \(Text("キーボードの種類"))(\(Text("現在")): \(Text(viewModel.value.string)))"
        }
    }

    var tab: Tab.ExistentialTab {
        switch (selection, language){
        case (.flick, .japanese):
            return .flick_hira
        case (.flick, .english):
            return .flick_abc
        case (.qwerty, .japanese):
            return .qwerty_hira
        case (.qwerty, .english):
            return .qwerty_abc
        }
    }

    var body: some View {
        VStack{
            Text(labelText)
            CenterAlignedView{
                KeyboardPreview(theme: .default, scale: 0.8, defaultTab: tab)
                    .allowsHitTesting(false)
                    .disabled(true)
            }
            Picker(selection: $selection, label: Text(labelText)) {
                ForEach(0 ..< types.count) { i in
                    Text(types[i].string).tag(types[i])
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
        }
        .onChange(of: selection, perform: { _ in
            if ignoreChange{
                return
            }
            let type = selection
            self.viewModel.value = type
            switch language{
            case .japanese:
                Store.variableSection.japaneseKeyboardLayout = type
            case .english:
                Store.variableSection.englishKeyboardLayout = type
            }
            if setTogether{
                Store.shared.englishKeyboardTypeSetting.value = type
                Store.variableSection.englishKeyboardLayout = type
            }
        })
        .onAppear{
            self.ignoreChange = true
            self.selection = viewModel.value
            self.ignoreChange = false
        }
        .onDisappear{
            self.ignoreChange = true
        }
    }
}

