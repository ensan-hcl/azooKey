//
//  File.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct KeyboardTypeSettingItemView: View {
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

        var name: String {
            switch self {
            case .japanese:
                return "日本語"
            case .english:
                return "英語"
            }
        }
    }

    init(_ viewModel: ItemViewModel, language: Language = .japanese, setTogether: Bool = false){
        self.language = language
        self.setTogether = setTogether
        self.item = viewModel.item
        self.viewModel = viewModel
        self._selection = State(initialValue: viewModel.value)
    }

    var imageName: String {
        let type = selection
        switch (type, language){
        case (.flick, .japanese): return "KeyboardImage_flick_ja"
        case (.flick, .english): return "KeyboardImage_flick_en"
        case (.roman, .japanese): return "KeyboardImage_roman_ja"
        case (.roman, .english): return "KeyboardImage_roman_en"
        }
    }

    var labelText: String {
        if setTogether{
            return "キーボードの種類" + "(現在: \(viewModel.value.string))"
        }else{
            return "\(language.name)"+"キーボードの種類" + "(現在: \(viewModel.value.string))"
        }
    }

    var body: some View {
        VStack{
            Text(labelText)
            CenterAlignedView{
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: Store.shared.imageMaximumWidth)
            }
            Picker(selection: $selection, label: Text(labelText)) {
                ForEach(0 ..< types.count) { i in
                    Text(types[i].string).tag(types[i])
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selection, perform: { _ in
                if ignoreChange{
                    return
                }
                let type = selection
                self.viewModel.value = type
                if self.item.identifier == .japaneseKeyboardLayout{
                    Store.variableSection.keyboardType = type
                }
                if setTogether{
                    Store.shared.englishKeyboardTypeSetting.value = type
                }
            })
        }
        .onAppear{
            self.ignoreChange = true
            self.selection = viewModel.value
            self.ignoreChange = false
        }
    }
}

