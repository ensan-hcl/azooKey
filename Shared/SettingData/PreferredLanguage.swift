//
//  PreferredLanguage.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

struct PreferredLanguage: Codable, Hashable {
    var first: KeyboardLanguage
    var second: KeyboardLanguage?
}

extension PreferredLanguage: Savable {
    typealias SaveValue = Data

    var saveValue: Data {
        if let encodedValue = try? JSONEncoder().encode(self) {
            return encodedValue
        } else {
            return Data()
        }
    }

    static func get(_ value: Any) -> Self? {
        if let data = value as? Data, let result = try? JSONDecoder().decode(Self.self, from: data) {
            return result
        }
        return nil
    }

}
