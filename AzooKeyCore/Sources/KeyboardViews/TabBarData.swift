//
//  TabBarData.swift
//  azooKey
//
//  Created by ensan on 2021/02/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUtils

public enum TabBarItemLabelType: Codable, Equatable {
    case text(String)
    case imageAndText(ImageAndText)
    case image(String)

    public struct ImageAndText: Codable, Equatable {
        public init(systemName: String, text: String) {
            self.systemName = systemName
            self.text = text
        }

        public let systemName: String
        public let text: String
    }
}

public extension TabBarItemLabelType {
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

public struct TabBarItem: Codable {
    public init(label: TabBarItemLabelType, actions: [CodableActionData]) {
        self.label = label
        self.actions = actions
    }

    public let label: TabBarItemLabelType
    public let actions: [CodableActionData]
}

public struct TabBarData: Codable {
    public init(identifier: Int, lastUpdateDate: Date? = Date(), items: [TabBarItem]) {
        self.identifier = identifier
        self.lastUpdateDate = lastUpdateDate
        self.items = items
    }

    public let identifier: Int
    public var lastUpdateDate: Date? = Date()
    public var items: [TabBarItem]

    public static let `default` = TabBarData(identifier: 0, items: [
        TabBarItem(label: .text("片手"), actions: [.enableResizingMode, .toggleTabBar]),
        TabBarItem(label: .text("あいう"), actions: [.moveTab(.system(.user_japanese))]),
        TabBarItem(label: .text("ABC"), actions: [.moveTab(.system(.user_english))]),
        TabBarItem(label: .text("絵文字"), actions: [.moveTab(.system(.emoji_tab))]),
        TabBarItem(label: .text("閉じる"), actions: [.dismissKeyboard])
    ])
}
