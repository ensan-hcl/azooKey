//
//  Unicode.swift
//  Keyboard
//
//  Created by ensan on 2020/11/04.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

extension KanaKanjiConverter {
    /// unicode文字列`"uxxxx, Uxxxx, u+xxxx, U+xxxx"`を対応する記号に変換する関数
    /// - parameters:
    func unicodeCandidates(_ inputData: ComposingText) -> [Candidate] {
        let value0: PValue = -10
        let string = inputData.convertTarget.toKatakana()
        for prefix in ["u", "U", "u+", "U+"] where string.hasPrefix(prefix) {
            if let number = Int(string.dropFirst(prefix.count), radix: 16), let unicodeScalar = UnicodeScalar(number) {
                let char = String(unicodeScalar)
                return [
                    Candidate(
                        text: char,
                        value: value0,
                        correspondingCount: inputData.input.count,
                        lastMid: MIDData.一般.mid,
                        data: [DicdataElement(word: char, ruby: string, cid: .zero, mid: MIDData.一般.mid, value: value0)]
                    )
                ]
            }
        }
        return []
    }
}
