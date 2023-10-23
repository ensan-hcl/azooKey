//
//  KeyLabel.swift
//  Keyboard
//
//  Created by ensan on 2020/10/20.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public enum KeyLabelType {
    case text(String)
    case symbols([String])
    case image(String)
    case customImage(String)
    case changeKeyboard
    case selectable(String, String)
}

@MainActor
public struct KeyLabel<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    private let labelType: KeyLabelType
    private let width: CGFloat
    private var textColor: Color?
    private var textSize: Design.Fonts.LabelFontSizeStrategy
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action
    @EnvironmentObject private var variableStates: VariableStates

    private var mainKeyColor: Color {
        textColor ?? theme.textColor.color
    }

    init(_ type: KeyLabelType, width: CGFloat, textSize: Design.Fonts.LabelFontSizeStrategy = .large, textColor: Color? = nil) {
        self.labelType = type
        self.width = width
        self.textColor = textColor
        self.textSize = textSize
    }

    private var keyViewFontSize: CGFloat {
        Extension.SettingProvider.keyViewFontSize
    }

    public var body: some View {
        switch self.labelType {
        case let .text(text):
            let font = Design.fonts.keyLabelFont(text: text, width: width, fontSize: self.textSize, userDecidedSize: keyViewFontSize, layout: variableStates.keyboardLayout, theme: theme)
            Text(text)
                .font(font)
                .foregroundStyle(mainKeyColor)
                .allowsHitTesting(false)

        case let .symbols(symbols):
            let mainText = symbols.first!
            let font = Design.fonts.keyLabelFont(text: mainText, width: width, fontSize: self.textSize, userDecidedSize: keyViewFontSize, layout: variableStates.keyboardLayout, theme: theme)
            let subText = symbols.dropFirst().joined()
            let subFont = Design.fonts.keyLabelFont(text: subText, width: width, fontSize: .xsmall, userDecidedSize: keyViewFontSize, layout: variableStates.keyboardLayout, theme: theme)
            VStack {
                Text(mainText)
                    .font(font)
                Text(subText)
                    .font(subFont)
            }
            .foregroundStyle(mainKeyColor)
            .allowsHitTesting(false)

        case let .image(imageName):
            Image(systemName: imageName)
                .font(Design.fonts.iconImageFont(keyViewFontSizePreference: Extension.SettingProvider.keyViewFontSize, theme: theme))
                .foregroundStyle(mainKeyColor)
                .allowsHitTesting(false)

        case let .customImage(imageName):
            Image(imageName)
                .resizable()
                .frame(width: 30, height: 30, alignment: .leading)
                .allowsHitTesting(false)

        case .changeKeyboard:
            (self.action.makeChangeKeyboardButtonView() as ChangeKeyboardButtonView<Extension>)
                .foregroundStyle(mainKeyColor)

        case let .selectable(primary, secondery):
            let font = Design.fonts.keyLabelFont(text: primary + primary, width: width, fontSize: self.textSize, userDecidedSize: keyViewFontSize, layout: variableStates.keyboardLayout, theme: theme)
            let subFont = Design.fonts.keyLabelFont(text: secondery + secondery, width: width, fontSize: .small, userDecidedSize: keyViewFontSize, layout: variableStates.keyboardLayout, theme: theme)

            HStack(alignment: .bottom) {
                Text(primary)
                    .font(font)
                    .padding(.trailing, -5)
                    .foregroundStyle(mainKeyColor)
                Text(secondery)
                    .font(subFont.bold())
                    .foregroundStyle(.gray)
                    .padding(.leading, -5)
                    .offset(y: -1)
            }.allowsHitTesting(false)
        }
    }

    consuming func textColor(_ color: Color?) -> Self {
        self.textColor = color
        return self
    }
    consuming func textSize(_ textSize: Design.Fonts.LabelFontSizeStrategy) -> Self {
        self.textSize = textSize
        return self
    }
}
