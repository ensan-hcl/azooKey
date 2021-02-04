//
//  ThemeData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/04.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ThemeData: Codable {
    let pictureFileName: String?
    let textColor: Color
    let textFont: ThemeFontWeight
    let borderColor: Color
    let keyBackgroundColorOpacity: CGFloat
}

enum ThemeFontWeight: Int, Codable {
    case normal = 3
    case bold = 6
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

