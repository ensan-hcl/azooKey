//
//  RomanTypographys.swift
//  Keyboard
//
//  Created by β α on 2020/11/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension UnicodeScalar{
    var isRomanUppercased: Bool {
        return 0x0041 ... 0x005A ~= self.value
    }
    var isRomanLowercased: Bool {
        return 0x0061 ... 0x007A ~= self.value
    }
}

extension KanaKanjiConverter{

    func typographicalCandidates(from text: String) -> [Candidate] {
        let strings = self.typographicalLetters(from: text)
        return strings.map{
            Candidate(text: $0, value: -15, visibleString: text, rcid: 1288, lastMid: 501, data: [LRE_DicDataElement(word: $0, ruby: text, cid: 1288, mid: 501, value: -15)])
        }
    }

    func typographicalLetters(from text: String) -> [String] {
        if !text.onlyRomanAlphabet{
            return []
        }
        var strings: [String] = []
        ///𝐁𝐎𝐋𝐃
        do{
            let bold = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 119743)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 119737)!
                    return String(scalar)
                }
                return String($0)

            }.joined()
            strings.append(bold)
        }
        ///𝐼𝑇𝐴𝐿𝐼𝐶
        do{
            let italic = text.unicodeScalars.map{
                print($0)
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 119795)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
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
        ///𝑩𝑶𝑳𝑫𝑰𝑻𝑨𝑳𝑰𝑪
        do{
            let boldItalic = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 119847)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 119841)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(boldItalic)
        }

        ///𝒮𝒸𝓇𝒾𝓅𝓉
        do{
            let script = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    switch $0{
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
                if $0.isRomanLowercased{
                    switch $0{
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

        ///𝓑𝓸𝓵𝓭𝓢𝓬𝓻𝓲𝓹𝓽
        do{
            let boldScript = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 119951)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 119945)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(boldScript)
        }
        ///𝔉𝔯𝔞𝔨𝔱𝔲𝔯
        do{
            let fraktur = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    switch $0{
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
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 119997)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(fraktur)
        }

        ///𝕕𝕠𝕦𝕓𝕝𝕖𝕊𝕥𝕣𝕦𝕔𝕜
        do{
            let doubleStruck = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    switch $0{
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
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120049)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(doubleStruck)
        }

        ///𝕭𝖔𝖑𝖉𝕱𝖗𝖆𝖐𝖙𝖚𝖗
        do{
            let boldFraktur = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120107)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120101)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(boldFraktur)
        }

        ///𝖲𝖺𝗇𝗌𝖲𝖾𝗋𝗂𝖿
        do{
            let sansSerif = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120159)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120153)!
                    return String(scalar)
                }
                return String($0)
            }.joined()
            strings.append(sansSerif)
        }

        ///𝗦𝗮𝗻𝘀𝗦𝗲𝗿𝗶𝗳𝗕𝗼𝗹𝗱
        do{
            let sansSerifBold = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120211)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120205)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifBold)
        }

        ///𝘚𝘢𝘯𝘴𝘚𝘦𝘳𝘪𝘧𝘐𝘵𝘢𝘭𝘪𝘤
        do{
            let sansSerifItalic = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120263)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120257)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifItalic)
        }

        ///𝙎𝙖𝙣𝙨𝙎𝙚𝙧𝙞𝙛𝘽𝙤𝙡𝙙𝙄𝙩𝙖𝙡𝙞𝙘
        do{
            let sansSerifBoldItalic = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120315)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120309)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(sansSerifBoldItalic)
        }

        ///𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎
        do{
            let monospace = text.unicodeScalars.map{
                if $0.isRomanUppercased{
                    let scalar = UnicodeScalar($0.value + 120367)!
                    return String(scalar)
                }
                if $0.isRomanLowercased{
                    let scalar = UnicodeScalar($0.value + 120361)!
                    return String(scalar)
                }
                return String($0)
            }.joined()

            strings.append(monospace)
        }

        return strings
    }
}
