//
//  KeyboardType.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum LanguageLayout {
    case flick
    case qwerty
    case custard(String)
}

extension LanguageLayout: Codable {
    enum CodingKeys: CodingKey{
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
        guard let key = container.allKeys.first else{
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

extension LanguageLayout: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs){
        case (.flick, .flick), (.qwerty, .qwerty): return true
        case let (.custard(l), .custard(r)): return l == r
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .flick:
            hasher.combine(CodingKeys.flick)
        case .qwerty:
            hasher.combine(CodingKeys.qwerty)
        case let .custard(value):
            hasher.combine(CodingKeys.custard)
            hasher.combine(value)
        }

    }
}

extension LanguageLayout: Savable {
    typealias SaveValue = Data
    var saveValue: Data {
        if let encodedValue = try? JSONEncoder().encode(self) {
            return encodedValue
        }else{
            return Data()
        }
    }

    static func get(_ value: Any) -> LanguageLayout? {
        if let data = value as? Data, let layout = try? JSONDecoder().decode(Self.self, from: data){
            return layout
        }
        return nil
    }
}
