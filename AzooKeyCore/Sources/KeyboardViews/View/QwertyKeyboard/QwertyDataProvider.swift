//
//  VerticalQwertyKeyboardModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import enum CustardKit.TabData

struct QwertyDataProvider<Extension: ApplicationSpecificKeyboardViewExtension> {
    @MainActor static func tabKeys(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)) -> (languageKey: any QwertyKeyModelProtocol, numbersKey: any QwertyKeyModelProtocol, symbolsKey: any QwertyKeyModelProtocol, changeKeyboardKey: any QwertyKeyModelProtocol) {
        let preferredLanguage = Extension.SettingProvider.preferredLanguage
        let languageKey: any QwertyKeyModelProtocol
        let first = preferredLanguage.first
        if let second = preferredLanguage.second {
            languageKey = QwertySwitchLanguageKeyModel<Extension>(rowInfo: rowInfo, languages: (first, second))
        } else {
            let targetTab: TabData = {
                switch first {
                case .en_US:
                    return .system(.user_english)
                case .ja_JP:
                    return .system(.user_japanese)
                case .none, .el_GR:
                    return .system(.user_japanese)
                }
            }()
            languageKey = QwertyFunctionalKeyModel<Extension>(labelType: .text(first.symbol), rowInfo: rowInfo, pressActions: [.moveTab(targetTab)], longPressActions: .none, needSuggestView: false)
        }

        let numbersKey: any QwertyKeyModelProtocol = QwertyFunctionalKeyModel<Extension>(labelType: .image("textformat.123"), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_numbers))], longPressActions: .init(start: [.setTabBar(.toggle)]))
        let symbolsKey: any QwertyKeyModelProtocol = QwertyFunctionalKeyModel<Extension>(labelType: .text("#+="), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_symbols))], longPressActions: .init(start: [.setTabBar(.toggle)]))

        let changeKeyboardKey: any QwertyKeyModelProtocol
        if let second = preferredLanguage.second {
            changeKeyboardKey = QwertyChangeKeyboardKeyModel<Extension>(keySizeType: .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space), fallBackType: .secondTab(secondLanguage: second))
        } else {
            changeKeyboardKey = QwertyChangeKeyboardKeyModel<Extension>(keySizeType: .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space), fallBackType: .tabBar)
        }
        return (
            languageKey: languageKey,
            numbersKey: numbersKey,
            symbolsKey: symbolsKey,
            changeKeyboardKey: changeKeyboardKey
        )
    }

    // 横に並べる
    @MainActor static var numberKeyboard: [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(
                labelType: .text("1"),
                pressActions: [.input("1")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] )

                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("2"),
                pressActions: [.input("2")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] )

                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("3"),
                pressActions: [.input("3")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] )

                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("4"),
                pressActions: [.input("4")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("5"),
                pressActions: [.input("5")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("6"),
                pressActions: [.input("6")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("7"),
                pressActions: [.input("7")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("8"),
                pressActions: [.input("8")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("9"),
                pressActions: [.input("9")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] )
                ], direction: .left)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("0"),
                pressActions: [.input("0")],
                variationsModel: VariationsModel([
                    (label: .text("0"), actions: [.input("0")] ),
                    (label: .text("０"), actions: [.input("０")] ),
                    (label: .text("〇"), actions: [.input("〇")] ),
                    (label: .text("⓪"), actions: [.input("⓪")] )
                ], direction: .left)
            )
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("-"), pressActions: [.input("-")]),
            QwertyKeyModel<Extension>(
                labelType: .text("/"),
                pressActions: [.input("/")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(":"),
                pressActions: [.input(":")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("@"),
                pressActions: [.input("@")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] )
                ])
            ),
            QwertyKeyModel<Extension>(labelType: .text("("), pressActions: [.input("(")]),
            QwertyKeyModel<Extension>(labelType: .text(")"), pressActions: [.input(")")]),
            QwertyKeyModel<Extension>(
                labelType: .text("「"),
                pressActions: [.input("「")],
                variationsModel: VariationsModel([
                    (label: .text("「"), actions: [.input("「")] ),
                    (label: .text("『"), actions: [.input("『")] ),
                    (label: .text("【"), actions: [.input("【")] ),
                    (label: .text("（"), actions: [.input("（")] ),
                    (label: .text("《"), actions: [.input("《")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("」"),
                pressActions: [.input("」")],
                variationsModel: VariationsModel([
                    (label: .text("」"), actions: [.input("」")] ),
                    (label: .text("』"), actions: [.input("』")] ),
                    (label: .text("】"), actions: [.input("】")] ),
                    (label: .text("）"), actions: [.input("）")] ),
                    (label: .text("》"), actions: [.input("》")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("¥"),
                pressActions: [.input("¥")],
                variationsModel: VariationsModel([
                    (label: .text("¥"), actions: [.input("¥")] ),
                    (label: .text("￥"), actions: [.input("￥")] ),
                    (label: .text("$"), actions: [.input("$")] ),
                    (label: .text("＄"), actions: [.input("＄")] ),
                    (label: .text("€"), actions: [.input("€")] ),
                    (label: .text("₿"), actions: [.input("₿")] ),
                    (label: .text("£"), actions: [.input("£")] ),
                    (label: .text("¤"), actions: [.input("¤")] )
                ], direction: .left)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("&"),
                pressActions: [.input("&")],
                variationsModel: VariationsModel([
                    (label: .text("&"), actions: [.input("&")]),
                    (label: .text("＆"), actions: [.input("＆")])
                ], direction: .left)
            )
        ],

        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).symbolsKey
        ] + Extension.SettingProvider.numberTabCustomKeysSetting.compiled(extension: Extension.self) +
        [
            QwertyFunctionalKeyModel<Extension>.delete
        ],

        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            QwertyNextCandidateKeyModel<Extension>(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]
    }
    // 横に並べる
    @MainActor static func symbolsKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(
                labelType: .text("["),
                pressActions: [.input("[")],
                variationsModel: VariationsModel([
                    (label: .text("["), actions: [.input("[")]),
                    (label: .text("［"), actions: [.input("［")])
                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("]"),
                pressActions: [.input("]")],
                variationsModel: VariationsModel([
                    (label: .text("]"), actions: [.input("]")]),
                    (label: .text("］"), actions: [.input("］")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("{"),
                pressActions: [.input("{")],
                variationsModel: VariationsModel([
                    (label: .text("{"), actions: [.input("{")]),
                    (label: .text("｛"), actions: [.input("｛")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("}"),
                pressActions: [.input("}")],
                variationsModel: VariationsModel([
                    (label: .text("}"), actions: [.input("}")]),
                    (label: .text("｝"), actions: [.input("｝")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("#"),
                pressActions: [.input("#")],
                variationsModel: VariationsModel([
                    (label: .text("#"), actions: [.input("#")]),
                    (label: .text("＃"), actions: [.input("＃")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("%"),
                pressActions: [.input("%")],
                variationsModel: VariationsModel([
                    (label: .text("%"), actions: [.input("%")]),
                    (label: .text("％"), actions: [.input("％")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("^"),
                pressActions: [.input("^")],
                variationsModel: VariationsModel([
                    (label: .text("^"), actions: [.input("^")]),
                    (label: .text("＾"), actions: [.input("＾")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("*"),
                pressActions: [.input("*")],
                variationsModel: VariationsModel([
                    (label: .text("*"), actions: [.input("*")]),
                    (label: .text("＊"), actions: [.input("＊")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("+"),
                pressActions: [.input("+")],
                variationsModel: VariationsModel([
                    (label: .text("+"), actions: [.input("+")]),
                    (label: .text("＋"), actions: [.input("＋")]),
                    (label: .text("±"), actions: [.input("±")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("="),
                pressActions: [.input("=")],
                variationsModel: VariationsModel([
                    (label: .text("="), actions: [.input("=")]),
                    (label: .text("＝"), actions: [.input("＝")]),
                    (label: .text("≡"), actions: [.input("≡")]),
                    (label: .text("≒"), actions: [.input("≒")]),
                    (label: .text("≠"), actions: [.input("≠")])
                ], direction: .left)
            )
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("_"), pressActions: [.input("_")]),
            QwertyKeyModel<Extension>(
                labelType: .text("\\"),
                pressActions: [.input("\\")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(";"),
                pressActions: [.input(";")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("|"),
                pressActions: [.input("|")],
                variationsModel: VariationsModel([
                    (label: .text("|"), actions: [.input("|")] ),
                    (label: .text("｜"), actions: [.input("｜")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("<"),
                pressActions: [.input("<")],
                variationsModel: VariationsModel([
                    (label: .text("<"), actions: [.input("<")]),
                    (label: .text("＜"), actions: [.input("＜")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(">"),
                pressActions: [.input(">")],
                variationsModel: VariationsModel([
                    (label: .text(">"), actions: [.input(">")]),
                    (label: .text("＞"), actions: [.input("＞")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("\""),
                pressActions: [.input("\"")],
                variationsModel: VariationsModel([
                    (label: .text("\""), actions: [.input("\"")]),
                    (label: .text("＂"), actions: [.input("＂")]),
                    (label: .text("“"), actions: [.input("“")]),
                    (label: .text("”"), actions: [.input("”")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("'"),
                pressActions: [.input("'")],
                variationsModel: VariationsModel([
                    (label: .text("'"), actions: [.input("'")]),
                    (label: .text("`"), actions: [.input("`")])
                ])
            ),

            QwertyKeyModel<Extension>(
                labelType: .text("$"),
                pressActions: [.input("$")],
                variationsModel: VariationsModel([
                    (label: .text("$"), actions: [.input("$")]),
                    (label: .text("＄"), actions: [.input("＄")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("€"),
                pressActions: [.input("€")],
                variationsModel: VariationsModel([
                    (label: .text("¥"), actions: [.input("¥")] ),
                    (label: .text("￥"), actions: [.input("￥")] ),
                    (label: .text("$"), actions: [.input("$")] ),
                    (label: .text("＄"), actions: [.input("＄")] ),
                    (label: .text("€"), actions: [.input("€")] ),
                    (label: .text("₿"), actions: [.input("₿")] ),
                    (label: .text("£"), actions: [.input("£")] ),
                    (label: .text("¤"), actions: [.input("¤")] )
                ], direction: .left)
            )
        ],

        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).numbersKey,
            QwertyKeyModel<Extension>(
                labelType: .text("."),
                pressActions: [.input(".")],
                variationsModel: VariationsModel([
                    (label: .text("。"), actions: [.input("。")] ),
                    (label: .text("."), actions: [.input(".")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(","),
                pressActions: [.input(",")],
                variationsModel: VariationsModel([
                    (label: .text("、"), actions: [.input("、")] ),
                    (label: .text(","), actions: [.input(",")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel<Extension>(
                labelType: .text("?"),
                pressActions: [.input("?")],
                variationsModel: VariationsModel([
                    (label: .text("？"), actions: [.input("？")] ),
                    (label: .text("?"), actions: [.input("?")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("!"),
                pressActions: [.input("!")],
                variationsModel: VariationsModel([
                    (label: .text("！"), actions: [.input("！")] ),
                    (label: .text("!"), actions: [.input("!")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel<Extension>(labelType: .text("・"), pressActions: [.input("…")], for: (7, 5)),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            QwertyNextCandidateKeyModel<Extension>(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func hiraKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel<Extension>(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel<Extension>(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel<Extension>(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel<Extension>(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel<Extension>(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel<Extension>(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel<Extension>(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel<Extension>(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel<Extension>(labelType: .text("p"), pressActions: [.input("p")])
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("a"), pressActions: [.input("a")]),
            QwertyKeyModel<Extension>(labelType: .text("s"), pressActions: [.input("s")]),
            QwertyKeyModel<Extension>(labelType: .text("d"), pressActions: [.input("d")]),
            QwertyKeyModel<Extension>(labelType: .text("f"), pressActions: [.input("f")]),
            QwertyKeyModel<Extension>(labelType: .text("g"), pressActions: [.input("g")]),
            QwertyKeyModel<Extension>(labelType: .text("h"), pressActions: [.input("h")]),
            QwertyKeyModel<Extension>(labelType: .text("j"), pressActions: [.input("j")]),
            QwertyKeyModel<Extension>(labelType: .text("k"), pressActions: [.input("k")]),
            QwertyKeyModel<Extension>(labelType: .text("l"), pressActions: [.input("l")]),
            QwertyKeyModel<Extension>(labelType: .text("ー"), pressActions: [.input("ー")])
        ],
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel<Extension>(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel<Extension>(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel<Extension>(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel<Extension>(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel<Extension>(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel<Extension>(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel<Extension>(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            QwertyNextCandidateKeyModel<Extension>(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func abcKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel<Extension>(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel<Extension>(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel<Extension>(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel<Extension>(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel<Extension>(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel<Extension>(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel<Extension>(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel<Extension>(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel<Extension>(labelType: .text("p"), pressActions: [.input("p")])
        ],
        Extension.SettingProvider.useShiftKey ?
            [
                QwertyShiftKeyModel<Extension>.shared,
                QwertyKeyModel<Extension>(labelType: .text("a"), pressActions: [.input("a")]),
                QwertyKeyModel<Extension>(labelType: .text("s"), pressActions: [.input("s")]),
                QwertyKeyModel<Extension>(labelType: .text("d"), pressActions: [.input("d")]),
                QwertyKeyModel<Extension>(labelType: .text("f"), pressActions: [.input("f")]),
                QwertyKeyModel<Extension>(labelType: .text("g"), pressActions: [.input("g")]),
                QwertyKeyModel<Extension>(labelType: .text("h"), pressActions: [.input("h")]),
                QwertyKeyModel<Extension>(labelType: .text("j"), pressActions: [.input("j")]),
                QwertyKeyModel<Extension>(labelType: .text("k"), pressActions: [.input("k")]),
                QwertyKeyModel<Extension>(labelType: .text("l"), pressActions: [.input("l")])
            ] : [
                QwertyKeyModel<Extension>(labelType: .text("a"), pressActions: [.input("a")]),
                QwertyKeyModel<Extension>(labelType: .text("s"), pressActions: [.input("s")]),
                QwertyKeyModel<Extension>(labelType: .text("d"), pressActions: [.input("d")]),
                QwertyKeyModel<Extension>(labelType: .text("f"), pressActions: [.input("f")]),
                QwertyKeyModel<Extension>(labelType: .text("g"), pressActions: [.input("g")]),
                QwertyKeyModel<Extension>(labelType: .text("h"), pressActions: [.input("h")]),
                QwertyKeyModel<Extension>(labelType: .text("j"), pressActions: [.input("j")]),
                QwertyKeyModel<Extension>(labelType: .text("k"), pressActions: [.input("k")]),
                QwertyKeyModel<Extension>(labelType: .text("l"), pressActions: [.input("l")]),
                QwertyAaKeyModel<Extension>.shared
            ],
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel<Extension>(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel<Extension>(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel<Extension>(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel<Extension>(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel<Extension>(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel<Extension>(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel<Extension>(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            QwertyNextCandidateKeyModel<Extension>(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}
}
