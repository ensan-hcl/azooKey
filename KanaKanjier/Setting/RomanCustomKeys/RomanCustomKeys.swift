//
//  RomanCustomKeys.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct RomanVariationKey: Codable {
    var name: String
    var input: String
}

struct RomanCustomKey: Codable {
    var name: String
    var longpress: [String]
    var input: String
    var longpresses: [RomanVariationKey]
    enum CodingKeys: String, CodingKey {
        case name
        case longpress
        case input
        case longpresses
    }

    init(name: String, input: String? = nil, longpresses: [RomanVariationKey] = []){
        self.name = name
        self.longpress = []
        self.input = input ?? name
        self.longpresses = longpresses// ?? longpress.map{RomanVariationKey(name: $0, input: $0)}
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let longpress = try values.decode([String].self, forKey: .longpress)
        self.name = name
        self.longpress = []
        self.input = (try? values.decode(String.self, forKey: .input)) ?? name
        self.longpresses =  (try? values.decode([RomanVariationKey].self, forKey: .longpresses)) ?? longpress.map{RomanVariationKey(name: $0, input: $0)}
    }
}

private struct RomanCustomKeysArray: Codable {
    let list: [RomanCustomKey]
}

struct RomanCustomKeysValue: Savable {
    typealias SaveValue = Data
    static let defaultValue = RomanCustomKeysValue(keys: [
        RomanCustomKey(name: "。", input: "。", longpresses: [RomanVariationKey(name: "。", input: "。"), RomanVariationKey(name: ".", input: ".")]),
        RomanCustomKey(name: "、", input: "、", longpresses: [RomanVariationKey(name: "、", input: "、"), RomanVariationKey(name: ",", input: ",")]),
        RomanCustomKey(name: "？", input: "？", longpresses: [RomanVariationKey(name: "？", input: "？"), RomanVariationKey(name: "?", input: "?")]),
        RomanCustomKey(name: "！", input: "！", longpresses: [RomanVariationKey(name: "！", input: "！"), RomanVariationKey(name: "!", input: "!")]),
        RomanCustomKey(name: "・", input: "・", longpresses: []),
    ])

    var saveValue: SaveValue {
        let array = RomanCustomKeysArray(list: keys)
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(array) {
            return encodedValue
        }else{
            return Data()
        }
    }

    var keys: [RomanCustomKey]

    static func get(_ value: Any) -> RomanCustomKeysValue? {
        if let value = value as? SaveValue{
            let decoder = JSONDecoder()
            if let keys = try? decoder.decode(RomanCustomKeysArray.self, from: value) {
                return RomanCustomKeysValue(keys: keys.list)
            }
        }
        return nil
    }
}
