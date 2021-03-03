//
//  File.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/03.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

struct CodableDictionary<Key: Hashable, Value>{
    var dictionary: [Key: Value]
    init(_ dictionary: [Key: Value]){
        self.dictionary = dictionary
    }
}

extension CodableDictionary: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.dictionary = elements.reduce(into: [:]){dictionary, pair in
            dictionary[pair.0] = pair.1
        }
    }
}

extension CodableDictionary: Codable where Key: Codable, Value: Codable{
    struct CodableDictionaryPair: Codable {
        internal init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }

        let key: Key
        let value: Value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let pairs = self.dictionary.map{CodableDictionaryPair(key: $0.key, value: $0.value)}
        try container.encode(pairs)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let pairs = try container.decode([CodableDictionaryPair].self)
        self.dictionary = pairs.reduce(into: [:]){dictionary, pair in
            dictionary[pair.key] = pair.value
        }
    }

}
