//
//  KeyLabel.swift
//  Keyboard
//
//  Created by ensan on 2020/10/20.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyLabelType {
    case text(String)
    case symbols([String])
    case image(String)
    case customImage(String)
    case changeKeyboard
    case selectable(String, String)
}

struct KeyLabel: View {
    private let labelType: KeyLabelType
    private let width: CGFloat
    private let textColor: Color?
    private let textSize: Design.Fonts.LabelFontSizeStrategy
    @Environment(\.themeEnvironment) private var theme
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

    var body: some View {
        Group {
            switch self.labelType {
            case let .text(text):
                let font = Design.fonts.keyLabelFont(text: text, width: width, fontSize: self.textSize, layout: variableStates.keyboardLayout, theme: theme)
                Text(text)
                    .font(font)
                    .foregroundColor(mainKeyColor)
                    .allowsHitTesting(false)

            case let .symbols(symbols):
                let mainText = symbols.first!
                let font = Design.fonts.keyLabelFont(text: mainText, width: width, fontSize: self.textSize, layout: variableStates.keyboardLayout, theme: theme)
                let subText = symbols.dropFirst().joined()
                let subFont = Design.fonts.keyLabelFont(text: subText, width: width, fontSize: .xsmall, layout: variableStates.keyboardLayout, theme: theme)
                VStack {
                    Text(mainText)
                        .font(font)
                    Text(subText)
                        .font(subFont)
                }
                .foregroundColor(mainKeyColor)
                .allowsHitTesting(false)

            case let .image(imageName):
                Image(systemName: imageName)
                    .font(Design.fonts.iconImageFont(theme: theme))
                    .foregroundColor(mainKeyColor)
                    .allowsHitTesting(false)

            case let .customImage(imageName):
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .allowsHitTesting(false)

            case .changeKeyboard:
                self.action.makeChangeKeyboardButtonView()
                    .foregroundColor(mainKeyColor)

            case let .selectable(primary, secondery):
                let font = Design.fonts.keyLabelFont(text: primary + primary, width: width, fontSize: self.textSize, layout: variableStates.keyboardLayout, theme: theme)
                let subFont = Design.fonts.keyLabelFont(text: secondery + secondery, width: width, fontSize: .small, layout: variableStates.keyboardLayout, theme: theme)

                HStack(alignment: .bottom) {
                    Text(primary)
                        .font(font)
                        .padding(.trailing, -5)
                        .foregroundColor(mainKeyColor)
                    Text(secondery)
                        .font(subFont.bold())
                        .foregroundColor(.gray)
                        .padding(.leading, -5)
                        .offset(y: -1)
                }.allowsHitTesting(false)

            }
        }
    }
}
