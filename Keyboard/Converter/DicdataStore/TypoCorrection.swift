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
            Self.lengths.flatMap {(k: Int) -> [[InputElement]] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(self.input[left + i ... left + j])
            }
        }

        let unit: PValue = 3.5
        let triple = unit * 3
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
            let correct = [self.input[left + i]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
            if i == .zero {
                // 最初の値による枝刈りを実施する
                result = nodeArray.compactMap { inputElements in
                    guard let firstElement = inputElements.first else {
                        return nil
                    }
                    if Self.isLeftSideValid(first: firstElement, of: self.input, from: left) {
                        var convertTargetElements = [ConvertTargetElement]()
                        for element in inputElements {
                            ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                        }
                        return (convertTargetElements, inputElements.last!, inputElements.count, inputElements == correct ? .zero:unit)
                    }
                    return nil
                }
                continue
            }
            result = result.flatMap {(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue) -> [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] in
                if count != i {
                    return [(convertTargetElements, lastElement, count, penalty)]
                }
                // 訂正数上限(3個)
                if penalty == triple {
                    var convertTargetElements = convertTargetElements
                    for element in correct {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    return [(convertTargetElements, correct.last!, count + correct.count, penalty)]
                }
                return nodes[i].compactMap {
                    var convertTargetElements = convertTargetElements
                    for element in $0 {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    if shouldBeRemovedForDicdataStore(components: convertTargetElements) {
                        return nil
                    }
                    return (
                        convertTargetElements: convertTargetElements,
                        lastElement: $0.last!,
                        count: count + $0.count,
                        penalty: penalty + ($0 == correct ? .zero : unit)
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
            Self.lengths.flatMap {(k: Int) -> [[InputElement]] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(self.input[left + i ... left + j])
            }
        }

        let unit: PValue = 3.5
        let triple = unit * 3
        var result: [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] = []
        for (i, nodeArray) in nodes.enumerated() {
            let correct = [self.input[left + i]].map {InputElement(character: $0.character.toKatakana(), inputStyle: $0.inputStyle)}
            if i == .zero {
                // 最初の値による枝刈りを実施する
                result = nodeArray.compactMap {
                    guard let firstElement = $0.first else {
                        return nil
                    }
                    if Self.isLeftSideValid(first: firstElement, of: self.input, from: left) {
                        var convertTargetElements = [ConvertTargetElement]()
                        for element in $0 {
                            ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                        }
                        return (convertTargetElements, $0.last!, $0.count, $0 == correct ? .zero:unit)
                    }
                    return nil
                }
                continue
            }
            result = result.flatMap {(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue) -> [(convertTargetElements: [ConvertTargetElement], lastElement: InputElement, count: Int, penalty: PValue)] in
                if count != i {
                    return [(convertTargetElements, lastElement, count, penalty)]
                }
                // 訂正数上限(3個)
                if penalty == triple {
                    var convertTargetElements = convertTargetElements
                    for element in correct {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    return [(convertTargetElements, correct.last!, count + correct.count, penalty)]
                }
                return nodes[i].compactMap {
                    var convertTargetElements = convertTargetElements
                    for element in $0 {
                        ComposingText.updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
                    }
                    if shouldBeRemovedForDicdataStore(components: convertTargetElements) {
                        return nil
                    }
                    return (
                        convertTargetElements: convertTargetElements,
                        lastElement: $0.last!,
                        count: count + $0.count,
                        penalty: penalty + ($0 == correct ? .zero : unit)
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

    private static func getTypo(_ elements: some Collection<InputElement>) -> [[InputElement]] {
        let key = elements.reduce(into: "") {$0.append($1.character)}.toKatakana()

        if (elements.allSatisfy {$0.inputStyle == .direct}) {
            if key.count > 1 {
                return Self.directPossibleTypo[key, default: []].map {$0.map {InputElement(character: $0, inputStyle: .direct)}}
            } else if key.count == 1 {
                var result = Self.directPossibleTypo[key, default: []].map {$0.map {InputElement(character: $0, inputStyle: .direct)}}
                result.append(key.map {InputElement(character: $0, inputStyle: .direct)})
                return result
            }
        }
        if (elements.allSatisfy {$0.inputStyle == .roman2kana}) {
            if key.count > 1 {
                return Self.roman2KanaPossibleTypo[key, default: []].map {$0.map {InputElement(character: $0, inputStyle: .roman2kana)}}
            } else if key.count == 1 {
                var result = Self.roman2KanaPossibleTypo[key, default: []].map {$0.map {InputElement(character: $0, inputStyle: .roman2kana)}}
                result.append(key.map {InputElement(character: $0, inputStyle: .roman2kana)})
                return result
            }
        }
        return []
    }

    private static let lengths = [0, 1]

    /// ダイレクト入力用
    private static let directPossibleTypo: [String: [String]] = [
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
