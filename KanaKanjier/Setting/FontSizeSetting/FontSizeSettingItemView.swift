//
//  FontSizeSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct FontSizeSettingView<SettingKey: DoubleKeyboardSettingKey>: View {
    enum Target {
        case key
        case result
    }

    private let availableValues: [FontSizeSetting]
    private let target: Target

    @State private var value: FontSizeSetting
    @State private var isOn = false

    init(_ key: SettingKey, _ target: Target, availableValues: [FontSizeSetting]) {
        self._value = .init(initialValue: .value(SettingKey.value))
        self.target = target
        self.availableValues = availableValues
    }

    var body: some View {
        HStack {
            Text(SettingKey.title)
            Button {
                isOn = true
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                }
            }
            Spacer()
            let size = value.saveValue == -1 ? 18 : value.saveValue
            switch self.target {
            case .key:
                KeyView(fontSize: size)

            case .result:
                Text("サンプル")
                    .font(.system(size: size))
                    .underline()
                    .padding()
            }
        }
        .alert(isPresented: $isOn) {
            Alert(title: Text(SettingKey.explanation), dismissButton: .default(Text("OK")) {
                isOn = false
            })
        }
        .listRowSeparator(.hidden)
            Picker(selection: $value, label: Text("")) {
                ForEach(self.availableValues) {data in
                    Text(data.display).tag(data)
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .frame(height: 70)
            .clipped()
            .onChange(of: value) { value in
                SettingKey.value = value.saveValue
            }
    }
}

private struct KeyView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    private let fontSize: CGFloat

    init(fontSize: CGFloat) {
        self.fontSize = fontSize
    }

    private var size: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch storeVariableSection.japaneseLayout {
        case .flick:
            return CGSize(width: screenWidth / 5.6, height: screenWidth / 8)
        case .qwerty:
            return CGSize(width: screenWidth / 12.2, height: screenWidth / 9)
        case .custard:
            return CGSize(width: screenWidth / 5.6, height: screenWidth / 8)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke()
            .frame(width: size.width, height: size.height)
            .overlay(Text("あ").font(.system(size: fontSize)))
    }
}
