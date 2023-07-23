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

public enum UserMadeCustard: Codable, Sendable {
    case gridScroll(UserMadeGridScrollCustard)
    case tenkey(UserMadeTenKeyCustard)
}

public extension UserMadeCustard {
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

public struct UserMadeGridScrollCustard: Codable, Sendable {
    public init(tabName: String, direction: CustardInterfaceLayoutScrollValue.ScrollDirection, columnCount: String, rowCount: String, words: String, addTabBarAutomatically: Bool) {
        self.tabName = tabName
        self.direction = direction
        self.columnCount = columnCount
        self.rowCount = rowCount
        self.words = words
        self.addTabBarAutomatically = addTabBarAutomatically
    }

    public var tabName: String
    public var direction: CustardInterfaceLayoutScrollValue.ScrollDirection
    public var columnCount: String
    public var rowCount: String
    public var words: String
    public var addTabBarAutomatically: Bool
}

public struct UserMadeTenKeyCustard: Codable, Sendable {
    public init(tabName: String, rowCount: String, columnCount: String, inputStyle: CustardInputStyle, language: CustardLanguage, keys: [KeyPosition: UserMadeTenKeyCustard.KeyData], emptyKeys: Set<KeyPosition> = [], addTabBarAutomatically: Bool) {
        self.tabName = tabName
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.inputStyle = inputStyle
        self.language = language
        self.keys = keys
        self.emptyKeys = emptyKeys
        self.addTabBarAutomatically = addTabBarAutomatically
    }

    public var tabName: String
    public var rowCount: String
    public var columnCount: String
    public var inputStyle: CustardInputStyle
    public var language: CustardLanguage
    public var keys: [KeyPosition: KeyData]
    public var emptyKeys: Set<KeyPosition> = []
    public var addTabBarAutomatically: Bool

    public struct KeyData: Codable, Hashable, Sendable {
        public init(model: CustardInterfaceKey, width: Int, height: Int) {
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

        public var model: CustardInterfaceKey
        public var width: Int
        public var height: Int

        public func encode(to encoder: Encoder) throws {
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

        public init(from decoder: Decoder) throws {
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
