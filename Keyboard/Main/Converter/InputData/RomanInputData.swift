//
//  RomanInputData.swift
//  Keyboard
//
//  Created by β α on 2020/09/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct RomanInputData: InputDataProtocol {
    internal let katakanaString: String
    internal let characters: [Character]
    /// kana2Latticeにおける分割数だと思うこと。
    internal let count: Int
    internal var history: ComposingText
    internal init(_ input: ComposingText, count: Int? = nil) {
        self.history = input.prefixToCursorPosition()
        self.katakanaString = input.convertTarget.toKatakana()
        let romanString = String(self.history.input)   // split由来のデータではかな文字が含まれる
        if let count {
            self.count = count
        } else {
            self.count = romanString.count
        }
        self.characters = self.history.input
    }

    subscript(_ range: ClosedRange<Int>) -> String {
        get {
            return String(self.characters[range])
        }
    }

    /// 入力はローマ字列, 出力はひらがなに変換する。
    internal func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)] {
        let count = right - left + 1
        let unit: PValue = 3.5
        let triple = unit*3
        let nextLetter = (right + 1 == characters.count) ? "\0" : self.characters[right + 1]
        let nodes = (0..<count).map {(i: Int) in
            Self.lengths.flatMap {(k: Int) -> [String] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(String(self.characters[left + i ... left + j]))
            }
        }
        var result: [(lattice: RomanKanaConvertingLattice, penalty: PValue)] = []
        for (i, nodeArray) in nodes.enumerated() {
            let correct = String(self.characters[left + i])
            if i == .zero {
                result = nodeArray.map {(RomanKanaConvertingLattice([(string: $0, isFreezed: false)], count: $0.count), $0 == correct ? .zero:unit)}
                continue
            }
            result = result.flatMap {(lattice: RomanKanaConvertingLattice, penalty: PValue) -> [(lattice: RomanKanaConvertingLattice, penalty: PValue)] in
                // 訂正数上限(3個)
                if lattice.count != i {
                    return [(lattice, penalty)]
                }
                if penalty == triple {
                    return [(lattice.appending(correct), penalty)]
                }
                return nodes[i].compactMap {
                    let _lattice = lattice.appending($0)
                    if _lattice.shouldBeRemoved {
                        return nil
                    }
                    return (lattice: _lattice, penalty: penalty + ($0 == correct ? .zero : unit))
                }
            }
        }
        let finalResult: [(string: String, penalty: PValue)] = result.compactMap {
            if let string = $0.lattice.roman2kanaWithoutRomanLetters(nextCharacter: nextLetter) {
                return (string, $0.penalty)
            }
            return nil
        }
        return finalResult
    }

}

extension RomanInputData {
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

    private static let lengths = [0, 1]

    private static let possibleTypo: [String: [String]] = [
        "bs": ["ba"],
        "no": ["bo"],
        "li": ["ki"],
        "lo": ["ko"],
        "lu": ["ku"],
        "my": ["mu"],
        "tp": ["to"],
        "ts": ["ta"],
        "wi": ["wo"],
        "pu": ["ou"]
    ]
}

extension RomanInputData {
    internal func isAfterDeletedCharacter(previous: RomanInputData) -> Int? {
        // 意図はprevious.characters.hasPrefix(self.characters)だが、そういうAPIがないのでこうしている
        if Array(previous.characters.prefix(self.characters.count)) == self.characters {
            let count_a = self.characters.count
            let count_b = previous.characters.count
            if count_b-count_a <= 0 {
                return nil
            }
            return count_b-count_a
        }
        return nil
    }

    internal func isAfterReplacedCharacter(previous: RomanInputData) -> (deleted: Int, added: Int)? {
        // 共通接頭辞を求める
        let common = String(self.history.input).commonPrefix(with: String(previous.history.input))
        if common == "" {
            return nil
        }
        return (previous.history.input.count - common.count, self.history.input.count - common.count)
    }
}

private struct RomanKanaConvertingLattice {
    var components: [(string: String, isFreezed: Bool)]
    var count: Int = 0

    init(_ components: [(string: String, isFreezed: Bool)] = [], count: Int = 0) {
        self.components = components
        self.count = count
    }

    var shouldBeRemoved: Bool {
        if self.components.isEmpty {
            return false
        }
        let katakana = self.components[0].string.roman2katakana
        return (katakana.count == 1 && !katakana.containsRomanAlphabet && !DicdataStore.existFile(identifier: katakana))
    }

    func appending(_ string: String, isFreezed: Bool = false) -> Self {
        let count = self.count + string.count
        if components.isEmpty {
            var _components = self.components
            _components.append((string: string, isFreezed: isFreezed))
            return RomanKanaConvertingLattice(_components, count: count)
        }
        if let last = self.components.last {
            var _components = self.components
            if last.isFreezed || isFreezed {
                _components.append((string: string, isFreezed: isFreezed))
                return RomanKanaConvertingLattice(_components, count: count)
            } else {
                _components[self.components.endIndex - 1] = (string: last.string + string, isFreezed: false)
                return RomanKanaConvertingLattice(_components, count: count)
            }
        } else {
            return self
        }
    }

    private enum ConvertError: Error {
        case containsRomanLetter
    }

    func roman2kanaWithoutRomanLetters(nextCharacter: Character) -> String? {
        do {
            let strings: [String] = try components.enumerated().map { (index, component) in
                if component.isFreezed {
                    return component.string
                } else {
                    let roman2katakana = component.string.roman2katakana

                    if index == components.endIndex - 1 {
                        if let last = roman2katakana.last, last == "n" && !["a", "i", "u", "e", "o", "n", "y"].contains(nextCharacter) {
                            return roman2katakana.dropLast() + "ん"
                        }
                        if let last = roman2katakana.last, last == nextCharacter && String(last).onlyRomanAlphabet {
                            return roman2katakana.dropLast() + "っ"
                        }
                        return roman2katakana
                    }
                    if !roman2katakana.containsRomanAlphabet {
                        return roman2katakana
                    }
                    // フリーズしている場合以外でローマ字が残ってしまったらアウト
                    throw ConvertError.containsRomanLetter
                }
            }
            return strings.joined().toKatakana()
        } catch {
            return nil
        }
    }

}
