//
//  ThemePicture.swift
//  azooKey
//
//  Created by ensan on 2021/02/08.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUtils

public enum ThemePicture: Equatable {
    case none
    case path(String)
    case asset(String)
    case uiImage(UIImage)

    public var image: Image? {
        switch self {
        case .none:
            return nil
        case let .path(path):
            debug(#file, #line, "ThemePicture.image for case `path(\(path))` is not implemented")
            return nil
        case let .asset(name):
            return Image(name)
        case let .uiImage(uiImage):
            return Image(uiImage: uiImage)
        }
    }
}

extension ThemePicture: Codable {
    enum EncodeError: Error {
        case uiImageCannotEncode
    }

    enum DecodeError: Error {
        case emptyPath
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let valueType = try values.decode(ValueType.self, forKey: .valueType)
        let value = try values.decodeIfPresent(String.self, forKey: .value)
        switch valueType {
        case .none:
            self = .none
        case .path:
            guard let path = value else { throw DecodeError.emptyPath }
            self = .path(path)
        case .asset:
            guard let name = value else { throw DecodeError.emptyPath }
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
        switch self {
        case .none:
            valueType = .none
            value = nil
        case let .path(path):
            valueType = .path
            value = path
        case let .asset(name):
            valueType = .asset
            value = name
        case .uiImage:
            throw EncodeError.uiImageCannotEncode
        }

        try container.encode(valueType, forKey: .valueType)
        try container.encode(value, forKey: .value)
    }

}
