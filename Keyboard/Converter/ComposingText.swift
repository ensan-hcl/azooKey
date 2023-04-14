//
//  ComposingText.swift
//  Keyboard
//
//  Created by ensan on 2022/09/21.
//  Copyright © 2022 ensan. All rights reserved.
//

/// ユーザ入力、変換対象文字列、ディスプレイされる文字列、の3つを同時にハンドルするための構造体
///  - `input`: `[k, y, o, u, h, a, a, m, e]`
///  - `convertTarget`: `きょうはあめ`
/// のようになる。`
/// カーソルのポジションもこのクラスが管理する。
/// 設計方針として、inputStyleに関わる実装の違いは全てアップデート方法の違いとして吸収し、`input` / `delete` / `moveCursor` / `complete`時の違いとしては露出させないようにすることを目指した。
struct ComposingText {
    /// カーソルの位置。0は左端（左から右に書く言語の場合）に対応する。
    private(set) var convertTargetCursorPosition: Int = 0
    /// ユーザの入力シーケンス。historyとは異なり、変換対象文字列に対応するものを保持する。また、deleteやmove cursor等の操作履歴は保持しない。
    private(set) var input: [InputElement] = []
    /// 変換対象文字列。
    private(set) var convertTarget: String = ""

    /// ユーザ入力の単位
    struct InputElement {
        /// 入力された文字
        var character: Character
        /// そのときの入力方式(ローマ字入力 / ダイレクト入力)
        var inputStyle: InputStyle
    }

    /// 変換対象文字列が存在するか否か
    var isEmpty: Bool {
        self.convertTarget.isEmpty
    }

    /// カーソルが右端に存在するか
    var isAtEndIndex: Bool {
        self.convertTarget.count == self.convertTargetCursorPosition
    }

    /// カーソルが左端に存在するか
    var isAtStartIndex: Bool {
        0 == self.convertTargetCursorPosition
    }

    /// カーソルより前の変換対象
    var convertTargetBeforeCursor: some StringProtocol {
        self.convertTarget.prefix(self.convertTargetCursorPosition)
    }

    /// `input`でのカーソル位置を無理やり作り出す関数
    /// `target`が左側に来るようなカーソルの位置を返す。
    /// 例えば`input`が`[k, y, o, u]`で`target`が`き|`の場合を考える。
    /// この状態では`input`に対応するカーソル位置が存在しない。
    /// この場合、`input`を`[き, ょ, u]`と置き換えた上で、`き|`と考えて、`1`を返す。
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
                self.input.insert(contentsOf: suffix.map {InputElement(character: $0, inputStyle: CharacterUtils.isRomanLetter($0) ? .roman2kana : .direct)}, at: count - replaceCount)

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

    private func diff(from oldString: some StringProtocol, to newString: String) -> (delete: Int, input: String) {
        let common = oldString.commonPrefix(with: newString)
        return (oldString.count - common.count, String(newString.dropFirst(common.count)))
    }

    /// inputの更新における特殊処理を扱う
    /// TODO: アドホックな対処なのでどうにか一般化したい。
    private mutating func updateInput(_ string: String, at inputCursorPosition: Int, inputStyle: InputStyle) {
        if inputCursorPosition == 0 {
            self.input.insert(contentsOf: string.map {InputElement(character: $0, inputStyle: inputStyle)}, at: inputCursorPosition)
            return
        }
        let prev = self.input[inputCursorPosition - 1]
        if inputStyle == .roman2kana && prev.inputStyle == inputStyle, let first = string.first, String(first).onlyRomanAlphabet {
            if prev.character == first && !["a", "i", "u", "e", "o", "n"].contains(first) {
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
    mutating func insertAtCursorPosition(_ string: String, inputStyle: InputStyle) {
        if string.isEmpty {
            return
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
    }

    /// 現在のカーソル位置から（左から右に書く言語では）右側の文字を削除する関数
    mutating func deleteForwardFromCursorPosition(count: Int) {
        let count = min(convertTarget.count - convertTargetCursorPosition, count)
        if count == 0 {
            return
        }
        self.convertTargetCursorPosition += count
        self.deleteBackwardFromCursorPosition(count: count)
    }

    /// 現在のカーソル位置から（左から右に書く言語では）左側の文字を削除する関数
    /// エッジケースとして、`sha: しゃ|`の状態で1文字消すような場合がある。この場合、`[s, h, a]`を`[し, ゃ]`に変換した上で「ゃ」を削除する。
    mutating func deleteBackwardFromCursorPosition(count: Int) {
        let count = min(convertTargetCursorPosition, count)

        if count == 0 {
            return
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
    }

    /// 現在のカーソル位置からカーソルを動かす関数
    /// - parameters:
    ///   - count: `convertTarget`において対応する文字数
    /// - returns: 実際に動かした文字数
    /// - note: 動かすことのできない文字数を指定した場合、返り値が変化する。
    mutating func moveCursorFromCursorPosition(count: Int) -> Int {
        let count = max(min(self.convertTarget.count - self.convertTargetCursorPosition, count), -self.convertTargetCursorPosition)
        self.convertTargetCursorPosition += count
        return count
    }

    /// 文頭の方を確定させる関数
    ///  - parameters:
    ///   - correspondingCount: `input`において対応する文字数
    mutating func prefixComplete(correspondingCount: Int) {
        let correspondingCount = min(correspondingCount, self.input.count)
        self.input.removeFirst(correspondingCount)
        // convetTargetを更新する
        let newConvertTarget = Self.getConvertTarget(for: self.input)
        // カーソルの位置は、消す文字数の分削除する
        let cursorDelta = self.convertTarget.count - newConvertTarget.count
        self.convertTarget = newConvertTarget
        self.convertTargetCursorPosition -= cursorDelta
        // もしも左端にカーソルが位置していたら、文頭に移動させる
        if self.convertTargetCursorPosition == 0 {
            self.convertTargetCursorPosition = self.convertTarget.count
        }
    }

    /// 現在のカーソル位置までの文字でComposingTextを作成し、返す
    func prefixToCursorPosition() -> ComposingText {
        var text = self
        let index = text.forceGetInputCursorPosition(target: text.convertTarget.prefix(text.convertTargetCursorPosition))
        text.input = Array(text.input.prefix(index))
        text.convertTarget = String(text.convertTarget.prefix(text.convertTargetCursorPosition))
        return text
    }

    mutating func stopComposition() {
        self.input = []
        self.convertTarget = ""
        self.convertTargetCursorPosition = 0
    }
}

// MARK: 部分領域の計算のためのAPI
// 例えば、「akafa」という入力があるとき、「aka」はvalidな部分領域だが、「kaf」はinvalidである。
// 難しいケースとして「itta」の「it」を「いっ」としてvalidな部分領域と見做したいというモチベーションがある。
extension ComposingText {
    static func getConvertTarget(for elements: some Sequence<InputElement>) -> String {
        var convertTargetElements: [ConvertTargetElement] = []
        for element in elements {
            updateConvertTargetElements(currentElements: &convertTargetElements, newElement: element)
        }
        return convertTargetElements.reduce(into: "") {$0 += $1.string}
    }

    static func shouldEscapeOtherValidation(convertTargetElement: [ConvertTargetElement], of originalElements: [InputElement]) -> Bool {
        let string = convertTargetElement.reduce(into: "") {$0 += $1.string}
        // 句読点や矢印のエスケープ
        if !string.containsRomanAlphabet {
            return true
        }
        if ["→", "↓", "↑", "←"].contains(string) {
            return true
        }
        return false
    }

    // MARK: 利用されていないAPI
    static func isLeftSideValid(first firstElement: InputElement, of originalElements: [InputElement], from leftIndex: Int) -> Bool {
        // leftIndexの位置にある`el`のチェック
        // 許されるパターンは以下の通り
        // * leftIndex == startIndex
        // * el:direct
        // * (_:direct) -> el
        // * (a|i|u|e|o:roman2kana) -> el                  // aka、のような場合、ka部分を正当とみなす
        // * (e-1:roman2kana and not n) && e-1 == es       // tta、のような場合、ta部分を正当とみなすが、nnaはだめ。
        // * (n:roman2kana) -> el && el not a|i|u|e|o|y|n  // nka、のような場合、ka部分を正当とみなすが、nnaはだめ。

        if leftIndex < originalElements.startIndex {
            return false
        }
        // 左端か、directなElementである場合
        guard leftIndex != originalElements.startIndex && firstElement.inputStyle == .roman2kana else {
            return true
        }

        let prevLastElement = originalElements[leftIndex - 1]
        if prevLastElement.inputStyle != .roman2kana || !CharacterUtils.isRomanLetter(prevLastElement.character) {
            return true
        }

        if ["a", "i", "u", "e", "o"].contains(prevLastElement.character) {
            return true
        }
        if prevLastElement.character != "n" && prevLastElement.character == firstElement.character {
            return true
        }
        let last_2 = originalElements[0 ..< leftIndex].suffix(2)
        if ["zl", "zk", "zj", "zh"].contains(last_2.reduce(into: "") {$0.append($1.character)}) {
            return true
        }
        let n_suffix = originalElements[0 ..< leftIndex].suffix(while: {$0.inputStyle == .roman2kana && $0.character == "n"})
        if n_suffix.count % 2 == 0 && !n_suffix.isEmpty {
            return true
        }
        if n_suffix.count % 2 == 1 && !["a", "i", "u", "e", "o", "y", "n"].contains(firstElement.character) {
            return true
        }
        return false
    }

    /// 右側がvalidか調べる
    /// - Parameters:
    ///   - lastElement: 領域の最後の要素
    ///   - convertTargetElements: 領域内まで読んで作成した`convertTarget`
    ///   - originalElements: 領域を取り出した元の`input`
    ///   - rightIndex: 領域の右隣の要素のインデックス
    /// - Returns: 正当か否か
    static func isRightSideValid(lastElement: InputElement, convertTargetElements: [ConvertTargetElement], of originalElements: [InputElement], to rightIndex: Int) -> Bool {
        // rightIndexの位置にあるerのチェック
        // 許されるパターンは以下の通り
        // * rightIndex == endIndex
        // * er:direct
        // * er -> (_:direct)
        // * er == a|i|u|e|o                                          // aka、のような場合、a部分を正当とみなす
        // * er != n && er -> er == e+1                               // kka、のような場合、k部分を正当とみなす
        // * er == n && er -> (e+1:roman2kana and not a|i|u|e|o|n|y)  // (nn)*nka、のような場合、(nn)*n部分を正当とみなす
        // * er == n && er -> (e+1:roman2kana)  // (nn)*a、のような場合、nn部分を正当とみなす
        // 左端か、directなElementである場合
        guard rightIndex != originalElements.endIndex && lastElement.inputStyle == .roman2kana else {
            return true
        }
        if lastElement.inputStyle != .roman2kana {
            return true
        }
        let nextFirstElement = originalElements[rightIndex]
        if nextFirstElement.inputStyle != .roman2kana || !CharacterUtils.isRomanLetter(nextFirstElement.character) {
            return true
        }
        if ["a", "i", "u", "e", "o"].contains(lastElement.character) {
            return true
        }
        if lastElement.character != "n" && lastElement.character == nextFirstElement.character {
            return true
        }
        guard let lastConvertTargetElements = convertTargetElements.last else {
            return false
        }
        // nnが偶数個なら許す
        if lastElement.character == "n" && lastConvertTargetElements.string.last != "n" {
            return true
        }
        // nが最後に1つ余っていて、characterが条件を満たせば許す
        if lastElement.character == "n" && lastConvertTargetElements.inputStyle == .roman2kana && lastConvertTargetElements.string.last == "n"  && !["a", "i", "u", "e", "o", "y", "n"].contains(nextFirstElement.character) {
            return true
        }
        return false
    }

    /// 「正当な」部分領域を返す関数
    /// - Parameters:
    ///   - lastElement: 領域の最後の要素
    ///   - originalElements: 領域を取り出した元の`input`
    ///   - rightIndex: 領域の右隣の要素のインデックス
    ///   - convertTargetElements: 領域内まで読んで作成した`convertTarget`
    /// - Returns: 領域がvalidであれば`convertTarget`を返し、invalidなら`nil`を返す。
    /// - Note: `elements = [r(k, a, n, s, h, a)]`のとき、`k,a,n,s,h,a`や`k, a`は正当だが`a, n`や`s, h`は正当ではない。`k, a, n`は特に正当であるとみなす。
    static func getConvertTargetIfRightSideIsValid(lastElement: InputElement, of originalElements: [InputElement], to rightIndex: Int, convertTargetElements: [ConvertTargetElement]) -> String? {
        debug("getConvertTargetIfRightSideIsValid", lastElement, rightIndex)
        if originalElements.endIndex < rightIndex {
            return nil
        }
        // 正当性のチェックを行う
        // 基本的に、convertTargetと正しく対応する部分のみを取り出したい。
        let shouldEscapeValidation = Self.shouldEscapeOtherValidation(convertTargetElement: convertTargetElements, of: originalElements)
        if !shouldEscapeValidation && !Self.isRightSideValid(lastElement: lastElement, convertTargetElements: convertTargetElements, of: originalElements, to: rightIndex) {
            return nil
        }
        // ここまで来たらvalid
        var convertTargetElements = convertTargetElements
        if let lastElement = convertTargetElements.last, lastElement.inputStyle == .roman2kana, rightIndex < originalElements.endIndex {
            let nextFirstElement = originalElements[rightIndex]

            if !lastElement.string.hasSuffix("n") && lastElement.string.last == nextFirstElement.character {
                // 書き換える
                convertTargetElements[convertTargetElements.endIndex - 1].string.removeLast()
                convertTargetElements.append(ConvertTargetElement(string: "っ", inputStyle: .direct))
            }

            if lastElement.string.hasSuffix("n") && !["a", "i", "u", "e", "o", "y", "n"].contains(nextFirstElement.character) {
                // 書き換える
                convertTargetElements[convertTargetElements.endIndex - 1].string.removeLast()
                convertTargetElements.append(ConvertTargetElement(string: "ん", inputStyle: .direct))
            }
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
            return Roman2Kana.toHiragana(currentText: current, added: String(newCharacter)).result
        }
    }

    static func updateConvertTarget(_ convertTarget: inout String, inputStyle: InputStyle, newCharacter: Character) {
        switch inputStyle {
        case .direct:
            convertTarget.append(newCharacter)
        case .roman2kana:
            convertTarget = Roman2Kana.toHiragana(currentText: convertTarget, added: String(newCharacter)).result
        }
    }

}

// Equatableにしておく
extension ComposingText: Equatable {}
extension ComposingText.InputElement: Equatable {}
extension ComposingText.ConvertTargetElement: Equatable {}

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
        self.input.hasSuffix(suffix.input)
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
        "ConvertTargetElement(string: \"\(string)\", inputStyle: \(inputStyle)"
    }
}
extension InputStyle: CustomDebugStringConvertible {
    var debugDescription: String {
        "." + self.rawValue
    }
}
#endif
