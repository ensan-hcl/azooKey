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

    private let availableValueRange: ClosedRange<Double>
    private let target: Target

    @State private var localValue: Double = -1
    @State private var isOn = false

    init(_ key: SettingKey, _ target: Target, availableValueRange: ClosedRange<Double>) {
        self.target = target
        self.availableValueRange = availableValueRange
        _localValue = State(initialValue: SettingKey.value)

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
            let size = localValue == -1 ? SettingKey.defaultValue : localValue
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
        Toggle("自動", isOn: .init(get: {SettingKey.value == -1}, set: {
            if $0 {
                SettingKey.value = -1
                localValue = -1
            } else {
                SettingKey.value = SettingKey.defaultValue
                localValue = SettingKey.defaultValue
            }
        }))

        if localValue != -1 {
            Slider(value: $localValue, in: availableValueRange) { (edited: Bool) in
                if edited {
                    SettingKey.value = localValue
                }
            }
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
