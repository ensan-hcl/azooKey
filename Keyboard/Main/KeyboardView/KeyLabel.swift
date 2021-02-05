//
//  KeyLabel.swift
//  Keyboard
//
//  Created by β α on 2020/10/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyLabelType{
    case text(String)
    case symbols([String])
    case image(String)
    case customImage(String)
    case changeKeyboard
    case selectable(String, String)
}

struct KeyLabel: View {
    enum TextSize{
        case large
        case medium
        case small
        case xsmall

        var scale: CGFloat {
            switch self {
            case .large:
                return 1
            case .medium:
                return 0.8
            case .small:
                return 0.7
            case .xsmall:
                return 0.6
            }
        }
    }

    private var labelType: KeyLabelType
    private var width: CGFloat
    private let textSize: TextSize

    private var mainKeyColor: Color {
        Design.shared.themeManager.theme.textColor
    }

    init(_ type: KeyLabelType, width: CGFloat, textSize: TextSize = .large){
        self.labelType = type
        self.width = width
        self.textSize = textSize
    }

    var body: some View {
        Group{
            switch self.labelType{
            case let .text(text):
                let font = Design.shared.fonts.keyLabelFont(text: text, width: width, scale: self.textSize.scale)
                Text(text)
                    .font(font)
                    .foregroundColor(mainKeyColor)
                    .allowsHitTesting(false)

            case let .symbols(symbols):
                let mainText = symbols.first!
                let font = Design.shared.fonts.keyLabelFont(text: mainText, width: width, scale: self.textSize.scale)
                let subText = symbols.dropFirst().joined()
                let subFont = Design.shared.fonts.keyLabelFont(text: subText, width: width, scale: TextSize.xsmall.scale)
                VStack{
                    Text(mainText)
                        .font(font)
                    Text(subText)
                        .font(subFont)
                }
                .foregroundColor(mainKeyColor)
                .allowsHitTesting(false)

            case let .image(imageName):
                Image(systemName: imageName)
                    .font(Design.shared.fonts.iconImageFont)
                    .foregroundColor(mainKeyColor)
                    .allowsHitTesting(false)

            case let .customImage(imageName):
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .allowsHitTesting(false)

            case .changeKeyboard:
                Store.shared.action.makeChangeKeyboardButtonView()
                    .foregroundColor(mainKeyColor)

            case let .selectable(primary, secondery):
                let font = Design.shared.fonts.keyLabelFont(text: primary+primary, width: width, scale: self.textSize.scale)
                let subFont = Design.shared.fonts.keyLabelFont(text: secondery+secondery, width: width, scale: TextSize.small.scale)
            
                HStack(alignment: .bottom){
                    Text(primary)
                        .font(font)
                        .padding(.trailing, -5)
                        .foregroundColor(mainKeyColor)
                    Text(secondery)
                        .font(subFont)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.leading, -5)
                        .offset(y: -1)
                }.allowsHitTesting(false)

            }
        }
    }
}
