//
//  CustardData.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/18.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

/// - 変換対象の言語を指定します。
/// - specify language to convert
enum CustardLanguage: String, Codable {
    /// - 英語(アメリカ)に変換します
    /// - convert to American English
    case en_US

    /// - 日本語(共通語)に変換します
    /// - convert to common Japanese
    case ja_JP

    /// - ギリシア語に変換します
    /// - convert to Greek
    case el_GR

    /// - 変換を行いません
    /// - don't convert
    case none

    /// - 特に変換する言語を指定しません
    /// - don't specify
    case undefined
}

/// - 入力方式を指定します。
/// - specify input style
enum CustardInputStyle: String, Codable {
    /// - 入力された文字をそのまま用います
    /// - use inputted characters directly
    case direct

    /// - 入力されたローマ字を仮名に変換して用います
    /// - use roman-kana conversion
    case roman2kana
}

/// - カスタードのバージョンを指定します。
/// - specify custard version
enum CustardVersion: String, Codable {
    case v1_0 = "1.0"
}

struct Custard: Codable {
    ///version
    var custard_version: CustardVersion = .v1_0

    ///identifier
    /// - must be unique
    let identifier: String

    ///display name
    /// - used in tab bar
    let display_name: String

    ///language to convert
    let language: CustardLanguage

    ///input style
    let input_style: CustardInputStyle

    ///interface
    let interface: CustardInterface
}

/// - インターフェースのキーのスタイルです
/// - style of keys
enum CustardInterfaceStyle: String, Codable {
    /// - フリック可能なキー
    /// - flickable keys
    case flick

    /// - 長押しで他の文字を選べるキー
    /// - keys with variations
    case qwerty
}


/// - インターフェースのレイアウトのスタイルです
/// - style of layout
enum CustardInterfaceLayout: Codable {
    /// - 画面いっぱいにマス目状で均等に配置されます
    /// - keys are evenly layouted in a grid pattern fitting to the screen
    case gridFit(CustardInterfaceLayoutGridValue)

    /// - はみ出した分はスクロールできる形でマス目状に均等に配置されます
    /// - keys are layouted in a scrollable grid pattern and can be overflown
    case gridScroll(CustardInterfaceLayoutScrollValue)
}

struct CustardInterfaceLayoutGridValue: Codable {
    /// - 横方向に配置するキーの数
    /// - number of keys placed horizontally
    let width: Int
    /// - 縦方向に配置するキーの数
    /// - number of keys placed vertically
    let height: Int
}

struct CustardInterfaceLayoutScrollValue: Codable {
    /// - スクロールの方向
    /// - direction of scroll
    let direction: ScrollDirection

    /// - 一列に配置するキーの数
    /// - number of keys in scroll normal direction
    let columnKeyCount: Int

    /// - 画面内に収まるスクロール方向のキーの数
    /// - number of keys in screen in scroll direction
    let screenRowKeyCount: Double

    /// - direction of scroll
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
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unabled to decode enum.")
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

/// - 画面内でのキーの位置を決める指定子
/// - the specifier of key's position in screen
enum CustardKeyPositionSpecifier: Codable, Hashable {
    /// - gridFitのレイアウトを利用した際のキーの位置指定子
    /// - position specifier when you use grid fit layout
    case grid_fit(GridFitPositionSpecifier)

    /// - gridScrollのレイアウトを利用した際のキーの位置指定子
    /// - position specifier when you use grid scroll layout
    case grid_scroll(GridScrollPositionSpecifier)
}

extension CustardKeyPositionSpecifier {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .grid_fit(value):
            hasher.combine(CodingKeys.grid_fit)
            hasher.combine(value)
        case let .grid_scroll(value):
            hasher.combine(CodingKeys.grid_scroll)
            hasher.combine(value)
        }
    }
}

extension CustardKeyPositionSpecifier{
    enum CodingKeys: CodingKey{
        case grid_fit
        case grid_scroll
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .grid_fit(value):
            try container.encode(value, forKey: .grid_fit)
        case let .grid_scroll(value):
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
                GridFitPositionSpecifier.self,
                forKey: .grid_fit
            )
            self = .grid_fit(value)
        case .grid_scroll:
            let value = try container.decode(
                GridScrollPositionSpecifier.self,
                forKey: .grid_scroll
            )
            self = .grid_scroll(value)
        }
    }
}

/// - gridFitのレイアウトを利用した際のキーの位置指定子に与える値
/// - values in position specifier when you use grid fit layout
struct GridFitPositionSpecifier: Codable, Hashable {
    /// - 横方向の位置(左をゼロとする)
    /// - horizontal position (leading edge is zero)
    let x: Int

    /// - 縦方向の位置(上をゼロとする)
    /// - vertical positon (top edge is zero)
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

/// - gridScrollのレイアウトを利用した際のキーの位置指定子に与える値
/// - values in position specifier when you use grid scroll layout
struct GridScrollPositionSpecifier: Codable, Hashable {
    /// - 通し番号
    /// - index
    let index: Int

    init(_ index: Int){
        self.index = index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

/// - 記述の簡便化のため定義
/// - conforms to protocol for writability
extension GridScrollPositionSpecifier: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int

    init(integerLiteral value: Int) {
        self.index = value
    }
}

/// - インターフェース
/// - interface
struct CustardInterface: Codable {
    /// - キーのスタイル
    /// - style of keys
    /// - warning: Currently when you use gird scroll. layout, key style would be ignored.
    let key_style: CustardInterfaceStyle

    /// - キーのレイアウト
    /// - layout of keys
    let key_layout: CustardInterfaceLayout

    /// - キーの辞書
    /// - dictionary of keys
    /// - warning: You must use specifiers consistent with key layout. When you use inconsistent one, it would be ignored.
    let keys: [CustardKeyPositionSpecifier: CustardInterfaceKey]
}

extension CustardInterface {
    enum CodingKeys: CodingKey{
        case key_style
        case key_layout
        case keys
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key_style, forKey: .key_style)
        try container.encode(key_layout, forKey: .key_layout)
        try container.encode(CodableDictionary(keys), forKey: .keys)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key_style = try container.decode(CustardInterfaceStyle.self, forKey: .key_style)
        self.key_layout = try container.decode(CustardInterfaceLayout.self, forKey: .key_layout)
        self.keys = try container.decode(CodableDictionary<CustardKeyPositionSpecifier, CustardInterfaceKey>.self, forKey: .keys).dictionary
    }
}

/// - キーのデザイン
/// - design information of key
struct CustardKeyDesign: Codable {
    let label: CustardKeyLabelStyle
    let color: ColorType

    enum ColorType: String, Codable{
        case normal
        case special
    }
}

/// - キーに指定するラベル
/// - labels on the key
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

/// - キーの変種の種類
/// - type of key variation
enum CustardKeyVariationType: Codable {
    /// - variation of flick
    /// - warning: when you use qwerty key style, this type of variation would be ignored.
    case flick(FlickDirection)

    /// - variation of qwerty selectable when keys were longoressed
    /// - warning: when you use flick key style, this type of variation would be ignored.
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

/// - key's data in interface
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

/// - keys prepared in default
enum CustardInterfaceSystemKey: Codable {
    /// - the globe key
    case change_keyboard

    /// - the enter key that changes its label in condition
    case enter(Int)

    ///custom keys.
    /// - flick 小ﾞﾟkey
    case flick_kogaki
    /// - flick ､｡!? key
    case flick_kutoten
    /// - flick hiragana tab
    case flick_hira_tab
    /// - flick abc tab
    case flick_abc_tab
    /// - flick number and symbols tab
    case flick_star123_tab

}

extension CustardInterfaceSystemKey{
    enum CodingKeys: CodingKey{
        case change_keyboard
        case enter
        case flick_kogaki
        case flick_kutoten
        case flick_hira_tab
        case flick_abc_tab
        case flick_star123_tab
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .change_keyboard:
            try container.encode(true, forKey: .change_keyboard)
        case .flick_kogaki:
            try container.encode(true, forKey: .flick_kogaki)
        case .flick_kutoten:
            try container.encode(true, forKey: .flick_kutoten)
        case .flick_hira_tab:
            try container.encode(true, forKey: .flick_hira_tab)
        case .flick_abc_tab:
            try container.encode(true, forKey: .flick_abc_tab)
        case .flick_star123_tab:
            try container.encode(true, forKey: .flick_star123_tab)
        case let .enter(count):
            try container.encode(count, forKey: .enter)
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
        case .enter:
            let value = try container.decode(
                Int.self,
                forKey: .enter
            )
            self = .enter(value)
        case .change_keyboard:
            self = .change_keyboard
        case .flick_kogaki:
            self = .flick_kogaki
        case .flick_kutoten:
            self = .flick_kutoten
        case .flick_hira_tab:
            self = .flick_hira_tab
        case .flick_abc_tab:
            self = .flick_abc_tab
        case .flick_star123_tab:
            self = .flick_star123_tab
        }
    }
}

/// - keys you can defined
struct CustardInterfaceCustomKey: Codable {
    /// - design of this key
    let design: CustardKeyDesign

    /// - action done when this key is pressed. actions are done in order.
    let press_action: [CodableActionData]

    /// - action done when this key is longpressed. actions are done in order.
    let longpress_action: [CodableActionData]

    /// - variations available when user flick or longpress this key
    let variation: [CustardInterfaceVariation]
}

/// - variation of key, includes flick keys and selectable variations in qwerty keyboard.
struct CustardInterfaceVariation: Codable {
    /// - type of the variation
    let type: CustardKeyVariationType

    /// - data of variation
    let key: CustardInterfaceVariationKey
}

/// - data of variation key
struct CustardInterfaceVariationKey: Codable {
    /// - label on this variation
    let label: CustardKeyLabelStyle

    /// - action done when you select this variation. actions are done in order..
    let press_action: [CodableActionData]

    /// - action done when you 'long select' this variation, like long-flick. actions are done in order.
    let longpress_action: [CodableActionData]
}

extension Custard{
    static let hieroglyph: Custard = {
        let hieroglyphs = Array(String.UnicodeScalarView((UInt32(0x13000)...UInt32(0x133FF)).compactMap(UnicodeScalar.init))).map(String.init)

        var keys: [CustardKeyPositionSpecifier: CustardInterfaceKey] = [
            .grid_scroll(0): .system(.change_keyboard),
            .grid_scroll(1): .custom(
                .init(
                    design: .init(label: .text("←"), color: .special),
                    press_action: [.moveCursor(-1)],
                    longpress_action: [.moveCursor(-1)],
                    variation: []
                )
            ),
            .grid_scroll(2): .custom(
                .init(
                    design: .init(label: .systemImage("list.dash"), color: .special),
                    press_action: [.toggleTabBar],
                    longpress_action: [],
                    variation: []
                )
            ),
            .grid_scroll(3): .custom(
                .init(
                    design: .init(label: .text("→"), color: .special),
                    press_action: [.moveCursor(1)],
                    longpress_action: [.moveCursor(1)],
                    variation: []
                )
            ),
            .grid_scroll(4): .custom(
                .init(
                    design: .init(label: .systemImage("delete.left"), color: .special),
                    press_action: [.delete(1)],
                    longpress_action: [.delete(1)],
                    variation: []
                )
            ),
        ]

        hieroglyphs.indices.forEach{
            keys[.grid_scroll(GridScrollPositionSpecifier(5+$0))] = .custom(
                .init(
                    design: .init(label: .text(hieroglyphs[$0]), color: .normal),
                    press_action: [.input(hieroglyphs[$0])],
                    longpress_action: [],
                    variation: []
                )
            )
        }

        let custard = Custard(
            custard_version: .v1_0,
            identifier: "Hieroglyphs",
            display_name: "ヒエログリフ",
            language: .undefined,
            input_style: .direct,
            interface: .init(
                key_style: .flick,
                key_layout: .gridScroll(.init(direction: .vertical, columnKeyCount: 8, screenRowKeyCount: 4.2)),
                keys: keys
            )
        )
        return custard
    }()

    static let mock_flick_grid = Custard(
        custard_version: .v1_0,
        identifier: "my_custard",
        display_name: "マイカスタード",
        language: .ja_JP,
        input_style: .direct,
        interface: .init(
            key_style: .flick,
            key_layout: .gridFit(.init(width: 3, height: 5)),
            keys: [
                .grid_fit(.init(x: 0, y: 0)): .system(.change_keyboard),
                .grid_fit(.init(x: 1, y: 0)): .custom(
                    .init(
                        design: .init(label: .text("←"), color: .special),
                        press_action: [.moveCursor(-1)],
                        longpress_action: [.moveCursor(-1)],
                        variation: []
                    )
                ),
                .grid_fit(.init(x: 2, y: 0)): .custom(
                    .init(
                        design: .init(label: .text("→"), color: .special),
                        press_action: [.moveCursor(1)],
                        longpress_action: [.moveCursor(1)],
                        variation: []
                    )
                ),
                .grid_fit(.init(x: 0, y: 1)): .custom(
                    .init(
                        design: .init(label: .text("①"), color: .normal),
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
                .grid_fit(.init(x: 1, y: 1)): .custom(
                    .init(
                        design: .init(label: .text("②"), color: .normal),
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
                .grid_fit(.init(x: 2, y: 1)): .custom(
                    .init(
                        design: .init(label: .text("③"), color: .normal),
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
                .grid_fit(.init(x: 0, y: 2)): .custom(
                    .init(
                        design: .init(label: .text("④"), color: .normal),
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
                .grid_fit(.init(x: 1, y: 2)): .custom(
                    .init(
                        design: .init(label: .text("⑤"), color: .normal),
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
                .grid_fit(.init(x: 2, y: 2)): .custom(
                    .init(
                        design: .init(label: .text("⑥"), color: .normal),
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
                .grid_fit(.init(x: 0, y: 3)): .custom(
                    .init(
                        design: .init(label: .text("⑦"), color: .normal),
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
                .grid_fit(.init(x: 1, y: 3)): .custom(
                    .init(
                        design: .init(label: .text("⑧"), color: .normal),
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
                .grid_fit(.init(x: 2, y: 3)): .custom(
                    .init(
                        design: .init(label: .text("⑨"), color: .normal),
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
                .grid_fit(.init(x: 0, y: 4)): .custom(
                    .init(
                        design: .init(label: .text("空白"), color: .special),
                        press_action: [.input(" ")],
                        longpress_action: [.toggleCursorMovingView],
                        variation: []
                    )
                ),
                .grid_fit(.init(x: 1, y: 4)): .system(.enter(1)),
                .grid_fit(.init(x: 2, y: 4)): .custom(
                    .init(
                        design: .init(label: .systemImage("delete.left"), color: .special),
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
