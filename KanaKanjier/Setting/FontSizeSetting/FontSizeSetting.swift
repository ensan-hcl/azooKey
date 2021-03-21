//
//  FontSizeSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

enum FontSizeSetting: Savable, Hashable {
    typealias SaveValue = Double
    case value(Double)

    var saveValue: Double {
        switch self{
        case let .value(value):
            return value
        }
    }

    static func get(_ value: Any) -> FontSizeSetting? {
        if let value = value as? SaveValue{
            return .value(value)
        }
        return nil
    }
}
extension FontSizeSetting: ExpressibleByFloatLiteral{
    init(floatLiteral value: Double) {
        self = .value(value)
    }

    typealias FloatLiteralType = Double
}

extension FontSizeSetting: ExpressibleByIntegerLiteral{
    init(integerLiteral value: Int) {
        self = .value(Double(value))
    }

    typealias IntegerLiteralType = Int
}

extension FontSizeSetting: CustomStringConvertible{
    var display: LocalizedStringKey {
        LocalizedStringKey(stringLiteral: description)
    }

    var description: String {
        switch self{
        case let .value(value):
            if value == -1{
                return "自動"
            }
            return "\(value)"
        }
    }
}

extension FontSizeSetting: Identifiable{
    var id: Double {
        return self.saveValue
    }
}

