//
//  QwertyCustomKeys.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct QwertyVariationKey: Codable {
    var name: String
    var input: String
}

struct QwertyCustomKey: Codable {
    var name: String
    var longpress: [String]
    var input: String
    var longpresses: [QwertyVariationKey]
    enum CodingKeys: String, CodingKey {
        case name
        case longpress
        case input
        case longpresses
    }

    init(name: String, input: String? = nil, longpresses: [QwertyVariationKey] = []){
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
        self.longpresses =  (try? values.decode([QwertyVariationKey].self, forKey: .longpresses)) ?? longpress.map{QwertyVariationKey(name: $0, input: $0)}
    }
}

private struct QwertyCustomKeysArray: Codable {
    let list: [QwertyCustomKey]
}

struct QwertyCustomKeysValue: Savable {
    typealias SaveValue = Data
    static let defaultValue = QwertyCustomKeysValue(keys: [
        QwertyCustomKey(name: "。", input: "。", longpresses: [QwertyVariationKey(name: "。", input: "。"), QwertyVariationKey(name: ".", input: ".")]),
        QwertyCustomKey(name: "、", input: "、", longpresses: [QwertyVariationKey(name: "、", input: "、"), QwertyVariationKey(name: ",", input: ",")]),
        QwertyCustomKey(name: "？", input: "？", longpresses: [QwertyVariationKey(name: "？", input: "？"), QwertyVariationKey(name: "?", input: "?")]),
        QwertyCustomKey(name: "！", input: "！", longpresses: [QwertyVariationKey(name: "！", input: "！"), QwertyVariationKey(name: "!", input: "!")]),
        QwertyCustomKey(name: "・", input: "・", longpresses: [QwertyVariationKey(name: "…", input: "…")]),
    ])

    var saveValue: SaveValue {
        let array = QwertyCustomKeysArray(list: keys)
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(array) {
            return encodedValue
        }else{
            return Data()
        }
    }

    var keys: [QwertyCustomKey]

    static func get(_ value: Any) -> QwertyCustomKeysValue? {
        if let value = value as? SaveValue{
            let decoder = JSONDecoder()
            if let keys = try? decoder.decode(QwertyCustomKeysArray.self, from: value) {
                return QwertyCustomKeysValue(keys: keys.list)
            }
        }
        return nil
    }
}
