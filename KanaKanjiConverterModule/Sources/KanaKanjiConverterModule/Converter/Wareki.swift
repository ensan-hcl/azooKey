//
//  extension Converter.swift
//  Keyboard
//
//  Created by ensan on 2020/09/11.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

extension KanaKanjiConverter {
    /// バージョン情報を表示する関数。
    /// Mozcは「バージョン」で言語モデルのバージョンが表示されるらしいので、azooKeyもこれをつけて「azooKey 1.7.2」とか表示させよう。
    /// - parameters:
    ///  - inputData: 入力情報。
    func toVersionCandidate(_ inputData: ComposingText, options: ConvertRequestOptions) -> [Candidate] {
        if inputData.convertTarget.toKatakana() == "バージョン" {
            let versionString = "azooKey Version \(options.metadata.appVersionString)"
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

    /// 西暦に変換した結果を返す関数。
    /// - parameters:
    ///   - inputData: 入力情報。
    /// - note:
    ///    現在英字のみ。ギリシャ文字や数字に対応する必要あり。
    func toSeirekiCandidates(_ inputData: ComposingText) -> [Candidate] {
        let string = inputData.convertTarget.toKatakana()
        let result = self.toSeireki(string)
        return result.map {[Candidate(
            text: $0,
            value: -15,
            correspondingCount: inputData.input.count,
            lastMid: MIDData.一般.mid,
            data: [DicdataElement(word: $0, ruby: string, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -15)]
        )]} ?? []
    }

    /// 和暦で書かれた入力を西暦に変換する関数
    /// - parameters:
    ///   - string: 入力
    private func toSeireki(_ string: String) -> String? {
        let katakanaStringCount = string.count
        if string == "メイジガンネン"{
            return "1868年"
        }
        if string == "タイショウガンネン"{
            return "1912年"
        }
        if string == "ショウワガンネン"{
            return "1926年"
        }
        if string == "ヘイセイガンネン"{
            return "1989年"
        }
        if string == "レイワガンネン"{
            return "2019年"
        }
        var string = string[...]
        // ネンをdropする
        guard "ネン" == string.suffix(2) else {
            return nil
        }
        string = string.dropLast(2)
        if string.hasPrefix("ショウワ") {
            // ショウワをdropする
            string = string.dropFirst(4)
            // 残るは数値部分のみ
            if katakanaStringCount == 8, let year = Int(string) {
                return "\(year + 1925)年"
            }
            if katakanaStringCount == 7, let year = Int(string) {
                return "\(year + 1925)年"
            }
        } else if string.hasPrefix("ヘイセイ") {
            // ヘイセイをdropする
            string = string.dropFirst(4)
            // 残るは数値部分のみ
            if katakanaStringCount == 8, let year = Int(string) {
                return "\(year + 1988)年"
            }
            if katakanaStringCount == 7, let year = Int(string) {
                return "\(year + 1988)年"
            }
        } else if string.hasPrefix("レイワ") {
            // レイワをdropする
            string = string.dropFirst(3)
            // 残るは数値部分のみ
            if katakanaStringCount == 7, let year = Int(string) {
                return "\(year + 2018)年"
            }
            if katakanaStringCount == 6, let year = Int(string) {
                return "\(year + 2018)年"
            }
        } else if string.hasPrefix("メイジ") {
            // メイジをdropする
            string = string.dropFirst(3)
            // 残るは数値部分のみ
            if katakanaStringCount == 7, let year = Int(string) {
                return "\(year + 1867)年"
            }
            if katakanaStringCount == 6, let year = Int(string) {
                return "\(year + 1867)年"
            }
        } else if string.hasPrefix("タイショウ") {
            // タイショウをdropする
            string = string.dropFirst(5)
            // 残るは数値部分のみ
            if katakanaStringCount == 9, let year = Int(string) {
                return "\(year + 1911)年"
            }
            if katakanaStringCount == 8, let year = Int(string) {
                return "\(year + 1911)年"
            }
        }
        return nil
    }
    /// 西暦で書かれた入力を和暦に変換する関数
    /// - parameters:
    ///   - string: 入力
    func toWarekiCandidates(_ inputData: ComposingText) -> [Candidate] {
        let string = inputData.convertTarget.toKatakana()

        let makeResult0: (String) -> Candidate = {
            Candidate(
                text: $0,
                value: -18,
                correspondingCount: inputData.input.count,
                lastMid: MIDData.年.mid,
                data: [DicdataElement(word: $0, ruby: string, cid: CIDData.一般名詞.cid, mid: MIDData.年.mid, value: -18)]
            )
        }
        let makeResult1: (String) -> Candidate = {
            Candidate(
                text: $0,
                value: -19,
                correspondingCount: inputData.input.count,
                lastMid: MIDData.年.mid,
                data: [DicdataElement(word: $0, ruby: string, cid: CIDData.一般名詞.cid, mid: MIDData.年.mid, value: -19)]
            )
        }

        guard let seireki = Int(string.prefix(4)) else {
            return []
        }
        if !string.hasSuffix("ネン") {
            return []
        }
        if seireki == 1989 {
            return [
                makeResult0("平成元年"),
                makeResult1("昭和64年")
            ]
        }
        if seireki == 2019 {
            return [
                makeResult0("令和元年"),
                makeResult1("平成31年")
            ]
        }
        if seireki == 1926 {
            return [
                makeResult0("昭和元年"),
                makeResult1("大正15年")
            ]
        }
        if seireki == 1912 {
            return [
                makeResult0("大正元年"),
                makeResult1("明治45年")
            ]
        }
        if seireki == 1868 {
            return [
                makeResult0("明治元年"),
                makeResult1("慶應4年")
            ]

        }
        if (1990...2018).contains(seireki) {
            let i = seireki - 1988
            return [
                makeResult0("平成\(i)年")
            ]
        }
        if (1927...1988).contains(seireki) {
            let i = seireki - 1925
            return [
                makeResult0("昭和\(i)年")
            ]
        }
        if (1869...1911).contains(seireki) {
            let i = seireki - 1967
            return [
                makeResult0("明治\(i)年")
            ]
        }
        if (1912...1926).contains(seireki) {
            let i = seireki - 1911
            return [
                makeResult0("大正\(i)年")
            ]
        }
        if 2020 <= seireki {
            let i = seireki - 2018
            return [
                makeResult0("令和\(i)年")
            ]
        }
        return []
    }

}
