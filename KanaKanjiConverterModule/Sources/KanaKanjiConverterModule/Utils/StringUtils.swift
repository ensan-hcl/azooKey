//
//  extension StringProtocol.swift
//  Keyboard
//
//  Created by ensan on 2020/10/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

extension StringProtocol {
    /// ローマ字と数字のみかどうか
    ///  - note: 空文字列の場合`false`を返す。
    @inlinable
    var onlyRomanAlphabetOrNumber: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    /// ローマ字のみかどうか
    ///  - note: 空文字列の場合`false`を返す。
    @inlinable
    var onlyRomanAlphabet: Bool {
        !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    /// ローマ字を含むかどうか
    ///  - note: 空文字列の場合`false`を返す。
    /// 以前は正規表現ベースで実装していたが、パフォーマンス上良くなかったので以下のような実装にしたところ40倍程度高速化した。
    @inlinable
    var containsRomanAlphabet: Bool {
        for value in self.utf8 {
            if (UInt8(ascii: "a") <= value && value <= UInt8(ascii: "z")) || (UInt8(ascii: "A") <= value && value <= UInt8(ascii: "Z")) {
                return true
            }
        }
        return false
    }
    /// 英語として許容可能な文字のみで構成されているか。
    ///  - note: 空文字列の場合`false`を返す。
    @inlinable
    var isEnglishSentence: Bool {
        !isEmpty && range(of: "[^0-9a-zA-Z\n !'_<>\\[\\]{}*@`\\^|~=\"#$%&\\+\\(\\),\\-\\./:;?’\\\\]", options: .regularExpression) == nil
    }

    /// 仮名か
    @inlinable
    public var isKana: Bool {
        !isEmpty && range(of: "[^ぁ-ゖァ-ヶ]", options: .regularExpression) == nil
    }

    /// Returns a String value in which Hiraganas are all converted to Katakana.
    /// - Returns: A String value in which Hiraganas are all converted to Katakana.
    @inlinable public func toKatakana() -> String {
        // カタカナはutf16で常に2バイトなので、utf16単位で処理して良い
        let result = self.utf16.map { scalar -> UInt16 in
            if 0x3041 <= scalar && scalar <= 0x3096 {
                return scalar + 96
            } else {
                return scalar
            }
        }
        return String(utf16CodeUnits: result, count: result.count)
    }

    /// Returns a String value in which Katakana are all converted to Hiragana.
    /// - Returns: A String value in which Katakana are all converted to Hiragana.
    @inlinable public func toHiragana() -> String {
        // ひらがなはutf16で常に2バイトなので、utf16単位で処理して良い
        let result = self.utf16.map { scalar -> UInt16 in
            if 0x30A1 <= scalar && scalar <= 0x30F6 {
                return scalar - 96
            } else {
                return scalar
            }
        }
        return String(utf16CodeUnits: result, count: result.count)
    }

    /// Returns an Index value that is the specified distance from the start index.
    /// - Parameter:
    ///   - offset: The distance to offset from the start index.
    /// - Returns: An Index value that is the specified distance from the start index.
    @inlinable
    public func indexFromStart(_ offset: Int) -> Index {
        self.index(self.startIndex, offsetBy: offset)
    }

    // エスケープが必要なのは次の文字:
    /*
     \ -> \\
     \0 -> \0
     \n -> \n
     \t -> \t
     , -> \c
     " -> \d
     */
    // please use these letters in order to avoid user-inputting text crash
    public func escaped() -> String {
        var result = self.replacingOccurrences(of: "\\", with: "\\b")
        result = result.replacingOccurrences(of: "\0", with: "\\0")
        result = result.replacingOccurrences(of: "\n", with: "\\n")
        result = result.replacingOccurrences(of: "\t", with: "\\t")
        result = result.replacingOccurrences(of: ",", with: "\\c")
        result = result.replacingOccurrences(of: " ", with: "\\s")
        result = result.replacingOccurrences(of: "\"", with: "\\d")
        return result
    }

    public func unescaped() -> String {
        var result = self.replacingOccurrences(of: "\\d", with: "\"")
        result = result.replacingOccurrences(of: "\\s", with: " ")
        result = result.replacingOccurrences(of: "\\c", with: ",")
        result = result.replacingOccurrences(of: "\\t", with: "\t")
        result = result.replacingOccurrences(of: "\\n", with: "\n")
        result = result.replacingOccurrences(of: "\\0", with: "\0")
        result = result.replacingOccurrences(of: "\\b", with: "\\")
        return result
    }
}
