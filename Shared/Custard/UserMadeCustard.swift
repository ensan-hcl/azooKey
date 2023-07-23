//
//  UserMadeCustard.swift
//  azooKey
//
//  Created by ensan on 2021/02/23.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import KeyboardViews

enum UserMadeCustard: Codable {
    case gridScroll(UserMadeGridScrollCustard)
    case tenkey(UserMadeTenKeyCustard)
}

extension UserMadeCustard {
    enum CodingKeys: CodingKey {
        case gridScroll
        case tenkey
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gridScroll(value):
            try container.encode(value, forKey: .gridScroll)
        case let .tenkey(value):
            try container.encode(value, forKey: .tenkey)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode UserMadeCustard."
                )
            )
        }
        switch key {
        case .gridScroll:
            let value = try container.decode(
                UserMadeGridScrollCustard.self,
                forKey: .gridScroll
            )
            self = .gridScroll(value)
        case .tenkey:
            let value = try container.decode(
                UserMadeTenKeyCustard.self,
                forKey: .tenkey
            )
            self = .tenkey(value)
        }
    }
}

struct UserMadeGridScrollCustard: Codable {
    var tabName: String
    var direction: CustardInterfaceLayoutScrollValue.ScrollDirection
    var columnCount: String
    var rowCount: String
    var words: String
    var addTabBarAutomatically: Bool
}

struct UserMadeTenKeyCustard: Codable {
    var tabName: String
    var rowCount: String
    var columnCount: String
    var inputStyle: CustardInputStyle
    var language: CustardLanguage
    var keys: [KeyPosition: KeyData]
    var emptyKeys: Set<KeyPosition> = []
    var addTabBarAutomatically: Bool

    struct KeyData: Codable, Hashable {
        init(model: CustardInterfaceKey, width: Int, height: Int) {
            self.model = model
            self.width = width
            self.height = height
        }

        private enum CodingKeys: CodingKey {
            case type, key, width, height
        }

        private enum ModelType: String, Codable {
            case system, custom
        }

        var model: CustardInterfaceKey
        var width: Int
        var height: Int

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            switch self.model {
            case let .system(value):
                try container.encode(ModelType.system, forKey: .type)
                try container.encode(value, forKey: .key)
            case let .custom(value):
                try container.encode(ModelType.custom, forKey: .type)
                try container.encode(value, forKey: .key)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.width = try container.decode(Int.self, forKey: .width)
            self.height = try container.decode(Int.self, forKey: .height)
            let type = try container.decode(ModelType.self, forKey: .type)
            switch type {
            case .system:
                let key = try container.decode(CustardInterfaceSystemKey.self, forKey: .key)
                self.model = .system(key)
            case .custom:
                let key = try container.decode(CustardInterfaceCustomKey.self, forKey: .key)
                self.model = .custom(key)
            }
        }
    }
}
