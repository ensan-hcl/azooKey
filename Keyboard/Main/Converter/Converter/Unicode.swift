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
    func unicode(_ inputData: InputData) -> [Candidate] {
        let value0: PValue = -10
        let string = inputData.katakanaString
        if string.count < 5{
            return []
        }
        for prefix in ["u","U","u+","U+"] where string.hasPrefix(prefix){
            if let number = Int(string.dropFirst(prefix.count), radix: 16), let unicodeScalar = UnicodeScalar(number){
                let char = String(unicodeScalar)
                return [
                    Candidate(
                        text: char,
                        value: value0,
                        correspondingCount: inputData.characters.count,
                        lastMid: 500,
                        data: [LRE_DicDataElement(word: char, ruby: string, cid: .zero, mid: 500, value: value0)]
                    ),
                ]
            }
        }
        return []

    }
}
