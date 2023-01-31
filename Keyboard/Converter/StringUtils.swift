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
    var isKana: Bool {
        !isEmpty && range(of: "[^ぁ-ゖァ-ヶ]", options: .regularExpression) == nil
    }
}
