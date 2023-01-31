//
//  EmailAddress.swift
//  Keyboard
//
//  Created by ensan on 2022/10/01.
//  Copyright © 2022 ensan. All rights reserved.
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
    func toEmailAddressCandidates(_ inputData: ComposingText) -> [Candidate] {
        if !inputData.convertTarget.hasSuffix("@") {
            return []
        }
        let id = inputData.convertTarget.dropLast(1)
        if !(id.isEnglishSentence || id.isEmpty) {
            return []
        }
        let baseValue: PValue = id.isEmpty ? -20 : -13
        let string = inputData.convertTarget.toKatakana()
        var results: [Candidate] = []
        for (i, domain) in Self.domains.enumerated() {
            let address = id.appending(domain)
            results.append(
                Candidate(
                    text: address,
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
