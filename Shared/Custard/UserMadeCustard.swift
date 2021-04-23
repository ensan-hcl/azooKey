//
//  UserMadeCustard.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

enum UserMadeCustard: Codable {
    case gridScroll(UserMadeGridScrollCustard)
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
    var addTabBarAutomatically: Bool
}

extension UserMadeCustard {
    enum CodingKeys: CodingKey {
        case gridScroll
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gridScroll(value):
            try container.encode(value, forKey: .gridScroll)
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
        }
    }
}
