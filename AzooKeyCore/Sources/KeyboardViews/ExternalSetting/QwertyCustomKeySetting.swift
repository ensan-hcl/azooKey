//
//  QwertyCustomKeys.swift
//  azooKey
//
//  Created by ensan on 2020/11/20.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import SwiftUI

private struct _QwertyVariationKey: Codable {
    var name: String
    var input: String
}

private struct _QwertyCustomKey: Codable {
    var name: String
    var longpress: [String]
    var input: String
    var longpresses: [_QwertyVariationKey]

    enum CodingKeys: String, CodingKey {
        case name
        case longpress
        case input
        case longpresses
    }

    init(name: String, input: String? = nil, longpresses: [_QwertyVariationKey] = []) {
        self.name = name
        self.longpress = []
        self.input = input ?? name
        self.longpresses = longpresses
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let longpress = try values.decode([String].self, forKey: .longpress)
        self.name = name
        self.longpress = []
        self.input = (try? values.decode(String.self, forKey: .input)) ?? name
        self.longpresses = (try? values.decode([_QwertyVariationKey].self, forKey: .longpresses)) ?? longpress.map {_QwertyVariationKey(name: $0, input: $0)}
    }
}

public struct QwertyVariationKey: Codable, Equatable {
    public init(name: String, actions: [CodableActionData]) {
        self.name = name
        self.actions = actions
    }

    public var name: String
    public var actions: [CodableActionData]
}

public struct QwertyCustomKey: Codable, Equatable {
    public init(name: String, actions: [CodableActionData], longpresses: [QwertyVariationKey]) {
        self.name = name
        self.actions = actions
        self.longpresses = longpresses
    }

    public var name: String
    public var actions: [CodableActionData]
    public var longpresses: [QwertyVariationKey]
}

struct QwertyCustomKeysArray: Codable {
    // let list: [_QwertyCustomKey
    let keys: [QwertyCustomKey]

    init(keys: [QwertyCustomKey]) {
        self.keys = keys
    }

    enum CodingKeys: CodingKey {
        case list
        case keys
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keys, forKey: .keys)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let keys = try? container.decode([QwertyCustomKey].self, forKey: .keys) {
            self.keys = keys
        } else if let list = try? container.decode([_QwertyCustomKey].self, forKey: .list) {
            self.keys = list.map {key in
                QwertyCustomKey(name: key.name, actions: [.input(key.input)], longpresses: key.longpresses.map {QwertyVariationKey(name: $0.name, actions: [.input($0.input)])})
            }
        } else {
            self.keys = QwertyCustomKeysValue.defaultValue.keys
        }
    }
}

public struct QwertyCustomKeysValue: Equatable {
    public static let defaultValue = QwertyCustomKeysValue(keys: [
        QwertyCustomKey(name: "。", actions: [.input("。")], longpresses: [QwertyVariationKey(name: "。", actions: [.input("。")]), QwertyVariationKey(name: ".", actions: [.input(".")])]),
        QwertyCustomKey(name: "、", actions: [.input("、")], longpresses: [QwertyVariationKey(name: "、", actions: [.input("、")]), QwertyVariationKey(name: ",", actions: [.input(",")])]),
        QwertyCustomKey(name: "？", actions: [.input("？")], longpresses: [QwertyVariationKey(name: "？", actions: [.input("？")]), QwertyVariationKey(name: "?", actions: [.input("?")])]),
        QwertyCustomKey(name: "！", actions: [.input("！")], longpresses: [QwertyVariationKey(name: "！", actions: [.input("！")]), QwertyVariationKey(name: "!", actions: [.input("!")])]),
        QwertyCustomKey(name: "・", actions: [.input("・")], longpresses: [QwertyVariationKey(name: "・", actions: [.input("・")]), QwertyVariationKey(name: "…", actions: [.input("…")])])
    ])

    public var keys: [QwertyCustomKey]

    public static func get(_ value: Any) -> QwertyCustomKeysValue? {
        if let value = value as? Data {
            let decoder = JSONDecoder()
            if let keys = try? decoder.decode(QwertyCustomKeysArray.self, from: value) {
                return QwertyCustomKeysValue(keys: keys.keys)
            }
        }
        return nil
    }

    public var saveValue: Data {
        let array = QwertyCustomKeysArray(keys: keys)
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(array) {
            return encodedValue
        } else {
            return Data()
        }
    }

}

extension QwertyCustomKeysValue {
    func compiled<Extension: ApplicationSpecificKeyboardViewExtension>(extension _: Extension.Type) -> [QwertyKeyModel<Extension>] {
        let keys = self.keys
        let count = keys.count
        let scale = (7, count)
        return keys.map {key in
            QwertyKeyModel(
                labelType: .text(key.name),
                pressActions: key.actions.map {$0.actionType},
                variationsModel: VariationsModel(
                    key.longpresses.map {item in
                        (label: .text(item.name), actions: item.actions.map {$0.actionType})
                    }
                ),
                for: scale
            )
        }
    }
}
