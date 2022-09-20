//
//  ComposingText.swift
//  Keyboard
//
//  Created by β α on 2022/09/21.
//  Copyright © 2022 DevEn3. All rights reserved.
//

/// ユーザ入力、変換対象文字列、ディスプレイされる文字列、の3つを同時にハンドルするための構造体
/// ローマ字入力でライブ変換を使う場合を考える。`kyouhaame`との入力は
///  - `input`: `[k, y, o, u, h, a, a, m, e]`
///  - `convertTarget`: `きょうはあめ`
///  - `displayText`:`今日は雨
/// のようになる。`
/// カーソルのポジションもこのクラスが管理する。
struct ComposingText {
    private(set) var inputStyle: InputStyle = .direct
    var liveConversionEnabled: Bool = false

    var convertTargetCursorPosition: Int = 0
    private(set) var input: [Character] = []
    private(set) var convertTarget: String = ""
    private(set) var displayText: String = ""

    /// ライブ変換が有効化されている場合、カーソル移動を許さない
    var allowCursorMove: Bool {
        return !liveConversionEnabled
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
        debug("ComposingText forceGetInputCursorPosition", target, input, convertTarget)
        if target.isEmpty {
            return 0
        }
        // inputを変換するメソッド
        switch inputStyle {
        case .direct:
            // 直接入力の場合、厳密に一致する
            return target.count
        case .roman2kana:
            // 動作例1
            // input: `k, a, n, s, h, a`
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
            // input: `k, a, n, s, h, a`
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
            // input: `i, t, t, a`
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

            var roman2kana = ""
            var count = 0
            var lastPrefixIndex = 0
            var lastPrefix = ""
            for character in input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(character))
                count += 1

                // 一致していたらその時点のカウントを返す
                if roman2kana == target {
                    return count
                }
                // 一致ではないのにhasPrefixが成立する場合、変換しすぎている
                // この場合、inputの変換が必要になる。
                // 例えばcovnertTargetが「あき|ょ」で、`[a, k, y, o]`まで見て「あきょ」になってしまった場合、「あき」がprefixとなる。
                // この場合、lastPrefix=1なので、1番目から現在までの入力をひらがなで置き換える
                else if roman2kana.hasPrefix(target) {
                    let replaceCount = count - lastPrefixIndex
                    let suffix = roman2kana.suffix(roman2kana.count - lastPrefix.count)
                    self.input = self.input.prefix(count - replaceCount) + suffix + self.input.suffix(self.input.count - count)

                    count -= replaceCount
                    count += suffix.count
                    while roman2kana != target {
                        _ = roman2kana.popLast()
                        count -= 1
                    }
                    break
                }
                // prefixになっている場合は更新する
                else if target.hasPrefix(roman2kana) {
                    lastPrefixIndex = count
                    lastPrefix = roman2kana
                }

            }
            return count
        }
    }

    struct ViewOperation {
        var delete: Int
        var input: String
        var moveCursor: Int
    }

    /// 現在のカーソル位置に文字を追加する関数
    mutating func insertAtCursorPosition(_ string: String) -> ViewOperation {
        let inputCursorPosition = self.forceGetInputCursorPosition(target: self.convertTarget.prefix(convertTargetCursorPosition))

        // input, convertTarget, convertTargetCursorPositionの3つを更新する

        switch inputStyle {
        case .direct:
            // inputを更新
            self.input.insert(contentsOf: Array(string), at: inputCursorPosition)
            self.convertTarget = String(self.input)
            // カーソルを1つ進める
            self.convertTargetCursorPosition += string.count

            return ViewOperation(delete: 0, input: string, moveCursor: 0)
        case .roman2kana:
            // inputを更新
            self.input.insert(contentsOf: Array(string), at: inputCursorPosition)
            var roman2kana = ""
            for c in self.input.prefix(inputCursorPosition) {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            let (newConvertTargetPrefix, deleteCount, input) = String.roman2hiragana(currentText: roman2kana, added: string)
            // convertTargetの更新
            self.convertTarget.removeFirst(convertTargetCursorPosition)
            self.convertTarget.insert(contentsOf: newConvertTargetPrefix, at: convertTarget.startIndex)
            // カーソルを更新する
            self.convertTargetCursorPosition = newConvertTargetPrefix.count

            return ViewOperation(delete: deleteCount, input: input, moveCursor: 0)
        }
    }

    /// 現在のカーソル位置から文字を削除する関数
    /// エッジケースとして、`sha: しゃ|`の状態で1文字消すような場合がある。
    mutating func backspaceFromCursorPosition(count: Int) {
        if self.convertTargetCursorPosition == 0 {
            return
        }
        let count = min(convertTargetCursorPosition, count)

        // input, convertTarget, convertTargetCursorPositionの3つを更新する
        switch inputStyle {
        case .direct:
            self.input = self.input.prefix(convertTargetCursorPosition - count) + self.input.suffix(self.convertTarget.count - self.convertTargetCursorPosition)
            self.convertTargetCursorPosition -= count
            self.convertTarget = String(self.input)
        case .roman2kana:
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
            let currentPrefix = self.convertTarget.prefix(convertTargetCursorPosition)

            // この2つの値はこの順で計算する。
            // これから行く位置
            let targetCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix.dropLast(count))
            // 現在の位置
            let inputCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix)

            // inputを更新する
            self.input = self.input.prefix(targetCursorPosition) + self.input.suffix(self.input.count - inputCursorPosition)
            // カーソルを更新する
            self.convertTargetCursorPosition -= count

            // convetTargetを更新する
            var roman2kana = ""
            for c in self.input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            self.convertTarget = roman2kana
        }
    }

    /// 現在のカーソル位置からカーソルを動かす関数
    mutating func moveCursorFromCursorPosition(count: Int) {
        self.convertTargetCursorPosition += count
        self.convertTargetCursorPosition = max(0, self.convertTargetCursorPosition)
        self.convertTargetCursorPosition = min(self.convertTargetCursorPosition, self.convertTarget.count)
    }

    /// 文頭の方を確定させる関数
    ///  - parameters:
    ///   - correspondingCount: `converTarget`において対応する文字数
    mutating func complete(correspondingCount: Int) {
        let correspondingCount = min(correspondingCount, self.input.count)
        self.input.removeFirst(correspondingCount)

        // convetTargetを更新する
        switch inputStyle {
        case .direct:
            // カーソルの位置は、消す文字数の分削除する
            let cursorDelta = self.convertTarget.count - self.input.count
            self.convertTarget = String(self.input)
            self.convertTargetCursorPosition -= cursorDelta
        case .roman2kana:
            var roman2kana = ""
            for c in self.input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            // カーソルの位置は、消す文字数の分削除する
            let cursorDelta = self.convertTarget.count - roman2kana.count

            self.convertTarget = roman2kana
            self.convertTargetCursorPosition -= cursorDelta
        }
    }

    mutating func setInputStyle(_ newStyle: InputStyle) {
        if newStyle == inputStyle {
            return
        }
        self.input = Array(self.convertTarget)
        self.inputStyle = newStyle
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
