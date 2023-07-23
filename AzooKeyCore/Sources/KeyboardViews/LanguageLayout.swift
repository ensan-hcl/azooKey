//
//  LanguageLayout.swift
//
//
//  Created by ensan on 2023/07/23.
//

import Foundation

public enum LanguageLayout: Codable, Hashable, Sendable {
    case flick
    case qwerty
    case custard(String)
}

public extension LanguageLayout {
    private enum CodingKeys: CodingKey {
        case flick
        case qwerty
        case custard
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .flick:
            try container.encode(true, forKey: .flick)
        case .qwerty:
            try container.encode(true, forKey: .qwerty)
        case let .custard(value):
            try container.encode(value, forKey: .custard)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode LanguageLayout."
                )
            )
        }
        switch key {
        case .flick:
            self = .flick
        case .qwerty:
            self = .qwerty
        case .custard:
            let value = try container.decode(
                String.self,
                forKey: .custard
            )
            self = .custard(value)
        }
    }
}
