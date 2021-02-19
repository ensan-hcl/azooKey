//
//  CustardData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/18.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

enum CustardLanguage: String, Codable {
    case english
    case japanese
}

enum CustardInputStyle: String, Codable {
    case direct
    case roman2kana
}

struct Custard: Codable {
    let identifier: String
    let display_name: String
    let language: CustardLanguage
    let input_style: CustardInputStyle
    let interface: CustardInterface
}

enum CustardInterfaceStyle: String, Codable {
    case flick
    case qwerty
}

enum CustardInterfaceLayout: Codable {
    ///画面いっぱいにマス目状で均等に配置されます。
    case gridFit(CustardInterfaceLayoutGridValue)
    ///はみ出した分はスクロールできる形で配置されます。スクロール方向と垂直方向には画面いっぱいに配置します。
    case scrollFit(CustardInterfaceLayoutScrollValue)

}

struct CustardInterfaceLayoutGridValue: Codable {
    ///横方向に配置するキーの数。3以上を推奨。
    let width: Int
    ///縦方向に配置するキーの数。4以上を推奨。
    let height: Int
}

struct CustardInterfaceLayoutScrollValue: Codable {
    ///スクロールの方向
    let direction: ScrollDirection
    ///一列に配置するキーの数
    let columnKeyCount: Int
    ///画面内に収まるスクロール方向のキーの数
    let screenRowKeyCount: Double

    enum ScrollDirection: String, Codable{
        case vertical
        case horizontal
    }
}


extension CustardInterfaceLayout{
    enum CodingKeys: CodingKey{
        case grid_fit
        case scroll_fit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gridFit(value):
            try container.encode(value, forKey: .grid_fit)
        case let .scrollFit(value):
            try container.encode(value, forKey: .scroll_fit)
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
        case .grid_fit:
            let value = try container.decode(
                CustardInterfaceLayoutGridValue.self,
                forKey: .grid_fit
            )
            self = .gridFit(value)
        case .scroll_fit:
            let value = try container.decode(
                CustardInterfaceLayoutScrollValue.self,
                forKey: .scroll_fit
            )
            self = .scrollFit(value)
        }
    }
}

struct GridCoordinator: Codable, Hashable {
    let x: Int
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

enum CustardKeyCoordinator: Codable, Hashable {
    case grid(GridCoordinator)
}

extension CustardKeyCoordinator {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .grid(value):
            hasher.combine(CodingKeys.grid)
            hasher.combine(value)
        }
    }
}
extension CustardKeyCoordinator{
    enum CodingKeys: CodingKey{
        case grid
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .grid(value):
            try container.encode(value, forKey: .grid)
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
        case .grid:
            let value = try container.decode(
                GridCoordinator.self,
                forKey: .grid
            )
            self = .grid(value)
        }
    }
}


struct CustardInterface: Codable {
    let key_style: CustardInterfaceStyle
    let key_layout: CustardInterfaceLayout
    let keys: [CustardKeyCoordinator: CustardInterfaceKey]
}

enum CustardKeyLabelStyle: Codable {
    case text(String)
    case systemImage(String)
}

extension CustardKeyLabelStyle{
    enum CodingKeys: CodingKey{
        case text
        case systemImage
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .text(value):
            try container.encode(value, forKey: .text)
        case let .systemImage(value):
            try container.encode(value, forKey: .systemImage)
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
        case .text:
            let value = try container.decode(
                String.self,
                forKey: .text
            )
            self = .text(value)
        case .systemImage:
            let value = try container.decode(
                String.self,
                forKey: .systemImage
            )
            self = .systemImage(value)
        }
    }
}

enum CustardKeyActionTrigger: String, Codable {
    case press
    case longpress
}

enum CustardKeyAction: Codable {
    case input(String)
    case exchangeCharacter
    case delete(Int)
    case smoothDelete
    case enter
    case moveCursor(Int)
    case moveTab(String)
    case toggleCursorMovingView
    case toggleCapsLockState
}

extension CustardKeyAction{
    enum CodingKeys: CodingKey{
        case input
        case exchange_character
        case delete
        case smooth_delete
        case enter
        case move_cursor
        case move_tab
        case toggle_cursor_moving_view
        case toggle_caps_lock_state
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .input(value):
            try container.encode(value, forKey: .input)
        case .exchangeCharacter:
            try container.encode(true, forKey: .exchange_character)
        case let .delete(value):
            try container.encode(value, forKey: .delete)
        case .smoothDelete:
            try container.encode(true, forKey: .smooth_delete)
        case .enter:
            try container.encode(true, forKey: .enter)
        case let .moveCursor(value):
            try container.encode(value, forKey: .move_cursor)
        case let .moveTab(destination):
            try container.encode(destination, forKey: .move_tab)
        case .toggleCursorMovingView:
            try container.encode(true, forKey: .toggle_cursor_moving_view)
        case .toggleCapsLockState:
            try container.encode(true, forKey: .toggle_caps_lock_state)
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
        case .input:
            let value = try container.decode(
                String.self,
                forKey: .input
            )
            self = .input(value)
        case .exchange_character:
            self = .exchangeCharacter
        case .delete:
            let value = try container.decode(
                Int.self,
                forKey: .delete
            )
            self = .delete(value)
        case .smooth_delete:
            self = .smoothDelete
        case .enter:
            self = .enter
        case .move_cursor:
            let value = try container.decode(
                Int.self,
                forKey: .move_cursor
            )
            self = .moveCursor(value)
        case .move_tab:
            let destination = try container.decode(
                String.self,
                forKey: .move_tab
            )
            self = .moveTab(destination)
        case .toggle_cursor_moving_view:
            self = .toggleCursorMovingView
        case .toggle_caps_lock_state:
            self = .toggleCapsLockState
        }
    }
}

enum CustardKeyVariationType: Codable {
    case flick(FlickDirection)
    case variations
}

extension CustardKeyVariationType{
    enum CodingKeys: CodingKey{
        case flick
        case variations
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .flick(flickDirection):
            try container.encode(flickDirection, forKey: .flick)
        case .variations:
            try container.encode(true, forKey: .variations)
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
        case .flick:
            let direction = try container.decode(
                FlickDirection.self,
                forKey: .flick
            )
            self = .flick(direction)
        case .variations:
            self = .variations
        }
    }
}

enum CustardInterfaceSystemKey: String, Codable {
    case change_keyboard
}

enum CustardInterfaceKey: Codable {
    case system(CustardInterfaceSystemKey)
    case custom(CustardInterfaceCustomKey)
}

extension CustardInterfaceKey{
    enum CodingKeys: CodingKey{
        case system
        case custom
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .system(value):
            try container.encode(value, forKey: .system)
        case let .custom(value):
            try container.encode(value, forKey: .custom)
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
        case .system:
            let value = try container.decode(
                CustardInterfaceSystemKey.self,
                forKey: .system
            )
            self = .system(value)
        case .custom:
            let value = try container.decode(
                CustardInterfaceCustomKey.self,
                forKey: .custom
            )
            self = .custom(value)
        }
    }
}

struct CustardInterfaceCustomKey: Codable {
    let label: CustardKeyLabelStyle
    let press_action: [CustardKeyAction]
    let longpress_action: [CustardKeyAction]
    let variation: [CustardInterfaceVariation]
}

struct CustardInterfaceVariation: Codable {
    let type: CustardKeyVariationType
    let key: CustardInterfaceVariationKey
}

struct CustardInterfaceVariationKey: Codable {
    let label: CustardKeyLabelStyle
    let press_action: [CustardKeyAction]
    let longpress_action: [CustardKeyAction]
}

extension Custard{
    static let mock = Custard(
        identifier: "my_custard",
        display_name: "マイカスタード",
        language: .japanese,
        input_style: .direct,
        interface: .init(
            key_style: .flick,
            key_layout: .gridFit(.init(width: 2, height: 2)),
            keys: [
                .grid(.init(x: 0, y: 0)): .custom(
                    .init(
                        label: .text("削除"),
                        press_action: [.delete(1)],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .flick(.left),
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 1, y: 0)): .custom(
                    .init(
                        label: .text("入力"),
                        press_action: [.input("あ")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .flick(.left),
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 0, y: 1)): .custom(
                    .init(
                        label: .text("削除"),
                        press_action: [.delete(1)],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .flick(.left),
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 1, y: 1)): .custom(
                    .init(
                        label: .text("削除"),
                        press_action: [.delete(1)],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .flick(.left),
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                )
            ]
        )
    )
}
