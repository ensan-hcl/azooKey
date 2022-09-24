//
//  RomanTypographys.swift
//  Keyboard
//
//  Created by β α on 2020/11/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

private extension UnicodeScalar {
    /// ローマ字の大文字かどうか
    var isRomanUppercased: Bool {
        return ("A"..."Z").contains(self)
    }
    /// ローマ字の小文字かどうか
    var isRomanLowercased: Bool {
        return ("a"..."z").contains(self)
    }
    /// ローマ字の数字かどうか
    var isRomanNumber: Bool {
        return ("0"..."9").contains(self)
    }
}

extension KanaKanjiConverter {
    /// 装飾文字に変換した結果を返す関数。
    /// - parameters:
    ///   - text: 対象文字列。
    /// - note:
    ///    現在英字のみ。ギリシャ文字や数字に対応する必要あり。
    func typographicalCandidates(_ inputData: InputData) -> [Candidate] {
        let string = inputData.convertTarget.toKatakana()
        let strings = self.typographicalLetters(from: string)
        return strings.map {
            Candidate(
                text: $0,
                value: -15,
                correspondingCount: inputData.input.count,
                lastMid: 501,
                data: [DicdataElement(word: $0, ruby: string, cid: CIDData.固有名詞.cid, mid: 501, value: -15)]
            )
        }
    }

    /// 装飾文字を実際に作る部分。
    /// - parameters:
    ///   - text: 対象文字列。
    private func typographicalLetters(from text: String) -> [String] {
        if !text.onlyRomanAlphabetOrNumber {
            return []
        }
        let onlyRomanAlphabet = text.onlyRomanAlphabet
        var strings: [String] = []
        /// 𝐁𝐎𝐋𝐃
        do {
            let bold = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 119743)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 119737)!
                    return String(scalar)
                }
                if $0.isRomanNumber {
                    let scalar = UnicodeScalar($0.value + 120734)!
                    return String(scalar)
                }
                return String($0)

            }.joined()
            strings.append(bold)
        }
        /// 𝐼𝑇𝐴𝐿𝐼𝐶
        if onlyRomanAlphabet {
            let italic = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 119795)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    if $0 == "h"{
                        return "ℎ"
                    }
                    let scalar = UnicodeScalar($0.value + 119789)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(italic)
        }
        /// 𝑩𝑶𝑳𝑫𝑰𝑻𝑨𝑳𝑰𝑪
        if onlyRomanAlphabet {
            let boldItalic = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 119847)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 119841)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(boldItalic)
        }

        /// 𝒮𝒸𝓇𝒾𝓅𝓉
        if onlyRomanAlphabet {
            let script = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    switch $0 {
                    case "B":
                        return "ℬ"
                    case "E":
                        return "ℰ"
                    case "F":
                        return "ℱ"
                    case "H":
                        return "ℋ"
                    case "I":
                        return "ℐ"
                    case "L":
                        return "ℒ"
                    case "M":
                        return "ℳ"
                    case "R":
                        return "ℛ"
                    default:
                        break
                    }

                    let scalar = UnicodeScalar($0.value + 119899)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    switch $0 {
                    case "e":
                        return "ℯ"
                    case "g":
                        return "ℊ"
                    case "o":
                        return "ℴ"
                    default: break
                    }
                    let scalar = UnicodeScalar($0.value + 119893)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(script)
        }

        /// 𝓑𝓸𝓵𝓭𝓢𝓬𝓻𝓲𝓹𝓽
        if onlyRomanAlphabet {
            let boldScript = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 119951)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 119945)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(boldScript)
        }
        /// 𝔉𝔯𝔞𝔨𝔱𝔲𝔯
        if onlyRomanAlphabet {
            let fraktur = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    switch $0 {
                    case "C":
                        return "ℭ"
                    case "H":
                        return "ℌ"
                    case "I":
                        return "ℑ"
                    case "R":
                        return "ℜ"
                    case "Z":
                        return "ℨ"
                    default: break
                    }
                    let scalar = UnicodeScalar($0.value + 120003)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 119997)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(fraktur)
        }

        /// 𝕕𝕠𝕦𝕓𝕝𝕖𝕊𝕥𝕣𝕦𝕔𝕜
        do {
            let doubleStruck = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    switch $0 {
                    case "C":
                        return "ℂ"
                    case "H":
                        return "ℍ"
                    case "N":
                        return "ℕ"
                    case "P":
                        return "ℙ"
                    case "Q":
                        return "ℚ"
                    case "R":
                        return "ℝ"
                    case "Z":
                        return "ℤ"
                    default: break
                    }
                    let scalar = UnicodeScalar($0.value + 120055)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120049)!
                    return String(scalar)
                }
                if $0.isRomanNumber {
                    let scalar = UnicodeScalar($0.value + 120744)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(doubleStruck)
        }

        /// 𝕭𝖔𝖑𝖉𝕱𝖗𝖆𝖐𝖙𝖚𝖗
        if onlyRomanAlphabet {
            let boldFraktur = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120107)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120101)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(boldFraktur)
        }

        /// 𝖲𝖺𝗇𝗌𝖲𝖾𝗋𝗂𝖿
        do {
            let sansSerif = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120159)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120153)!
                    return String(scalar)
                }
                if $0.isRomanNumber {
                    let scalar = UnicodeScalar($0.value + 120754)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(sansSerif)
        }

        /// 𝗦𝗮𝗻𝘀𝗦𝗲𝗿𝗶𝗳𝗕𝗼𝗹𝗱
        do {
            let sansSerifBold = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120211)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120205)!
                    return String(scalar)
                }
                if $0.isRomanNumber {
                    let scalar = UnicodeScalar($0.value + 120764)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifBold)
        }

        /// 𝘚𝘢𝘯𝘴𝘚𝘦𝘳𝘪𝘧𝘐𝘵𝘢𝘭𝘪𝘤
        if onlyRomanAlphabet {
            let sansSerifItalic = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120263)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120257)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifItalic)
        }

        /// 𝙎𝙖𝙣𝙨𝙎𝙚𝙧𝙞𝙛𝘽𝙤𝙡𝙙𝙄𝙩𝙖𝙡𝙞𝙘
        if onlyRomanAlphabet {
            let sansSerifBoldItalic = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120315)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120309)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifBoldItalic)
        }

        /// 𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎
        do {
            let monospace = text.unicodeScalars.map {
                if $0.isRomanUppercased {
                    let scalar = UnicodeScalar($0.value + 120367)!
                    return String(scalar)
                }
                if $0.isRomanLowercased {
                    let scalar = UnicodeScalar($0.value + 120361)!
                    return String(scalar)
                }
                if $0.isRomanNumber {
                    let scalar = UnicodeScalar($0.value + 120774)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(monospace)
        }

        return strings
    }
}
