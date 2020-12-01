//
//  Unicode.swift
//  Keyboard
//
//  Created by β α on 2020/11/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension KanaKanjiConverter{
    func unicode<S: StringProtocol>(string: S) -> [Candidate] {
        let value0: PValue = -17
        if string.count < 5{
            return []
        }
        if string.hasPrefix("u"){
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
        return []

    }
}
