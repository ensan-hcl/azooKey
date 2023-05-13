//
//  VersionCandidate.swift
//  Keyboard
//
//  Created by N-i-ke on 2023/05/13.
//  Copyright © 2023 ensan All rights reserved.
//

import Foundation

extension KanaKanjiConverter {
    
    /// バージョン情報を表示する関数。
    /// Mozcは「バージョン」で言語モデルのバージョンが表示されるらしいので、azooKeyもこれをつけて「azooKey 1.7.2」とか表示させよう。
    /// - parameters:
    ///  - inputData: 入力情報。
    func toVersionCandidate(_ inputData: ComposingText) -> [Candidate] {

        if inputData.convertTarget.toKatakana() == "バージョン", let version = SharedStore.currentAppVersion?.description {
            let versionString = "azooKey Version \(version)"
            return [Candidate(
                text: versionString,
                value: -30,
                correspondingCount: inputData.input.count,
                lastMid: MIDData.一般.mid,
                data: [DicdataElement(word: versionString, ruby: inputData.convertTarget.toKatakana(), cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -30)]
            )]
        }
        return []
    }
}
