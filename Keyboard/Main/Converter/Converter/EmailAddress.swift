//
//  EmailAddress.swift
//  Keyboard
//
//  Created by β α on 2022/10/01.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

extension KanaKanjiConverter {
    private static let domains = [
        "@gmail.com",
        "@icloud.com",
        "@yahoo.co.jp",
        "@au.com",
        "@docomo.ne.jp",
        "@excite.co.jp",
        "@ezweb.ne.jp",
        "@googlemail.com",
        "@hotmail.co.jp",
        "@hotmail.com",
        "@i.softbank.jp",
        "@live.jp",
        "@me.com",
        "@mineo.jp",
        "@nifty.com",
        "@outlook.com",
        "@outlook.jp",
        "@softbank.ne.jp",
        "@yahoo.ne.jp",
        "@ybb.ne.jp",
        "@ymobile.ne.jp"
    ]
    /// 入力が@で終わる場合に、メアドのような候補を追加する関数
    /// - parameters:
    func toEmailAddress(_ inputData: ComposingText) -> [Candidate] {
        let baseValue: PValue = -13
        let string = inputData.convertTarget.toKatakana()
        if inputData.convertTarget.last != "@" || !inputData.convertTarget.dropLast(1).isEnglishSentence {
            return []
        }
        var results: [Candidate] = []
        for (i, domain) in Self.domains.enumerated() {
            let address = inputData.convertTarget.dropLast(1).appending(domain)
            results.append(
                Candidate(
                    text: String(address),
                    value: baseValue - PValue(i),
                    correspondingCount: inputData.input.count,
                    lastMid: MIDData.一般.mid,
                    data: [DicdataElement(word: address, ruby: string, cid: .zero, mid: MIDData.一般.mid, value: baseValue - PValue(i))]
                )
            )
        }
        return results
    }
}
