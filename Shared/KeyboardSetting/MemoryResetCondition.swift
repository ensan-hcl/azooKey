//
//  MemoryResetCondition.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/24.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum MemoryResetCondition: Int, Savable {
    typealias SaveValue = String
    case none = 0
    case need = 1

    var saveValue: SaveValue {
        switch self {
        case .none:
            return "none"
        case .need:
            return "need\(Date().hashValue)"
        }
    }

    static func get(_ value: Any) -> MemoryResetCondition? {
        if let value = value as? SaveValue {
            if value.hasPrefix("none") {
                return MemoryResetCondition.none
            } else if value.hasPrefix("need") {
                return .need
            }
        }
        return nil
    }

    static func identifier(_ value: Any) -> String? {
        if let value = value as? SaveValue {
            if value.hasPrefix("none") {
                return nil
            } else if value.hasPrefix("need") {
                return String(value.dropFirst(4))
            }
        }
        return nil
    }

    private static let key = "memory_reset_setting"

    static func set(value: Self) {
        SharedStore.userDefaults.set(value.saveValue, forKey: key)
    }

    static func shouldReset() -> Bool {
        if let object = SharedStore.userDefaults.object(forKey: key),
           let identifier = identifier(object) {
            if let finished = UserDefaults.standard.string(forKey: "finished_reset"), finished == identifier {
                return false
            }
            UserDefaults.standard.set(identifier, forKey: "finished_reset")
            return true
        }
        return false
    }
}
