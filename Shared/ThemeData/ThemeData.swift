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
    var backgroundColor: Color
    var picture: ThemePicture
    var textColor: Color
    var textFont: ThemeFontWeight
    var resultTextColor: Color
    var borderColor: Color
    var borderWidth: Double
    var keyBackgroundColorOpacity: Double

    static let `default`: Self = Self.init(
        backgroundColor: Design.colors.backGroundColor,
        picture: .none,
        textColor: .primary,
        textFont: .regular,
        resultTextColor: .primary,
        borderColor: .clear,
        borderWidth: 1,
        keyBackgroundColorOpacity: 1
    )

    static let mock: Self = Self.init(
        backgroundColor: Design.colors.backGroundColor,
        picture: .asset("wallPaperMock"),
        textColor: Color(.displayP3, white: 1, opacity: 1),
        textFont: .bold,
        resultTextColor: Color(.displayP3, white: 1, opacity: 1),
        borderColor: Color(.displayP3, white: 0, opacity: 0),
        borderWidth: 1,
        keyBackgroundColorOpacity: 0.3
    )

    static let clear: Self = Self.init(
        backgroundColor: Design.colors.backGroundColor,
        picture: .asset("wallPaperMock"),
        textColor: Color(.displayP3, white: 1, opacity: 1),
        textFont: .bold,
        resultTextColor: Color(.displayP3, white: 1, opacity: 1),
        borderColor: Color(.displayP3, white: 1, opacity: 0),
        borderWidth: 1,
        keyBackgroundColorOpacity: 0.001
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
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case opacity
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let red = try values.decode(Double.self, forKey: .red)
        let green = try values.decode(Double.self, forKey: .green)
        let blue = try values.decode(Double.self, forKey: .blue)
        let opacity = try values.decode(Double.self, forKey: .blue)
        self.init(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let rgba = self.cgColor?.components else{
            throw NSError(domain: "Color.encode", code: 34, userInfo: [:])
        }
        try container.encode(rgba[0], forKey: .red)
        try container.encode(rgba[1], forKey: .green)
        try container.encode(rgba[2], forKey: .blue)
        try container.encode(rgba[3], forKey: .opacity)
    }
}

