//
//  Unicode.swift
//  Keyboard
//
//  Created by β α on 2020/11/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension KanaKanjiConverter{
    ///unicode文字列`"uxxxx"`を対応する記号に変換する関数
    /// - parameters: 
    func unicode<S: StringProtocol>(string: S) -> [Candidate] {
        let value0: PValue = -10
        if string.count < 5{
            return []
        }
        if string.hasPrefix("u") || string.hasPrefix("U"){
            if let number = Int(string.dropFirst(), radix: 16), let unicodeScalar = UnicodeScalar(number){
                let char = String(unicodeScalar)
                return [
                    Candidate(
                        text: char,
                        value: value0,
                        visibleString: String(string),
                        rcid: .zero,
                        lastMid: 500,
                        data: [LRE_DicDataElement(word: char, ruby: String(string), cid: .zero, mid: 500, value: value0)]
                    ),
                ]
            }
        }
        if string.hasPrefix("u+") || string.hasPrefix("U+"){
            if let number = Int(string.dropFirst(2), radix: 16), let unicodeScalar = UnicodeScalar(number){
                let char = String(unicodeScalar)
                return [
                    Candidate(
                        text: char,
                        value: value0,
                        visibleString: String(string),
                        rcid: .zero,
                        lastMid: 500,
                        data: [LRE_DicDataElement(word: char, ruby: String(string), cid: .zero, mid: 500, value: value0)]
                    ),
                ]
            }
        }
        return []

    }
}
