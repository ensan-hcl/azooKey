//
//  extension StringProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/10/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension StringProtocol {
    /// ローマ字と数字のみかどうか
    @inlinable
    var onlyRomanAlphabetOrNumber: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    /// ローマ字のみかどうか
    @inlinable
    var onlyRomanAlphabet: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    /// ローマ字を含むかどうか
    @inlinable
    var containsRomanAlphabet: Bool {
        return !isEmpty && range(of: "[a-zA-Z]", options: .regularExpression) != nil
    }
    /// 英語として許容可能な文字のみで構成されているか。
    @inlinable
    var isEnglishSentence: Bool {
        return !isEmpty && range(of: "[^0-9a-zA-Z\n !'_<>\\[\\]{}*@`\\^|~=\"#$%&+(),-./:;?’]", options: .regularExpression) == nil
    }
}

extension StringProtocol {
    @inlinable func toKatakana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x3041 <= scalar.value && scalar.value <= 0x3096 {
                return UnicodeScalar(scalar.value+96)!
            } else {
                return scalar
            }
        }
        return String(String.UnicodeScalarView(result))
    }

    @inlinable func toHiragana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 {
                return UnicodeScalar(scalar.value-96)!
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

    @inlinable
    subscript(_ index: Int) -> Character {
        get {
            return self[self.indexFromStart(index)]
        }
    }

    @inlinable
    subscript(_ range: ClosedRange<Int>) -> SubSequence {
        get {
            return self[self.indexFromStart(range.lowerBound) ... self.indexFromStart(range.upperBound)]
        }
    }

    @inlinable
    subscript(_ range: Range<Int>) -> SubSequence {
        get {
            return self[self.indexFromStart(range.lowerBound) ..< self.indexFromStart(range.upperBound)]
        }
    }
}
