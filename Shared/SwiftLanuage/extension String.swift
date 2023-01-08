//
//  extension String.swift
//  KanaKanjier
//
//  Created by β α on 2022/11/20.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

extension StringProtocol {
    /// Returns a String value in which Hiraganas are all converted to Katakana.
    /// - Returns: A String value in which Hiraganas are all converted to Katakana.
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

    /// Returns a String value in which Katakana are all converted to Hiragana.
    /// - Returns: A String value in which Katakana are all converted to Hiragana.
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

    /// Returns an Index value that is the specified distance from the start index.
    /// - Parameter:
    ///   - offset: The distance to offset from the start index.
    /// - Returns: An Index value that is the specified distance from the start index.
    @inlinable
    public func indexFromStart(_ offset: Int) -> Index {
        self.index(self.startIndex, offsetBy: offset)
    }
}
