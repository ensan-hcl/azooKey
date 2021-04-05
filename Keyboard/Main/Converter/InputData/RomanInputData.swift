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
    internal let history: KanaRomanStateHolder
    internal let freezed: [Bool]
    internal init(_ input: String, history: KanaRomanStateHolder, count: Int? = nil) {
        // 入力とhistoryが正しく対応するように調整する。
        if input.isEmpty {
            self.history = KanaRomanStateHolder()
        } else {
            let index = history.supremumIndexWithFreezing(for: input)
            self.history = KanaRomanStateHolder(components: Array(history.components.prefix(index + 1)))
        }
        self.katakanaString = input.applyingTransform(.hiraganaToKatakana, reverse: false) ?? ""
        let romanString = self.history.components.map {$0.internalText}.joined()   // split由来のデータではかな文字が含まれる
        if let count = count {
            self.count = count
        } else {
            self.count = romanString.count
        }
        self.characters = Array(romanString)
        self.freezed = self.history.components.reduce(into: []) {array, component in
            array.append(contentsOf: [Bool].init(repeating: component.isFreezed, count: component.internalText.count))
        }
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
            Self.lengths.map {i+$0}.flatMap {(j: Int) -> [String] in
                if count <= j {
                    return []
                }
                if i == j && freezed[left + i] {
                    return [String(self.characters[left + i])]
                }
                if (left + i ... left + j).allSatisfy({!freezed[$0]}) {
                    return Self.getTypo(String(self.characters[left + i ... left + j]))
                }
                return []
            }
        }
        var result: [(lattice: RomanKanaConvertingLattice, penalty: PValue)] = []
        nodes.indices.forEach {(i: Int) in
            let correct = String(self.characters[left + i])
            if i == .zero {
                if let component = history.freezedData(internalCharacterCount: left + i + 1) {
                    let lattice = RomanKanaConvertingLattice([(string: component.displayedText, isFreezed: true)], count: component.displayedText.count)
                    result = [(lattice: lattice, penalty: .zero)]
                    return
                }
                result = nodes[i].map {(RomanKanaConvertingLattice([(string: $0, isFreezed: false)], count: $0.count), $0 == correct ? .zero:unit)}
                return
            }
            result = result.flatMap {(lattice: RomanKanaConvertingLattice, penalty: PValue) -> [(lattice: RomanKanaConvertingLattice, penalty: PValue)] in
                // 訂正数上限(3個)
                if lattice.count != i {
                    return [(lattice, penalty)]
                }
                if let component = history.freezedData(internalCharacterCount: left + i + 1) {
                    return [(lattice: lattice.appending(component.displayedText, isFreezed: true), penalty: penalty)]
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
    fileprivate static func getTypo(_ string: String) -> [String] {
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
    /*
     internal func isAfterAddedCharacter(previous: Self) -> Int? {
     let count_a = self.characters.count
     let count_b = previous.characters.count
     if count_b-count_a >= 0{
     return nil
     }
     let prefix: [Character] = Array(self.characters.prefix(count_b))
     if prefix == previous.characters{
     //nとっのパターンの場合は判定しない。
     if prefix.last == "n" || self.characters.suffix(count_a-count_b).first == prefix.last{
     return nil
     }
     return self.characters.count - previous.count
     }
     return nil
     }
     */
    internal func isAfterDeletedCharacter(previous: RomanInputData) -> Int? {
        if Array(previous.characters.prefix(self.characters.count)) == self.characters {
            let count_a = self.characters.count
            let count_b = previous.characters.count
            if count_b-count_a <= 0 {
                return nil
            }

            let minCount = min(count_a, count_b)
            if self.freezed.prefix(minCount) != previous.freezed.prefix(minCount) {
                return nil
            }

            return count_b-count_a
        } else {
            return nil
        }
    }

    internal func isAfterReplacedCharacter(previous: RomanInputData) -> (deleted: Int, added: Int)? {
        let displayedText_s = self.history.components.flatMap {Array($0.displayedText)}
        let displayedText_p = previous.history.components.flatMap {Array($0.displayedText)}
        let displayedText_endIndex = min(displayedText_s.endIndex, displayedText_p.endIndex)

        var i = 0
        while i<displayedText_endIndex && displayedText_s[i] == displayedText_p[i] {
            i += 1
        }
        if i == 0 || i == displayedText_endIndex {
            return nil
        }
        let common = String(displayedText_s.prefix(i))  // 共通部分
        let result = self.history.supremumIndex(for: common)
        if result.match {
            let index = self.history.components[0...result.index].map {$0.internalText.count}.reduce(0, +)
            let deleted = previous.characters.count - index
            let added = self.characters.count - index
            if deleted == 0 || added == 0 {
                return nil
            }
            return (deleted, added)
        } else {
            return nil
        }
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
            let strings: [String] = try components.indices.map {
                if components[$0].isFreezed {
                    return components[$0].string
                } else {
                    let roman2katakana = components[$0].string.roman2katakana

                    if $0 == components.endIndex - 1 {
                        if let last = roman2katakana.last, last == nextCharacter && String(last).onlyRomanAlphabet {
                            return roman2katakana.dropLast() + "っ"
                        }
                        if let last = roman2katakana.last, last == "n" && !["a", "i", "u", "e", "o", "n", "y"].contains(nextCharacter) {
                            return roman2katakana.dropLast() + "ん"
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
            return strings.joined().applyingTransform(.hiraganaToKatakana, reverse: false)!
        } catch {
            return nil
        }
    }

}
