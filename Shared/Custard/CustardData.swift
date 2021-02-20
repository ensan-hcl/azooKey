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
    ///はみ出した分はスクロールできる形でマス目状に均等に配置されます。
    case gridScroll(CustardInterfaceLayoutScrollValue)

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
        case grid_scroll
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gridFit(value):
            try container.encode(value, forKey: .grid_fit)
        case let .gridScroll(value):
            try container.encode(value, forKey: .grid_scroll)
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
        case .grid_scroll:
            let value = try container.decode(
                CustardInterfaceLayoutScrollValue.self,
                forKey: .grid_scroll
            )
            self = .gridScroll(value)
        }
    }
}

struct GridFitCoordinator: Codable, Hashable {
    let x: Int
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct GridScrollCoordinator: Codable, Hashable {
    let index: Int

    init(_ index: Int){
        self.index = index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

extension GridScrollCoordinator: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int

    init(integerLiteral value: Int) {
        self.index = value
    }
}

enum CustardKeyCoordinator: Codable, Hashable {
    case grid(GridFitCoordinator)
    case scroll(GridScrollCoordinator)
}

extension CustardKeyCoordinator {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .grid(value):
            hasher.combine(CodingKeys.grid)
            hasher.combine(value)
        case let .scroll(value):
            hasher.combine(CodingKeys.scroll)
            hasher.combine(value)
        }
    }
}
extension CustardKeyCoordinator{
    enum CodingKeys: CodingKey{
        case grid
        case scroll
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .grid(value):
            try container.encode(value, forKey: .grid)
        case let .scroll(value):
            try container.encode(value, forKey: .scroll)
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
                GridFitCoordinator.self,
                forKey: .grid
            )
            self = .grid(value)
        case .scroll:
            let value = try container.decode(
                GridScrollCoordinator.self,
                forKey: .scroll
            )
            self = .scroll(value)
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
    case enter
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
    static let mock_flick_grid = Custard(
        identifier: "my_custard",
        display_name: "マイカスタード",
        language: .japanese,
        input_style: .direct,
        interface: .init(
            key_style: .flick,
            key_layout: .gridFit(.init(width: 3, height: 5)),
            keys: [
                .grid(.init(x: 0, y: 0)): .system(.change_keyboard),
                .grid(.init(x: 1, y: 0)): .custom(
                    .init(
                        label: .text("←"),
                        press_action: [.moveCursor(-1)],
                        longpress_action: [.moveCursor(-1)],
                        variation: []
                    )
                ),
                .grid(.init(x: 2, y: 0)): .custom(
                    .init(
                        label: .text("→"),
                        press_action: [.moveCursor(1)],
                        longpress_action: [.moveCursor(1)],
                        variation: []
                    )
                ),
                .grid(.init(x: 0, y: 1)): .custom(
                    .init(
                        label: .text("①"),
                        press_action: [.input("①")],
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
                        label: .text("②"),
                        press_action: [.input("②")],
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
                .grid(.init(x: 2, y: 1)): .custom(
                    .init(
                        label: .text("③"),
                        press_action: [.input("③")],
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
                .grid(.init(x: 0, y: 2)): .custom(
                    .init(
                        label: .text("④"),
                        press_action: [.input("④")],
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
                .grid(.init(x: 1, y: 2)): .custom(
                    .init(
                        label: .text("⑤"),
                        press_action: [.input("⑤")],
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
                .grid(.init(x: 2, y: 2)): .custom(
                    .init(
                        label: .text("⑥"),
                        press_action: [.input("⑥")],
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
                .grid(.init(x: 0, y: 3)): .custom(
                    .init(
                        label: .text("⑦"),
                        press_action: [.input("⑦")],
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
                .grid(.init(x: 1, y: 3)): .custom(
                    .init(
                        label: .text("⑧"),
                        press_action: [.input("⑧")],
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
                .grid(.init(x: 2, y: 3)): .custom(
                    .init(
                        label: .text("⑨"),
                        press_action: [.input("⑨")],
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
                .grid(.init(x: 0, y: 4)): .custom(
                    .init(
                        label: .text("空白"),
                        press_action: [.input(" ")],
                        longpress_action: [.toggleCursorMovingView],
                        variation: []
                    )
                ),
                .grid(.init(x: 1, y: 4)): .system(.enter),
                .grid(.init(x: 2, y: 4)): .custom(
                    .init(
                        label: .systemImage("delete.left"),
                        press_action: [.delete(1)],
                        longpress_action: [.delete(1)],
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

    static let mock_qwerty_grid = Custard(
        identifier: "my_custard_qwerty",
        display_name: "マイカスタード_qwerty",
        language: .japanese,
        input_style: .direct,
        interface: .init(
            key_style: .qwerty,
            key_layout: .gridFit(.init(width: 3, height: 5)),
            keys: [
                .grid(.init(x: 0, y: 0)): .system(.change_keyboard),
                .grid(.init(x: 1, y: 0)): .custom(
                    .init(
                        label: .text("←"),
                        press_action: [.moveCursor(-1)],
                        longpress_action: [.moveCursor(-1)],
                        variation: []
                    )
                ),
                .grid(.init(x: 2, y: 0)): .custom(
                    .init(
                        label: .text("→"),
                        press_action: [.moveCursor(1)],
                        longpress_action: [.moveCursor(1)],
                        variation: []
                    )
                ),
                .grid(.init(x: 0, y: 1)): .custom(
                    .init(
                        label: .text("①"),
                        press_action: [.input("①")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .variations,
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
                        label: .text("②"),
                        press_action: [.input("②")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .variations,
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 2, y: 1)): .custom(
                    .init(
                        label: .text("③"),
                        press_action: [.input("③")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .variations,
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 0, y: 2)): .custom(
                    .init(
                        label: .text("④"),
                        press_action: [.input("④")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .variations,
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 1, y: 2)): .custom(
                    .init(
                        label: .text("⑤"),
                        press_action: [.input("⑤")],
                        longpress_action: [],
                        variation: [
                            .init(
                                type: .variations,
                                key: .init(
                                    label: .text("❌"),
                                    press_action: [.smoothDelete],
                                    longpress_action: []
                                )
                            )
                        ]
                    )
                ),
                .grid(.init(x: 2, y: 2)): .custom(
                    .init(
                        label: .text("⑥"),
                        press_action: [.input("⑥")],
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
                .grid(.init(x: 0, y: 3)): .custom(
                    .init(
                        label: .text("⑦"),
                        press_action: [.input("⑦")],
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
                .grid(.init(x: 1, y: 3)): .custom(
                    .init(
                        label: .text("⑧"),
                        press_action: [.input("⑧")],
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
                .grid(.init(x: 2, y: 3)): .custom(
                    .init(
                        label: .text("⑨"),
                        press_action: [.input("⑨")],
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
                .grid(.init(x: 0, y: 4)): .custom(
                    .init(
                        label: .text("空白"),
                        press_action: [.input(" ")],
                        longpress_action: [.toggleCursorMovingView],
                        variation: []
                    )
                ),
                .grid(.init(x: 1, y: 4)): .system(.enter),
                .grid(.init(x: 2, y: 4)): .custom(
                    .init(
                        label: .systemImage("delete.left"),
                        press_action: [.delete(1)],
                        longpress_action: [.delete(1)],
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

    static let mock_qwerty_scroll = Custard(
        identifier: "my_custard",
        display_name: "マイカスタード",
        language: .japanese,
        input_style: .direct,
        interface: .init(
            key_style: .qwerty,
            key_layout: .gridScroll(.init(direction: .horizontal, columnKeyCount: 4, screenRowKeyCount: 2.2)),
            keys: [
                .scroll(0): .system(.change_keyboard),
                .scroll(1): .custom(
                    .init(
                        label: .text("←"),
                        press_action: [.moveCursor(-1)],
                        longpress_action: [.moveCursor(-1)],
                        variation: []
                    )
                ),
                .scroll(2): .custom(
                    .init(
                        label: .text("→"),
                        press_action: [.moveCursor(1)],
                        longpress_action: [.moveCursor(1)],
                        variation: []
                    )
                ),
                .scroll(3): .custom(
                    .init(
                        label: .text("①"),
                        press_action: [.input("①")],
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
                .scroll(4): .custom(
                    .init(
                        label: .text("②"),
                        press_action: [.input("②")],
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
                .scroll(5): .custom(
                    .init(
                        label: .text("③"),
                        press_action: [.input("③")],
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
                .scroll(6): .custom(
                    .init(
                        label: .text("④"),
                        press_action: [.input("④")],
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
                .scroll(7): .custom(
                    .init(
                        label: .text("⑤"),
                        press_action: [.input("⑤")],
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
                .scroll(8): .custom(
                    .init(
                        label: .text("⑥"),
                        press_action: [.input("⑥")],
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
                .scroll(9): .custom(
                    .init(
                        label: .text("⑦"),
                        press_action: [.input("⑦")],
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
                .scroll(10): .custom(
                    .init(
                        label: .text("⑧"),
                        press_action: [.input("⑧")],
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
                .scroll(11): .custom(
                    .init(
                        label: .text("⑨"),
                        press_action: [.input("⑨")],
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
                .scroll(12): .custom(
                    .init(
                        label: .text("空白"),
                        press_action: [.input(" ")],
                        longpress_action: [.toggleCursorMovingView],
                        variation: []
                    )
                ),
                .scroll(13): .system(.enter),
                .scroll(14): .custom(
                    .init(
                        label: .systemImage("delete.left"),
                        press_action: [.delete(1)],
                        longpress_action: [.delete(1)],
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
