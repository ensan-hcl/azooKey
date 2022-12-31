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
    @inlinable
    var containsRomanAlphabet: Bool {
        !isEmpty && range(of: "[a-zA-Z]", options: .regularExpression) != nil
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
