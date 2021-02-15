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
    var backgroundColor: ThemeColor
    var picture: ThemePicture
    var textColor: ThemeColor
    var textFont: ThemeFontWeight
    var resultTextColor: ThemeColor
    var borderColor: ThemeColor
    var borderWidth: Double
    var normalKeyFillColor: ThemeColor
    var specialKeyFillColor: ThemeColor
    var pushedKeyFillColor: ThemeColor   //自動で設定する
    var suggestKeyFillColor: ThemeColor?  //自動で設定する

    static let `default`: Self = Self.init(
        backgroundColor: .system(.backgroundColor),
        picture: .none,
        textColor: .dynamic(.primary),
        textFont: .regular,
        resultTextColor: .dynamic(.primary),
        borderColor: .color(Color(white: 0, opacity: 0)),
        borderWidth: 1,
        normalKeyFillColor: .system(.normalKeyColor),
        specialKeyFillColor: .system(.specialKeyColor),
        pushedKeyFillColor: .system(.highlightedKeyColor),
        suggestKeyFillColor: nil
    )

    static let base: Self = Self.init(
        backgroundColor: .color(Color(.displayP3, red: 0.839, green: 0.843, blue: 0.862)),
        picture: .none,
        textColor: .color(Color(.displayP3, white: 0, opacity: 1)),
        textFont: .regular,
        resultTextColor: .color(Color(.displayP3, white: 0, opacity: 1)),
        borderColor: .color(Color(white: 0, opacity: 1)),
        borderWidth: 0,
        normalKeyFillColor: .color(Color(.displayP3, white: 1, opacity: 1)),
        specialKeyFillColor: .color(Color(.displayP3, red: 0.804, green: 0.808, blue: 0.835)),
        pushedKeyFillColor: .color(Color(.displayP3, red: 0.929, green: 0.929, blue: 0.945)),
        suggestKeyFillColor: nil
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
