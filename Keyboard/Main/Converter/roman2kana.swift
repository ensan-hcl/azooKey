//
//  extension String.swift
//  Keyboard
//
//  Created by β α on 2020/09/24.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension String{
    private static let katakanaChanges: [String: String] = [
        "a":"ア",
        "xa":"ァ",
        "la":"ァ",
        "i":"イ",
        "xi":"ィ",
        "li":"ィ",
        "u":"ウ",
        "wu":"ウ",
        "vu":"ヴ",
        "xu":"ゥ",
        "lu":"ゥ",
        "e":"エ",
        "xe":"ェ",
        "le":"ェ",
        "o":"オ",
        "xo":"ォ",
        "lo":"ォ",
        "ka":"カ",
        "ga":"ガ",
        "xka":"ヵ",
        "lka":"ヵ",
        "ki":"キ",
        "gi":"ギ",
        "ku":"ク",
        "gu":"グ",
        "ke":"ケ",
        "ge":"ゲ",
        "xke":"ヶ",
        "lke":"ヶ",
        "ko":"コ",
        "go":"ゴ",
        "sa":"サ",
        "za":"ザ",
        "si":"シ",
        "shi":"シ",
        "zi":"ジ",
        "ji":"ジ",
        "su":"ス",
        "zu":"ズ",
        "se":"セ",
        "ze":"ゼ",
        "so":"ソ",
        "zo":"ゾ",
        "ta":"タ",
        "da":"ダ",
        "ti":"チ",
        "chi":"チ",
        "di":"ヂ",
        "tu":"ツ",
        "tsu":"ツ",
        "xtu":"ッ",
        "ltu":"ッ",
        "xtsu":"ッ",
        "ltsu":"ッ",
        "du":"ヅ",
        "te":"テ",
        "de":"デ",
        "to":"ト",
        "do":"ド",
        "na":"ナ",
        "ni":"ニ",
        "nu":"ヌ",
        "ne":"ネ",
        "no":"ノ",
        "ha":"ハ",
        "ba":"バ",
        "pa":"パ",
        "hi":"ヒ",
        "bi":"ビ",
        "pi":"ピ",
        "hu":"フ",
        "fu":"フ",
        "bu":"ブ",
        "pu":"プ",
        "he":"ヘ",
        "be":"ベ",
        "pe":"ペ",
        "ho":"ホ",
        "bo":"ボ",
        "po":"ポ",
        "ma":"マ",
        "mi":"ミ",
        "mu":"ム",
        "me":"メ",
        "mo":"モ",
        "ya":"ヤ",
        "xya":"ャ",
        "lya":"ャ",
        "yu":"ユ",
        "xyu":"ュ",
        "lyu":"ュ",
        "yo":"ヨ",
        "xyo":"ョ",
        "lyo":"ョ",
        "ra":"ラ",
        "ri":"リ",
        "ru":"ル",
        "re":"レ",
        "ro":"ロ",
        "wa":"ワ",
        "xwa":"ヮ",
        "lwa":"ヮ",
        "wyi":"ヰ",
        "wye":"ヱ",
        "wo":"ヲ",
        "nn":"ン",
        "ye":"イェ",
        "va":"ヴァ",
        "vi":"ヴィ",
        "ve":"ヴェ",
        "vo":"ヴォ",
        "kya":"キャ",
        "kyu":"キュ",
        "kye":"キェ",
        "kyo":"キョ",
        "gya":"ギャ",
        "gyu":"ギュ",
        "gye":"ギェ",
        "gyo":"ギョ",
        "qa":"クァ",
        "kwa":"クァ",
        "qwa":"クァ",
        "qi":"クィ",
        "kwi":"クィ",
        "qwi":"クィ",
        "qu":"クゥ",
        "kwu":"クゥ",
        "qwu":"クゥ",
        "qe":"クェ",
        "kwe":"クェ",
        "qwe":"クェ",
        "qo":"クォ",
        "kwo":"クォ",
        "qwo":"クォ",
        "gwa":"グァ",
        "gwi":"グィ",
        "gwu":"グゥ",
        "gwe":"グェ",
        "gwo":"グォ",
        "sha":"シャ",
        "sya":"シャ",
        "shu":"シュ",
        "syu":"シュ",
        "she":"シェ",
        "sye":"シェ",
        "sho":"ショ",
        "syo":"ショ",
        "ja":"ジャ",
        "zya":"ジャ",
        "jya":"ジャ",
        "jyi":"ジィ",
        "ju":"ジュ",
        "zyu":"ジュ",
        "jyu":"ジュ",
        "je":"ジェ",
        "zye":"ジェ",
        "jye":"ジェ",
        "jo":"ジョ",
        "zyo":"ジョ",
        "jyo":"ジョ",
        "swa":"スァ",
        "swi":"スィ",
        "swu":"スゥ",
        "swe":"スェ",
        "swo":"スォ",
        "cha":"チャ",
        "cya":"チャ",
        "tya":"チャ",
        "tyi":"チィ",
        "cyi":"チィ",
        "chu":"チュ",
        "cyu":"チュ",
        "tyu":"チュ",
        "che":"チェ",
        "cye":"チェ",
        "tye":"チェ",
        "cho":"チョ",
        "cyo":"チョ",
        "tyo":"チョ",
        "tsa":"ツァ",
        "tsi":"ツィ",
        "tse":"ツェ",
        "tso":"ツォ",
        "tha":"テャ",
        "thi":"ティ",
        "thu":"テュ",
        "the":"テェ",
        "tho":"テョ",
        "twa":"トァ",
        "twi":"トィ",
        "twu":"トゥ",
        "twe":"トェ",
        "two":"トォ",
        "dya":"ヂャ",
        "dyi":"ヂィ",
        "dyu":"ヂュ",
        "dye":"ヂェ",
        "dyo":"ヂョ",
        "dha":"デャ",
        "dhi":"ディ",
        "dhu":"デュ",
        "dhe":"デェ",
        "dho":"デョ",
        "dwa":"ドァ",
        "dwi":"ドィ",
        "dwu":"ドゥ",
        "dwe":"ドェ",
        "dwo":"ドォ",
        "nya":"ニャ",
        "nyi":"ニィ",
        "nyu":"ニュ",
        "nye":"ニェ",
        "nyo":"ニョ",
        "hya":"ヒャ",
        "hyi":"ヒィ",
        "hyu":"ヒュ",
        "hye":"ヒェ",
        "hyo":"ヒョ",
        "bya":"ビャ",
        "byi":"ビィ",
        "byu":"ビュ",
        "bye":"ビェ",
        "byo":"ビョ",
        "pya":"ピャ",
        "pyi":"ピィ",
        "pyu":"ピュ",
        "pye":"ピェ",
        "pyo":"ピョ",
        "fa":"ファ",
        "hwa":"ファ",
        "fwa":"ファ",
        "fi":"ファ",
        "hwi":"フィ",
        "fwi":"フィ",
        "fwu":"フゥ",
        "fe":"フェ",
        "hwe":"フェ",
        "fwe":"フェ",
        "fo":"フォ",
        "hwo":"フォ",
        "fwo":"フォ",
        "mya":"ミャ",
        "myi":"ミィ",
        "myu":"ミュ",
        "mye":"ミェ",
        "myo":"ミョ",
        "rya":"リャ",
        "ryi":"リィ",
        "ryu":"リュ",
        "rye":"リェ",
        "ryo":"リョ",
        "wi":"ウィ",
        "we":"ウェ",
        "zh":"←",
        "zj":"↓",
        "zk":"↑",
        "zl":"→",
    ]
    private static let hiraganaChanges: [String: String] = [
        "a":"あ",
        "xa":"ぁ",
        "la":"ぁ",
        "i":"い",
        "xi":"ぃ",
        "li":"ぃ",
        "u":"う",
        "wu":"う",
        "vu":"ゔ",
        "xu":"ぅ",
        "lu":"ぅ",
        "e":"え",
        "xe":"ぇ",
        "le":"ぇ",
        "o":"お",
        "xo":"ぉ",
        "lo":"ぉ",
        "ka":"か",
        "ga":"が",
        "xka":"ゕ",
        "lka":"ゕ",
        "ki":"き",
        "gi":"ぎ",
        "ku":"く",
        "gu":"ぐ",
        "ke":"け",
        "ge":"げ",
        "xke":"ゖ",
        "lke":"ゖ",
        "ko":"こ",
        "go":"ご",
        "sa":"さ",
        "za":"ざ",
        "si":"し",
        "shi":"し",
        "zi":"じ",
        "ji":"じ",
        "su":"す",
        "zu":"ず",
        "se":"せ",
        "ze":"ぜ",
        "so":"そ",
        "zo":"ぞ",
        "ta":"た",
        "da":"だ",
        "ti":"ち",
        "chi":"ち",
        "di":"ぢ",
        "tu":"つ",
        "tsu":"つ",
        "xtu":"っ",
        "ltu":"っ",
        "xtsu":"っ",
        "ltsu":"っ",
        "du":"づ",
        "te":"て",
        "de":"で",
        "to":"と",
        "do":"ど",
        "na":"な",
        "ni":"に",
        "nu":"ぬ",
        "ne":"ね",
        "no":"の",
        "ha":"は",
        "ba":"ば",
        "pa":"ぱ",
        "hi":"ひ",
        "bi":"び",
        "pi":"ぴ",
        "hu":"ふ",
        "fu":"ふ",
        "bu":"ぶ",
        "pu":"ぷ",
        "he":"へ",
        "be":"べ",
        "pe":"ぺ",
        "ho":"ほ",
        "bo":"ぼ",
        "po":"ぽ",
        "ma":"ま",
        "mi":"み",
        "mu":"む",
        "me":"め",
        "mo":"も",
        "ya":"や",
        "xya":"ゃ",
        "lya":"ゃ",
        "yu":"ゆ",
        "xyu":"ゅ",
        "lyu":"ゅ",
        "yo":"よ",
        "xyo":"ょ",
        "lyo":"ょ",
        "ra":"ら",
        "ri":"り",
        "ru":"る",
        "re":"れ",
        "ro":"ろ",
        "wa":"わ",
        "xwa":"ゎ",
        "lwa":"ゎ",
        "wyi":"ゐ",
        "wye":"ゑ",
        "wo":"を",
        "nn":"ん",
        "ye":"いぇ",
        "va":"ゔぁ",
        "vi":"ゔぃ",
        "ve":"ゔぇ",
        "vo":"ゔぉ",
        "kya":"きゃ",
        "kyu":"きゅ",
        "kye":"きぇ",
        "kyo":"きょ",
        "gya":"ぎゃ",
        "gyu":"ぎゅ",
        "gye":"ぎぇ",
        "gyo":"ぎょ",
        "qa":"くぁ",
        "kwa":"くぁ",
        "qwa":"くぁ",
        "qi":"くぃ",
        "kwi":"くぃ",
        "qwi":"くぃ",
        "qu":"くぅ",
        "kwu":"くぅ",
        "qwu":"くぅ",
        "qe":"くぇ",
        "kwe":"くぇ",
        "qwe":"くぇ",
        "qo":"くぉ",
        "kwo":"くぉ",
        "qwo":"くぉ",
        "gwa":"ぐぁ",
        "gwi":"ぐぃ",
        "gwu":"ぐぅ",
        "gwe":"ぐぇ",
        "gwo":"ぐぉ",
        "sha":"しゃ",
        "sya":"しゃ",
        "shu":"しゅ",
        "syu":"しゅ",
        "she":"しぇ",
        "sye":"しぇ",
        "sho":"しょ",
        "syo":"しょ",
        "ja":"じゃ",
        "zya":"じゃ",
        "jya":"じゃ",
        "jyi":"じぃ",
        "ju":"じゅ",
        "zyu":"じゅ",
        "jyu":"じゅ",
        "je":"じぇ",
        "zye":"じぇ",
        "jye":"じぇ",
        "jo":"じょ",
        "zyo":"じょ",
        "jyo":"じょ",
        "swa":"すぁ",
        "swi":"すぃ",
        "swu":"すぅ",
        "swe":"すぇ",
        "swo":"すぉ",
        "cha":"ちゃ",
        "cya":"ちゃ",
        "tya":"ちゃ",
        "tyi":"ちぃ",
        "cyi":"ちぃ",
        "chu":"ちゅ",
        "cyu":"ちゅ",
        "tyu":"ちゅ",
        "che":"ちぇ",
        "cye":"ちぇ",
        "tye":"ちぇ",
        "cho":"ちょ",
        "cyo":"ちょ",
        "tyo":"ちょ",
        "tsa":"つぁ",
        "tsi":"つぃ",
        "tse":"つぇ",
        "tso":"つぉ",
        "tha":"てゃ",
        "thi":"てぃ",
        "thu":"てゅ",
        "the":"てぇ",
        "tho":"てょ",
        "twa":"とぁ",
        "twi":"とぃ",
        "twu":"とぅ",
        "twe":"とぇ",
        "two":"とぉ",
        "dya":"ぢゃ",
        "dyi":"ぢぃ",
        "dyu":"ぢゅ",
        "dye":"ぢぇ",
        "dyo":"ぢょ",
        "dha":"でゃ",
        "dhi":"でぃ",
        "dhu":"でゅ",
        "dhe":"でぇ",
        "dho":"でょ",
        "dwa":"どぁ",
        "dwi":"どぃ",
        "dwu":"どぅ",
        "dwe":"どぇ",
        "dwo":"どぉ",
        "nya":"にゃ",
        "nyi":"にぃ",
        "nyu":"にゅ",
        "nye":"にぇ",
        "nyo":"にょ",
        "hya":"ひゃ",
        "hyi":"ひぃ",
        "hyu":"ひゅ",
        "hye":"ひぇ",
        "hyo":"ひょ",
        "bya":"びゃ",
        "byi":"びぃ",
        "byu":"びゅ",
        "bye":"びぇ",
        "byo":"びょ",
        "pya":"ぴゃ",
        "pyi":"ぴぃ",
        "pyu":"ぴゅ",
        "pye":"ぴぇ",
        "pyo":"ぴょ",
        "fa":"ふぁ",
        "hwa":"ふぁ",
        "fwa":"ふぁ",
        "fi":"ふぃ",
        "hwi":"ふぃ",
        "fwi":"ふぃ",
        "fwu":"ふぅ",
        "fe":"ふぇ",
        "hwe":"ふぇ",
        "fwe":"ふぇ",
        "fo":"ふぉ",
        "hwo":"ふぉ",
        "fwo":"ふぉ",
        "mya":"みゃ",
        "myi":"みぃ",
        "myu":"みゅ",
        "mye":"みぇ",
        "myo":"みょ",
        "rya":"りゃ",
        "ryi":"りぃ",
        "ryu":"りゅ",
        "rye":"りぇ",
        "ryo":"りょ",
        "wi":"うぃ",
        "we":"うぇ",
        "zh":"←",
        "zj":"↓",
        "zk":"↑",
        "zl":"→",
    ]

    static func roman2katakana<S: StringProtocol>(currentText: S, added: String) -> (result: String, delete: Int, input: String){
        let last_3 = currentText.suffix(3)
        if let kana = String.katakanaChanges[last_3 + added]{
            return (result: currentText.prefix(currentText.count-last_3.count) + kana, delete: last_3.count, input: kana)
        }
        let last_2 = currentText.suffix(2)
        if let kana = String.katakanaChanges[last_2 + added]{
            return (result: currentText.prefix(currentText.count-last_2.count) + kana, delete: last_2.count, input: kana)
        }
        let last_1 = currentText.suffix(1)
        if let kana = String.katakanaChanges[last_1 + added]{
            return (result: currentText.prefix(currentText.count-last_1.count) + kana, delete: last_1.count, input: kana)
        }
        if last_1 == added && added.onlyRomanAlphabet{
            return (result: currentText.prefix(currentText.count-last_1.count) + "ッ" + added, delete: 1, input: "ッ" + added)
        }
        if last_1 == "n" && added != "y"{
            return (result: currentText.prefix(currentText.count-last_1.count) + "ン" + added, delete: 1, input: "ン" + added)
        }

        if let kana = String.katakanaChanges[added]{
            return (result: currentText + kana, delete: .zero, input: kana)
        }
        return (result: currentText + added, delete: .zero, input: added)
    }


    static func roman2hiragana<S: StringProtocol>(currentText: S, added: String) -> (result: String, delete: Int, input: String) {
        let last_3 = currentText.suffix(3)
        if let kana = String.hiraganaChanges[last_3 + added]{
            return (result: currentText.prefix(currentText.count-last_3.count) + kana, delete: last_3.count, input: kana)
        }
        let last_2 = currentText.suffix(2)
        if let kana = String.hiraganaChanges[last_2 + added]{
            return (result: currentText.prefix(currentText.count-last_2.count) + kana, delete: last_2.count, input: kana)
        }
        let last_1 = currentText.suffix(1)
        if let kana = String.hiraganaChanges[last_1 + added]{
            return (result: currentText.prefix(currentText.count-last_1.count) + kana, delete: last_1.count, input: kana)
        }
        if last_1 == added && added.onlyRomanAlphabet{
            return (result: currentText.prefix(currentText.count-last_1.count) + "っ" + added, delete: 1, input: "っ" + added)
        }
        if last_1 == "n" && added != "y"{
            return (result: currentText.prefix(currentText.count-last_1.count) + "ん" + added, delete: 1, input: "ん" + added)
        }

        if let kana = String.hiraganaChanges[added]{
            return (result: currentText + kana, delete: .zero, input: kana)
        }
        return (result: currentText + added, delete: .zero, input: added)
    }
    
    static func roman2hiraganaConsideringDisplaying<C: BidirectionalCollection>(current: C, added: String) -> (result: String, components: [KanaComponent], delete: Int, input: String) where C.Element == KanaComponent {
        if !added.onlyRomanAlphabet{
            let components = current + [KanaComponent(internalText: added, kana: added, escapeRomanKanaConverting: false)]
            return (current.map{$0.displayedText}.joined() + added, components, .zero, added)
        }
        do{
            let last = current.suffix(3)
            if last.allSatisfy({!$0.escapeRomanKanaConverting}){
                let last_roman = last.map{$0.internalText}.joined() + added
                if let kana = String.hiraganaChanges[last_roman]{
                    let deleteCount = last.map{$0.displayedText}.joined().count
                    let actualText = current.dropLast(last.count).map{$0.displayedText}.joined() + kana
                    let components = current.dropLast(last.count) + [KanaComponent(internalText: last_roman, kana: kana)]
                    return (result: actualText, components: components, delete: deleteCount, input: kana)
                }
            }
        }
        do{
            let last = current.suffix(2)
            if last.allSatisfy({!$0.escapeRomanKanaConverting}){
                let last_roman = last.map{$0.internalText}.joined() + added
                if let kana = String.hiraganaChanges[last_roman]{
                    let deleteCount = last.map{$0.displayedText}.joined().count
                    let actualText = current.dropLast(last.count).map{$0.displayedText}.joined() + kana
                    let components = current.dropLast(last.count) + [KanaComponent(internalText: last_roman, kana: kana)]
                    return (result: actualText, components: components, delete: deleteCount, input: kana)
                }
            }
        }
        do{
            if let last = current.last{
                let lastLetter = last.internalText
                if !last.escapeRomanKanaConverting, let kana = String.hiraganaChanges[lastLetter + added]{
                    let components = current.dropLast() + [KanaComponent(internalText: lastLetter + added, kana: kana)]

                    let deleteCount = last.displayedText.count
                    let actualText = current.dropLast().map{$0.displayedText}.joined() + kana
                    return (result: actualText, components: components, delete: deleteCount, input: kana)
                }

                if !last.escapeRomanKanaConverting, lastLetter == added{
                    let components = current.dropLast() + [KanaComponent(internalText: lastLetter, kana: "っ"), KanaComponent(internalText: added, kana: added, escapeRomanKanaConverting: false)]
                    let actualText = current.dropLast().map{$0.displayedText}.joined() + "っ" + added
                    return (result: actualText, components: components, delete: 1, input: "っ" + added)
                }

                if !last.escapeRomanKanaConverting, lastLetter == "n", added != "y"{
                    let components = current.dropLast() + [KanaComponent(internalText: lastLetter, kana: "ん"), KanaComponent(internalText: added, kana: added, escapeRomanKanaConverting: false)]
                    let actualText = current.dropLast().map{$0.displayedText}.joined() + "ん" + added
                    return (result: actualText, components: components, delete: 1, input: "ん" + added)
                }
            }
        }
        do{
            if let kana = String.hiraganaChanges[added]{
                let components = current + [KanaComponent(internalText: added, kana: kana)]
                return (result: current.map{$0.displayedText}.joined() + kana, components: components, delete: .zero, input: kana)
            }
        }
        let components = current + [KanaComponent(internalText: added, kana: added, escapeRomanKanaConverting: false)]
        return (result: current.map{$0.displayedText}.joined() + added, components: components, delete: .zero, input: added)

    }

}

extension StringProtocol{
    public var roman2katakana: String {
        var result = ""
        var iterator = self.makeIterator()
        while let char = iterator.next(){
            result = String.roman2katakana(currentText: result, added: String(char)).result
        }
        return result
    }
}
