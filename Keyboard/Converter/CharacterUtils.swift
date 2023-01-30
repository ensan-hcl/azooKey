//
//  extension Character.swift
//  Keyboard
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum CharacterUtils {
    /// 小書きのかなカナ集合
    private static let kogakiKana: Set<Character> = [
        "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゕ", "ゖ", "っ", "ゃ", "ゅ", "ょ", "ゎ",
        "ァ", "ィ", "ゥ", "ェ", "ォ", "ヵ", "ヶ", "ッ", "ャ", "ュ", "ョ", "ヮ"
    ]
    /// 濁点付きのかなカナ集合
    private static let dakutenKana: Set<Character> = [
        "ゔ", "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ",
        "ヴ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ", "ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ"
    ]

    /// 小書きかなか否か
    static func isKogana(_ character: Character) -> Bool {
        kogakiKana.contains(character)
    }

    /// ローマ字(a-z, A-Zか否か)
    static func isRomanLetter(_ character: Character) -> Bool {
        character.isASCII && character.isCased
    }

    /// 自分が小書きであれば該当する文字を返す。
    static func kogaki(_ character: Character) -> Character {
        switch character {
        case "あ":return "ぁ"
        case "い":return "ぃ"
        case "う":return "ぅ"
        case "え":return "ぇ"
        case "お":return "ぉ"
        case "か":return "ゕ"
        case "け":return "ゖ"
        case "つ":return "っ"
        case "や":return "ゃ"
        case "ゆ":return "ゅ"
        case "よ":return "ょ"
        case "わ":return "ゎ"
        case "ア":return "ァ"
        case "イ":return "ィ"
        case "ウ":return "ゥ"
        case "エ":return "ェ"
        case "オ":return "ォ"
        case "カ":return "ヵ"
        case "ケ":return "ヶ"
        case "ツ":return "ッ"
        case "ヤ":return "ャ"
        case "ユ":return "ュ"
        case "ヨ":return "ョ"
        case "ワ":return "ヮ"
        default: return character
        }
    }

    /// 小書きから大書きを返す
    static func ogaki(_ character: Character) -> Character {
        switch character {
        case "ぁ":return "あ"
        case "ぃ":return "い"
        case "ぅ":return "う"
        case "ぇ":return "え"
        case "ぉ":return "お"
        case "ゕ":return "か"
        case "ゖ":return "け"
        case "っ":return "つ"
        case "ゃ":return "や"
        case "ゅ":return "ゆ"
        case "ょ":return "よ"
        case "ゎ":return "わ"
        case "ァ":return "ア"
        case "ィ":return "イ"
        case "ゥ":return "ウ"
        case "ェ":return "エ"
        case "ォ":return "オ"
        case "ヵ":return "カ"
        case "ヶ":return "ケ"
        case "ッ":return "ツ"
        case "ャ":return "ヤ"
        case "ュ":return "ユ"
        case "ョ":return "ヨ"
        case "ヮ":return "ワ"
        default: return character
        }
    }

    /// 濁点付きか否か
    static func isDakuten(_ character: Character) -> Bool {
        dakutenKana.contains(character)
    }
    /// 濁点をつけて返す
    static func dakuten(_ character: Character) -> Character {
        switch character {
        case"う":return "ゔ"
        case"か":return "が"
        case"き":return "ぎ"
        case"く":return "ぐ"
        case"け":return "げ"
        case"こ":return "ご"
        case"さ":return "ざ"
        case"し":return "じ"
        case"す":return "ず"
        case"せ":return "ぜ"
        case"そ":return "ぞ"
        case"た":return "だ"
        case"ち":return "ぢ"
        case"つ":return "づ"
        case"て":return "で"
        case"と":return "ど"
        case"は":return "ば"
        case"ひ":return "び"
        case"ふ":return "ぶ"
        case"へ":return "べ"
        case"ほ":return "ぼ"
        case"ウ":return "ヴ"
        case"カ":return "ガ"
        case"キ":return "ギ"
        case"ク":return "グ"
        case"ケ":return "ゲ"
        case"コ":return "ゴ"
        case"サ":return "ザ"
        case"シ":return "ジ"
        case"ス":return "ズ"
        case"セ":return "ゼ"
        case"ソ":return "ゾ"
        case"タ":return "ダ"
        case"チ":return "ヂ"
        case"ツ":return "ヅ"
        case"テ":return "デ"
        case"ト":return "ド"
        case"ハ":return "バ"
        case"ヒ":return "ビ"
        case"フ":return "ブ"
        case"ヘ":return "ベ"
        case"ホ":return "ボ"
        default: return character
        }
    }
    /// 濁点を外して返す
    static func mudakuten(_ character: Character) -> Character {
        switch character {
        case"ゔ":return "う"
        case"が":return "か"
        case"ぎ":return "き"
        case"ぐ":return "く"
        case"げ":return "け"
        case"ご":return "こ"
        case"ざ":return "さ"
        case"じ":return "し"
        case"ず":return "す"
        case"ぜ":return "せ"
        case"ぞ":return "そ"
        case"だ":return "た"
        case"ぢ":return "ち"
        case"づ":return "つ"
        case"で":return "て"
        case"ど":return "と"
        case"ば":return "は"
        case"び":return "ひ"
        case"ぶ":return "ふ"
        case"べ":return "へ"
        case"ぼ":return "ほ"
        case"ヴ":return "ウ"
        case"ガ":return "カ"
        case"ギ":return "キ"
        case"グ":return "ク"
        case"ゲ":return "ケ"
        case"ゴ":return "コ"
        case"ザ":return "サ"
        case"ジ":return "シ"
        case"ズ":return "ス"
        case"ゼ":return "セ"
        case"ゾ":return "ソ"
        case"ダ":return "タ"
        case"ヂ":return "チ"
        case"ヅ":return "ツ"
        case"デ":return "テ"
        case"ド":return "ト"
        case"バ":return "ハ"
        case"ビ":return "ヒ"
        case"ブ":return "フ"
        case"ベ":return "ヘ"
        case"ボ":return "ホ"
        default: return character
        }
    }
    /// 半濁点かどうか
    static func isHandakuten(_ character: Character) -> Bool {
        [
            "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
            "パ", "ピ", "プ", "ペ", "ポ"
        ].contains(character)
    }
    /// 半濁点をつけて返す
    static func handakuten(_ character: Character) -> Character {
        switch character {
        case"は":return "ぱ"
        case"ひ":return "ぴ"
        case"ふ":return "ぷ"
        case"へ":return "ぺ"
        case"ほ":return "ぽ"
        case"ハ":return "パ"
        case"ヒ":return "ピ"
        case"フ":return "プ"
        case"ヘ":return "ペ"
        case"ホ":return "ポ"
        default: return character
        }
    }
    /// 半濁点を外して返す
    static func muhandakuten(_ character: Character) -> Character {
        switch character {
        case"ぱ":return "は"
        case"ぴ":return "ひ"
        case"ぷ":return "ふ"
        case"ぺ":return "へ"
        case"ぽ":return "ほ"
        case"パ":return "ハ"
        case"ピ":return "ヒ"
        case"プ":return "フ"
        case"ペ":return "ヘ"
        case"ポ":return "ホ"
        default: return character
        }
    }

    /// 濁点、小書き、半濁点などを相互に変換する関数。
    static func requestChange(_ character: Character) -> String {
        if character.isLowercase {
            return character.uppercased()
        }
        if character.isUppercase {
            return character.lowercased()
        }

        if Set(["あ", "い", "え", "お", "や", "ゆ", "よ", "わ"]).contains(character) {
            return String(kogaki(character))
        }

        if Set(["ぁ", "ぃ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "ゎ"]).contains(character) {
            return String(ogaki(character))
        }

        if Set(["か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "て", "と"]).contains(character) {
            return String(dakuten(character))
        }

        if Set(["が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ", "だ", "ぢ", "で", "ど"]).contains(character) {
            return String(mudakuten(character))
        }

        if Set(["つ", "う"]).contains(character) {
            return String(kogaki(character))
        }

        if Set(["っ", "ぅ"]).contains(character) {
            return String(dakuten(ogaki(character)))
        }

        if Set(["づ", "ゔ"]).contains(character) {
            return String(mudakuten(character))
        }

        if Set(["は", "ひ", "ふ", "へ", "ほ"]).contains(character) {
            return String(dakuten(character))
        }

        if Set(["ば", "び", "ぶ", "べ", "ぼ"]).contains(character) {
            return String(handakuten(mudakuten(character)))
        }

        if Set(["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"]).contains(character) {
            return String(muhandakuten(character))
        }

        return String(character)
    }
}

extension Character {
    /// Returns the Katakanized version of the character.
    @inlinable func toKatakana() -> Character {
        if self.unicodeScalars.count != 1 {
            return self
        }
        let scalar = self.unicodeScalars.first!
        if 0x3041 <= scalar.value && scalar.value <= 0x3096 {
            return Character(UnicodeScalar(scalar.value + 96)!)
        } else {
            return self
        }
    }

    /// Returns the Hiraganized version of the character.
    @inlinable func toHiragana() -> Character {
        if self.unicodeScalars.count != 1 {
            return self
        }
        let scalar = self.unicodeScalars.first!
        if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 {
            return Character(UnicodeScalar(scalar.value - 96)!)
        } else {
            return self
        }
    }
}
