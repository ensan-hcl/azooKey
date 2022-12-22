//
//  extension String.swift
//  KanaKanjier
//
//  Created by β α on 2022/11/20.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

extension StringProtocol {
    @inlinable func toKatakana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x3041 <= scalar.value && scalar.value <= 0x3096 {
                return UnicodeScalar(scalar.value + 96)!
            } else {
                return scalar
            }
        }
        return String(String.UnicodeScalarView(result))
    }

    @inlinable func toHiragana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 {
                return UnicodeScalar(scalar.value - 96)!
            } else {
                return scalar
            }
        }
        return String(String.UnicodeScalarView(result))
    }

    @inlinable
    public func indexFromStart(_ offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }
}
