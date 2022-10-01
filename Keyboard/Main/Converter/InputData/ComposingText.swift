//
//  ComposingText.swift
//  Keyboard
//
//  Created by β α on 2022/09/21.
//  Copyright © 2022 DevEn3. All rights reserved.
//

/// ユーザ入力、変換対象文字列、ディスプレイされる文字列、の3つを同時にハンドルするための構造体
///  - `input`: `[k, y, o, u, h, a, a, m, e]`
///  - `convertTarget`: `きょうはあめ`
/// のようになる。`
/// カーソルのポジションもこのクラスが管理する。
/// 設計方針として、inputStyleに関わる実装の違いは全てアップデート方法の違いとして吸収し、`input` / `delete` / `moveCursor` / `complete`時の違いとしては露出させないようにすることを目指した。
struct ComposingText {
    private(set) var convertTargetCursorPosition: Int = 0
    private(set) var input: [InputElement] = []
    private(set) var convertTarget: String = ""

    struct InputElement {
        var character: Character
        var inputStyle: InputStyle
    }

    /// 変換しなくて良いか
    var isEmpty: Bool {
        return self.convertTarget.isEmpty
    }

    /// カーソルが右端に存在するか
    var isAtEndIndex: Bool {
        return self.convertTarget.count == self.convertTargetCursorPosition
    }

    /// カーソルが左端に存在するか
    var isAtStartIndex: Bool {
        return 0 == self.convertTargetCursorPosition
    }

    /// カーソルより前の変換対象
    var convertTargetBeforeCursor: some StringProtocol {
        return self.convertTarget.prefix(self.convertTargetCursorPosition)
    }

    /// `input`でのカーソル位置を無理やり作り出す関数
    /// `target`が左側に来るようなカーソルの位置を返す。
    /// 例えば`input`が`[k, y, o, u]`で`target`が`き|`の場合を考える。
    /// この状態では`input`に対応するカーソル位置が存在しない。
    /// この場合、`input`を`[き, ょ, u]`と置き換えた上で`1`を返す。
    private mutating func forceGetInputCursorPosition(target: some StringProtocol) -> Int {
        debug("ComposingText forceGetInputCursorPosition", self, target)
        if target.isEmpty {
            return 0
        }
        // 動作例1
        // input: `k, a, n, s, h, a` (全てroman2kana)
        // convetTarget: `か ん し| ゃ`
        // convertTargetCursorPosition: 3
        // target: かんし
        // 動作
        // 1. character = "k"
        //    roman2kana = "k"
        //    count = 1
        // 2. character = "a"
        //    roman2kana = "か"
        //    count = 2
        //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 2, lastPrefix = "か"
        // 3. character = "n"
        //    roman2kana = "かn"
        //    count = 3
        // 4. character = "s"
        //    roman2kana = "かんs"
        //    count = 4
        // 5. character = "h"
        //    roman2kana = "かんsh"
        //    count = 5
        // 6. character = "a"
        //    roman2kana = "かんしゃ"
        //    count = 6
        //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
        //    replaceCountは6-2 = 4、したがって`n, s, h, a`が消去される
        //    input = [k, a]
        //    count = 2
        //    roman2kana.count == 4, lastPrefix.count = 1なので、3文字分のsuffix`ん,し,ゃ`が追加される
        //    input = [k, a, ん, し, ゃ]
        //    count = 5
        //    while
        //       1. roman2kana = かんし
        //          count = 4
        //       break
        // return count = 4
        //
        // 動作例2
        // input: `k, a, n, s, h, a` (全てroman2kana)
        // convetTarget: `か ん し| ゃ`
        // convertTargetCursorPosition: 2
        // target: かん
        // 動作
        // 1. character = "k"
        //    roman2kana = "k"
        //    count = 1
        // 2. character = "a"
        //    roman2kana = "か"
        //    count = 2
        //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 2, lastPrefix = "か"
        // 3. character = "n"
        //    roman2kana = "かn"
        //    count = 3
        // 4. character = "s"
        //    roman2kana = "かんs"
        //    count = 4
        //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
        //    replaceCountは4-2 = 2、したがって`n, s`が消去される
        //    input = [k, a] ... [h, a]
        //    count = 2
        //    roman2kana.count == 3, lastPrefix.count = 1なので、2文字分のsuffix`ん,s`が追加される
        //    input = [k, a, ん, s]
        //    count = 4
        //    while
        //       1. roman2kana = かん
        //          count = 3
        //       break
        // return count = 3
        //
        // 動作例3
        // input: `i, t, t, a` (全てroman2kana)
        // convetTarget: `い っ| た`
        // convertTargetCursorPosition: 2
        // target: いっ
        // 動作
        // 1. character = "i"
        //    roman2kana = "い"
        //    count = 1
        //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 1, lastPrefix = "い"
        // 2. character = "t"
        //    roman2kana = "いt"
        //    count = 2
        // 3. character = "t"
        //    roman2kana = "いっt"
        //    count = 3
        //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
        //    replaceCountは3-1 = 2、したがって`t, t`が消去される
        //    input = [i] ... [a]
        //    count = 1
        //    roman2kana.count == 3, lastPrefix.count = 1なので、2文字分のsuffix`っ,t`が追加される
        //    input = [i, っ, t, a]
        //    count = 3
        //    while
        //       1. roman2kana = いっ
        //          count = 2
        //       break
        // return count = 2

        var count = 0
        var lastPrefixIndex = 0
        var lastPrefix = ""
        var converting: [ConvertTargetElement] = []

        for element in input {
            Self.updateConvertTargetElements(currentElements: &converting, newElement: element)
            var converted = converting.reduce(into: "") {$0 += $1.string}
            count += 1

            // 一致していたらその時点のカウントを返す
            if converted == target {
                return count
            }
            // 一致ではないのにhasPrefixが成立する場合、変換しすぎている
            // この場合、inputの変換が必要になる。
            // 例えばcovnertTargetが「あき|ょ」で、`[a, k, y, o]`まで見て「あきょ」になってしまった場合、「あき」がprefixとなる。
            // この場合、lastPrefix=1なので、1番目から現在までの入力をひらがな(suffix)で置き換える
            else if converted.hasPrefix(target) {
                let replaceCount = count - lastPrefixIndex
                let suffix = converted.suffix(converted.count - lastPrefix.count)
                self.input.removeSubrange(count - replaceCount ..< count)
                self.input.insert(contentsOf: suffix.map {InputElement(character: $0, inputStyle: $0.isRomanLetter ? .roman2kana : .direct)}, at: count - replaceCount)

                count -= replaceCount
                count += suffix.count
                while converted != target {
                    _ = converted.popLast()
                    count -= 1
                }
                break
            }
            // prefixになっている場合は更新する
            else if target.hasPrefix(converted) {
                lastPrefixIndex = count
                lastPrefix = converted
            }

        }
        return count
    }

    struct ViewOperation {
        var delete: Int
        var input: String
        var cursor: Int = 0
    }

    private func diff(from oldString: some StringProtocol, to newString: String) -> (delete: Int, input: String) {
        let common = oldString.commonPrefix(with: newString)
        return (oldString.count - common.count, String(newString.dropFirst(common.count)))
    }

    /// inputの更新における特殊処理を扱う
    /// アドホックな対処なのでどうにか一般化したい所存。
    private mutating func updateInput(_ string: String, at inputCursorPosition: Int, inputStyle: InputStyle) {
        if inputCursorPosition == 0 {
            self.input.insert(contentsOf: string.map {InputElement(character: $0, inputStyle: inputStyle)}, at: inputCursorPosition)
            return
        }
        let prev = self.input[inputCursorPosition - 1]
        if inputStyle == .roman2kana && prev.inputStyle == inputStyle, let first = string.first, String(first).onlyRomanAlphabet {
            if prev.character == first && !["a", "i", "u", "e", "n"].contains(first) {
                self.input[inputCursorPosition - 1] = InputElement(character: "っ", inputStyle: .direct)
                self.input.insert(contentsOf: string.map {InputElement(character: $0, inputStyle: inputStyle)}, at: inputCursorPosition)
                return
            }
            let n_prefix = self.input[0 ..< inputCursorPosition].suffix {$0.character == "n" && $0.inputStyle == .roman2kana}
            if n_prefix.count % 2 == 1 && !["n", "a", "i", "u", "e", "o", "y"].contains(first) {
                self.input[inputCursorPosition - 1] = InputElement(character: "ん", inputStyle: .direct)
                self.input.insert(contentsOf: string.map {InputElement(character: $0, inputStyle: inputStyle)}, at: inputCursorPosition)
                return
            }
        }
        self.input.insert(contentsOf: string.map {InputElement(character: $0, inputStyle: inputStyle)}, at: inputCursorPosition)
    }

    /// 現在のカーソル位置に文字を追加する関数
    mutating func insertAtCursorPosition(_ string: String, inputStyle: InputStyle) -> ViewOperation {
        if string.isEmpty {
            return ViewOperation(delete: 0, input: "")
        }
        let inputCursorPosition = self.forceGetInputCursorPosition(target: self.convertTarget.prefix(convertTargetCursorPosition))
        // input, convertTarget, convertTargetCursorPositionの3つを更新する
        // inputを更新
        self.updateInput(string, at: inputCursorPosition, inputStyle: inputStyle)

        let oldConvertTarget = self.convertTarget.prefix(self.convertTargetCursorPosition)
        let newConvertTarget = Self.getConvertTarget(for: self.input.prefix(inputCursorPosition + string.count))
        let diff = self.diff(from: oldConvertTarget, to: newConvertTarget)
        // convertTargetを更新
        self.convertTarget.removeFirst(convertTargetCursorPosition)
        self.convertTarget.insert(contentsOf: newConvertTarget, at: convertTarget.startIndex)
        // convertTargetCursorPositionを更新
        self.convertTargetCursorPosition -= diff.delete
        self.convertTargetCursorPosition += diff.input.count

        return ViewOperation(delete: diff.delete, input: diff.input)
    }


    mutating func deleteForwardFromCursorPosition(count: Int) -> ViewOperation {
        let count = min(convertTarget.count - convertTargetCursorPosition, count)
        if count == 0 {
            return ViewOperation(delete: 0, input: "")
        }
        self.convertTargetCursorPosition += count
        let result = self.deleteBackwardFromCursorPosition(count: count)
        // 進行方向のデリートなので負の値を返す
        return ViewOperation(delete: -result.delete, input: result.input)
    }

    /// 現在のカーソル位置から文字を削除する関数
    /// エッジケースとして、`sha: しゃ|`の状態で1文字消すような場合がある。
    mutating func deleteBackwardFromCursorPosition(count: Int) -> ViewOperation {
        let count = min(convertTargetCursorPosition, count)

        if count == 0 {
            return ViewOperation(delete: 0, input: "")
        }
        // 動作例1
        // convertTarget: かんしゃ|
        // input: [k, a, n, s, h, a]
        // count = 1
        // currentPrefix = かんしゃ
        // これから行く位置
        //  targetCursorPosition = forceGetInputCursorPosition(かんし) = 4
        //  副作用でinputは[k, a, ん, し, ゃ]
        // 現在の位置
        //  inputCursorPosition = forceGetInputCursorPosition(かんしゃ) = 5
        //  副作用でinputは[k, a, ん, し, ゃ]
        // inputを更新する
        //  input =   (input.prefix(targetCursorPosition) = [k, a, ん, し])
        //          + (input.suffix(input.count - inputCursorPosition) = [])
        //        =   [k, a, ん, し]

        // 動作例2
        // convertTarget: かんしゃ|
        // input: [k, a, n, s, h, a]
        // count = 2
        // currentPrefix = かんしゃ
        // これから行く位置
        //  targetCursorPosition = forceGetInputCursorPosition(かん) = 3
        //  副作用でinputは[k, a, ん, s, h, a]
        // 現在の位置
        //  inputCursorPosition = forceGetInputCursorPosition(かんしゃ) = 6
        //  副作用でinputは[k, a, ん, s, h, a]
        // inputを更新する
        //  input =   (input.prefix(targetCursorPosition) = [k, a, ん])
        //          + (input.suffix(input.count - inputCursorPosition) = [])
        //        =   [k, a, ん]

        // 今いる位置
        let currentPrefix = self.convertTargetBeforeCursor

        // この2つの値はこの順で計算する。
        // これから行く位置
        let targetCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix.dropLast(count))
        // 現在の位置
        let inputCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix)

        // inputを更新する
        self.input.removeSubrange(targetCursorPosition ..< inputCursorPosition)
        // カーソルを更新する
        self.convertTargetCursorPosition -= count

        // convetTargetを更新する
        self.convertTarget = Self.getConvertTarget(for: self.input)

        return ViewOperation(delete: count, input: "")
    }

    /// 現在のカーソル位置からカーソルを動かす関数
    mutating func moveCursorFromCursorPosition(count: Int) -> ViewOperation {
        let count = max(min(self.convertTarget.count - self.convertTargetCursorPosition, count), -self.convertTargetCursorPosition)
        self.convertTargetCursorPosition += count
        return ViewOperation(delete: 0, input: "", cursor: count)
    }

    /// 文頭の方を確定させる関数
    ///  - parameters:
    ///   - correspondingCount: `converTarget`において対応する文字数
    mutating func complete(correspondingCount: Int) {
        let correspondingCount = min(correspondingCount, self.input.count)
        self.input.removeFirst(correspondingCount)
        // convetTargetを更新する
        let newConvertTarget = Self.getConvertTarget(for: self.input)
        // カーソルの位置は、消す文字数の分削除する
        let cursorDelta = self.convertTarget.count - newConvertTarget.count
        self.convertTarget = newConvertTarget
        self.convertTargetCursorPosition -= cursorDelta
    }

    func prefixToCursorPosition() -> ComposingText {
        var text = self
        let index = text.forceGetInputCursorPosition(target: text.convertTarget.prefix(text.convertTargetCursorPosition))
        text.input = Array(text.input.prefix(index))
        text.convertTarget = String(text.convertTarget.prefix(text.convertTargetCursorPosition))
        return text
    }

    mutating func clear() {
        self.input = []
        self.convertTarget = ""
        self.convertTargetCursorPosition = 0
    }
}

extension ComposingText {
    static func getConvertTarget(for elements: some Sequence<InputElement>) -> String {
        var convertTargetElements: [ConvertTargetElement] = []
        for element in elements {
            updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
        }
        return convertTargetElements.reduce(into: "") {$0 += $1.string}
    }

    /// 「正当な」部分領域を返す関数
    /// `elements[leftIndex ..< rightIndex]が正当であればこれをConvertTargetに変換して返す。
    ///  - examples
    ///  `elements = [r(k, a, n, s, h, a)]`のとき、`k,a,n,s,h,a`や`k, a`は正当だが`a, n`や`s, h`は正当ではない。`k, a, n`は特に正当であるとみなす。
    ///
    static func getConvertTargetForValidPart(part partialElements: [InputElement], of originalElements: [InputElement], from leftIndex: Int, to rightIndex: Int) -> String? {
        debug("getConvertTargetForValidPart", partialElements, originalElements, leftIndex, rightIndex)
        if leftIndex < originalElements.startIndex || originalElements.endIndex < rightIndex {
            return nil
        }
        if leftIndex == rightIndex {
            return nil
        }
        // 正当性のチェックを行う
        // 基本的に、convertTargetと正しく対応する部分のみを取り出したい。
        // leftIndexの位置にある`el`のチェック
        // 許されるパターンは以下の通り
        // * leftIndex == startIndex
        // * el:direct
        // * (_:direct) -> el
        // * (a|i|u|e|o:roman2kana) -> el                  // aka、のような場合、ka部分を正当とみなす
        // * (e-1:roman2kana and not n) && e-1 == es       // tta、のような場合、ta部分を正当とみなすが、nnaはだめ。
        // * (n:roman2kana) -> el && el not a|i|u|e|o|y|n  // nka、のような場合、ka部分を正当とみなすが、nnaはだめ。
        guard let firstElement = partialElements.first else {
            return nil
        }
        let string = partialElements.reduce(into: "") {$0.append($1.character)}
        checkIsStartValid: do {
            // 左端か、directなElementである場合
            guard leftIndex != originalElements.startIndex && firstElement.inputStyle == .roman2kana else {
                break checkIsStartValid
            }

            // 句読点や矢印のエスケープ
            if !string.containsRomanAlphabet {
                break checkIsStartValid
            }
            if ["zl", "zk", "zj", "zh"].contains(string) {
                break checkIsStartValid
            }

            let prevLastElement = originalElements[leftIndex - 1]
            if prevLastElement.inputStyle != .roman2kana || !prevLastElement.character.isRomanLetter {
                break checkIsStartValid
            }

            if ["a", "i", "u", "e", "o"].contains(prevLastElement.character) {
                break checkIsStartValid
            }
            if prevLastElement.character != "n" && prevLastElement.character == firstElement.character {
                break checkIsStartValid
            }
            let last_2 = originalElements[0 ..< leftIndex].suffix(2)
            if ["zl", "zk", "zj", "zh"].contains(last_2.reduce(into: "") {$0.append($1.character)}) {
                break checkIsStartValid
            }
            let n_suffix = originalElements[0 ..< leftIndex].suffix(while: {$0.inputStyle == .roman2kana && $0.character == "n"})
            if n_suffix.count % 2 == 0 && n_suffix.count > 0 {
                break checkIsStartValid
            }
            if n_suffix.count % 2 == 1 && !["a", "i", "u", "e", "o", "y", "n"].contains(firstElement.character) {
                break checkIsStartValid
            }
            return nil
        }
        // rightIndexの位置にあるerのチェック
        // 許されるパターンは以下の通り
        // * rightIndex == endIndex
        // * er:direct
        // * er -> (_:direct)
        // * er == a|i|u|e|o                                          // aka、のような場合、a部分を正当とみなす
        // * er != n && er -> er == e+1                               // kka、のような場合、k部分を正当とみなす
        // * er == n && er -> (e+1:roman2kana and not a|i|u|e|o|n|y)  // (nn)*nka、のような場合、(nn)*n部分を正当とみなす
        // * er == n && er -> (e+1:roman2kana)  // (nn)*a、のような場合、nn部分を正当とみなす
        guard let lastElement = partialElements.last else {
            return nil
        }
        var part = partialElements
        checkIsEndValid: do {
            // 左端か、directなElementである場合
            guard rightIndex != originalElements.endIndex && lastElement.inputStyle == .roman2kana else {
                break checkIsEndValid
            }
            if lastElement.inputStyle != .roman2kana {
                break checkIsEndValid
            }

            // 句読点や矢印のエスケープ
            if !string.containsRomanAlphabet {
                break checkIsEndValid
            }
            if ["zl", "zk", "zj", "zh"].contains(string) {
                break checkIsEndValid
            }

            let nextFirstElement = originalElements[rightIndex]
            if nextFirstElement.inputStyle != .roman2kana || !nextFirstElement.character.isRomanLetter {
                break checkIsEndValid
            }
            if ["a", "i", "u", "e", "o"].contains(lastElement.character) {
                break checkIsEndValid
            }
            if lastElement.character != "n" && lastElement.character == nextFirstElement.character {
                // partを書き換える
                part.removeLast()
                part.append(InputElement(character: "っ", inputStyle: .direct))
                break checkIsEndValid
            }
            let n_suffix = partialElements.suffix {$0.inputStyle == .roman2kana && $0.character == "n"}
            // nnが偶数個なら許す
            if n_suffix.count > 0 && n_suffix.count % 2 == 0 {
                break checkIsEndValid
            }
            // nが最後に1つ余っていて、characterが条件を満たせば許す
            if n_suffix.count % 2 == 1 && !["a", "i", "u", "e", "o", "y", "n"].contains(nextFirstElement.character) {
                // partを書き換える
                part.removeLast()
                part.append(InputElement(character: "ん", inputStyle: .direct))
                break checkIsEndValid
            }
            return nil
        }
        // ここまで来たらvalid
        var convertTargetElements: [ConvertTargetElement] = []
        for element in part {
            updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
        }
        return convertTargetElements.reduce(into: "") {$0 += $1.string}
    }

    // inputStyleが同一であるような文字列を集積したもの
    // k, o, r, e, h, aまでをローマ字入力し、p, e, nをダイレクト入力、d, e, s, uをローマ字入力した場合、
    // originalInputに対して[ElementComposition(これは, roman2kana), ElementComposition(pen, direct), ElementComposition(です, roman2kana)]、のようになる。
    struct ConvertTargetElement {
        var string: String
        var inputStyle: InputStyle
    }

    static func updateConvertTargetElements(currentElements: inout [ConvertTargetElement], newElement: InputElement) {
        // currentElementsが空の場合、および
        // 直前のElementの入力方式が同じでない場合は、新たなConvertTargetElementを作成して追加する
        if currentElements.last?.inputStyle != newElement.inputStyle {
            currentElements.append(ConvertTargetElement(string: updateConvertTarget(current: "", inputStyle: newElement.inputStyle, newCharacter: newElement.character), inputStyle: newElement.inputStyle))
            return
        }
        // 末尾のエレメントの文字列を更新する
        updateConvertTarget(&currentElements[currentElements.endIndex - 1].string, inputStyle: newElement.inputStyle, newCharacter: newElement.character)
    }

    static func updateConvertTarget(current: String, inputStyle: InputStyle, newCharacter: Character) -> String {
        switch inputStyle {
        case .direct:
            return current + String(newCharacter)
        case .roman2kana:
            return String.roman2hiragana(currentText: current, added: String(newCharacter)).result
        }
    }

    static func updateConvertTarget(_ convertTarget: inout String, inputStyle: InputStyle, newCharacter: Character) {
        switch inputStyle {
        case .direct:
            convertTarget.append(newCharacter)
        case .roman2kana:
            convertTarget = String.roman2hiragana(currentText: convertTarget, added: String(newCharacter)).result
        }
    }

}

extension ComposingText.InputElement: Equatable {}


// MARK: 誤り訂正用のAPI
extension ComposingText {
    private func shouldBeRemovedForDicdataStore(components: [InputElement]) -> Bool {
        let input = ComposingText.getConvertTarget(for: components).toKatakana()
        if input.isEmpty {
            return false
        }
        return !String(input.first!).containsRomanAlphabet && !DicdataStore.existFile(identifier: String(input.first!))
    }

    func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)] {
        let count = right - left + 1
        let unit: PValue = 3.5
        let triple = unit*3
        // 各iから始まる候補を列挙する
        // 例えばinput = [d(あ), r(s), r(i), r(t), r(s), d(は), d(は), d(れ)]の場合
        // nodes =      [[d(あ)], [r(s)], [r(i)], [r(t), [r(t), r(a)]], [r(s)], [d(は), d(ば), d(ぱ)], [d(れ)]]
        // となる
        let nodes = (0..<count).map {(i: Int) in
            Self.lengths.flatMap {(k: Int) -> [[InputElement]] in
                let j = i + k
                if count <= j {
                    return []
                }
                return Self.getTypo(self.input[left + i ... left + j])
            }
        }

        var result: [(elements: [InputElement], penalty: PValue)] = []
        for (i, nodeArray) in nodes.enumerated() {
            let correct = [self.input[left + i]].map {InputElement(character: Character(String($0.character).toKatakana()), inputStyle: $0.inputStyle)}
            if i == .zero {
                result = nodeArray.map {($0, $0 == correct ? .zero:unit)}
                continue
            }
            result = result.flatMap {(elements: [InputElement], penalty: PValue) -> [(elements: [InputElement], penalty: PValue)] in
                if elements.count != i {
                    return [(elements, penalty)]
                }
                // 訂正数上限(3個)
                if penalty == triple {
                    return [(elements + correct, penalty)]
                }
                return nodes[i].compactMap {
                    let _elements = elements + $0
                    if shouldBeRemovedForDicdataStore(components: _elements) {
                        return nil
                    }
                    return (elements: _elements, penalty: penalty + ($0 == correct ? .zero : unit))
                }
            }
        }
        let filtered: [(string: String, penalty: PValue)] = result.compactMap {
            if let convertTarget = ComposingText.getConvertTargetForValidPart(part: $0.elements, of: self.input, from: left, to: right + 1) {
                return (convertTarget.toKatakana(), $0.penalty)
            }
            return nil
        }
        debug("getRangeWithTypos", filtered, result)
        return filtered
    }

    private static func getTypo(_ elements: some Collection<InputElement>) -> [[InputElement]] {
        let key = elements.reduce(into: "") {$0.append($1.character)}.toKatakana()

        if (elements.allSatisfy{$0.inputStyle == .direct}) {
            if key.count > 1 {
                return Self.directPossibleTypo[key, default: []].map {$0.map{InputElement(character: $0, inputStyle: .direct)}}
            } else if key.count == 1 {
                var result = Self.directPossibleTypo[key, default: []].map {$0.map{InputElement(character: $0, inputStyle: .direct)}}
                result.append(key.map{InputElement(character: $0, inputStyle: .direct)})
                return result
            }
        }
        if (elements.allSatisfy{$0.inputStyle == .roman2kana}) {
            if key.count > 1 {
                return Self.roman2KanaPossibleTypo[key, default: []].map {$0.map{InputElement(character: $0, inputStyle: .roman2kana)}}
            } else if key.count == 1 {
                var result = Self.roman2KanaPossibleTypo[key, default: []].map {$0.map{InputElement(character: $0, inputStyle: .roman2kana)}}
                result.append(key.map{InputElement(character: $0, inputStyle: .roman2kana)})
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

// MARK: 差分計算用のAPI
extension ComposingText {
    /// 2つの`ComposingText`のデータを比較し、差分を計算する。
    /// `convertTarget`との整合性をとるため、`convertTarget`に合わせた上で比較する
    func differenceSuffix(to previousData: ComposingText) -> (deleted: Int, addedCount: Int) {
        // k→か、sh→しゃ、のような場合、差分は全てx ... lastの範囲に現れるので、差分計算が問題なく動作する
        // かn → かんs、のような場合、「かんs、んs、s」のようなものは現れるが、「かん」が生成できない
        // 本質的にこれはポリシーの問題であり、「は|しゃ」の変換で「はし」が部分変換として現れないことと同根の問題である。
        // 解決のためには、inputの段階で「ん」をdirectで扱うべきである。

        // 差分を計算する
        let common = self.input.commonPrefix(with: previousData.input)
        let deleted = previousData.input.count - common.count
        let added = self.input.dropFirst(common.count).count
        return (deleted, added)
    }

    func inputHasSuffix(inputOf suffix: ComposingText) -> Bool {
        return self.input.hasSuffix(suffix.input)
    }
}


#if DEBUG
extension ComposingText.InputElement: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self.inputStyle {
        case .direct:
            return "direct(\(character))"
        case .roman2kana:
            return "roman2kana(\(character))"
        }
    }
}

extension ComposingText.ConvertTargetElement: CustomDebugStringConvertible {
    var debugDescription: String {
        return "ConvertTargetElement(string: \"\(string)\", inputStyle: \(inputStyle)"
    }
}
extension InputStyle: CustomDebugStringConvertible {
    var debugDescription: String {
        return "." + self.rawValue
    }
}
#endif
