//
//  TabBarData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import CustardKit

enum TabBarItemLabelType: Codable, Equatable {
    case text(String)
    case imageAndText(ImageAndText)
    case image(String)

    struct ImageAndText: Codable, Equatable {
        let systemName: String
        let text: String
    }
}

extension TabBarItemLabelType {
    private enum CodingKeys: CodingKey {
        case text
        case imageAndText
        case image
    }

    private var key: CodingKeys {
        switch self {
        case .image: return .image
        case .text: return .text
        case .imageAndText: return .imageAndText
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .text(value as Encodable), let .imageAndText(value as Encodable), let .image(value as Encodable):
            try value.containerEncode(container: &container, key: self.key)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unabled to decode TabBarItemLabelType.")
            )
        }
        switch key {
        case .text:
            let value = try container.decode(String.self, forKey: .text)
            self = .text(value)
        case .imageAndText:
            let value = try container.decode(ImageAndText.self, forKey: .imageAndText)
            self = .imageAndText(value)
        case .image:
            let value = try container.decode(String.self, forKey: .image)
            self = .image(value)
        }
    }
}

struct TabBarItem: Codable {
    let label: TabBarItemLabelType
    let actions: [CodableActionData]
}

struct TabBarData: Codable {
    let identifier: Int
    let items: [TabBarItem]

    static let `default` = TabBarData(identifier: 0, items: [
        TabBarItem(label: .text("片手"), actions: [.enableResizingMode, .toggleTabBar]),
        TabBarItem(label: .text("あいう"), actions: [.moveTab(.system(.user_japanese))]),
        TabBarItem(label: .text("ABC"), actions: [.moveTab(.system(.user_english))]),
        TabBarItem(label: .text("閉じる"), actions: [.dismissKeyboard])
    ])
}
