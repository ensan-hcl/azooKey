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
    internal init(tabName: String, direction: CustardInterfaceLayoutScrollValue.ScrollDirection, columnCount: String, screenRowCount: String, words: String) {
        self.tabName = tabName
        self.direction = direction
        self.columnCount = columnCount
        self.screenRowCount = screenRowCount
        self.words = words
    }

    var tabName: String
    var direction: CustardInterfaceLayoutScrollValue.ScrollDirection
    var columnCount: String
    var screenRowCount: String
    var words: String
}

extension UserMadeCustard{
    enum CodingKeys: CodingKey{
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
        guard let key = container.allKeys.first else{
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
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

