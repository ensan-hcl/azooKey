//
//  DirectInputData.swift
//  Keyboard
//
//  Created by β α on 2020/09/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct DirectInputData: InputDataProtocol {
    internal let katakanaString: String
    internal let characters: [Character]
    internal let count: Int

    internal init(_ input: String, count: Int? = nil) {
        if let count = count {
            self.count = count
        } else {
            self.count = input.count
        }
        self.katakanaString = input.toKatakana()
        self.characters = Array(self.katakanaString)
    }

    internal subscript(_ range: ClosedRange<Int>) -> String {
        get {
            return String(self.katakanaString[range])
        }
    }

    internal func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)] {
        let unit: PValue = 3.5
        let triple: PValue = unit * 3
        let count = right-left+1
        let nodes = (0..<count).map {(i: Int) in
            (i..<min(count, i + Self.possibleMaxLength)).flatMap {(j: Int) -> [String] in
                let segment = String(self.characters[left+i...left+j])
                return Self.getTypo(segment)
            }
        }

        let result = nodes.indices.dropFirst().reduce(into: nodes[0].map {(string: $0, penalty: $0 == String(characters[left]) ? .zero:unit)}) {array, i in
            let correct = String(characters[left + i])
            array = array.flatMap {(rstring: String, penalty: PValue) -> [(string: String, penalty: PValue)] in
                // アーリーリターン
                if rstring.count != i {
                    return [(rstring, penalty)]
                }
                // 訂正数上限(3個)
                if penalty == triple {
                    return [(rstring + correct, penalty)]
                }
                return nodes[i].map {node -> (string: String, penalty: PValue) in
                    return (string: rstring + node, penalty: penalty + (node == correct ? .zero:unit))
                }
            }

        }
        return result
    }
}

extension DirectInputData {
    /// 誤り部分の最長文字数
    private static let possibleMaxLength = 1

    /// 誤り訂正候補を取得する関数
    /// - parameters:
    ///  - string: 元の文字列
    private static func getTypo(_ string: String) -> [String] {
        let count = string.count
        if count > 1 {
            return Self.possibleTypo[string, default: []]
        }
        if count == 1 {
            var result = Self.possibleTypo[string, default: []]
            result.append(string)
            return result
        }
        return []
    }

    /// あり得る誤りをまとめた辞書。
    private static let possibleTypo: [String: [String]] = [
        "カ": ["ガ"],
        "キ": ["ギ"],
        "ク": ["グ"],
        "ケ": ["ゲ"],
        "コ": ["ゴ"],
        "サ": ["ザ"],
        "シ": ["ジ"],
        "ス": ["ズ"],
        "セ": ["ゼ"],
        "ソ": ["ゾ"],
        "タ": ["ダ"],
        "チ": ["ヂ"],
        "ツ": ["ヅ", "ッ"],
        "テ": ["デ"],
        "ト": ["ド"],
        "ハ": ["バ", "パ"],
        "ヒ": ["ビ", "ピ"],
        "フ": ["ブ", "プ"],
        "ヘ": ["ベ", "ペ"],
        "ホ": ["ボ", "ポ"],
        "バ": ["パ"],
        "ビ": ["ピ"],
        "ブ": ["プ"],
        "ベ": ["ペ"],
        "ボ": ["ポ"],
        "ヤ": ["ャ"],
        "ユ": ["ュ"],
        "ヨ": ["ョ"]
    ]
}
