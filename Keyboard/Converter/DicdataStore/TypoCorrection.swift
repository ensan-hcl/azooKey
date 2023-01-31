//
//  TypoCorrection.swift
//  KanaKanjier
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
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
    func getRangesWithTypos(_ left: Int, rightIndexRange: Range<Int>) -> (typos: [(string: String, penalty: PValue)], stringToEndIndex: [String: Int]) {
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
        var result: [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] = []
        var typos: [(string: String, penalty: PValue)] = []
        var stringToEndIndex: [String: Int] = [:]

        for (i, nodeArray) in nodes.enumerated() {
            defer {
                // i + 1 + leftがrightIndexRangeの中に入っている場合、typosに追加する
                if rightIndexRange.contains(i + left) {
                    for typo in result {
                        if let convertTarget = ComposingText.getConvertTargetIfRightSideIsValid(lastElement: typo.lastElement, of: self.input, to: i + left + 1, convertTargetElements: typo.convertTargetElements)?.toKatakana() {
                            stringToEndIndex[convertTarget] = i + left
                            typos.append( (convertTarget, typo.penalty) )
                        }
                    }
                }
            }
            if i == .zero {
                // 最初の値による枝刈りを実施する
                result = nodeArray.compactMap { typoCandidate in
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
                continue
            }

            let correct = [self.input[left + i]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
            result = result.flatMap {(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue) -> [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] in
                if count != i {
                    return [(convertTargetElements, lastElement, count, penalty)]
                }
                // 訂正数上限(3個)
                if penalty >= maxPenalty {
                    var convertTargetElements = convertTargetElements
                    for element in correct {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    return [(convertTargetElements, correct.last!, count + correct.count, penalty)]
                }
                return nodes[i].compactMap {
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
                }
            }
        }
        return (typos, stringToEndIndex)
    }

    func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)] {
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
        var result: [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] = []
        for (i, nodeArray) in nodes.enumerated() {
            if i == .zero {
                // 最初の値による枝刈りを実施する
                result = nodeArray.compactMap {
                    guard let firstElement = $0.inputElements.first else {
                        return nil
                    }
                    if Self.isLeftSideValid(first: firstElement, of: self.input, from: left) {
                        var convertTargetElements = [ConvertTargetElement]()
                        for element in $0.inputElements {
                            ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                        }
                        return (convertTargetElements, $0.inputElements.last!, $0.inputElements.count, $0.weight)
                    }
                    return nil
                }
                continue
            }
            let correct = [self.input[left + i]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
            result = result.flatMap {(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue) -> [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] in
                if count != i {
                    return [(convertTargetElements, lastElement, count, penalty)]
                }
                // 訂正数上限(3個)
                if penalty >= maxPenalty {
                    var convertTargetElements = convertTargetElements
                    for element in correct {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    return [(convertTargetElements, correct.last!, count + correct.count, penalty)]
                }
                return nodes[i].compactMap {
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
                }
            }
        }
        let filtered: [(string: String, penalty: PValue)] = result.compactMap {
            if let convertTarget = ComposingText.getConvertTargetIfRightSideIsValid(lastElement: $0.lastElement, of: self.input, to: right + 1, convertTargetElements: $0.convertTargetElements) {
                return (convertTarget.toKatakana(), $0.penalty)
            }
            return nil
        }
        return filtered
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
