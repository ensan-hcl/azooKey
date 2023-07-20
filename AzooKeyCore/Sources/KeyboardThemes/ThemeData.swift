//
//  ThemeData.swift
//  azooKey
//
//  Created by ensan on 2021/02/04.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public struct ThemeData<ApplicationExtension: ApplicationSpecificTheme>: Codable, Equatable {
    public typealias ColorData = ThemeColor<ApplicationExtension.ApplicationColor>
    public var id: Int?
    public var backgroundColor: ColorData
    public var picture: ThemePicture
    public var textColor: ColorData
    public var textFont: ThemeFontWeight
    public var resultTextColor: ColorData
    public var resultBackgroundColor: ColorData
    public var borderColor: ColorData
    public var borderWidth: Double
    public var normalKeyFillColor: ColorData
    public var specialKeyFillColor: ColorData
    public var pushedKeyFillColor: ColorData   // 自動で設定する
    public var suggestKeyFillColor: ColorData?  // 自動で設定する

    public init(id: Int? = nil, backgroundColor: ColorData, picture: ThemePicture, textColor: ColorData, textFont: ThemeFontWeight, resultTextColor: ColorData, resultBackgroundColor: ColorData, borderColor: ColorData, borderWidth: Double, normalKeyFillColor: ColorData, specialKeyFillColor: ColorData, pushedKeyFillColor: ColorData, suggestKeyFillColor: ColorData? = nil) {
        self.id = id
        self.backgroundColor = backgroundColor
        self.picture = picture
        self.textColor = textColor
        self.textFont = textFont
        self.resultTextColor = resultTextColor
        self.resultBackgroundColor = resultBackgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.normalKeyFillColor = normalKeyFillColor
        self.specialKeyFillColor = specialKeyFillColor
        self.pushedKeyFillColor = pushedKeyFillColor
        self.suggestKeyFillColor = suggestKeyFillColor
    }

    enum CodingKeys: CodingKey {
        case id
        case backgroundColor
        case picture
        case textColor
        case textFont
        case resultTextColor
        case resultBackgroundColor
        case borderColor
        case borderWidth
        case normalKeyFillColor
        case specialKeyFillColor
        case pushedKeyFillColor
        case suggestKeyFillColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let backgroundColor = try container.decode(ColorData.self, forKey: .backgroundColor)
        self.id = try container.decode(Int.self, forKey: .id)
        self.backgroundColor = backgroundColor
        self.picture = try container.decode(ThemePicture.self, forKey: .picture)
        self.textColor = try container.decode(ColorData.self, forKey: .textColor)
        self.textFont = try container.decode(ThemeFontWeight.self, forKey: .textFont)
        self.resultTextColor = try container.decode(ColorData.self, forKey: .resultTextColor)
        self.resultBackgroundColor = (try? container.decode(ColorData.self, forKey: .resultBackgroundColor)) ?? backgroundColor
        self.borderColor = try container.decode(ColorData.self, forKey: .borderColor)
        self.borderWidth = try container.decode(Double.self, forKey: .borderWidth)
        self.normalKeyFillColor = try container.decode(ColorData.self, forKey: .normalKeyFillColor)
        self.specialKeyFillColor = try container.decode(ColorData.self, forKey: .specialKeyFillColor)
        self.pushedKeyFillColor = try container.decode(ColorData.self, forKey: .pushedKeyFillColor)
        self.suggestKeyFillColor = try? container.decode(ColorData?.self, forKey: .suggestKeyFillColor)
    }

}

public enum ThemeFontWeight: Int, Codable {
    case ultraLight = 1
    case thin = 2
    case light = 3
    case regular = 4
    case medium = 5
    case semibold = 6
    case bold = 7
    case heavy = 8
    case black = 9

    public var weight: Font.Weight {
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
