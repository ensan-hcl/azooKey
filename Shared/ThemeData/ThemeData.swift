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
    var pictureFileName: String?
    var textColor: Color
    var textFont: ThemeFontWeight
    var resultTextColor: Color
    var borderColor: Color
    var keyBackgroundColorOpacity: Double

    static let `default`: Self = Self.init(pictureFileName: nil, textColor: .primary, textFont: .regular, resultTextColor: .primary, borderColor: .clear, keyBackgroundColorOpacity: 1)

    static let mock: Self = Self.init(pictureFileName: "wallPaperMock", textColor: Color(.displayP3, white: 1, opacity: 1), textFont: .bold, resultTextColor: Color(.displayP3, white: 1, opacity: 1), borderColor: Color(.displayP3, white: 0, opacity: 0), keyBackgroundColorOpacity: 0.3)

    static let clear: Self = Self.init(pictureFileName: "wallPaperMock", textColor: Color(.displayP3, white: 1, opacity: 1), textFont: .bold, resultTextColor: Color(.displayP3, white: 1, opacity: 1), borderColor: Color(.displayP3, white: 1, opacity: 0), keyBackgroundColorOpacity: 0.001)
}

enum ThemePicture: Codable {
    case none
    case path(String)
    case asset(String)
    case uiImage(UIImage)

    var image: Image? {
        switch self{
        case .none:
            return nil
        case let .path(path):
            let data = Data()   //この部分でpathから画像を読み込む
            return UIImage(data: data).flatMap{Image(uiImage: $0)}
        case let .asset(name):
            return Image(name)
        case let .uiImage(uiImage):
            return Image(uiImage: uiImage)
        }
    }

    enum DecodeError: Error {
        case emptyPath
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let valueType = try values.decode(ValueType.self, forKey: .value)
        let value = try values.decode(String?.self, forKey: .value)
        switch valueType{
        case .none:
            self = .none
        case .path:
            guard let path = value else{ throw DecodeError.emptyPath }
            self = .path(path)
        case .asset:
            guard let name = value else{ throw DecodeError.emptyPath }
            self = .asset(name)
        }
    }

    private enum ValueType: String, Codable {
        case none
        case path
        case asset
    }

    enum CodingKeys: String, CodingKey {
        case valueType
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let valueType: ValueType
        let value: String?
        switch self{
        case .none:
            valueType = .none
            value = nil
        case let .path(path):
            valueType = .path
            value = path
        case let .asset(name):
            valueType = .asset
            value = name
        case let .uiImage(uiImage):
            //ここでuiImageを保存する
            valueType = .path
            value = "path"
        }

        try container.encode(valueType, forKey: .valueType)
        try container.encode(value, forKey: .value)
    }

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

