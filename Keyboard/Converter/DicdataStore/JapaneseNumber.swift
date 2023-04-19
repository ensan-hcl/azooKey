//
//  extension JapaneseNumber.swift
//  Keyboard
//
//  Created by ensan on 2020/09/17.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
private enum JapaneseNumber {
    case いち, に, さん, よん, ご, ろく, なな, はち, きゅう, れい
    case じゅう, ひゃく, せん, まん, おく, ちょう
    case おわり
    case エラー
    var isNumber: Bool {
        [.いち, .に, .さん, .よん, .ご, .ろく, .なな, .はち, .きゅう, .れい, .おわり].contains(self)
    }
    var isNotNumber: Bool {
        [.じゅう, .ひゃく, .せん, .まん, .おく, .ちょう, .エラー, .おわり].contains(self)
    }

    var toRoman: String {
        switch self {
        case .いち:
            return "1"
        case .に:
            return "2"
        case .さん:
            return "3"
        case .よん:
            return "4"
        case .ご:
            return "5"
        case .ろく:
            return "6"
        case .なな:
            return "7"
        case .はち:
            return "8"
        case .きゅう:
            return "9"
        case .れい:
            return "0"
        default:
            return ""
        }
    }

    var maxDigit: Int? {
        switch self {
        case .おわり:
            return 1
        case .まん:
            return 2
        case .おく:
            return 3
        case .ちょう:
            return 4
        default:
            return nil
        }
    }
    var toKanji: String {
        switch self {
        case .いち:
            return "一"
        case .に:
            return "二"
        case .さん:
            return "三"
        case .よん:
            return "四"
        case .ご:
            return "五"
        case .ろく:
            return "六"
        case .なな:
            return "七"
        case .はち:
            return "八"
        case .きゅう:
            return "九"
        case .れい:
            return "〇"
        case .じゅう:
            return "十"
        case .ひゃく:
            return "百"
        case .せん:
            return "千"
        case .まん:
            return "万"
        case .おく:
            return "億"
        case .ちょう:
            return "兆"
        case .おわり:
            return ""
        case .エラー:
            return ""
        }
    }

}

private enum Number {
    case Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine
    var character: Character {
        switch self {

        case .Zero:
            return "0"
        case .One:
            return "1"
        case .Two:
            return "2"
        case .Three:
            return "3"
        case .Four:
            return "4"
        case .Five:
            return "5"
        case .Six:
            return "6"
        case .Seven:
            return "7"
        case .Eight:
            return "8"
        case .Nine:
            return "9"
        }
    }
}

extension DicdataStore {
    private func parseLiteral(input: some StringProtocol) -> [JapaneseNumber] {
        var chars = input.makeIterator()
        var tokens: [JapaneseNumber] = []
        func judge(char: Character) {
            if char == "イ"{
                if let char = chars.next(), char == "チ" || char == "ッ"{
                    tokens.append(.いち)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "オ"{
                if let char = chars.next(), char == "ク"{
                    tokens.append(.おく)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "キ"{
                if let char = chars.next(), char == "ュ"{
                    if let char = chars.next(), char == "ウ"{
                        tokens.append(.きゅう)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ク"{
                tokens.append(.きゅう)
            } else if char == "ゴ"{
                tokens.append(.ご)
            } else if char == "サ"{
                if let char = chars.next(), char == "ン"{
                    tokens.append(.さん)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "シ"{
                if let char = chars.next() {
                    if char == "チ"{
                        tokens.append(.なな)
                    } else {
                        tokens.append(.よん)
                        judge(char: char)
                    }
                } else {
                    tokens.append(.よん)
                }
            } else if char == "ジ"{
                if let char = chars.next(), char == "ュ"{
                    if let char = chars.next(), char == "ウ" || char == "ッ"{
                        tokens.append(.じゅう)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "セ"{
                if let char = chars.next(), char == "ン"{
                    tokens.append(.せん)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ゼ"{
                if let char = chars.next() {
                    if char == "ロ"{
                        tokens.append(.れい)
                    } else if char == "ン"{
                        tokens.append(.せん)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "チ"{
                if let char = chars.next(), char == "ョ"{
                    if let char = chars.next(), char == "ウ"{
                        tokens.append(.ちょう)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ナ"{
                if let char = chars.next(), char == "ナ"{
                    tokens.append(.なな)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ニ"{
                tokens.append(.に)
            } else if char == "ハ"{
                if let char = chars.next(), char == "チ" || char == "ッ"{
                    tokens.append(.はち)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ヒ"{
                if let char = chars.next(), char == "ャ"{
                    if let char = chars.next(), char == "ク"{
                        tokens.append(.ひゃく)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ビ"{
                if let char = chars.next(), char == "ャ"{
                    if let char = chars.next(), char == "ク"{
                        tokens.append(.ひゃく)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ピ"{
                if let char = chars.next(), char == "ャ"{
                    if let char = chars.next(), char == "ク"{
                        tokens.append(.ひゃく)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "マ"{
                if let char = chars.next() {
                    if char == "ン"{
                        tokens.append(.まん)
                    } else if char == "ル"{
                        tokens.append(.れい)
                    } else {
                        tokens.append(.エラー)
                        return
                    }
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ヨ"{
                if let char = chars.next(), char == "ン"{
                    tokens.append(.よん)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "レ"{
                if let char = chars.next(), char == "イ"{
                    tokens.append(.れい)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else if char == "ロ"{
                if let char = chars.next(), char == "ク" || char == "ッ"{
                    tokens.append(.ろく)
                } else {
                    tokens.append(.エラー)
                    return
                }
            } else {
                tokens.append(.エラー)
                return
            }

        }
        while let char = chars.next() {
            judge(char: char)
        }
        tokens.append(.おわり)
        return tokens
    }

    private func parseTokens(tokens: [JapaneseNumber]) -> [(Number, Number, Number, Number)] {
        var maxDigits: Int?
        var result: [(Number, Number, Number, Number)] = []
        var stack: (Number, Number, Number, Number) = (.Zero, .Zero, .Zero, .Zero)
        var tokens = tokens.makeIterator()
        var curnum: Number?
        while let token = tokens.next() {
            switch token {
            case .いち:
                if curnum != nil {return []}
                curnum = .One
            case .に:
                if curnum != nil {return []}
                curnum = .Two
            case .さん:
                if curnum != nil {return []}
                curnum = .Three
            case .よん:
                if curnum != nil {return []}
                curnum = .Four
            case .ご:
                if curnum != nil {return []}
                curnum = .Five
            case .ろく:
                if curnum != nil {return []}
                curnum = .Six
            case .なな:
                if curnum != nil {return []}
                curnum = .Seven
            case .はち:
                if curnum != nil {return []}
                curnum = .Eight
            case .きゅう:
                if curnum != nil {return []}
                curnum = .Nine
            case .れい:
                if curnum != nil {return []}
                curnum = .Zero
            case .じゅう:
                stack.2 = curnum ?? .One
                curnum = nil
            case .ひゃく:
                stack.1 = curnum ?? .One
                curnum = nil
            case .せん:
                stack.0 = curnum ?? .One
                curnum = nil
            case .おわり, .まん, .おく, .ちょう:
                stack.3 = curnum ?? .Zero
                if let maxDigit = maxDigits {
                    if maxDigit <= token.maxDigit! {
                        return []
                    }
                    result[maxDigit - token.maxDigit!] = stack
                } else {
                    maxDigits = token.maxDigit!
                    result = [(Number, Number, Number, Number)].init(repeating: (.Zero, .Zero, .Zero, .Zero), count: maxDigits!)
                    result[0] = stack
                }
                curnum = nil
                stack = (.Zero, .Zero, .Zero, .Zero)
            case .エラー:
                break
            }
        }
        return result

    }

    func getJapaneseNumberDicdata(head: String) -> [DicdataElement] {

        let tokens = parseLiteral(input: head)

        if !tokens.allSatisfy({$0 != .エラー}) {
            return []
        }
        let kanji = tokens.map {$0.toKanji}.joined()

        let roman: String
        if tokens.allSatisfy({$0.isNumber}) {
            roman = tokens.map {$0.toRoman}.joined()
        } else if tokens.allSatisfy({$0.isNotNumber}) {
            return []
        } else {
            let result = parseTokens(tokens: tokens)
            if result.isEmpty {
                return []
            }
            var chars: [Character] = []
            for stack in result {
                if chars.isEmpty {
                    if stack.0 != .Zero {
                        chars.append(contentsOf: [stack.0.character, stack.1.character, stack.2.character, stack.3.character])
                    } else if stack.1 != .Zero {
                        chars.append(contentsOf: [stack.1.character, stack.2.character, stack.3.character])
                    } else if stack.2 != .Zero {
                        chars.append(contentsOf: [stack.2.character, stack.3.character])
                    } else if stack.3 != .Zero {
                        chars.append(stack.3.character)
                    } else {
                        return []
                    }
                } else {
                    chars.append(contentsOf: [stack.0.character, stack.1.character, stack.2.character, stack.3.character])
                }
            }
            roman = String(chars)
        }
        return [
            DicdataElement(word: kanji, ruby: head, cid: CIDData.数.cid, mid: MIDData.数.mid, value: -17 + PValue(head.count) / 3),
            DicdataElement(word: roman, ruby: head, cid: CIDData.数.cid, mid: MIDData.数.mid, value: -16 + 4 / PValue(roman.count))
        ]
    }

}
