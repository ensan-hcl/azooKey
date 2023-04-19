//
//  TypoCorrection.swift
//  Keyboard
//
//  Created by ensan on 2022/12/18.
//  Copyright © 2022 ensan. All rights reserved.
//

// MARK: 誤り訂正用のAPI
extension ComposingText {
    private func shouldBeRemovedForDicdataStore(components: [ConvertTargetElement]) -> Bool {
        // 判定に使うのは最初の1エレメントの最初の文字で十分
        guard let first = components.first?.string.first?.toKatakana() else {
            return false
        }
        return !CharacterUtils.isRomanLetter(first) && !DicdataStore.existLOUDS(for: first)
    }

    /// closedRangeでもらう
    /// getRangeWithTyposの複数版にあたる。`result`の計算が一回で済む分、高速になる。
    /// 例えば`left=4, rightIndexRange=6..<10`の場合、`4...6, 4...7, 4...8, 4...9`の範囲で計算する
    /// `left <= rightIndexRange.startIndex`が常に成り立つ
    func getRangesWithTypos(_ left: Int, rightIndexRange: Range<Int>) -> [[Character]: (endIndex: Int, penalty: PValue)] {
        let count = rightIndexRange.endIndex - left
        debug("getRangesWithTypos", left, rightIndexRange, count)
        let nodes = (0..<count).map {(i: Int) in
            Self.lengths.flatMap {(k: Int) -> [TypoCandidate] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(self.input[left + i ... left + j])
            }
        }

        let maxPenalty: PValue = 3.5 * 3
        // Performance Tuning Note：直接Dictionaryを作るのではなく、一度Arrayを作ってから最後にDictionaryに変換する方が、高速である
        var stringToInfo: [([Character], (endIndex: Int, penalty: PValue))] = []

        // 深さ優先で列挙する
        var stack: [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] = nodes[0].compactMap { typoCandidate in
            guard let firstElement = typoCandidate.inputElements.first else {
                return nil
            }
            if Self.isLeftSideValid(first: firstElement, of: self.input, from: left) {
                var convertTargetElements = [ConvertTargetElement]()
                for element in typoCandidate.inputElements {
                    ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                }
                return (convertTargetElements, typoCandidate.inputElements.last!, typoCandidate.inputElements.count, typoCandidate.weight)
            }
            return nil
        }
        while let (convertTargetElements, lastElement, count, penalty) = stack.popLast() {
            if rightIndexRange.contains(count + left - 1) {
                if let convertTarget = ComposingText.getConvertTargetIfRightSideIsValid(lastElement: lastElement, of: self.input, to: count + left, convertTargetElements: convertTargetElements)?.map({$0.toKatakana()}) {
                    stringToInfo.append((convertTarget, (count + left - 1, penalty)))
                }
            }
            // エスケープ
            if nodes.endIndex <= count {
                continue
            }
            // 訂正数上限(3個)
            if penalty >= maxPenalty {
                var convertTargetElements = convertTargetElements
                let correct = [self.input[left + count]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
                if count + correct.count > nodes.endIndex {
                    continue
                }
                for element in correct {
                    ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                }
                stack.append((convertTargetElements, correct.last!, count + correct.count, penalty))
            } else {
                stack.append(contentsOf: nodes[count].compactMap {
                    if count + $0.inputElements.count > nodes.endIndex {
                        return nil
                    }
                    var convertTargetElements = convertTargetElements
                    for element in $0.inputElements {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    if shouldBeRemovedForDicdataStore(components: convertTargetElements) {
                        return nil
                    }
                    return (
                        convertTargetElements: convertTargetElements,
                        lastElement: $0.inputElements.last!,
                        count: count + $0.inputElements.count,
                        penalty: penalty + $0.weight
                    )
                })
            }
        }
        return Dictionary(stringToInfo, uniquingKeysWith: {$0.penalty < $1.penalty ? $1 : $0})
    }

    func getRangeWithTypos(_ left: Int, _ right: Int) -> [[Character]: PValue] {
        // 各iから始まる候補を列挙する
        // 例えばinput = [d(あ), r(s), r(i), r(t), r(s), d(は), d(は), d(れ)]の場合
        // nodes =      [[d(あ)], [r(s)], [r(i)], [r(t), [r(t), r(a)]], [r(s)], [d(は), d(ば), d(ぱ)], [d(れ)]]
        // となる
        let count = right - left + 1
        let nodes = (0..<count).map {(i: Int) in
            Self.lengths.flatMap {(k: Int) -> [TypoCandidate] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(self.input[left + i ... left + j])
            }
        }

        let maxPenalty: PValue = 3.5 * 3

        // 深さ優先で列挙する
        var stack: [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] = nodes[0].compactMap { typoCandidate in
            guard let firstElement = typoCandidate.inputElements.first else {
                return nil
            }
            if Self.isLeftSideValid(first: firstElement, of: self.input, from: left) {
                var convertTargetElements = [ConvertTargetElement]()
                for element in typoCandidate.inputElements {
                    ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                }
                return (convertTargetElements, typoCandidate.inputElements.last!, typoCandidate.inputElements.count, typoCandidate.weight)
            }
            return nil
        }

        var stringToPenalty: [([Character], PValue)] = []

        while let (convertTargetElements, lastElement, count, penalty) = stack.popLast() {
            if count + left - 1 == right {
                if let convertTarget = ComposingText.getConvertTargetIfRightSideIsValid(lastElement: lastElement, of: self.input, to: count + left, convertTargetElements: convertTargetElements)?.map({$0.toKatakana()}) {
                    stringToPenalty.append((convertTarget, penalty))
                }
                continue
            }
            // エスケープ
            if nodes.endIndex <= count {
                continue
            }
            // 訂正数上限(3個)
            if penalty >= maxPenalty {
                var convertTargetElements = convertTargetElements
                let correct = [self.input[left + count]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
                if count + correct.count > nodes.endIndex {
                    continue
                }
                for element in correct {
                    ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                }
                stack.append((convertTargetElements, correct.last!, count + correct.count, penalty))
            } else {
                stack.append(contentsOf: nodes[count].compactMap {
                    if count + $0.inputElements.count > nodes.endIndex {
                        return nil
                    }
                    var convertTargetElements = convertTargetElements
                    for element in $0.inputElements {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    if shouldBeRemovedForDicdataStore(components: convertTargetElements) {
                        return nil
                    }
                    return (
                        convertTargetElements: convertTargetElements,
                        lastElement: $0.inputElements.last!,
                        count: count + $0.inputElements.count,
                        penalty: penalty + $0.weight
                    )
                })
            }
        }
        return Dictionary(stringToPenalty, uniquingKeysWith: max)
    }

    private static func getTypo(_ elements: some Collection<InputElement>) -> [TypoCandidate] {
        let key = elements.reduce(into: "") {$0.append($1.character)}.toKatakana()

        if (elements.allSatisfy {$0.inputStyle == .direct}) {
            if key.count > 1 {
                return Self.directPossibleTypo[key, default: []].map {
                    TypoCandidate(
                        inputElements: $0.value.map {InputElement(character: $0, inputStyle: .direct)},
                        weight: $0.weight
                    )
                }
            } else if key.count == 1 {
                var result = Self.directPossibleTypo[key, default: []].map {
                    TypoCandidate(
                        inputElements: $0.value.map {InputElement(character: $0, inputStyle: .direct)},
                        weight: $0.weight
                    )
                }
                // そのまま
                result.append(TypoCandidate(inputElements: key.map {InputElement(character: $0, inputStyle: .direct)}, weight: 0))
                return result
            }
        }
        if (elements.allSatisfy {$0.inputStyle == .roman2kana}) {
            if key.count > 1 {
                return Self.roman2KanaPossibleTypo[key, default: []].map {
                    TypoCandidate(
                        inputElements: $0.map {InputElement(character: $0, inputStyle: .roman2kana)},
                        weight: 3.5
                    )
                }
            } else if key.count == 1 {
                var result = Self.roman2KanaPossibleTypo[key, default: []].map {
                    TypoCandidate(
                        inputElements: $0.map {InputElement(character: $0, inputStyle: .roman2kana)},
                        weight: 3.5
                    )
                }
                // そのまま
                result.append(
                    TypoCandidate(inputElements: key.map {InputElement(character: $0, inputStyle: .roman2kana)}, weight: 0)
                )
                return result
            }
        }
        return []
    }

    private static let lengths = [0, 1]

    private struct TypoUnit: Equatable {
        var value: String
        var weight: PValue

        init(_ value: String, weight: PValue = 3.5) {
            self.value = value
            self.weight = weight
        }
    }

    struct TypoCandidate: Equatable {
        var inputElements: [InputElement]
        var weight: PValue
    }

    /// ダイレクト入力用
    private static let directPossibleTypo: [String: [TypoUnit]] = [
        "カ": [TypoUnit("ガ", weight: 7.0)],
        "キ": [TypoUnit("ギ")],
        "ク": [TypoUnit("グ")],
        "ケ": [TypoUnit("ゲ")],
        "コ": [TypoUnit("ゴ")],
        "サ": [TypoUnit("ザ")],
        "シ": [TypoUnit("ジ")],
        "ス": [TypoUnit("ズ")],
        "セ": [TypoUnit("ゼ")],
        "ソ": [TypoUnit("ゾ")],
        "タ": [TypoUnit("ダ", weight: 6.0)],
        "チ": [TypoUnit("ヂ")],
        "ツ": [TypoUnit("ッ", weight: 6.0), TypoUnit("ヅ", weight: 4.5)],
        "テ": [TypoUnit("デ", weight: 6.0)],
        "ト": [TypoUnit("ド", weight: 4.5)],
        "ハ": [TypoUnit("バ", weight: 4.5), TypoUnit("パ", weight: 6.0)],
        "ヒ": [TypoUnit("ビ"), TypoUnit("ピ", weight: 4.5)],
        "フ": [TypoUnit("ブ"), TypoUnit("プ", weight: 4.5)],
        "ヘ": [TypoUnit("ベ"), TypoUnit("ペ", weight: 4.5)],
        "ホ": [TypoUnit("ボ"), TypoUnit("ポ", weight: 4.5)],
        "バ": [TypoUnit("パ")],
        "ビ": [TypoUnit("ピ")],
        "ブ": [TypoUnit("プ")],
        "ベ": [TypoUnit("ペ")],
        "ボ": [TypoUnit("ポ")],
        "ヤ": [TypoUnit("ャ")],
        "ユ": [TypoUnit("ュ")],
        "ヨ": [TypoUnit("ョ")]
    ]

    private static let roman2KanaPossibleTypo: [String: [String]] = [
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
