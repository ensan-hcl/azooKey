//
//  ThemeData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/04.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ThemeData: Codable, Equatable {
    var id: Int? = nil
    var backgroundColor: Color
    var picture: ThemePicture
    var textColor: Color
    var textFont: ThemeFontWeight
    var resultTextColor: Color
    var borderColor: Color
    var borderWidth: Double
    var normalKeyFillColor: ThemeColor
    var specialKeyFillColor: ThemeColor
    var pushedKeyFillColor: ThemeColor   //自動で設定する
    var suggestKeyFillColor: ThemeColor?  //自動で設定する

    static let `default`: Self = Self.init(
        backgroundColor: Design.colors.backGroundColor,
        picture: .none,
        textColor: .primary,
        textFont: .regular,
        resultTextColor: .primary,
        borderColor: .clear,
        borderWidth: 1,
        normalKeyFillColor: .system(.normalKeyColor),
        specialKeyFillColor: .system(.specialKeyColor),
        pushedKeyFillColor: .system(.highlightedKeyColor),
        suggestKeyFillColor: nil
    )

    static let mock: Self = Self.init(
        backgroundColor: Design.colors.backGroundColor,
        picture: .asset("wallPaperMock"),
        textColor: Color(.displayP3, white: 1, opacity: 1),
        textFont: .bold,
        resultTextColor: Color(.displayP3, white: 1, opacity: 1),
        borderColor: Color(.displayP3, white: 0, opacity: 0),
        borderWidth: 1,
        normalKeyFillColor: .system(.normalKeyColor),
        specialKeyFillColor: .system(.specialKeyColor),
        pushedKeyFillColor: .system(.highlightedKeyColor),
        suggestKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 1))
    )

    static let clear: Self = Self.init(
        backgroundColor: Color(.displayP3, white: 1, opacity: 0),
        picture: .asset("wallPaperMock"),
        textColor: Color(.displayP3, white: 1, opacity: 1),
        textFont: .bold,
        resultTextColor: Color(.displayP3, white: 1, opacity: 1),
        borderColor: Color(.displayP3, white: 1, opacity: 0),
        borderWidth: 1,
        normalKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 0.001)),
        specialKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 0.001)),
        pushedKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 0.05)),
        suggestKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 1))
    )
}

enum ThemeFontWeight: Int, Codable {
    case ultraLight = 1
    case thin = 2
    case light = 3
    case regular = 4
    case medium = 5
    case semibold = 6
    case bold = 7
    case heavy = 8
    case black = 9

    var weight: Font.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }

}
