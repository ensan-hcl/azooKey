//
//  Combinations.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
// import Combinatorics
import XCTest

class CombinatoricsTest: XCTestCase {
    let possibleMaxLength = 1
    let possibleTypo: [String: [String]] = [
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

    func getTypo(_ string: String) -> [String] {
        let count = string.count
        if count > 1 {
            return self.possibleTypo[string] ?? []
        }
        if count == 1 {
            return (self.possibleTypo[string] ?? []) + [string]
        }
        return []
    }

    func getRangeWithTypos(text: String) -> [(string: String, penalty: PValue)] {
        let characters = Array(text)
        let count = characters.count

        let nodes = (0..<count).map {(i: Int) in
            (i..<min(count, i + self.possibleMaxLength)).flatMap {(j: Int) -> [String] in
                self.getTypo(String(characters[i...j]))
            }
        }

        let result = nodes.indices.dropFirst().reduce(into: nodes[0].map {(string: $0, penalty: $0 == String(characters[0]) ? .zero:PValue(3))}) {array, i in
            let correct = String(characters[i])
            array = array.flatMap {(rstring: String, penalty: PValue) -> [(string: String, penalty: PValue)] in
                // 訂正数上限(3個)
                if penalty == 9 || rstring.count != i {
                    return [(rstring, penalty)]
                }
                return nodes[i].map {node -> (String, PValue) in
                    (rstring + node, penalty + (node == correct ? 0:3))
                }
            }

        }
        return result
    }

    func getRangeWithTypos4(text: String) -> [(string: String, penalty: PValue)] {
        let characters = Array(text)
        let count = characters.count

        let typos = (0..<count).map {(i: Int) in
            (i..<min(count, i + self.possibleMaxLength)).flatMap {(j: Int) -> [String] in
                self.possibleTypo[String(characters[i...j]), default: []]
            }
        }

        let result = typos.indices.dropFirst().reduce(into: [(string: String(characters[0]), penalty: PValue.zero)] + typos[0].map {(string: $0, penalty: 3)}) {array, i in
            let correct = String(characters[i])
            array = array.flatMap {(rstring: String, penalty: PValue) -> [(string: String, penalty: PValue)] in
                // 訂正数上限(3個)
                if penalty == 9 || rstring.count != i {
                    return [(rstring, penalty)]
                }
                return [(rstring + correct, penalty)] + typos[i].map {typo -> (String, PValue) in
                    (rstring + typo, penalty + 3)
                }
            }

        }
        return result
    }

    func getRangeWithTypos3(text: String) -> [(string: String, penalty: PValue)] {
        let characters = Array(text)
        let count = characters.count

        let nodes = (0..<count).map {(i: Int) in
            (i..<min(count, i + self.possibleMaxLength)).flatMap {(j: Int) -> [String] in
                self.possibleTypo[String(characters[i...j]), default: []]
            }
        }
        var result0: [String] = [String(characters[0])]
        var result1: [String] = nodes[0]
        var result2: [String] = []
        var result3: [String] = []

        nodes.indices.dropFirst().forEach {i in
            let correct = [characters[i]]
            result3 = result3.map {
                $0.count == i ? $0 + correct : $0
            }

            result2 = result2.map {string in
                if string.count == i {
                    let addTypo = nodes[i].map {node in
                        string + node
                    }
                    result3.append(contentsOf: addTypo)
                    return string + correct
                }
                return string
            }

            result1 = result1.map {string in
                if string.count == i {
                    let addTypo = nodes[i].map {node in
                        string + node
                    }
                    result2.append(contentsOf: addTypo)
                    return string + correct
                }
                return string
            }

            result0 = result0.map {string in
                if string.count == i {
                    let addTypo = nodes[i].map {node in
                        string + node
                    }
                    result1.append(contentsOf: addTypo)
                    return string + correct
                }
                return string
            }
        }
        let result: [(string: String, penalty: PValue)] = result3.map {(string: $0, penalty: 9.0)}
            + result2.map {(string: $0, penalty: 6.0)}
            + result1.map {(string: $0, penalty: 3.0)}

        return result + result0.map {(string: $0, penalty: 0.0)}

    }

    func getRangeWithTypos2(text: String) -> [(string: String, penalty: PValue)] {
        let characters = Array(text)
        let count = characters.count
        let keys = self.possibleTypo.keys
        let typoRanges = (0..<count).flatMap {(i: Int) -> [ClosedRange<Int>] in
            (i..<min(count, i + self.possibleMaxLength)).compactMap {(j: Int) -> ClosedRange<Int>? in
                if keys.contains(String(characters[i...j])) {
                    return i...j
                }
                return nil
            }
        }
        let typos: [[[Character]]] = typoRanges.map {range in
            self.possibleTypo[String(characters[range]), default: []].map {Array($0)}
        }

        let combinations2 = typoRanges.indices.flatMap {i -> [[Int]] in
            typoRanges.indices.compactMap {
                if i >= $0 {
                    return nil
                }
                return [i, $0]
            }
        }

        let combinations3 = combinations2.flatMap {values -> [[Int]] in
            typoRanges.indices.compactMap {
                if let max = values.max(), max >= $0 {
                    return nil
                }
                return values + [$0]
            }
        }
        /*
         let result: [(string: String, penalty: PValue)] = combinations3.flatMap{combs -> [(string: String, penalty: PValue)] in
         var replaced: [(characters: [Character], penalty: PValue)] = [(characters, 0)]
         combs.forEach{i in
         let replaceCandidates = typos[i]
         replaced = replaced.flatMap{(chars: [Character], penalty: PValue) -> [(characters: [Character], penalty: PValue)] in
         return replaceCandidates.map{(candidate: [Character])  -> (characters: [Character], penalty: PValue) in
         var _chars = chars
         _chars.replaceSubrange(typoRanges[i], with: candidate)
         return (_chars, penalty+1)
         }
         }
         }
         return replaced.map{(String($0.characters), $0.penalty*3)}
         }
         */

        let result3: [[Character]] = combinations3.flatMap {combs -> [[Character]] in
            var replaced = [characters]
            combs.forEach {i in
                let replaceCandidates = typos[i]
                replaced = replaced.flatMap {(chars: [Character]) -> [[Character]] in
                    replaceCandidates.map {
                        var _chars = chars
                        _chars.replaceSubrange(typoRanges[i], with: $0)
                        return _chars
                    }
                }
            }
            return replaced
        }

        let result2: [[Character]] = combinations2.flatMap {combs -> [[Character]] in
            var replaced = [characters]
            combs.forEach {i in
                let replaceCandidates = typos[i]
                replaced = replaced.flatMap {(chars: [Character]) -> [[Character]] in
                    replaceCandidates.map {
                        var _chars = chars
                        _chars.replaceSubrange(typoRanges[i], with: $0)
                        return _chars
                    }
                }
            }
            return replaced
        }

        let result1: [[Character]] = typoRanges.indices.flatMap {i -> [[Character]] in
            let replaceCandidates = typos[i]
            let replaced: [[Character]] = replaceCandidates.map {
                var _chars = characters
                _chars.replaceSubrange(typoRanges[i], with: $0)
                return _chars
            }
            return replaced
        }

        var result: [(string: String, penalty: PValue)] = result3.map {(string: String($0), penalty: 9.0)}
        result.append(contentsOf: result2.map {(string: String($0), penalty: 6.0)})
        result.append(contentsOf: result1.map {(string: String($0), penalty: 3.0)})
        result.append((string: text, penalty: PValue.zero))

        return result
    }

    func testPerformanceForEachIndices() throws {
        let text = "シンフンシキエイノタンシヨウヒノハンツウ"
        self.measure {
            for _ in 0..<10 {
                _ = getRangeWithTypos(text: text)
            }
        }
        print(getRangeWithTypos(text: text).count)
    }

    func testPerformanceForInIndices() throws {
        let text = "シンフンシキエイノタンシヨウヒノハンツウ"
        self.measure {
            for _ in 0..<10 {
                _ = getRangeWithTypos4(text: text)
            }
        }
        print(getRangeWithTypos4(text: text).count)
    }

}
