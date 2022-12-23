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
        // カタカナはutf16で常に2バイトなので、utf16単位で処理して良い
        let result = self.utf16.map { scalar -> UInt16 in
            if 0x3041 <= scalar && scalar <= 0x3096 {
                return scalar + 96
            } else {
                return scalar
            }
        }
        return String(utf16CodeUnits: result, count: self.count)
    }

    @inlinable func toHiragana() -> String {
        // ひらがなはutf16で常に2バイトなので、utf16単位で処理して良い
        let result = self.utf16.map { scalar -> UInt16 in
            if 0x30A1 <= scalar && scalar <= 0x30F6 {
                return scalar - 96
            } else {
                return scalar
            }
        }
        return String(utf16CodeUnits: result, count: self.count)
    }

    @inlinable
    public func indexFromStart(_ offset: Int) -> Index {
        self.index(self.startIndex, offsetBy: offset)
    }
}
