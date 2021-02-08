//
//  ThemeColor.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/08.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum ThemeColor{
    case color(Color)
    case system(SystemColor)

    var color: Color {
        switch self{
        case let .color(color):
            return color
        case let .system(systemColor):
            switch systemColor{
            case .backgroundColor:
                return Design.colors.backGroundColor
            case .normalKeyColor:
                return Design.colors.normalKeyColor
            case .specialKeyColor:
                return Design.colors.specialKeyColor
            case .highlightedKeyColor:
                return Design.colors.highlightedKeyColor
            case .suggestKeyColor:
                return Design.colors.suggestKeyColor
            }
        }
    }

    enum SystemColor: String, Codable{
        case normalKeyColor
        case specialKeyColor
        case highlightedKeyColor
        case suggestKeyColor
        case backgroundColor
    }
}

extension ThemeColor: Codable, Equatable {
    enum DecodeError: Error {
        case emptyData
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let color = try values.decode(Color?.self, forKey: .color)
        let systemColor = try values.decode(SystemColor?.self, forKey: .systemColor)

        if let color = color{
            self = .color(color)
        }else if let systemColor = systemColor{
            self = .system(systemColor)
        }else{
            throw DecodeError.emptyData
        }
    }

    enum CodingKeys: String, CodingKey {
        case color
        case systemColor
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let color: Color?
        let systemColor: SystemColor?

        switch self{
        case let .color(_color):
            color = _color
            systemColor = nil
        case let .system(_systemColor):
            color = nil
            systemColor = _systemColor
        }

        try container.encode(color, forKey: .color)
        try container.encode(systemColor, forKey: .systemColor)
    }

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

