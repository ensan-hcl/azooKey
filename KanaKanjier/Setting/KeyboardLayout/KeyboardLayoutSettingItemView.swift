//
//  File.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

extension LanguageLayout{
    var label: LocalizedStringKey {
        switch self {
        case .flick:
            return "フリック入力"
        case .qwerty:
            return "ローマ字入力"
        case let .custard(identifier):
            return LocalizedStringKey(identifier)
        }
    }
}

struct LanguageLayoutSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<LanguageLayout>
    typealias ItemModel = SettingItem<LanguageLayout>

    @State private var selection: LanguageLayout = .flick
    @State private var ignoreChange = false
    let custardManager = CustardManager.load()
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    let language: Language
    let setTogether: Bool

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
        self.types = {
            let keyboardlanguage: KeyboardLanguage
            switch language{
            case .japanese:
                keyboardlanguage = .japanese
            case .english:
                keyboardlanguage = .english
            }
            return [.flick, .qwerty] + CustardManager.load().availableCustard(for: keyboardlanguage).map{.custard($0)}
        }()
    }

    private let types: [LanguageLayout]

    var labelText: LocalizedStringKey {
        if setTogether{
            return "キーボードの種類(現在: \(selection.label))"
        }else{
            return "\(language.name)キーボードの種類(現在: \(selection.label))"
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
        case let (.custard(identifier), _):
            if let custard = try? custardManager.custard(identifier: identifier){
                return .custard(custard)
            }else{
                return .custard(.errorMessage)
            }
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
                    Text(types[i].label).tag(types[i])
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
        }
        .onChange(of: selection){ _ in
            if ignoreChange{
                return
            }
            let type = selection
            self.viewModel.value = type
            switch language{
            case .japanese:
                Store.variableSection.japaneseLayout = type
            case .english:
                Store.variableSection.englishLayout = type
            }
            if setTogether{
                Store.shared.englishLayoutSetting.value = type
                Store.variableSection.englishLayout = type
            }
        }
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

/*
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
        .onChange(of: selection){ _ in
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
        }
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

*/
