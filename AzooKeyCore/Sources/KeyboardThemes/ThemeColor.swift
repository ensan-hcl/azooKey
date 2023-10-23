//
//  ThemeColor.swift
//  azooKey
//
//  Created by ensan on 2021/02/08.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public enum ThemeColor<SystemColor: ApplicationSpecificColor>: Sendable {
    case color(Color)
    case system(SystemColor)
    case dynamic(DynamicColor)

    public var color: Color {
        switch self {
        case let .color(color):
            return color
        case let .system(systemColor):
            return systemColor.color
        case let .dynamic(dynamicColor):
            return dynamicColor.color
        }
    }

    public enum DynamicColor: String, Codable, CaseIterable, Sendable {
        case accentColor
        case black
        case blue
        case clear
        case gray
        case green
        case orange
        case pink
        case primary
        case purple
        case red
        case secondary
        case yellow
        case white

        var color: Color {
            switch self {
            case .accentColor: return .accentColor
            case .black: return .black
            case .blue: return .blue
            case .clear: return .clear
            case .gray: return .gray
            case .green: return .green
            case .orange: return .orange
            case .pink: return .pink
            case .primary: return .primary
            case .purple: return .purple
            case .red: return .red
            case .secondary: return .secondary
            case .yellow: return .yellow
            case .white: return .white
            }
        }
    }

}

extension ThemeColor: Codable, Equatable {
    enum DecodeError: Error {
        case emptyData
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let color = try values.decode(Color?.self, forKey: .color)
        let systemColor = try values.decode(SystemColor?.self, forKey: .systemColor)
        let dynamicColor = try values.decode(DynamicColor?.self, forKey: .dynamicColor)

        if let color {
            self = .color(color)
        } else if let systemColor = systemColor {
            self = .system(systemColor)
        } else if let dynamicColor = dynamicColor {
            self = .dynamic(dynamicColor)
        } else {
            throw DecodeError.emptyData
        }
    }

    enum CodingKeys: String, CodingKey {
        case color
        case systemColor
        case dynamicColor
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let color: Color?
        let systemColor: SystemColor?
        let dynamicColor: DynamicColor?
        switch self {
        case let .color(_color):
            if let matchedDynamicColor = DynamicColor.allCases.first(where: {$0.color == _color}) {
                color = nil
                systemColor = nil
                dynamicColor = matchedDynamicColor
            } else {
                color = _color
                systemColor = nil
                dynamicColor = nil
            }
        case let .system(_systemColor):
            color = nil
            systemColor = _systemColor
            dynamicColor = nil
        case let .dynamic(_dynamicColor):
            color = nil
            systemColor = nil
            dynamicColor = _dynamicColor
        }

        try container.encode(color, forKey: .color)
        try container.encode(systemColor, forKey: .systemColor)
        try container.encode(dynamicColor, forKey: .dynamicColor)
    }

}

extension Color: Codable {
    enum EncodeError: Error {
        case dynamicColor(Color)
    }

    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case opacity
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let red = try values.decode(Double.self, forKey: .red)
        let green = try values.decode(Double.self, forKey: .green)
        let blue = try values.decode(Double.self, forKey: .blue)
        let opacity = try values.decode(Double.self, forKey: .opacity)
        self.init(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let rgba = self.cgColor?.components else {
            throw EncodeError.dynamicColor(self)
        }
        try container.encode(rgba[0], forKey: .red)
        try container.encode(rgba[1], forKey: .green)
        try container.encode(rgba[2], forKey: .blue)
        try container.encode(rgba[3], forKey: .opacity)
    }
}
